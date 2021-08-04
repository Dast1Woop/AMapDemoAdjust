//
//  CustomBuildingOverlayViewController.m
//  MAMapKit_3D_Demo
//
//  Created by liubo on 2018/6/5.
//  Copyright © 2018年 Autonavi. All rights reserved.
//

#import "CustomBuildingOverlayViewController.h"

@interface CustomBuildingOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MACustomBuildingOverlay *customBuindingOverlay;
@property (nonatomic, strong) MACustomBuildingOverlayOption *buildingOption;

@end

@implementation CustomBuildingOverlayViewController

#pragma mark - MAMapVieDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MACustomBuildingOverlay class]]) {
        MACustomBuildingOverlayRenderer *overlayRenderer = [[MACustomBuildingOverlayRenderer alloc] initWithCustomBuildingOverlay:overlay];
        return overlayRenderer;
    }
    
    return nil;
}

#pragma mark - Initialization

- (void)initOverlay {
    ///1.创建MACustomBuildingOverlay实例
    self.customBuindingOverlay = [[MACustomBuildingOverlay alloc] init];
    
    ///2.创建MACustomBuildingOverlayOption选项, 详细说明参考MACustomBuildingOverlayOption类
    CLLocationCoordinate2D coordinate1[4] = {
        {39.922665,116.391863},
        {39.923027,116.401669},
        {39.913581,116.402163},
        {39.913186,116.392314},
    };
    self.buildingOption = [MACustomBuildingOverlayOption optionWithCoordinates:&coordinate1[0] count:4];
    self.buildingOption.heightScale = 4;
    self.buildingOption.topColor = [UIColor colorWithRed:238/255.0 green:201/255.0 blue:1/255.0 alpha:1.0];
    self.buildingOption.sideColor = [UIColor colorWithRed:239/255.0 green:59/255.0 blue:59/255.0 alpha:1.0];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initOverlay];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.915449, 116.397142);
    self.mapView.cameraDegree = 30.f;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ///1.为达到更好的显示效果，关闭地图默认的楼块显示
    self.mapView.showsBuildings = NO;
    
    ///2.MACustomBuildingOverlay仅支持在zoomLevel>=15级时显示
    self.mapView.zoomLevel = 16.1;
    
    ///3.设置是否显示默认的楼块
    [self.customBuindingOverlay.defaultOption setVisibile:YES];
    
    ///4.为MACustomBuildingOverlay添加显示option
    [self.customBuindingOverlay addCustomOption:self.buildingOption];
    
    ///5.将MACustomBuildingOverlay添加到地图上。为达到更好的效果，建议level为MAOverlayLevelAboveRoads
    [self.mapView addOverlay:self.customBuindingOverlay level:MAOverlayLevelAboveRoads];
}

#pragma mark - back action handling

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
