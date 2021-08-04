//
//  ParticleOverlayViewController.m
//  MAMapKitDemo
//
//  Created by liubo on 2018/9/21.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "ParticleOverlayViewController.h"


@interface ParticleOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation ParticleOverlayViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    [self initToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addWeatherOverlayWithType:MAParticleOverlayTypeSunny];
}

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Init

- (void)initToolBar {
    UISegmentedControl *weatherTypeSegMentControl = [[UISegmentedControl alloc] initWithItems:@[@"晴天", @"雨天", @"雪天", @"雾霾天"]];
    [weatherTypeSegMentControl addTarget:self action:@selector(weatherTypeAction:) forControlEvents:UIControlEventValueChanged];
    weatherTypeSegMentControl.selectedSegmentIndex = 0;
    
    UIBarButtonItem *mayTypeItem = [[UIBarButtonItem alloc] initWithCustomView:weatherTypeSegMentControl];
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, mayTypeItem, flexbleItem, nil];
}

#pragma mark - Action

- (void)weatherTypeAction:(UISegmentedControl *)segmentControl
{
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            [self addWeatherOverlayWithType:MAParticleOverlayTypeSunny];
            break;
        }
        case 1:
        {
            [self addWeatherOverlayWithType:MAParticleOverlayTypeRain];
            break;
        }
        case 2:
        {
            [self addWeatherOverlayWithType:MAParticleOverlayTypeSnowy];
            break;
        }
        case 3:
        {
            [self addWeatherOverlayWithType:MAParticleOverlayTypeHaze];
            break;
        }
        default:
            break;
    }
}

- (void)addWeatherOverlayWithType:(MAParticleOverlayType)type {
    [self.mapView removeOverlays:[self.mapView overlays]];
    
    NSArray<MAParticleOverlayOptions *> *results = [MAParticleOverlayOptionsFactory particleOverlayOptionsWithType:type];
    for (MAParticleOverlayOptions *option in results) {
        MAParticleOverlay *overlay = [MAParticleOverlay particleOverlayWithOption:option];
        [self.mapView addOverlay:overlay];
    }
}

#pragma mark - Delegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAParticleOverlay class]]) {
        MAParticleOverlayRenderer *particleOverlayRenderer = [[MAParticleOverlayRenderer alloc] initWithParticleOverlay:overlay];
        return particleOverlayRenderer;
    }
    return nil;
}

@end
