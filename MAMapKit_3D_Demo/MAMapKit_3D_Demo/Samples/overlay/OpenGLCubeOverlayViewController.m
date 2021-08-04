//
//  OpenGLCubeOverlayViewController.m
//  MAMapKit_Debug
//
//  Created by yi chen on 1/12/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//


#import "OpenGLCubeOverlayViewController.h"
#import "CubeOverlayRenderer.h"
#import "CubeOverlay.h"

@interface OpenGLCubeOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) CubeOverlay * cubeOverlay;

@end

@implementation OpenGLCubeOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    //地图初始化前，设置metal为YES
    MAMapView.metalEnabled = NO;
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

#pragma mark - action handle
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CubeOverlay *)cubeOverlay
{
    if(_cubeOverlay == nil)
    {
        _cubeOverlay = [CubeOverlay cubeOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.99325, 116.473209) lengthOfSide:5000.f];
    }
    
    return _cubeOverlay;
}

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CubeOverlay class]])
    {
        CubeOverlayRenderer * renderer = [[CubeOverlayRenderer alloc] initWithCubeOverlay:overlay];
        
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
