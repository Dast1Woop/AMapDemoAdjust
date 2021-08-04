//
//  MATrackPointAnnotation.h
//  TrackMapDemo
//
//  Created by zuola on 2019/5/13.
//  Copyright © 2019 zuola. All rights reserved.
//

@import Foundation;
@import MAMapKit;

NS_ASSUME_NONNULL_BEGIN

@interface MATrackPointAnnotation : MAPointAnnotation
@property (nonatomic, assign) NSInteger type;//0-gas,1-service,2-Violation

@end

NS_ASSUME_NONNULL_END
