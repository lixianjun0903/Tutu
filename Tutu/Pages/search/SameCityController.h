//
//  SameCityController.h
//  Tutu
//
//  Created by zhangxinyao on 14-11-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import <CoreLocation/CoreLocation.h>
//#import "BMKLocationService.h"
#import <BaiduMapAPI/BMKLocationService.h>
#import "ListMenuView.h"

@interface SameCityController : BaseController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,CLLocationManagerDelegate,BMKLocationServiceDelegate,ListMenuDelegate>

@property(nonatomic,assign) BOOL fromRoot;
@property(nonatomic)NSInteger comefrom;

@property(nonatomic,strong) NSString *province;
@property(nonatomic,strong) NSString *city;

@property(nonatomic,assign) double latitude;
@property(nonatomic,assign) double longitude;

@property(nonatomic,retain)CLLocationManager *locationManager;
@property (strong, nonatomic) BMKLocationService *locService;

@end
