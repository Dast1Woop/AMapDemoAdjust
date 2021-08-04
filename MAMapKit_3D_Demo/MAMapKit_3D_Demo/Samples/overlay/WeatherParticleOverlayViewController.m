//
//  WeatherParticleOverlayViewController.m
//  MAMapKit_3D_Demo
//
//  Created by liubo on 2018/9/21.
//  Copyright © 2018年 Autonavi. All rights reserved.
//

#import "WeatherParticleOverlayViewController.h"


@interface WeatherParticleOverlayViewController ()<MAMapViewDelegate>
{
    NSMutableArray<MAPointAnnotation *> *_provinceAnnotations;
}

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, assign) BOOL showDetailWeather;
@property (nonatomic, assign) int currentShowIndex;

@end

@implementation WeatherParticleOverlayViewController

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
    self.mapView.mapType = MAMapTypeStandardNight;
    
    self.currentShowIndex = -1;
    
    [self.view addSubview:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addPorvinceAnnotation];
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
}

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Methods

- (void)addPorvinceAnnotation {
    if ([_provinceAnnotations count] <= 0) {
        _provinceAnnotations = [[NSMutableArray alloc] init];
        
        const int count = 11;
        CLLocationCoordinate2D coordinates[count] = {
            {39.920263, 116.399792},
            {38.064304, 117.119396},
            {34.276219, 108.942478},
            {36.630675, 101.756733},
            {30.663010, 104.073475},
            {26.603562, 106.687534},
            {31.224832, 121.416081},
            {30.272996, 120.025967},
            {23.146981, 113.226803},
            {28.209643, 113.022354},
            {33.005993, 112.610367},
        };
        
        for (int i = 0; i < count; ++i) {
            MAPointAnnotation *anotaiton = [[MAPointAnnotation alloc] init];
            anotaiton.coordinate = coordinates[i];
            [_provinceAnnotations addObject:anotaiton];
        }
    }
    
    [self.mapView addAnnotations:_provinceAnnotations];
}

- (MAParticleOverlayType)weatherTypeForIndex:(NSUInteger)index {
    return (MAParticleOverlayType)(index%4+1);
}

- (UIImage *)annotationImageForType:(MAParticleOverlayType)type {
    switch (type) {
        case MAParticleOverlayTypeSunny:
            return [UIImage imageNamed:@"weather_qing"];
            break;
        case MAParticleOverlayTypeRain:
            return [UIImage imageNamed:@"weather_baoyu"];
            break;
        case MAParticleOverlayTypeSnowy:
            return [UIImage imageNamed:@"weather_daxue"];
            break;
        case MAParticleOverlayTypeHaze:
            return [UIImage imageNamed:@"weather_wumai"];
            break;
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

- (void)updateMapWeather:(BOOL)showDetailWeather {
    self.showDetailWeather = showDetailWeather;
    
    if (self.showDetailWeather) {
        if ([self.mapView.annotations count] > 0) {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        
        ///获取屏幕范围内第一个有效的经纬度
        int indexToShow = self.currentShowIndex;
        for (int i = 0; i < [_provinceAnnotations count]; ++i) {
            MAMapPoint mapPoint = MAMapPointForCoordinate([[_provinceAnnotations objectAtIndex:i] coordinate]);
            if (MAMapRectContainsPoint(self.mapView.visibleMapRect, mapPoint)) {
                indexToShow = i;
                break;
            }
        }
        
        if (self.currentShowIndex != indexToShow) {
            ///如果和当前显示的不一致则更新
            self.currentShowIndex = indexToShow;
            [self.mapView removeOverlays:self.mapView.overlays];
            [self addWeatherOverlayWithType:[self weatherTypeForIndex:self.currentShowIndex]];
        } else {
            ///一致的话，判断是否在屏幕范围内，不在的话则移除当前显示的天气
            if (self.currentShowIndex >= 0) {
                MAMapPoint mapPoint = MAMapPointForCoordinate([[_provinceAnnotations objectAtIndex:self.currentShowIndex] coordinate]);
                if (!MAMapRectContainsPoint(self.mapView.visibleMapRect, mapPoint)) {
                    [self.mapView removeOverlays:self.mapView.overlays];
                    self.currentShowIndex = -1;
                }
            }
        }
        
    } else {
        if ([self.mapView.overlays count] > 0) {
            [self.mapView removeOverlays:self.mapView.overlays];
            self.currentShowIndex = -1;
        }
        
        if ([self.mapView.annotations count] <= 0) {
            [self addPorvinceAnnotation];
        }
    }
}

#pragma mark - Delegate

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self updateMapWeather:(self.mapView.zoomLevel > 8.f)];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    MAPointAnnotation *annotation = (MAPointAnnotation *)[view annotation];
    
    [self.mapView setCenterCoordinate:annotation.coordinate];
    [self.mapView setZoomLevel:10.f];
}

- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.animatesDrop = NO;
        annotationView.draggable = NO;
        annotationView.image = [self annotationImageForType:[self weatherTypeForIndex:[_provinceAnnotations indexOfObject:annotation]]];
        
        return annotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAParticleOverlay class]]) {
        MAParticleOverlayRenderer *particleOverlayRenderer = [[MAParticleOverlayRenderer alloc] initWithParticleOverlay:overlay];
        return particleOverlayRenderer;
    }
    return nil;
}

@end
