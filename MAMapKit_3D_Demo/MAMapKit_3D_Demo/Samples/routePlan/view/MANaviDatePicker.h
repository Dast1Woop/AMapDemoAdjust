//
//  UICustomDatePicker.h
//  MAMapKit_3D_Demo
//
//  Created by ldj on 2019/4/26.
//  Copyright © 2019 Autonavi. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol MANaviDatePickerDelegate <NSObject>

- (void)choosedDate:(NSDate *)date;

@end

@interface MANaviDatePicker : UIView

+ (void) showCustomDatePickerAtView:(UIView *)superView delegate:(id<MANaviDatePickerDelegate>)delegate;

@end
