//
//  MANaviDatePicker.m
//  MAMapKit_3D_Demo
//
//  Created by ldj on 2019/5/9.
//  Copyright © 2019 Autonavi. All rights reserved.
//

#import "MANaviDatePicker.h"

@interface MANaviDatePicker()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView        *bottomView;
@property (nonatomic, weak) id<MANaviDatePickerDelegate> delegate;

@end

@implementation MANaviDatePicker

+ (void) showCustomDatePickerAtView:(UIView *)superView delegate:(id<MANaviDatePickerDelegate>)delegate
{
    if ([superView viewWithTag:1887]) {
        [[superView viewWithTag:1887] removeFromSuperview];
    }
    MANaviDatePicker *picker = [[NSBundle mainBundle] loadNibNamed:@"MANaviDatePicker" owner:nil options:nil][0];
    picker.tag = 1887;
    [superView addSubview:picker];
    picker.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:picker
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:superView
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0
                                                        constant:0.0]];
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:picker
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:picker
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:picker
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0.0]];
    picker.delegate = delegate;
 
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)dismissBtnAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)confirmBtnAction:(id)sender {
    if (self.delegate) {
        [self.delegate choosedDate:self.datePicker.date];
    }
    [self removeFromSuperview];
}

@end
