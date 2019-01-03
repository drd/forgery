//
//  Shaders.metal
//  mesher Shared
//
//  Created by Eric O'Connell on 12/26/18.
//  Copyright © 2018 Eric O'Connell. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position;
    float3 normal;
    float2 texCoord;
    float4 ambient;
    float4 diffuse;
    float4 specular;
} Vertex;

typedef struct
{
    float4 position [[position]];
    float4 ambient;
    float4 diffuse;
    float4 specular;
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(constant Vertex * vertices [[ buffer(BufferIndexMeshPositions) ]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               unsigned int vid [[ vertex_id ]])
{
    ColorInOut out;

    Vertex in = vertices[vid];
    
    float4 position = float4(in.position, 1.0);
    float4 viewPosition = uniforms.modelViewMatrix * position;
    out.position = uniforms.projectionMatrix * viewPosition;
    out.texCoord = in.texCoord;
    out.ambient = in.ambient;
    out.diffuse = in.diffuse;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

    return in.ambient; // + in.diffuse + in.specular;
}
