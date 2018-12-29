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
    let base: URL
    let device: MTLDevice
    let fileNames: [String]
    
    private func constructCompositeMesh(_ meshes: [Mesh]) throws -> CompositeMesh {
        var vertices = [Vertex]()
        var indices = [UInt32]()
        var center = float3()
        
        let submeshes = meshes.enumerated().map { (i, mesh) -> Submesh in
            if (mesh.indices.count == 0) {
                print("Mesh \(i) \(mesh)")
            }

            center += mesh.center
            
            let indexOffset = indices.count
            
            let submesh = Submesh(
                primitiveType: .triangle,
                vertexOffset: vertices.count * MemoryLayout<Vertex>.stride,
                indexType: .uint32,
                indexCount: mesh.indices.count,
                indexOffset: indexOffset * MemoryLayout<UInt32>.stride
            )

            vertices += mesh.vertices
            indices += mesh.indices.map { UInt32($0 + indexOffset) }
            
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

    init(url: URL, device: MTLDevice) throws {
        let fileManager = FileManager.default
        self.base = url
        self.device = device
        print("Looking in \(url)")
        self.fileNames = try fileManager.contentsOfDirectory(atPath: url.path).sorted()
    }
    
    private func serialLoad() -> [Mesh] {
        do {
            return try fileNames.map { name in
                let fileURL = self.base.appendingPathComponent(name)
                return try MeshParser(url: fileURL).parse()
            }
        } catch {
            print("Failure! \(error)")
            return [Mesh]()
        }
    }
    
    private func load() -> ([Mesh], DispatchGroup) {
        var meshes = [Mesh](repeating: Mesh.empty, count: fileNames.count)
        let loadGroup = DispatchGroup()
        
        for (i, name) in fileNames.enumerated() {
            print("Enter: \(i) Loading: \(name)")
            loadGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                defer {
                    print("Leave \(i)")
                    loadGroup.leave()
                }
                do {
                    let fileURL = self.base.appendingPathComponent(name)
                    let mesh = try MeshParser(url: fileURL).parse()
                    meshes[i] = mesh
                    print("Mesh \(i) index count: \(meshes[i].indices.count)")
                } catch {
                    print("Failed to load \(name)")
                }
            }
        }
        
        return (meshes, loadGroup)
    }
    
    func loadAsync(completion: @escaping (CompositeMesh?) -> Void) {
        let (meshes, loadGroup) = load()
        
        loadGroup.notify(
            queue: DispatchQueue.global(),
            work: DispatchWorkItem(block: {
                do {
                    completion(try self.constructCompositeMesh(meshes))
                } catch {
                    completion(nil)
                }
            })
        )
    }

    func loadBlocking() -> CompositeMesh? {
        do {
//            let (meshes, loadGroup) = load()
//            loadGroup.wait()
            return try constructCompositeMesh(self.serialLoad())
        } catch {
            print("Failure! \(error)")
            return nil
        }
    }
}
