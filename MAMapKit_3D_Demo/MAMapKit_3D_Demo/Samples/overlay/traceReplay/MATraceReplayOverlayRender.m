//
//  MATraceReplayOverlayRender.m
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MATraceReplayOverlayRender.h"
#import "MATraceReplayOverlay.h"
#import "MATraceReplayOverlay+Addition.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>

typedef struct _MADrawPoint {
    float x;
    float y;
} MADrawPoint;

@interface MATraceReplayOverlayRenderer () {
    MAMultiColoredPolylineRenderer *_proxyRender;
    NSTimeInterval _prevTime;
    
    MAPolylineRenderer *_patchLineRender;
    
    CGPoint _imageMapPoints[4];
    GLuint _textureName;
    GLuint _programe;
    GLuint _uniform_viewMatrix_location;
    GLuint _uniform_projMatrix_location;
    GLuint _attribute_position_location;
    GLuint _attribute_texCoord_location;
}

@end

@implementation MATraceReplayOverlayRenderer

- (id)initWithOverlay:(id<MAOverlay>)overlay {
    if(![overlay isKindOfClass:[MATraceReplayOverlay class]]) {
        return nil;
    }
    
    self = [super initWithOverlay:overlay];
    if(self) {
        MATraceReplayOverlay *traceOverlay = (MATraceReplayOverlay*)overlay;
        _proxyRender = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:[traceOverlay getMultiPolyline]];
        _proxyRender.gradient = NO;
        _proxyRender.strokeColors = @[[UIColor grayColor], [UIColor greenColor]];
        _proxyRender.strokeColor = _proxyRender.strokeColors.lastObject;
        
        _patchLineRender = [[MAPolylineRenderer alloc] initWithPolyline:[traceOverlay getPatchPolyline]];
        _patchLineRender.strokeColor = _proxyRender.strokeColors.lastObject;
        
        _carImage = [UIImage imageNamed:@"userPosition"];
    }
    
    return self;
}

- (void)dealloc
{
    if(_textureName) {
        glDeleteTextures(1, &_textureName);
        _textureName = 0;
    }
}

- (void)glRender
{
    MATraceReplayOverlay *traceOverlay = (MATraceReplayOverlay*)self.overlay;
    
    CGFloat zoomLevel = [self getMapZoomLevel];
    if(_prevTime == 0) {
        _prevTime = CFAbsoluteTimeGetCurrent();
        [traceOverlay drawStepWithTime:0 zoomLevel:zoomLevel];
    } else {
        NSTimeInterval curTime = CFAbsoluteTimeGetCurrent();
        [traceOverlay drawStepWithTime:curTime - _prevTime zoomLevel:zoomLevel];
        _prevTime = curTime;
    }
    
    if(self.carImage && [traceOverlay getMultiPolyline].pointCount > 0) {
        [_proxyRender glRender];
        [_patchLineRender glRender];
        
        [self renderCarImage];
    } else {
        [_proxyRender glRender];
    }
}

- (void)setRendererDelegate:(id<MAOverlayRenderDelegate>)rendererDelegate {
    [super setRendererDelegate:rendererDelegate];
    _proxyRender.rendererDelegate = rendererDelegate;
    _patchLineRender.rendererDelegate = rendererDelegate;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    [super setLineWidth:lineWidth];
    _proxyRender.lineWidth = lineWidth;
    _patchLineRender.lineWidth = lineWidth;
}

- (void)setStrokeColors:(NSArray *)strokeColors {
    if(strokeColors.count != 2) {
        return;
    }
    _proxyRender.strokeColors = strokeColors;
    
    if(strokeColors.count > 0) {
        _proxyRender.strokeColor = strokeColors.lastObject;
        _patchLineRender.strokeColor = strokeColors.lastObject;
    }
}

- (NSArray *)strokeColors {
    return _proxyRender.strokeColors;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [super setStrokeColor:strokeColor];
    [_proxyRender setStrokeColor:strokeColor];
    [_patchLineRender setStrokeColor:strokeColor];
}

- (UIColor *)strokeColor {
    return _proxyRender.strokeColor;
}

- (void)reset {
    _prevTime = 0;
}

