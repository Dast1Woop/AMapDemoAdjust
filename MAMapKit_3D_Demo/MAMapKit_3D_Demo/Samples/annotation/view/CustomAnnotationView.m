//
//  CustomAnnotationView.m
//  CustomAnnotationDemo
//
//  Created by songjian on 13-3-11.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"
//#import <Masonry/Masonry.h>


#define kHoriMargin 5.f
#define kVertMargin 5.f

#define kPortraitWidth  20.f
#define kPortraitHeight 20.f

#define kH4Text 20.f


#define kWidth  80.f
#define kHeight (kPortraitHeight + kVertMargin +kH4Text)

#define kCalloutWidth   200.0
#define kCalloutHeight  70.0

static const int KFONT_SIZE = 12.f;

@interface CustomAnnotationView ()

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation CustomAnnotationView

@synthesize calloutView;
@synthesize portraitImageView   = _portraitImageView;
@synthesize nameLabel           = _nameLabel;

#pragma mark - Handle Action

- (void)btnAction
{
    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
    
    NSLog(@"coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
}

#pragma mark - Override

- (NSString *)name
{
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
    
    //计算文本高度
    CGRect lRect = [name boundingRectWithSize:CGSizeMake(kWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:KFONT_SIZE]} context:nil];
    float lHTextCal = ceilf(lRect.size.height);
    self.bounds = CGRectMake(0, 0, kWidth, kHeight - kH4Text + lHTextCal);
    self.nameLabel.frame =CGRectMake(0,
                                     kVertMargin + kPortraitHeight,
                                     kWidth,
                                     lHTextCal);
}

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            /* Construct custom callout. */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(10, 10, 40, 40);
            [btn setTitle:@"Test" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
            
            [self.calloutView addSubview:btn];
            
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 30)];
            name.backgroundColor = [UIColor clearColor];
            name.textColor = [UIColor whiteColor];
            name.text = @"Hello Amap!";
            [self.calloutView addSubview:name];
        }
        
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        
        self.backgroundColor = [UIColor clearColor];
        
        /* Create portrait image view and add to view hierarchy. */
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(kWidth - kPortraitWidth), 0, kPortraitWidth, kPortraitHeight)];
        [self addSubview:self.portraitImageView];

        /* Create name label. */
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   kVertMargin + kPortraitHeight,
                                                                   kWidth,
                                                                   kHeight - (kVertMargin + kPortraitHeight))];
        self.nameLabel.backgroundColor  = [UIColor clearColor];
        self.nameLabel.textAlignment    = NSTextAlignmentCenter;
        self.nameLabel.textColor        = [UIColor blackColor];
        self.nameLabel.font             = [UIFont systemFontOfSize:KFONT_SIZE];
        self.nameLabel.numberOfLines = 0;
        [self addSubview:self.nameLabel];
        
    }
    
    return self;
}

@end
