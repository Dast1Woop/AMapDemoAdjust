//
//  DistrictViewController.m
//  officialDemo2D
//
//  Created by xiaoming han on 14/11/26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "DistrictViewController.h"
#import "CommonUtility.h"

#define kDefaultDistrictName        @"北京市市辖区" //市辖区

@interface DistrictViewController ()<MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation DistrictViewController

#pragma mark - life cycle
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
    
    [self initSearchBar];
}

#pragma mark -
- (void)initSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.searchBar.barStyle     = UIBarStyleBlack;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"输入关键字";
    self.searchBar.text = kDefaultDistrictName;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    self.navigationItem.titleView = self.searchBar;
    
    [self.searchBar sizeToFit];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    if(self.searchBar.text.length == 0) {
        return;
    }
    
    [self searchDistrictWithName:self.searchBar.text];
}


#pragma mark - action handle

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helpers

- (void)handleDistrictResponse:(AMapDistrictSearchResponse *)response
{
    if (response == nil)
    {
        return;
    }
    
    for (AMapDistrict *dist in response.districts)
    {
        MAPointAnnotation *poiAnnotation = [[MAPointAnnotation alloc] init];
        
        poiAnnotation.coordinate = CLLocationCoordinate2DMake(dist.center.latitude, dist.center.longitude);
        poiAnnotation.title      = dist.name;
        poiAnnotation.subtitle   = dist.adcode;
        
        [self.mapView addAnnotation:poiAnnotation];
        
        if (dist.polylines.count > 0)
        {
            MAMapRect bounds = MAMapRectZero;
            
            
            for (NSString *polylineStr in dist.polylines)
            {
                MAPolyline *polyline = [CommonUtility polylineForCoordinateString:polylineStr];
                [self.mapView addOverlay:polyline];
                if(MAMapRectEqualToRect(bounds, MAMapRectZero)) {
                    bounds = polyline.boundingMapRect;
                } else {
                    bounds = MAMapRectUnion(bounds, polyline.boundingMapRect);
                }
            }
            
#if 0 //如果要显示带填充色的polygon，打开此开关
            for (NSString *polylineStr in dist.polylines)
            {
                NSUInteger tempCount = 0;
                CLLocationCoordinate2D *coordinates = [CommonUtility coordinatesForString:polylineStr
                                                                          coordinateCount:&tempCount
                                                                               parseToken:@";"];
                
                
                MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:tempCount];
                free(coordinates);
                [self.mapView addOverlay:polygon];
            }
#endif
            
            [self.mapView setVisibleMapRect:bounds animated:YES];
        }
        
        // sub
        for (AMapDistrict *subdist in dist.districts)
        {
            MAPointAnnotation *subAnnotation = [[MAPointAnnotation alloc] init];
            
            subAnnotation.coordinate = CLLocationCoordinate2DMake(subdist.center.latitude, subdist.center.longitude);
            subAnnotation.title      = subdist.name;
            subAnnotation.subtitle   = subdist.adcode;
            
            [self.mapView addAnnotation:subAnnotation];
            
        }
        
    }
    
}

- (void)searchDistrictWithName:(NSString *)name
{
    AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
    dist.keywords = name;
    dist.requireExtension = YES;
    
    [self.search AMapDistrictSearch:dist];
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *busStopIdentifier = @"districtIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:busStopIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:busStopIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        return poiAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *render = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        render.lineWidth   = 2.f;
        render.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.4];
        render.strokeColor = [UIColor redColor];
        
        return render;
    } else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 2.f;
        polylineRenderer.strokeColor = [UIColor magentaColor];
        
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
}

- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    NSLog(@"response: %@", response);
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self handleDistrictResponse:response];
}

@end