- (void)renderCarImage {
    if(_textureName == 0) {
        NSError *error = nil;
        GLKTextureInfo *texInfo = [GLKTextureLoader textureWithCGImage:self.carImage.CGImage options:nil error:&error];
        _textureName = texInfo.name;
    }
    
    if(_programe == 0) {
        _programe = [self loadGLESPrograme];
    }
    
    if(_textureName == 0 || _programe == 0) {
        return;
    }
    
    MATraceReplayOverlay *traceOverlay = (MATraceReplayOverlay*)self.overlay;
    MAMapPoint carPoint = [traceOverlay getCarPosition];
    CLLocationDirection rotate = [traceOverlay getRunningDirection];
    
    double zoomLevel = [self getMapZoomLevel];
    double zoomScale = pow(2, zoomLevel);
    
    CGSize imageSize = self.carImage.size;
    
    double halfWidth  = imageSize.width  * (1 << 20) / zoomScale/2;
    double halfHeight = imageSize.height * (1 << 20) / zoomScale/2;
    
    _imageMapPoints[0].x = -halfWidth;
    _imageMapPoints[0].y = halfHeight;
    _imageMapPoints[1].x = halfWidth;
    _imageMapPoints[1].y = halfHeight;
    _imageMapPoints[2].x = halfWidth;
    _imageMapPoints[2].y = -halfHeight;
    _imageMapPoints[3].x = -halfWidth;
    _imageMapPoints[3].y = -halfHeight;
    
    
    MADrawPoint points[4] = { 0 };
    for(int i = 0; i < 4; ++i) {
        CGPoint tempPoint = _imageMapPoints[i];
        if(traceOverlay.enableAutoCarDirection) {
            tempPoint = CGPointApplyAffineTransform(_imageMapPoints[i], CGAffineTransformMakeRotation(rotate));
        }
        
        tempPoint.x += carPoint.x;
        tempPoint.y += carPoint.y;
        CGPoint p = [self glPointForMapPoint:MAMapPointMake(tempPoint.x, tempPoint.y)];
        points[i].x = p.x;
        points[i].y = p.y;
    }
    
    float *viewMatrix = [self getViewMatrix];
    float *projectionMatrix = [self getProjectionMatrix];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);//纹理和顶点皆已做过预乘alpha值处理
    
    
    glUseProgram(_programe);
    glBindTexture(GL_TEXTURE_2D, _textureName);
    
    //glUseProgram(shaderToUse.programName);
    glEnableVertexAttribArray(_attribute_position_location);
    glEnableVertexAttribArray(_attribute_texCoord_location);
    
    glUniformMatrix4fv(_uniform_viewMatrix_location, 1, false, viewMatrix);
    glUniformMatrix4fv(_uniform_projMatrix_location, 1, false, projectionMatrix);
            
    MADrawPoint textureCoords[4] = {
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0
    };
    glVertexAttribPointer(_attribute_position_location, 2, GL_FLOAT, false, sizeof(MADrawPoint), &(points[0]));
    glVertexAttribPointer(_attribute_texCoord_location, 2, GL_FLOAT, false, sizeof(MADrawPoint), &(textureCoords[0]));
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glDisableVertexAttribArray(_attribute_position_location);
    glDisableVertexAttribArray(_attribute_texCoord_location);
    
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
    glUseProgram(0);
}

- (GLuint)loadGLESPrograme {
    NSString *vertexShaderSrc = @"precision highp float;\n\
    attribute vec2 attrVertex;\n\
    attribute vec2 attrTextureCoord;\n\
    uniform mat4 inViewMatrix;\n\
    uniform mat4 inProjMatrix;\n\
    varying vec2 textureCoord;\n\
    void main(){\n\
    gl_Position = inProjMatrix * inViewMatrix * (vec4(attrVertex, 1.0, 1.0));\n\
    textureCoord = attrTextureCoord;\n\
    }";
    
    NSString *fragShaderSrc = @"precision highp float;\n\
    varying vec2 textureCoord;\n\
    uniform sampler2D inTextureUnit;\n\
    void main(){\n\
    gl_FragColor = texture2D(inTextureUnit, textureCoord);\n\
    }";
    
    GLuint prgName = 0;
    prgName = glCreateProgram();
    
    if(prgName <= 0) {
        return 0;
    }
    
    GLint logLength = 0, status = 0;
    //////////////////////////////////////
    // Specify and compile VertexShader //
    //////////////////////////////////////
    const GLchar* vertexShaderSrcStr = (const GLchar*)[vertexShaderSrc UTF8String];
    
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, (const GLchar **)&(vertexShaderSrcStr), NULL);
    glCompileShader(vertexShader);
    glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength > 0) {
        GLchar *log = (GLchar*) malloc(logLength);
        glGetShaderInfoLog(vertexShader, logLength, &logLength, log);
        NSLog(@"Vtx Shader compile log:%s\n", log);
        free(log);
    }
    
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        NSLog(@"Failed to compile vtx shader:\n%s\n", vertexShaderSrcStr);
        return 0;
    }
    
    glAttachShader(prgName, vertexShader);
    glDeleteShader(vertexShader);
    
    
    /////////////////////////////////////////
    // Specify and compile Fragment Shader //
    /////////////////////////////////////////
    const GLchar* fragmentShaderSrcStr = (const GLchar*)[fragShaderSrc UTF8String];

    GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragShader, 1, (const GLchar **)&(fragmentShaderSrcStr), NULL);
    glCompileShader(fragShader);
    glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetShaderInfoLog(fragShader, logLength, &logLength, log);
        NSLog(@"Frag Shader compile log:\n%s\n", log);
        free(log);
    }
    
    glGetShaderiv(fragShader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        NSLog(@"Failed to compile frag shader:\n%s\n", fragmentShaderSrcStr);
        return 0;
    }
    
    glAttachShader(prgName, fragShader);
    glDeleteShader(fragShader);
    
    //////////////////////
    // Link the program //
    //////////////////////
    glLinkProgram(prgName);
    glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(prgName, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s\n", log);
        free(log);
    }
    
    glGetProgramiv(prgName, GL_LINK_STATUS, &status);
    if (status == 0) {
        NSLog(@"Failed to link program");
        return 0;
    }
    
    _uniform_viewMatrix_location = glGetUniformLocation(prgName, "inViewMatrix");
    _uniform_projMatrix_location = glGetUniformLocation(prgName, "inProjMatrix");
    
    _attribute_position_location = glGetAttribLocation(prgName, "attrVertex");
    _attribute_texCoord_location = glGetAttribLocation(prgName, "attrTextureCoord");
    
    return prgName;
}
@end
