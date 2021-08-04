//
//  RoutePlanFutureDriveViewController.m
//  MAMapKit_3D_Demo
//
//  Created by ldj on 2019/4/26.
//  Copyright © 2019 Autonavi. All rights reserved.
//

#import "RoutePlanFutureDriveViewController.h"
#import "CommonUtility.h"
#import "MANaviRoute.h"
#import "MANaviDatePicker.h"
#import "MANaviTimeInfoView.h"

static const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
static const NSInteger RoutePlanningPaddingEdge                    = 20;

@interface RoutePlanFutureDriveViewController() <MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,MANaviDatePickerDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapRoute *route;

@property (nonatomic, strong) NSArray<AMapFutureTimeInfo *> *timeInfos;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@property (nonatomic, copy) NSString *startTime;

@property(nonatomic,strong) UITableView *timeListTableView;

@property(nonatomic,strong) UIView *bottomView;

@property(nonatomic,strong) MANaviTimeInfoView *leftView;
@property(nonatomic,strong) MANaviTimeInfoView *middleView;
@property(nonatomic,strong) MANaviTimeInfoView *rightView;

@property(nonatomic,strong) MANaviDatePicker *datePickerView;

@property(nonatomic,assign) BOOL isFirstLoad;
@property(nonatomic,assign) BOOL isClickedArrivalTime;

@property(nonatomic,assign) NSInteger arrivalTime;


@end

@implementation RoutePlanFutureDriveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.startCoordinate        = CLLocationCoordinate2DMake(39.993291, 116.473188);
    self.destinationCoordinate  = CLLocationCoordinate2DMake(39.940474, 116.355426);
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"到达时间"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(arrivalTimeAction)];
    
    [self initBottomView];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    [self addDefaultAnnotations];
    
    [self searchRoutePlanningDrive:nil];
    
    [self initTableView];
}

- (void)initBottomView
{
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 250, CGRectGetWidth(self.view.bounds), 250)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    _bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_bottomView];
    CGFloat width = CGRectGetWidth(self.bottomView.bounds)/3;
    self.leftView = [[MANaviTimeInfoView alloc] initWithFrame:CGRectMake(0, 0, width, 70)];
    [_bottomView addSubview:_leftView];
    self.middleView = [[MANaviTimeInfoView alloc] initWithFrame:CGRectMake(width, 0, width, 70)];
    [_bottomView addSubview:_middleView];
    self.rightView = [[MANaviTimeInfoView alloc] initWithFrame:CGRectMake(width*2, 0, width, 70)];
    [_bottomView addSubview:_rightView];
    
    UIButton *timeButton = [[UIButton alloc] initWithFrame:self.leftView.frame];
    timeButton.backgroundColor = [UIColor clearColor];
    [timeButton addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:timeButton];
    
}

- (void)btnAction
{
    _isClickedArrivalTime = NO;
    [MANaviDatePicker showCustomDatePickerAtView:self.view delegate:self];
}

- (void)choosedDate:(NSDate *)date
{
    if (_isClickedArrivalTime) {
        [self presentArrivalRoute:date];
        return;
    }
    [self searchRoutePlanningDrive:date];
}

- (void)arrivalTimeAction
{
    _isClickedArrivalTime = YES;
    [MANaviDatePicker showCustomDatePickerAtView:self.view delegate:self];
}

- (void)presentArrivalRoute:(NSDate *)date
{
    AMapFutureTimeInfo *info =self.timeInfos.firstObject;
    NSInteger duration = info.elements.count ? info.elements[0].duration : 30;
    //NSDate *date = timeDate ? : [NSDate dateWithTimeIntervalSinceNow:3600];
    NSTimeInterval a = [date timeIntervalSince1970];
    self.arrivalTime = a;
    a -= (duration + 10) * 60;
    //NSString *timeString = [NSString stringWithFormat:@"%0.f", a];
    NSDate *arrivalTime = [NSDate dateWithTimeIntervalSince1970:a];
    [self searchRoutePlanningDrive:arrivalTime];
}

- (void)updateBottomView
{
    AMapFutureTimeInfo *info =self.timeInfos[self.currentCourse];
    if (!info.elements.count) {
        return;
    }
    [_leftView updateTime:[self getCurrentTime:info.startTime] timeLabelStr:@"出发时间"];
    _leftView.timeLabel.textColor = [UIColor blueColor];
    
    NSInteger hour = info.elements[0].duration;
    double allTime = [info.startTime doubleValue] + hour*60;
    [_middleView updateTime:[self getCurrentTime:[NSString stringWithFormat:@"%f",allTime]] timeLabelStr:@"预计到达"];
    
    NSInteger pathIndex = info.elements[0].pathindex;
    NSInteger distance = 0;
    if (pathIndex < self.route.paths.count) {
        distance = self.route.paths[pathIndex].distance;
    }
    [_rightView updateTime:[NSString stringWithFormat:@"%ld公里",distance/1000] timeLabelStr:@"总里程"];
}

