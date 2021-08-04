//
//  Cross180LongitudeViewController.m
//  MAMapKitDemo
//
//  Created by shaobin on 2018/7/26.
//  Copyright © 2018年 Amap. All rights reserved.
//

#import "Cross180LongitudeViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface Cross180LongitudeViewController ()<MAMapViewDelegate> {
    MAMultiPolyline *_polyline;
    MAPolyline *_180LonPolyline;
}

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation Cross180LongitudeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    CLLocationCoordinate2D pCoords[3] = {
        CLLocationCoordinate2DMake(40.079666, 116.602058),
        CLLocationCoordinate2DMake(37.969392, -122.51812 + 360),
        CLLocationCoordinate2DMake(31.36216,121.499214)};
    
    _polyline = [MAMultiPolyline polylineWithCoordinates:pCoords count:3];
    _polyline.drawStyleIndexes = @[@0, @1, @2];
    [self.mapView addOverlay:_polyline];
    
    CLLocationCoordinate2D pCoords2[2] = {
        CLLocationCoordinate2DMake(90, 180),
        CLLocationCoordinate2DMake(-90, 180)
    };
    
    _180LonPolyline = [MAPolyline polylineWithCoordinates:pCoords2 count:2];
    [self.mapView addOverlay:_180LonPolyline];
    
    
    [self.mapView showOverlays:@[_polyline] animated:NO];
}

#pragma mark - delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if (overlay == _polyline) {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        polylineRenderer.lineWidth = 5;
        polylineRenderer.strokeColors = @[[UIColor blueColor],
                                          [UIColor redColor],
                                          [UIColor yellowColor]];
        
        polylineRenderer.gradient = YES;
        return polylineRenderer;
    } else if(overlay == _180LonPolyline) {
        MAPolylineRenderer *render = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        render.lineWidth = 1;
        render.strokeColor = [UIColor blackColor];
        render.lineDashType = kMALineDashTypeSquare;
        return render;
    }
    
    return nil;
}

@end
