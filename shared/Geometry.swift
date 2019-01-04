//
//  Geometry.swift
//  fb
//
//  Created by Eric O'Connell on 10/17/18.
//  Copyright © 2018 compassing. All rights reserved.
//

import Foundation
import Metal
import simd

enum GeometryError: Error {
    case ZeroVector
}

struct Material {
    let ambient: float4
    let diffuse: float4
    let specular: float4
    
    static let empty = Material(
        ambient: float4(),
        diffuse: float4(),
        specular: float4()
    )
}

struct Vertex {
    let position: float3
    let normal: float3
    let uv: float2
    let material: Material
}

struct Mesh {
    let indexCount: Int
    let vertices: [Vertex]
    let indices: [Int]
    let material: Material
    
    var center: float3 {
        get {
            return vertices.reduce(float3()) { acc, v in acc + v.position } / Float(vertices.count)
        }
    }
    
    func materializedVertices() -> [Vertex] {
        return vertices.map {
            Vertex(
                position: $0.position,
                normal: $0.normal,
                uv: $0.uv,
                material: material
            )
        }
    }
    
    static let empty = Mesh(
        indexCount: 0,
        vertices: [Vertex](),
        indices: [Int](),
        material: Material.empty
    )
}

// Contains metadata and location describing geometry and indexing in CompositeMesh#buffer
struct Submesh {
    // Geometry type
    let primitiveType: MTLPrimitiveType
    // Vertex data location in shared vertex buffer
    let vertexOffset: Int
    
    // Either unit16 or uint32
    let indexType: MTLIndexType
    // Number of indices into geometry
    let indexCount: Int
    // Index data location in shared index buffer
    let indexOffset: Int
}

// A convenient representation of aggregate mesh data for rendering by metal
struct CompositeMesh {
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let submeshes: [Submesh]
    let center: float3
}
