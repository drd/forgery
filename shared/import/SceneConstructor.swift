//
//  MeshParser.swift
//  mesher-scenekit
//
//  Created by Eric O'Connell on 12/26/18.
//  Copyright © 2018 Eric O'Connell. All rights reserved.
//

import Foundation
import Metal
import simd

class SceneConstructor {
    struct LoadError : Error {
        let message: String
    }
    
    struct PendingMesh {
        let mesh: Mesh
        let materialId: String
    }
    
    let baseDir: URL
    private var instanceTreeUrl: URL {
        return baseDir.appendingPathComponent("instancetree.json")
    }
    private var materialDir: URL {
        return baseDir.appendingPathComponent("materials")
    }
    private var meshDir: URL {
        return baseDir.appendingPathComponent("meshes")
    }
    private var propertyDir: URL {
        return baseDir.appendingPathComponent("properties")
    }
    private var textureDir: URL {
        return baseDir.appendingPathComponent("textures")
    }

    let device: MTLDevice

    let controlQueue = DispatchQueue(label: "LoadQueue", attributes: .concurrent)
    
    let decoder = JSONDecoder()
    var meshes = [String: Mesh]()
    var materials = [String: Material]()
    
    var instanceTree: Node!
    
    let workManager = WorkManager()

    lazy var meshFiles: [String: URL] = directoryAsDict(dir: self.meshDir)
    lazy var materialFiles: [String: URL] = directoryAsDict(dir: self.materialDir)

    private func directoryAsDict(dir: URL) -> [String: URL] {
        do {
            let fileUrls = try FileManager.default
                .contentsOfDirectory(
                    atPath: dir.path
                )
                .map { dir.appendingPathComponent($0) }
            return Dictionary.init(
                uniqueKeysWithValues: fileUrls.map {
                    (String($0.lastPathComponent.split(separator: ".").first!), $0)
                }
            )
        } catch {
            logger("Error loading \(dir): \(error)")
            return [:]
        }
    }
    
    init(url: URL, device: MTLDevice) throws {
        self.baseDir = url
        self.device = device
        self.instanceTree = try decoder.decode(Node.self, from:
            Data.init(contentsOf: baseDir.appendingPathComponent("instancetree.json"))
        )
    }
    
    private func kickoffWorkQueue() {
        workManager.add(id: "1") {
            self.loadMaterials()
            self.loadMeshes()
        }
    }
    
    private func loadMaterials() {
        for (id, url) in self.materialFiles {
            do {
                self.materials[id] = try self.loadMaterial(from: url)
            } catch {
                logger("Error loading material \(id): \(error)")
            }
        }
    }
    
    struct MeshInfo {
        let id: String
        let material: Material
    }
    
    private func loadMeshes() {
        logger("I'm looking for meshes")

        var meshes = [MeshInfo]()

        func iterateChildren(node: Node) {
            if let children = node.childs {
                for child in children {
                    if (child.type == "Mesh") {
                        for (i, (fragmentId, materialId)) in zip(child.fragments!, child.materials!.map(String.init)).enumerated() {
                            if (child.fragPolys![i] > 0) {
                                // TODO: don't hardcode scene id
                                let meshId = "\(1)-\(child.id)-\(fragmentId)"
                                meshes.append(MeshInfo(id: meshId, material: self.materials[materialId]!))
                            }
                        }
                    }
                    
                    iterateChildren(node: child)
                }
            }
        }
        
        iterateChildren(node: self.instanceTree)
        
        logger("Found \(meshes.count) meshes")
        
        for (i, chunk) in meshes.chunked(into: 20).enumerated() {
            workManager.add(id: "chunk-\(i)") {
                for meshInfo in chunk {
                    self.loadMesh(meshInfo)
                }
            }
        }
    }

    private func loadMaterial(from url: URL) throws -> Material {
        let svfMaterial = try self.decoder.decode(SVFMaterial.self, from: Data(contentsOf: url))

        if let defn = svfMaterial.materials.first {
            var ambient = defn.value.properties.colors.generic_ambient?.float4
            var diffuse = defn.value.properties.colors.generic_diffuse?.float4
            var specular = defn.value.properties.colors.generic_specular?.float4
            let opacity: Float = 1.0 - (defn.value.properties.scalars.generic_transparency?.values.first ?? 0.0)
            
            ambient?.w = opacity
            diffuse?.w = opacity
            specular?.w = opacity
            
            return Material(
                ambient: ambient ?? diffuse ?? float4(),
                diffuse: diffuse ?? float4(),
                specular: specular ?? float4()
            )
        }
        
        throw LoadError(message: "Couldn't load material at \(url)")
    }
    
    private func loadMesh(_ info: MeshInfo) {
        do {
            if let meshUrl = self.meshFiles[info.id] {
                let mesh = try MeshParser(url: meshUrl).parse(with: info.material)
                controlQueue.async(flags: .barrier) {
                    self.meshes[info.id] = mesh
                }
            }
        } catch {
            logger("Error loading mesh: \(info.id): \(error)")
        }
    }

    func loadAsync(completion: @escaping (CompositeMesh?) -> Void) {
        kickoffWorkQueue()
        
        workManager.notify(
            queue: DispatchQueue.global(),
            work: DispatchWorkItem(block: {
                do {
                    completion(try self.constructCompositeMesh())
                } catch {
                    completion(nil)
                }
            })
        )
    }

    func loadBlocking() -> CompositeMesh? {
        do {
            kickoffWorkQueue()
            workManager.wait()
            return try constructCompositeMesh()
        } catch {
            logger("Failure! \(error)")
            return nil
        }
    }
    
    private func constructCompositeMesh() throws -> CompositeMesh {
        var vertices = [Vertex]()
        var indices = [UInt32]()
        var center = float3()
        var indexOffset = 0
        
        let submeshes = meshes.map { (i, mesh) -> Submesh in
            center += mesh.center
            
            let submesh = Submesh(
                name: mesh.name,
                primitiveType: .triangle,
                vertexOffset: vertices.count * MemoryLayout<Vertex>.stride,
                indexType: .uint32,
                indexCount: mesh.indices.count,
                indexOffset: indexOffset * MemoryLayout<UInt32>.stride
            )
            
            indices += mesh.indices.map { UInt32($0 + vertices.count) }
            vertices += mesh.materializedVertices()
            
            indexOffset += mesh.indexCount
            
            logger("At mesh \(i): \(vertices.count) verts \(indices.count) indices; offset: \(indexOffset)")
            
            return submesh
        }

        let vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: MTLResourceOptions.storageModeShared
        )
        
        let indexBuffer = device.makeBuffer(
            bytes: indices,
            length: indices.count * MemoryLayout<UInt32>.stride,
            options: MTLResourceOptions.storageModeShared
        )
        
        return CompositeMesh(
            vertexBuffer: vertexBuffer!,
            indexBuffer: indexBuffer!,
            submeshes: submeshes,
            center: center / Float(meshes.count)
        )
    }
    
}

extension DispatchQueue {
    class var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? "unknown"
    }
}
