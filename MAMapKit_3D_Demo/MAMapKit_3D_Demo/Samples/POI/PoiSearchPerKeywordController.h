//
//  PoiSearchPerKeywordController.h
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/8/11.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AMapPOISearchResponse_OnePage : NSObject

@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger status; //-1:未开始 0:成功 1:失败
@property (nonatomic, strong) NSArray<AMapPOI*> *pois;

@end

@interface AMapPOISearchResponse_AllResults : NSObject

@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableArray<AMapPOISearchResponse_OnePage*> *allPages;

@end

typedef void(^MAKeyWordsPOISearchCallback)(AMapPOISearchResponse_AllResults* result);

@interface MAAllResultsSearch : NSObject

@property (nonatomic, strong) AMapSearchAPI *searchAPI;

- (void)searchAllPOIsWith:(AMapPOIKeywordsSearchRequest *)req resultCallback:(MAKeyWordsPOISearchCallback)resultCallback;

@end

@interface PoiSearchPerKeywordController : UIViewController

@end
