//
//  HeatmapVectorOverlayViewController.m
//  MAMapKit_3D_Demo
//
//  Created by ldj on 2019/10/14.
//  Copyright © 2019 Autonavi. All rights reserved.
//

#import "HeatMapVectorOverlayViewController.h"

@interface HeatMapVectorOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAHeatMapVectorOverlay *overlay;

@end

@implementation HeatMapVectorOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    self.mapView.zoomLevel = 8;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(35.683927, 119.518251)];
    //self.annotations = [NSMutableArray array];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"honeycomb" ofType:@"txt"];
    NSString *locationString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *locations = [locationString componentsSeparatedByString:@"\n"];
    
    NSMutableArray<MAHeatMapVectorNode *> *data = [NSMutableArray arrayWithCapacity:100];

    for (int i = 0; i < locations.count; ++i)
    {
        @autoreleasepool {
            //MAMultiPointItem *item = [[MAMultiPointItem alloc] init];
            
            NSArray *coordinate = [locations[i] componentsSeparatedByString:@","];
            
            if (coordinate.count == 3)
            {
                MAHeatMapVectorNode *node = [[MAHeatMapVectorNode alloc] init];
                node.coordinate = CLLocationCoordinate2DMake([coordinate[1] doubleValue], [coordinate[0] doubleValue]);
                node.weight = 1;
                [data addObject:node];
            }
        }
    }
    
    MAHeatMapVectorOverlayOptions *option = [[MAHeatMapVectorOverlayOptions alloc] init];
    option.inputNodes = data;
    option.size = 3000;
    option.gap = 5;
    option.type = MAHeatMapTypeHoneycomb;
    option.opacity = 0.8;
    option.maxIntensity = 0;
    NSMutableArray<UIColor *> *colors = [NSMutableArray array];
    //color: ['#ecda9a', '#efc47e', '#f3ad6a', '#f7945d', '#f97b57', '#f66356', '#ee4d5a'],
    [colors addObject:[self conversionStrColor:@"ecda9a"]];
    [colors addObject:[self conversionStrColor:@"efc47e"]];
    [colors addObject:[self conversionStrColor:@"f3ad6a"]];
    [colors addObject:[self conversionStrColor:@"f7945d"]];
    [colors addObject:[self conversionStrColor:@"f97b57"]];
    [colors addObject:[self conversionStrColor:@"f66356"]];
    [colors addObject:[self conversionStrColor:@"ee4d5a"]];
    option.colors = colors;
    
    NSMutableArray<NSNumber *> *startPoints = [NSMutableArray array];
    for(int i =0 ; i < colors.count; i ++) {
        [startPoints addObject: @(i * 1.0f / colors.count)] ;
    }
    option.startPoints = startPoints;

    self.overlay = [MAHeatMapVectorOverlay heatMapOverlayWithOption:option];
    [self.mapView addOverlay:_overlay];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAHeatMapVectorOverlay class]]) {
        MAHeatMapVectorOverlayRender *render = [[MAHeatMapVectorOverlayRender alloc] initWithHeatOverlay:overlay];
        return render;
    }

    return nil;
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    MAHeatMapVectorOverlayRender *render = (MAHeatMapVectorOverlayRender*)[self.mapView rendererForOverlay:self.overlay];
    MAHeatMapVectorItem *result = [render getHeatMapItem:coordinate];
    if(result) {
        CLLocationCoordinate2D coord = MACoordinateForMapPoint(result.center);
        NSLog(@"=== {%f,%f}, %f, %@", coord.longitude, coord.latitude, result.intensity, result.nodeIndices);
    }
}

- (UIColor *)conversionStrColor:(NSString *)colorStr
{
    if (!colorStr.length) {
        return nil;
    }
    UIColor *outColor = nil;
    if([colorStr hasPrefix:@"#"]) {
        colorStr = [colorStr substringFromIndex:1];
    }
    if(colorStr.length > 0) {
        UInt32 color = 0;
        [[NSScanner scannerWithString:colorStr] scanHexInt:(unsigned int *)&color];
        outColor = [UIColor colorWithRed:((float)(color >>16 & 0xff)) / 255
                                   green:((float)(color >>8 & 0xff)) / 255
                                    blue:((float)(color & 0xff)) / 255
                                   alpha:1.0];
    }
    return outColor;
}


@end
