//
//  AppDelegate.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

//#import "BMapKit.h"
#import <BaiduMapAPI/BMapKit.h>
#import "Reachability.h"

#import "SendLocalTools.h"
#import "RCIMClient.h"
//NSInteger newfollowcount = [dict[@"data"][@"newfollowcount"]integerValue];
//NSInteger newfriendcount = [dict[@"data"][@"newfriendcount"]integerValue];
////  NSInteger newhotcount = [dict[@"data"][@"newhotcount"]integerValue];
//NSInteger newmsgcount = [dict[@"data"][@"newmsgcount"]integerValue];
//NSInteger newtipscount = [dict[@"data"][@"newtipscount"]integerValue];


@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate,BMKLocationServiceDelegate,RCConnectDelegate,RCReceiveMessageDelegate,RCConnectionStatusDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKLocationService *locService;
@property (assign, nonatomic) BOOL isLocStart;


@property (assign, nonatomic) BOOL locSuccess;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;


@property (strong, nonatomic) NSString *RCTokenStr;
@property (assign, nonatomic) BOOL isConnect;
-(void)doConnection;


//当前网络状态
@property (strong, nonatomic) Reachability *hostReach;
@property (assign, nonatomic) BOOL isReachable;
@property (assign, nonatomic) BOOL isReachableWiFi;
@property (assign, nonatomic) BOOL isReachableWLAN;
@property (assign, nonatomic) BOOL isAutoPlay;
@property (strong, nonatomic) NSString * NetWorkStatus;
- (NSString *)currentNetWorkStatusString;

//是否处理年龄
@property (assign, nonatomic) BOOL checkUserAge;



//通讯录
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
-(void)registerXGPUSH:(NSDictionary *)launchOptions;


-(UIViewController *)getCurrentTopViewController;
-(UIViewController *)getCurrentRootViewController;

@end

