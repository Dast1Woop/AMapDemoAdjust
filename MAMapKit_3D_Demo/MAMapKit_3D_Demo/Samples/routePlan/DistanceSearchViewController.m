//
//  DistanceSearchViewController.m
//  MAMapKit_3D_Demo
//
//  Created by hanxiaoming on 2018/2/2.
//  Copyright © 2018年 Autonavi. All rights reserved.
//

#import "DistanceSearchViewController.h"
#import "UIView+Toast.h"

@interface DistanceSearchViewController ()<MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) MAPointAnnotation *pin1;
@property (nonatomic, strong) MAPointAnnotation *pin2;

@end

@implementation DistanceSearchViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    MAPointAnnotation *pin1 = [[MAPointAnnotation alloc] init];
    pin1.coordinate =  CLLocationCoordinate2DMake(39.992520, 116.336170);
    
    MAPointAnnotation *pin2 = [[MAPointAnnotation alloc] init];
    pin2.coordinate =  CLLocationCoordinate2DMake(39.892520, 116.436170);
    pin2.title = @"拖动我哦";
    
    [self.mapView addAnnotations:@[pin1, pin2]];
    self.pin1 = pin1;
    self.pin2 = pin2;
    
    [self.mapView selectAnnotation:pin2 animated:YES];
}

#pragma mark - Action Handlers
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MAMapViewDelegate
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = YES;
        annotationView.draggable                    = YES;
        annotationView.rightCalloutAccessoryView    = nil;
        annotationView.pinColor                     = MAPinAnnotationColorRed;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState {
    if(newState == MAAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D loc1 = self.pin1.coordinate;
        CLLocationCoordinate2D loc2 = self.pin2.coordinate;
        
        [self searchDistanceFrom:loc1 to:loc2];
    }
}

#pragma mark - AMapSearch

- (void)searchDistanceFrom:(CLLocationCoordinate2D)startCoordinate to:(CLLocationCoordinate2D)endCoordinate
{
    AMapDistanceSearchRequest *request = [[AMapDistanceSearchRequest alloc] init];
    
    request.origins = @[[AMapGeoPoint locationWithLatitude:startCoordinate.latitude longitude:startCoordinate.longitude]];
    request.destination = [AMapGeoPoint locationWithLatitude:endCoordinate.latitude longitude:endCoordinate.longitude];
    [self.search AMapDistanceSearch:request];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"request error :%@", error);
}

- (void)onDistanceSearchDone:(AMapDistanceSearchRequest *)request response:(AMapDistanceSearchResponse *)response
{
    if (response.results.firstObject) {
        
        AMapDistanceResult *result = response.results.firstObject;
        if (result.info) {
            [self.view makeToast:[NSString stringWithFormat:@"distance search failed :%@", result.info] duration:1.0];
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"driving distance :%ld m, duration :%ld s", (long)result.distance, (long)result.duration] duration:1.0];
        }
        
    }
}

@end
