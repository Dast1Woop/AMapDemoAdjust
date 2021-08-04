//
//  FaceOverlay.h
//  CustomOverlayViewDemo
//
//  Created by songjian on 13-3-12.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

@import MAMapKit;
@import CoreLocation;

@interface FaceOverlay : MABaseOverlay

+ (id)faceWithLeftEyeCoordinate:(CLLocationCoordinate2D)leftEyeCoordinate
                  leftEyeRadius:(CLLocationDistance)leftEyeRadius
             rightEyeCoordinate:(CLLocationCoordinate2D)rightEyeCoordinate
                 rightEyeRadius:(CLLocationDistance)rightEyeRadius;

@property (nonatomic, readonly) CLLocationCoordinate2D leftEyeCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D rightEyeCoordinate;
@property (nonatomic, readonly) CLLocationDistance leftEyeRadius;
@property (nonatomic, readonly) CLLocationDistance rightEyeRadius;

@end
