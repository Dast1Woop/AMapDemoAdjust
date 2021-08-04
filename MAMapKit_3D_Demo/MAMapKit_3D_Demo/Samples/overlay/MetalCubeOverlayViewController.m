//
//  StereoOverlayMetalViewController.m
//  MAMapKitDemo
//
//  Created by JZ on 2021/1/19.
//  Copyright © 2021 Amap. All rights reserved.
//

#import "MetalCubeOverlayViewController.h"
#import "CubeOverlay.h"
#import "MetalCubeOverlayRenderer.h"

@interface MetalCubeOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) CubeOverlay * cubeOverlay;

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation MetalCubeOverlayViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    //地图初始化前，设置metal为YES
    MAMapView.metalEnabled = YES;
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    [self.mapView addOverlay:self.cubeOverlay];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (CubeOverlay *)cubeOverlay
{
    if(_cubeOverlay == nil)
    {
        _cubeOverlay = [CubeOverlay cubeOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.99325, 116.473209) lengthOfSide:5000.f];
    }
    
    return _cubeOverlay;
}

#pragma mark - action handle
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CubeOverlay class]])
    {
        MetalCubeOverlayRenderer * renderer = [[MetalCubeOverlayRenderer alloc] initWithCubeOverlay:overlay];
        return renderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers
{
    MAMapStatus * mapStatus = [mapView getMapStatus];
    mapStatus.centerCoordinate = self.cubeOverlay.coordinate;
    mapStatus.cameraDegree = 60.f;
    mapStatus.rotationDegree = 135.f;
    mapStatus.zoomLevel = 12;
    
    [mapView setMapStatus:mapStatus animated:YES duration:5.f];
}

@end
