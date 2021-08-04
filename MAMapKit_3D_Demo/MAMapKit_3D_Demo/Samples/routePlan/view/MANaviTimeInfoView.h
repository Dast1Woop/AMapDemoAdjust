//
//  MANaviTimeInfoView.h
//  MAMapKit_3D_Demo
//
//  Created by ldj on 2019/5/10.
//  Copyright © 2019 Autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MANaviTimeInfoView : UIView


@property (strong, nonatomic) UILabel *startLabel;

@property (strong, nonatomic) UILabel *timeLabel;

- (void)updateTime:(NSString *)time timeLabelStr:(NSString *)str;

@end

@interface TimerInfoCell : UITableViewCell

@property (strong, nonatomic) UIView *timeView;

- (void)updateTime:(NSInteger)time startTime:(NSString *)startTime;

@end
