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

    let loadQueue = DispatchQueue(label: "LoadQueue", attributes: .concurrent)
    let loadGroup = DispatchGroup()

    let decoder = JSONDecoder()
    var pendingMeshes = [String: PendingMesh]()
    var materials = [String: Material]()
    
    var instanceTree: Node!

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
            print("Error loading \(dir): \(error)")
            return [:]
        }
    }
    
    init(url: URL, device: MTLDevice) throws {
        self.baseDir = url
        self.device = device
        print("Looking in \(url)")
        self.instanceTree = try decoder.decode(Node.self, from:
            Data.init(contentsOf: baseDir.appendingPathComponent("instancetree.json"))
        )
    }
    
    private func serialLoad() -> [Mesh] {
        do {
            return try meshFiles.map { (key, url) in
                try MeshParser(url: url).parse()
            }
        } catch {
            print("Failure! \(error)")
            return [Mesh]()
        }
    }
    
    private func loadNode(_ node: Node) {
        switch (node.type) {
        case "Transform":
            // TODO: handle transform matrixes
            print(node.mtype)
        case "Mesh":
            for (fragmentId, materialId) in zip(node.fragments!, node.materials!.map(String.init)) {
                self.loadMaterial(String(materialId))
                // TODO: don't hardcode scene id
                self.loadMesh(1, node.id, fragmentId, materialId)
            }
        default:
            print("Unknown Node type: \(node.type)")
        }
        
        if let children = node.childs {
            self.load(nodes: children)
        }
    }
    
    private func loadMaterial(_ materialId: String) {
//        loadGroup.enter()
//        DispatchQueue.global(qos: .userInitiated).async {
            var loaded = false
            
//            self.loadQueue.sync {
                if self.materials[materialId] != nil {
                    loaded = true
                }
                print("Hey saved some time there for \(materialId)")
//            }

            if !loaded {
                do {
                    if let materialUrl = self.materialFiles[materialId] {
                        let svfMaterial = try self.decoder.decode(SVFMaterial.self, from: Data(contentsOf: materialUrl))
                        if let defn = svfMaterial.materials.first {
                            var ambient = defn.value.properties.colors.generic_ambient?.float4
                            var diffuse = defn.value.properties.colors.generic_diffuse?.float4
                            var specular = defn.value.properties.colors.generic_specular?.float4
                            let opacity: Float = 1.0 - (defn.value.properties.scalars.generic_transparency?.values.first ?? 0.0)
                            
                            ambient?.w = opacity
                            diffuse?.w = opacity
                            specular?.w = opacity
//                            self.loadGroup.enter()
//                            self.loadQueue.async(flags: .barrier) {
                                print("Stored material: \(materialId)")
                                self.materials[materialId] = Material(
                                    ambient: ambient ?? diffuse ?? float4(),
                                    diffuse: diffuse ?? float4(),
                                    specular: specular ?? float4()
                            )
//                                self.loadGroup.leave()
//                            }
                        }
                    }
                } catch {
                    print("Error loading material \(materialId): \(error)")
                }
//            }
//
//            self.loadGroup.leave()
        }
    }
    
    private func loadMesh(_ sceneId: Int, _ nodeId: Int, _ fragmentId: Int, _ materialId: String) {
//        loadGroup.enter()
//        DispatchQueue.global(qos: .userInitiated).async {
            let meshId = "\(sceneId)-\(nodeId)-\(fragmentId)"
            do {
                if let meshUrl = self.meshFiles[meshId] {
                    let mesh = try MeshParser(url: meshUrl).parse()
//                    self.loadGroup.enter()
//                    self.loadQueue.async(flags: .barrier) {
                        print("Storing mesh \(meshId)")
                    self.pendingMeshes[meshId] = PendingMesh(
                        mesh: mesh,
                        materialId: materialId
                    )
//                        self.loadGroup.leave()
//                    }
                }
            } catch {
                print("Error loading mesh: \(meshId): \(error)")
            }

//            self.loadGroup.leave()
//        }
    }
    
    private func load(nodes: [Node]) {
        for node in nodes {
            loadNode(node)
        }
        
//        for (i, fileURL) in meshFiles.enumerated() {
//            print("Enter: \(i) Loading: \(fileURL)")
//            loadGroup.enter()
//            DispatchQueue.global(qos: .userInitiated).async {
//                do {
//                    let mesh = try MeshParser(url: fileURL).parse()
//                    self.queue.async(flags: .barrier) {
//                        self.meshes[i] = mesh
//                        print("Mesh \(i) index count: \(self.meshes[i].indices.count)")
//                        loadGroup.leave()
//                    }
//                } catch {
//                    print("Failed to load \(fileURL)")
//                }
//            }
//        }
        
//        return loadGroup
    }
    
    private func resolveMeshMaterials() -> [Mesh] {
        return pendingMeshes.map { (meshId, pendingMesh) in
            Mesh(
                indexCount: pendingMesh.mesh.indexCount,
                vertices: pendingMesh.mesh.vertices,
                indices: pendingMesh.mesh.indices,
                material: materials[pendingMesh.materialId] ?? pendingMesh.mesh.material
            )
        }
    }
    
    func loadAsync(completion: @escaping (CompositeMesh?) -> Void) {
        if let children = instanceTree.childs {
            load(nodes: children)
        }
        
        loadGroup.notify(
            queue: DispatchQueue.global(),
            work: DispatchWorkItem(block: {
                do {
                    completion(try self.constructCompositeMesh(self.resolveMeshMaterials()))
                } catch {
                    completion(nil)
                }
            })
        )
    }

    func loadBlocking() -> CompositeMesh? {
        do {
            if let children = instanceTree.childs {
                load(nodes: children)
            }

            loadGroup.wait()
            return try constructCompositeMesh(self.resolveMeshMaterials())
        } catch {
            print("Failure! \(error)")
            return nil
        }
    }

    private func constructCompositeMesh(_ meshes: [Mesh]) throws -> CompositeMesh {
        var vertices = [Vertex]()
        var indices = [UInt32]()
        var center = float3()
        var indexOffset = 0
        
        let submeshes = meshes.enumerated().map { (i, mesh) -> Submesh in
            center += mesh.center
            
            let submesh = Submesh(
                primitiveType: .triangle,
                vertexOffset: vertices.count * MemoryLayout<Vertex>.stride,
                indexType: .uint32,
                indexCount: mesh.indices.count,
                indexOffset: indexOffset * MemoryLayout<UInt32>.stride
            )
            
            vertices += mesh.materializedVertices()
            indices += mesh.indices.map { UInt32($0 + indexOffset) }
            
            indexOffset += mesh.indexCount
            
            print("At mesh \(i): \(vertices.count) verts \(indices.count) indices; offset: \(indexOffset)")
            
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
