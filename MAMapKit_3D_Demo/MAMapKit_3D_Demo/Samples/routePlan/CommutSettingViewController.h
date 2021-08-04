//
//  SettingViewController.h
//  CommutingCardDemo
//
//  Created by zuola on 2019/5/12.
//  Copyright © 2019 zuola. All rights reserved.
//

@import UIKit;
@import MAMapKit;
@import AMapSearchKit;

#import "RouteCommon.h"


NS_ASSUME_NONNULL_BEGIN

@protocol CommutSettingViewControllerDelegate <NSObject>
- (void)updateLocation:(AMapTip *)tip type:(NSInteger)ktype;
@end

@interface CommutSettingViewController : UIViewController
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, weak)id<CommutSettingViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
