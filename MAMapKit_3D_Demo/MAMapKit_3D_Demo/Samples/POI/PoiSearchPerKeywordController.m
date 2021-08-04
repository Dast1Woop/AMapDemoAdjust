//
//  PoiSearchPerKeywordController.m
//  MAMapKit_2D_Demo
//
//  Created by shaobin on 16/8/11.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "PoiSearchPerKeywordController.h"
#import "POIAnnotation.h"
#import "PoiDetailViewController.h"
#import "CommonUtility.h"


@interface PoiSearchPerKeywordController ()<MAMapViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) MAAllResultsSearch *search;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation PoiSearchPerKeywordController
#pragma mark - Life Cycle

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
    
    self.search = [[MAAllResultsSearch alloc] init];
    
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
    
    [self searchPoiByKeyword:self.searchBar.text];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MAAnnotation> annotation = view.annotation;
    
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        POIAnnotation *poiAnnotation = (POIAnnotation*)annotation;
        
        PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
        detail.poi = poiAnnotation.poi;
        
        /* 进入POI详情页面. */
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        static NSString *poiIdentifier = @"poiIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (response.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    /* 将结果以annotation的形式加载到地图上. */
    [self.mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:poiAnnotations animated:NO];
    }
}

- (void)onPoiSearchDone:(AMapPOISearchResponse_AllResults *)allResult {
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSMutableArray *poiAnnotations = [NSMutableArray array];
    for(AMapPOISearchResponse_OnePage *page in allResult.allPages) {
        [page.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        }];
    }
    
    /* 将结果以annotation的形式加载到地图上. */
    [self.mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:poiAnnotations animated:NO];
    }
}

#pragma mark - Utility
/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword:(NSString *)keyword
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    request.city = @"北京";
    request.requireSubPOIs      = YES;
    request.requireExtension = YES;
    request.offset = 50;
    
    __weak typeof(self) weakSelf = self;
    [self.search searchAllPOIsWith:request resultCallback:^(AMapPOISearchResponse_AllResults *result) {
        [weakSelf onPoiSearchDone:result];
    }];
}

#pragma mark - Handle Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation AMapPOISearchResponse_OnePage
@end
@implementation AMapPOISearchResponse_AllResults
@end

@interface MAAllResultsSearch ()<AMapSearchDelegate>
@property (nonatomic, copy) MAKeyWordsPOISearchCallback resultCallback;
@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *firstReq;
@property (nonatomic, strong) AMapPOISearchResponse_AllResults *allAroundPoiResults;

@end

@implementation MAAllResultsSearch

- (id)init {
    self = [super init];
    if(self) {
        self.searchAPI = [[AMapSearchAPI alloc] init];
        self.searchAPI.delegate = self;
    }
    
    return self;
}

- (void)searchAllPOIsWith:(AMapPOIKeywordsSearchRequest *)req resultCallback:(MAKeyWordsPOISearchCallback)resultCallback {
    self.firstReq = req;
    self.resultCallback = resultCallback;
    [self.searchAPI AMapPOIKeywordsSearch:req];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    BOOL allFinished = YES;
    
    if(self.firstReq == request) {
        self.allAroundPoiResults = [[AMapPOISearchResponse_AllResults alloc] init];
        self.allAroundPoiResults.offset = request.offset;
        self.allAroundPoiResults.totalCount = response.count;
        self.allAroundPoiResults.allPages = [NSMutableArray array];
        
        AMapPOISearchResponse_OnePage *page = [[AMapPOISearchResponse_OnePage alloc] init];
        page.pageNum = 1;
        page.pois = response.pois;
        page.status = 0;
        page.offset = request.offset;
        [self.allAroundPoiResults.allPages addObject:page];
        
        NSInteger pageCount = response.count / request.offset;
        if(response.count % request.offset > 0) {
            pageCount += 1;
        }
        
        if(pageCount > 1) {
            allFinished = NO;
        }
        
        for(int i = 2; i <= pageCount; ++i) {
            AMapPOISearchResponse_OnePage *page = [[AMapPOISearchResponse_OnePage alloc] init];
            page.pageNum = i;
            page.status = -1;
            page.offset = request.offset;
            [self.allAroundPoiResults.allPages addObject:page];
            
            AMapPOIKeywordsSearchRequest *remainReq = [[AMapPOIKeywordsSearchRequest alloc] init];
            remainReq.keywords = self.firstReq.keywords;
            remainReq.location = self.firstReq.location;
            remainReq.city = self.firstReq.city;
            remainReq.cityLimit = self.firstReq.cityLimit;
            
            remainReq.types = self.firstReq.types;
            remainReq.sortrule = self.firstReq.sortrule;
            remainReq.building = self.firstReq.building;
            remainReq.page = i;
            remainReq.offset = self.firstReq.offset;
            remainReq.requireSubPOIs = self.firstReq.requireSubPOIs;
            remainReq.requireExtension = self.firstReq.requireExtension;
            
            [self.searchAPI AMapPOIKeywordsSearch:remainReq];
        }
        
    } else {
        NSInteger pageNum = request.page;
        AMapPOISearchResponse_OnePage *page = [self.allAroundPoiResults.allPages objectAtIndex:pageNum - 1];
        page.status = 0;
        page.pois = response.pois;
        
        for(AMapPOISearchResponse_OnePage *page in self.allAroundPoiResults.allPages) {
            if(page.status == -1) {
                allFinished = NO;
                break;
            }
        }
        
    }
    
    if(allFinished) {
        if(self.resultCallback) {
            self.resultCallback(self.allAroundPoiResults);
        }
    }
    
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
    
    AMapPOISearchBaseRequest *req = (AMapPOISearchBaseRequest *)request;
    NSInteger pageNum = req.page;
    AMapPOISearchResponse_OnePage *page = [self.allAroundPoiResults.allPages objectAtIndex:pageNum - 1];
    page.status = 1;
}

@end

