//
//  MetalCube.metal
//  MAMapKitDemo
//
//  Created by JZ on 2021/1/19.
//  Copyright © 2021 Amap. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float3 aVertex [[attribute(0)]];
    float4 aColor [[attribute(1)]];
} VertexIn;

typedef struct
{
    float4 position [[position]];
    float4 color;
    
} VertexOut;

vertex VertexOut
MetalCubeVertexShader(
                         VertexIn in [[stage_in]],
                         constant float4x4& viewMatrix [[ buffer(1) ]],
                         constant float4x4& scaleMatrix [[ buffer(2) ]],
                         constant float4x4& projectionMatrix [[ buffer(3) ]]
                      ) {
    VertexOut out;
    
    out.position =  ((projectionMatrix * viewMatrix) * scaleMatrix) * float4(in.aVertex,1.0);
    out.color = in.aColor;
    
    return out;
}

fragment float4
MetalCubeFragmentShader(
                           VertexOut in [[ stage_in ]]
                           ) {
    return in.color;
}
