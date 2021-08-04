//
//  MetalCubeOverlayRenderer.m
//  MAMapKitDemo
//
//  Created by JZ on 2021/1/19.
//  Copyright © 2021 Amap. All rights reserved.
//

#import "MetalCubeOverlayRenderer.h"
#import <MetalKit/MetalKit.h>

const int totalVertexCount = 8;  //总顶点数
const int indexCount       = 36; //索引数
const int vertexSize       = 7;
@implementation MetalCubeOverlayRenderer
{
    float _vertex[totalVertexCount * vertexSize];
    UInt32 _indecies[indexCount];
    
    float _scale[16];
    
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipelineState;
    id<MTLDepthStencilState> _depthStencilState;
    
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
}

#pragma mark ---------------- lifeCycle ---------------
- (instancetype)initWithCubeOverlay:(CubeOverlay *)cubeOverlay
{
    self = [super initWithOverlay:cubeOverlay];
    if (self)
    {
        [self initVertext];
    }
    
    return self;
}

- (instancetype)initWithOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CubeOverlay class]])
    {
        return nil;
    }
    
    return [self initWithCubeOverlay:overlay];
}

- (void)setupMetal {
    _device = MTLCreateSystemDefaultDevice();
}

- (void)setupRenderPipeline{
    
    id<MTLLibrary> library = [_device newDefaultLibrary];
    
    id<MTLFunction> vertexFunc = [library newFunctionWithName: @"MetalCubeVertexShader"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName: @"MetalCubeFragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.label = @"Render Pipeline";
    pipelineDescriptor.vertexFunction = vertexFunc;
    pipelineDescriptor.fragmentFunction = fragmentFunc;
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc]init];
    //pos
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    //color
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
    vertexDescriptor.attributes[1].offset = 12;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    //layout
    vertexDescriptor.layouts[0].stride = 28;
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    //设置vertexDescriptor
    pipelineDescriptor.vertexDescriptor = vertexDescriptor;

    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormatStencil8;
    NSError *err;
    _renderPipelineState = [_device newRenderPipelineStateWithDescriptor: pipelineDescriptor error: &err];
    
    NSAssert(_renderPipelineState != nil, @"[MAMapViewDemo] Failed to create pipeline state: %@", err);
}

- (void)setupDepthStencil{
    MTLDepthStencilDescriptor *depthStencilDesc = [MTLDepthStencilDescriptor new];
    depthStencilDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDesc.depthWriteEnabled = true;
    _depthStencilState = [_device newDepthStencilStateWithDescriptor: depthStencilDesc];
}

- (void)setupVertexBuffer {
    //创建定点缓冲
    _vertexBuffer = [_device newBufferWithBytes: _vertex
                                         length: sizeof(_vertex)
                                        options: MTLResourceStorageModeShared];
    //创建索引缓冲
    _indexBuffer = [_device newBufferWithBytes: _indecies
                                        length: sizeof(_indecies)
                                       options: MTLResourceStorageModeShared];
}

#pragma mark - Metal

- (void)initVertext
{
    /* 创建vertex 与 color */
    float vertext[] = {
        0.0, 0.0, 0.0, 1.0f, 0.0f, 0.0f, 1.0f,
        2.0, 0.0, 0.0, 0.0f, 1.0f, 0.0f, 1.0f,
        2.0, 2.0, 0.0, 0.0f, 0.0f, 1.0f, 1.0f,
        0.0, 2.0, 0.0, 1.0f, 1.0f, 0.0f, 1.0f,
        0.0, 0.0, 2.0, 0.0f, 1.0f, 1.0f, 1.0f,
        2.0, 0.0, 2.0, 1.0f, 0.0f, 1.0f, 1.0f,
        2.0, 2.0, 2.0, 0.0f, 0.0f, 0.0f, 1.0f,
        0.0, 2.0, 2.0, 1.0f, 1.0f, 1.0f, 1.0f,
    };
    for (int i = 0; i < totalVertexCount * vertexSize; i++) {
        _vertex[i] = vertext[i];
    }

    /* 创建vertex索引 */
    UInt32 indices[] = {
        0, 4, 5,
        0, 5, 1,
        1, 5, 6,
        1, 6, 2,
        2, 6, 7,
        2, 7, 3,
        3, 7, 4,
        3, 4, 0,
        4, 7, 6,
        4, 6, 5,
        3, 0, 1,
        3, 1, 2,
    };
    for (int i = 0; i < 36; i++) {
        _indecies[i] = indices[i];
    }
    
    /* 创建缩放矩阵 */
    float scale[] = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    };
    for (int i = 0; i < 16; i++) {
        _scale[i] = scale[i];
    }
}
static void translateM(float* m, int mOffset,float x, float y, float z) {
    for (int i=0 ; i<4 ; i++) {
        int mi = mOffset + i;
        m[12 + mi] += m[mi] * x + m[4 + mi] * y + m[8 + mi] * z;
    }
}

- (void)glRender {
    if(_device == nil){
        [self setupMetal];
        //初始化渲染管线
        [self setupRenderPipeline];
        //初始化depth
        [self setupDepthStencil];
        //初始化索引buffer
        [self setupVertexBuffer];
        
        //设定缩放矩阵，在当前级别的10屏幕像素大小
        _scale[0] = 10 * [self glWidthForWindowWidth:1];
        _scale[5] = 10 * [self glWidthForWindowWidth:1];
        _scale[10] = 10 * [self glWidthForWindowWidth:1];
    }
    
    id<MTLRenderCommandEncoder> encoder = [self getCommandEncoder];
    [encoder setRenderPipelineState: _renderPipelineState];
    // depth
    [encoder setDepthStencilState: _depthStencilState];

    // vertex
    [encoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    
    MAMapPoint center = MAMapPointForCoordinate(self.overlay.coordinate);
    CGPoint offsetPoint = [self glPointForMapPoint:center];
    float * viewMatrix = [self getViewMatrix];
    translateM(viewMatrix, 0, offsetPoint.x, offsetPoint.y, 0);
    [encoder setVertexBytes: viewMatrix
                     length: sizeof(simd_float4x4)
                    atIndex: 1];
    
    [encoder setVertexBytes: _scale
                     length: sizeof(simd_float4x4)
                    atIndex: 2];
    
    float * projectionMatrix = [self getProjectionMatrix];
    [encoder setVertexBytes: projectionMatrix
                     length: sizeof(simd_float4x4)
                    atIndex: 3];
    
    [encoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle // Triangle
                        indexCount: sizeof(_indecies) / sizeof(UInt32)
                         indexType: MTLIndexTypeUInt32
                       indexBuffer: _indexBuffer
                 indexBufferOffset: 0];
    
//  外部不需要调用endEncoding，内部调用
//  [encoder endEncoding];
}

@end
