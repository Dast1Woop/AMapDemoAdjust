//
//  FaceOverlayRenderer.m
//  CustomOverlayViewDemo
//
//  Created by songjian on 13-3-12.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "FaceOverlayRenderer.h"

@interface FaceOverlayRenderer ()
{
    MAMapPoint _linePoints[2];
    
    MACircleRenderer *_leftCircleRender;
    MACircleRenderer *_rightCircleRender;
    MAPolylineRenderer *_lineRender;
}

@end

@implementation FaceOverlayRenderer

#pragma mark - Interface

- (FaceOverlay *)faceOverlay
{
    return (FaceOverlay*)self.overlay;
}

#pragma mark - Override

- (void)glRender
{
    if(!_leftCircleRender) {
        FaceOverlay *faceOverlay = (FaceOverlay*)self.overlay;
        MACircle* circle = [MACircle circleWithCenterCoordinate:faceOverlay.leftEyeCoordinate radius:faceOverlay.leftEyeRadius];
        _leftCircleRender = [[MACircleRenderer alloc] initWithCircle:circle];
        _leftCircleRender.fillColor = [UIColor clearColor];
        _leftCircleRender.lineWidth = self.lineWidth;
        _leftCircleRender.lineDashType = self.lineDashType;
        _leftCircleRender.strokeColor = self.strokeColor;
        _leftCircleRender.rendererDelegate = self.rendererDelegate;
    }
    if(!_rightCircleRender) {
        FaceOverlay *faceOverlay = (FaceOverlay*)self.overlay;
        MACircle* circle = [MACircle circleWithCenterCoordinate:faceOverlay.rightEyeCoordinate radius:faceOverlay.rightEyeRadius];
        _rightCircleRender = [[MACircleRenderer alloc] initWithCircle:circle];
        _rightCircleRender.fillColor = [UIColor clearColor];
        _rightCircleRender.lineWidth = self.lineWidth;
        _rightCircleRender.lineDashType = self.lineDashType;
        _rightCircleRender.strokeColor = self.strokeColor;
        _rightCircleRender.rendererDelegate = self.rendererDelegate;
    }
    if(!_lineRender) {
        MAPolyline *line = [MAPolyline polylineWithPoints:_linePoints count:2];
        _lineRender = [[MAPolylineRenderer alloc] initWithOverlay:line];
        _lineRender.rendererDelegate = self.rendererDelegate;
        _lineRender.strokeColor = self.strokeColor;
        _lineRender.lineWidth = self.lineWidth;
    }
    
    [_leftCircleRender glRender];
    [_rightCircleRender glRender];
    [_lineRender glRender];
}

#pragma mark - Life Cycle

- (void)initMapPoints
{
    FaceOverlay *faceOverlay = (FaceOverlay*)self.overlay;
    
    _linePoints[0] = MAMapPointForCoordinate(faceOverlay.leftEyeCoordinate);
    _linePoints[1] = MAMapPointForCoordinate(faceOverlay.rightEyeCoordinate);
}

- (id)initWithFaceOverlay:(FaceOverlay *)faceOverlay;
{
    self = [super initWithOverlay:faceOverlay];
    if (self)
    {
        [self initMapPoints];
    }
    
    return self;
}

@end
