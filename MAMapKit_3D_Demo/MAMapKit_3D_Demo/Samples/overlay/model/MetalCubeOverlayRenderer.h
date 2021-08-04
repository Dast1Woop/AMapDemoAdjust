//
//  MetalCubeOverlayRenderer.h
//  MAMapKitDemo
//
//  Created by JZ on 2021/1/19.
//  Copyright © 2021 Amap. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CubeOverlay.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalCubeOverlayRenderer : MAOverlayRenderer

- (instancetype)initWithCubeOverlay:(CubeOverlay *)cubeOverlay;

@property (nonatomic, readonly) CubeOverlay *cubeOverlay;

@end

NS_ASSUME_NONNULL_END