- (void)initTableView
{
    float width = (CGRectGetWidth(self.bottomView.frame) - 180) / 2;
    self.timeListTableView = [[UITableView alloc]initWithFrame:CGRectMake(width, 70 - width,180,self.view.frame.size.width) style:UITableViewStylePlain];
    self.timeListTableView.dataSource = self;
    self.timeListTableView.delegate = self;
    self.timeListTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    self.timeListTableView.showsVerticalScrollIndicator = NO;
    self.timeListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bottomView addSubview:self.timeListTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.timeInfos.count) {
        return 0;
    }
    return self.timeInfos.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"mapCell";
    TimerInfoCell *cell = (TimerInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[TimerInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row < self.timeInfos.count) {
        [cell updateTime:self.timeInfos[indexPath.row].elements[0].duration startTime:[self getCurrentTime:self.timeInfos[indexPath.row].startTime]];
    }
    if (indexPath == [tableView indexPathForSelectedRow]) {
        cell.timeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)path
{
    //设置到达时间后，时间列表不可点击
    if (_isClickedArrivalTime) {
        return nil;
    }
    return path;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentCourse != indexPath.row) {
        self.currentCourse = indexPath.row;
        [self presentCurrentCourse];
    }
    TimerInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.timeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    if (_isFirstLoad) {
        TimerInfoCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.timeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.4];
        _isFirstLoad = NO;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimerInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.timeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.4];
}

- (NSString *)getCurrentTime:(NSString *)timestamp

{
    if (!timestamp.length) {
        return @"";
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *dateString = [formatter stringFromDate:date];
        return dateString;
    }
}

- (void)searchRoutePlanningDrive:(NSDate *)timeDate
{
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapFutureRouteSearchRequest *navi = [[AMapFutureRouteSearchRequest alloc] init];
    
    navi.destinationId = @"BV10001595";
    navi.destinationtype = @"150500";
    //    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    NSDate *date = timeDate ? : [NSDate dateWithTimeIntervalSinceNow:3600];
    NSTimeInterval a = [date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];
    navi.beginTime = timeString;
    navi.interval = 900;
    navi.timeCount = 10;
    
    [self.search AMapFutureRouteSearch:navi];
}

/* 展示当前路线方案. */
- (void)presentCurrentCourse
{
    [self updateBottomView];
    MANaviAnnotationType type = MANaviAnnotationTypeFutureDrive;
    AMapFutureTimeInfoElement *element = self.timeInfos[self.currentCourse].elements[0];
    self.naviRoute = [MANaviRoute naviRouteForFuturePath:element withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
    [self.naviRoute addToMapView:self.mapView];
    
        /* 缩放地图使其适应polylines的展示. */
        [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                            edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, 200, RoutePlanningPaddingEdge)
                               animated:YES];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
}

- (void)onFutureRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapFutureRouteSearchResponse *)response
{
    if (!response.paths.count || !response.timeInfos.count) {
        return;
    }
    AMapRoute *route = [[AMapRoute alloc] init];
    NSMutableArray<AMapPath *> *allPaths = [NSMutableArray array];
    NSMutableArray<AMapPath *> *paths = [NSMutableArray arrayWithArray:response.paths];
    
    for (int i = 0; i < response.timeInfos.count; i ++) {
        AMapFutureTimeInfo *timeInfo = response.timeInfos[i];
        if (!timeInfo.elements.count) {
            continue;
        }
        AMapFutureTimeInfoElement *element = timeInfo.elements[0];
        NSInteger pathIndex = element.pathindex;
        if (pathIndex >= paths.count) {
            continue;
        }
        AMapPath *amapPath = paths[pathIndex];
        
        [allPaths addObject:amapPath];
        
    }
    
    
    route.paths = allPaths;
    //不显示交通状况
    self.route = route;
    
    self.timeInfos = response.timeInfos;
    
    if (response.timeInfos.count) {
        [self presentCurrentCourse];
    }
    [self.timeListTableView reloadData];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];

    if (_isClickedArrivalTime) {
        //若设置了到达时间
       path = [self searchProperRouteForArrivalTime];
    }
    
    [self.timeListTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    if ([self.timeListTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.timeListTableView.delegate tableView:self.timeListTableView didSelectRowAtIndexPath:path];
    }
    self.isFirstLoad = YES;
}

- (NSIndexPath *)searchProperRouteForArrivalTime
{
    NSInteger pathIndex = 0;
    NSInteger index = 0;
    NSInteger dela = NSIntegerMin;
    for (AMapFutureTimeInfo *info in _timeInfos) {
        double allTime = info.startTime.doubleValue + info.elements.firstObject.duration * 60;
        if (allTime <= _arrivalTime) {
            NSInteger difference = _arrivalTime - allTime;
            if (index == 0 || dela >= difference) {
                dela = difference;
                pathIndex = index;
            }
        } else {
            break;
        }
        index ++;
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:pathIndex inSection:0];
    return path;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 8;
        polylineRenderer.lineDashType = kMALineDashTypeSquare;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 8;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        
        return polylineRenderer;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]])
        {
            switch (((MANaviAnnotation*)annotation).type)
            {
                case MANaviAnnotationTypeRailway:
                    poiAnnotationView.image = [UIImage imageNamed:@"railway_station"];
                    break;
                    
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"car"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
                    poiAnnotationView.image = [UIImage imageNamed:@"man"];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            /* 起点. */
            if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
            }
            /* 终点. */
            else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
            }
            
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}
@end
