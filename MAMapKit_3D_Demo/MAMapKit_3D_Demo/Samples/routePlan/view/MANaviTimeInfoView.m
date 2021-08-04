//
//  MANaviTimeInfoView.m
//  MAMapKit_3D_Demo
//
//  Created by ldj on 2019/5/10.
//  Copyright © 2019 Autonavi. All rights reserved.
//

#import "MANaviTimeInfoView.h"

@implementation MANaviTimeInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initContentView];
    }
    return self;
}

- (void)initContentView
{
    self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    _startLabel.font = [UIFont systemFontOfSize:11.f];
    _startLabel.text = @"出发时间";
    _startLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_startLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 40)];
    _timeLabel.font = [UIFont systemFontOfSize:22];
    _timeLabel.text = @"21:15";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_timeLabel];
}

- (void)updateTime:(NSString *)time timeLabelStr:(NSString *)str
{
    _startLabel.text = str;
    _timeLabel.text = time;
}

@end

@interface TimerInfoCell()

@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UILabel *startTimeLabel;

@end

@implementation TimerInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, 60, 30)];
        _timeLabel.font = [UIFont systemFontOfSize:11.f];
        _timeLabel.text = @"38分钟";
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        [self.contentView addSubview:_timeLabel];
        
        self.timeView = [[UIView alloc] initWithFrame:CGRectMake(60, 18, 60, 24)];
        _timeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.4];
        [self.contentView addSubview:_timeView];
        
        self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 60, 30)];
        _startTimeLabel.font = [UIFont systemFontOfSize:11.f];
        _startTimeLabel.text = @"20:30";
        _startTimeLabel.textAlignment = NSTextAlignmentCenter;
        _startTimeLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.contentView addSubview:_startTimeLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateTime:(NSInteger)time startTime:(NSString *)startTime
{
    _timeLabel.text = [NSString stringWithFormat:@"%li分钟", time];
    _startTimeLabel.text = startTime;
    CGRect timeViewFrame = _timeView.frame;
    CGRect timeLabelFrame = _timeLabel.frame;
    if (time < 0) {
        return;
    }
    if (time < 60) {
        timeViewFrame.size.width = time;
    } else {
        timeViewFrame.size.width = 60;
    }
    timeLabelFrame.origin.x = 70 + time;
    _timeLabel.frame = timeLabelFrame;
    _timeView.frame = timeViewFrame;
    _timeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.4];
}

@end
