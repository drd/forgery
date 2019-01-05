//
//  MeshParser.swift
//  mesher-scenekit
//
//  Created by Eric O'Connell on 12/26/18.
//  Copyright © 2018 Eric O'Connell. All rights reserved.
//

import Foundation
import simd

class MeshParser {
    let data: Data
    let name: String
    
    init(data: Data, name: String = "") {
        self.data = data
        self.name = name
    }
    
    convenience init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(data: data, name: url.lastPathComponent)
    }
    
    func getInt32(data: Data) -> Int {
        return Int(data.copyBytes(as: type(of: Int32()))[0].littleEndian)
    }
    
    func getFloat32s(data: Data, count: Int) -> [Float] {
        return Array(data.copyBytes(as: type(of: Float()))[..<count])
    }

    func getInt32s(data: Data, count: Int) -> [Int] {
        return Array(data.copyBytes(as: type(of: Int32()))[..<count]).map { Int($0) }
    }

    func parse() -> Mesh {
        // Number of coordinates is the first Int32 in the data
        let coordCount = getInt32(data: data)
        
        let coordData = data.advanced(by: MemoryLayout<Int32>.stride)
        let rawCoords = getFloat32s(data: coordData, count: coordCount)
        let coords = rawCoords.chunked(into: 3).map(float3.init)
        
        let triangleCountData = coordData.advanced(by: MemoryLayout<Float32>.stride * coordCount)
        let triangleCount = getInt32(data: triangleCountData)
        
        let triangleData = triangleCountData.advanced(by: MemoryLayout<Int32>.stride)
        let indices = getInt32s(data: triangleData, count: triangleCount)
        
        let uvCountData = triangleData.advanced(by: triangleCount * MemoryLayout<Int32>.stride)
        let uvCount = getInt32(data: uvCountData)
        let uvData = uvCountData.advanced(by: MemoryLayout<Int32>.stride)
        let uvs = getFloat32s(data: uvData, count: uvCount)
            .chunked(into: 2)
            .map(float2.init)

        let normals = makeNormals(Dictionary(uniqueKeysWithValues: Array(coords.enumerated())), indices)
        
        let vertices = coords.enumerated().map { (i, coord) in
            Vertex(
                position: coord,
                normal: normals[i],
                uv: uvs[i],
                material: Material.empty
            )
        }
        
        return Mesh(
            name: name,
            indexCount: coords.count,
            vertices: vertices,
            indices: indices,
            material: Material.empty
        )
    }
    
    func parseDeduped() -> Mesh {
        // Number of coordinates is the first Int32 in the data
        let coordCount = getInt32(data: data)
        //        print("Coords: \(coordCount)")
        
        let coordData = data.advanced(by: MemoryLayout<Int32>.stride)
        let rawCoords = getFloat32s(data: coordData, count: coordCount)
        let coords = rawCoords.chunked(into: 3).map(float3.init)
        
        let dedupedCoords = coords.reduce(into: [float3: Int]()) { acc, el in
            if acc[el] == nil {
                acc[el] = acc.count
            }
        }
        
        print("Deduped \(coords.count) coords into \(dedupedCoords.count)")
        
        let indexMapping = Dictionary(uniqueKeysWithValues: dedupedCoords.map {
            ($1, $0)
        })
        let triangleCountData = coordData.advanced(by: MemoryLayout<Float32>.stride * coordCount)
        let triangleCount = getInt32(data: triangleCountData)
        //        print("Triangles: \(triangleCount)")
        
        let triangleData = triangleCountData.advanced(by: MemoryLayout<Int32>.stride)
        let indices = getInt32s(data: triangleData, count: triangleCount)
        let dedupedIndices = indices.map { i in
            dedupedCoords[coords[i]]!
        }
        
        let uvCountData = triangleData.advanced(by: triangleCount * MemoryLayout<Int32>.stride)
        let uvCount = getInt32(data: uvCountData)
        //        print("UVs: \(uvCount)")
        let uvData = uvCountData.advanced(by: MemoryLayout<Int32>.stride)
        let uvs = getFloat32s(data: uvData, count: uvCount)
            .chunked(into: 2)
            .map(float2.init)
        
        let normals = makeNormals(indexMapping, dedupedIndices)
        
        let vertices = dedupedCoords.reduce(into: [Vertex](repeating: Vertex.empty, count: dedupedCoords.count)) { acc, tuple in
            acc[tuple.value] = Vertex(
                position: tuple.key,
                normal: normals[tuple.value],
                uv: uvs[dedupedIndices[tuple.value]],
                material: Material.empty
            )
        }
        
        return Mesh(
            name: name,
            indexCount: dedupedIndices.count,
            vertices: vertices,
            indices: dedupedIndices,
            material: Material.empty
        )
    }
    func makeNormals(_ vertices: [Int: float3], _ triangles: [Int]) -> [float3] {
        var normals: [float3] = [float3](repeating: float3(), count: vertices.count)
        
        for triangle in triangles.chunked(into: 3) {
            let a = triangle[0]
            let b = triangle[1]
            let c = triangle[2]
            
            let ab = vertices[b]! - vertices[a]!
            let ac = vertices[c]! - vertices[a]!
            
            let normal = ab.cross(ac).normalized

            normals[a] += normal
            normals[b] += normal
            normals[c] += normal
        }
        
        return normals.map { $0.normalized }
    }
    
    func normalOf(triangle: [Int], vertices: [float3]) -> float3 {
        let a = vertices[triangle[0]]
        let b = vertices[triangle[1]]
        let c = vertices[triangle[2]]

        let ab = b - a
        let ac = c - a

        return ab.cross(ac).normalized
    }
}

extension float3 : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}
