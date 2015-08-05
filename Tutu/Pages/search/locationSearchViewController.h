//
//  locationSearchViewController.h
//  Tutu
//
//  Created by gexing on 15/4/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NavBaseController.h"
#import <CoreLocation/CoreLocation.h>
//#import "BMKPoiSearch.h"
#import <BaiduMapAPI/BMKPoiSearch.h>
@protocol localDelegate <NSObject>

-(void)searchPoiItemClick:(BMKPoiInfo *) info;


@end

@interface locationSearchViewController : NavBaseController<BMKLocationServiceDelegate>
{
    BMKPoiSearch *_poisearch;
}

@property(nonatomic,strong) BMKLocationService *locService;
@property(nonatomic,assign)id<localDelegate>delegate;
@property(nonatomic,strong)UITableView *mainTable;

@property(nonatomic,strong) BMKPoiInfo *poiInfo;


@end
