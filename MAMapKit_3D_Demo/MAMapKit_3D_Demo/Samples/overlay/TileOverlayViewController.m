//
//  TileOverlayViewController.m
//  OfficialDemo3D
//
//  Created by Li Fei on 3/3/14.
//  Copyright (c) 2014 songjian. All rights reserved.
//

#import "TileOverlayViewController.h"

#import "LocalTileOverlay.h"

//MARK: remote setting
static NSString *const kUrl4IndoorTileBeginningPart = @"https://dev.indoormap.huatugz.com/xyztiles/";
static NSString *const kUrl4IndoorTileEndPart = @"indoor/{z}/{x}/{y}.png?tileSize=512&scale=2&floorId=";

//static NSString *const kTileOverlayRemoteServerTemplate = @"http://cache1.arcgisonline.cn/arcgis/rest/services/ChinaCities_Community_BaseMap_ENG/BeiJing_Community_BaseMap_ENG/MapServer/tile/{z}/{y}/{x}";

#define kTileOverlayRemoteMinZ      4
#define kTileOverlayRemoteMaxZ      20

//MARK: local setting
#define kTileOverlayLocalMinZ       11
#define kTileOverlayLocalMaxZ       13


@interface TileOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MATileOverlay *tileOverlay;

@end

@implementation TileOverlayViewController

#pragma mark - Utility

- (MATileOverlay *)creatTileOverlayWithUrl:(NSString *)url
{
    MATileOverlay *tileOverlay = nil;
    tileOverlay = [[MATileOverlay alloc] initWithURLTemplate:url];
    
    /* minimumZ 是tileOverlay的可见最小Zoom值. */
    tileOverlay.minimumZ = kTileOverlayRemoteMinZ;
    /* minimumZ 是tileOverlay的可见最大Zoom值. */
    tileOverlay.maximumZ = kTileOverlayRemoteMaxZ;
    
    /* boundingMapRect 是用来 设定tileOverlay的可渲染区域. */
    tileOverlay.boundingMapRect = MAMapRectWorld;
    
    return tileOverlay;
}

- (void)updateTileOverlayWithUrl:(NSString *)url{
    /* 删除之前的楼层. */
    [self.mapView removeOverlay:self.tileOverlay];
    
    /* 添加新的楼层. */
    self.tileOverlay = [self creatTileOverlayWithUrl:url];
    
    [self.mapView addOverlay:self.tileOverlay];
}

#pragma mark - MAMapViewDelegate

- (void)mapViewRegionChanged:(MAMapView *)mapView{
//    NSLog(@"%s,center:%f,%f", __func__,mapView.centerCoordinate.longitude, mapView.centerCoordinate.latitude);
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MATileOverlay class]])
    {
        MATileOverlayRenderer *renderer = [[MATileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
//    NSLog(@"zoomLvl:%.1f", mapView.zoomLevel);
}

-(void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois{
    MATouchPoi *lP = pois.firstObject;
    NSLog(@"%s,%@,%f,%f", __func__,lP.name, lP.coordinate.longitude, lP.coordinate.latitude);
}

-(void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSLog(@"coor:%f,%f-%s", coordinate.longitude, coordinate.latitude,__func__);
    
    static BOOL isOddTap = YES;
    if (isOddTap) {
        [self updateTileOverlayWithUrl:[NSString stringWithFormat:@"%@%@%@",kUrl4IndoorTileBeginningPart,kUrl4IndoorTileEndPart,@"1"]];
    }else{
        [self updateTileOverlayWithUrl:[NSString stringWithFormat:@"%@%@%@",kUrl4IndoorTileBeginningPart,kUrl4IndoorTileEndPart,@"2"]];
    }
    
    isOddTap = !isOddTap;
}

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

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
    
    self.mapView.zoomLevel = kTileOverlayRemoteMaxZ-1;
    
    
    //控制是否可以旋转视角来显示3d效果
    self.mapView.rotateCameraEnabled = NO;
    
    //控制3d建筑是否显示
//    self.mapView.showsBuildings = NO;
    
    [self.view addSubview:self.mapView];
    
    
    /*宏太智慧谷,113.416927,23.173958
     珠江新城 113.32610067743077,23.11623425763484
     */
    CLLocationDistance lat = 23.173958;
    CLLocationDistance log = 113.416927;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat, log) animated:YES];
    
//    MATileOverlay *outDoorTile = [self creatTileOverlayWithUrl:kUrl4OutDoorTile];
//    [self.mapView addOverlay:outDoorTile level:MAOverlayLevelAboveRoads];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateTileOverlayWithUrl:[NSString stringWithFormat:@"%@%@%@",kUrl4IndoorTileBeginningPart,kUrl4IndoorTileEndPart,@"0"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

@end
