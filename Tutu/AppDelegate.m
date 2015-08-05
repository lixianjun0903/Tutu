//
//  AppDelegate.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AppDelegate.h"

#import "GuideController.h"
#import "LoginViewController.h"

#import "UMSocialQQHandler.h"
#import "CacheManager.h"

#import "ASIDownloadCache.h"
#import "RequestTools.h"
#import "XGPush.h"
#import "XGSetting.h"
#import "AreaDBHelper.h"

#import "TopicDetailController.h"
#import "MyFriendViewController.h"
#import "RCLetterController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UMSocialWechatHandler.h"
#import "UserDetailController.h"
#import "MobClick.h"
#import "UMSocialSinaHandler.h"
#import "SVWebViewController.h"

#import "RCIMClient.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <AdSupport/AdSupport.h>

#import "DownLoadManager.h"
#import "UserInfoDB.h"

#import "SameCityController.h"
#import "ListTopicsController.h"
#import "FansListController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
    //自定义缓存
    ASIDownloadCache *cache = [ASIDownloadCache sharedCache];
    
    //设置缓存路径
    NSString *documentDirectory = getLibraryFilePath(@"/Caches/resource");
    [cache setShouldRespectCacheControlHeaders:YES];
    [cache setStoragePath:documentDirectory];
    [cache setDefaultCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    
    
    [MobClick startWithAppkey:UMobClickAPI];
    [MobClick setAppVersion:[SysTools getAppVersion]];
    
    self.checkUserAge=YES;
    [MobClick updateOnlineConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mobupdateConfig:) name:UMOnlineConfigDidFinishedNotification object:nil];

    NSString *appKey=@"544f704ffd98c5a651002b48";
    //友盟分享
    [UMSocialData setAppKey:appKey];
    
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [self macString];
    NSString * idfa = [self idfaString];
    NSString * idfv = [self idfvString];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey, deviceName, mac, idfa, idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];

    
    //    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:TencentOpenAPI appKey:@"Z6sykUsn8G08ujo2" url:@"tutu.xinqing.com"];
    //    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wx8fa99b405996914a" appSecret:@"779948ea2c933e2e1a6d65b48b680763" url:nil];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    //百度定位
    BMKMapManager *_mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"nx3jF4ZG9hQa64HInBj84wEf" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    
    if(self.NetWorkStatus==nil){
        self.NetWorkStatus = [self currentNetWorkStatusString];
    }
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
    [self.hostReach startNotifier];  //开始监听，会启动一个run loop
    
    
    //注册推送，信鸽和融云
    [self registerXGPUSH:launchOptions];
    
    //开启本地服务
//    [[DownLoadManager getInstance] startServer];
    
    // 清理缓存
    [[CacheManager sharedCacheManager] clearImageAndVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doShareNotice:) name:Notification_Topic_Send_Success object:nil];
    
    //判断是否登录、是否显示引导页
    [self presentDPHelpPage];
    self.isAutoPlay = ![UserDefaults boolForKey:UserDefaults_is_Close_AutoPlay_Under_Wifi];
    return YES;
}


//判断是否登录，以及是否第一次启动
-(void)presentDPHelpPage
{
    
    id flag = [SysTools getValueFromNSUserDefaultsByKey:DP_GUIDE_FLAG];
    if (is_null(flag) ) {
        
        GuideController * guidePagesController = [[GuideController alloc] init];
        [self.window setRootViewController:guidePagesController];
    }else{
        if(![[LoginManager getInstance] isLogin]){
//            LoginViewController * login = [[LoginViewController alloc] init];
//            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:login];
//            nav.navigationBarHidden=YES;
//            [self.window setRootViewController:nav];
        }else{
            if([[LoginManager getInstance] getLoginInfo].token!=nil && ![@"" isEqual:[[LoginManager getInstance] getLoginInfo].token]){
                self.RCTokenStr=[[LoginManager getInstance] getLoginInfo].token;
                [self doConnection];
            }else{
                //重新获取token
                [[SendLocalTools getInstance] connetIM];
            }
        }
        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UIViewController *controller = [storyboard instantiateInitialViewController];
//        self.window.rootViewController = controller;
        
    }
}


//注册信鸽推送
-(void)registerXGPUSH:(NSDictionary *)launchOptions{
    [RCIMClient init:RCKey deviceToken:nil];
    
    [XGPush startApp:2200053278 appKey:@"IYA28LJT953H"];
    
    if([[LoginManager getInstance] isLogin]){
        [XGPush setAccount:[[LoginManager getInstance] getUid]];
    }
    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
    
    
    //角标清0,清空未读消息
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //清除所有通知(包含本地通知)
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [XGPush handleLaunching:launchOptions];
    
    if(launchOptions!=nil){
        NSDictionary *userInfo=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if(userInfo!=nil){
            
            //获取动态数量
            if([userInfo objectForKey:@"tipcount"]!=nil){
                [[RequestTools getInstance] doSetNewtipscount:CheckNilValue([userInfo objectForKey:@"tipcount"])];
            }

            // 做跳转的处理，当应用已结束，会调用此事件
            [self parsePush:userInfo type:1 state:UIApplicationStateInactive];
        }
    }
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([@"tencent1103429136" isEqual:url.scheme]){
        return [TencentOAuth HandleOpenURL:url];
    }
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if([@"tencent1103429136" isEqual:url.scheme]){
        return [TencentOAuth HandleOpenURL:url];
    }
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    application.applicationIconBadgeNumber=[[RequestTools getInstance] getAllNewsNum];

    
    //进入后台
    [[RCIMClient sharedRCIMClient] disconnect:NO];
    self.isConnect=NO;
    WSLog(@"进入后台：断开连接");
    
    
    //退出应用，直接清理缓存
    [[CacheManager sharedCacheManager] cleanAllCache];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)applicationDidBecomeActive:(UIApplication *)application
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MobClick updateOnlineConfig];
        //是否启用了定位服务的权限
        if ([SysTools isLocatonServicesAvailable]) {
            //重新获取位置
            if(_locService!=nil && !self.isLocStart){
                self.isLocStart=YES;
                [_locService startUserLocationService];
                
            }
        }
        
        //进入前台
        WSLog(@"如果没有连接，则建立连接%d",self.isConnect);
        if(!self.isConnect){
            [self doConnection];
        }
    });
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    //删除推送列表中的这一条
    [XGPush delLocalNotification:notification];
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_

//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
    
//    // Register to receive notifications.
//    [application registerForRemoteNotifications];
    
}

//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
    }
    // Handle the actions.
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
    completionHandler();
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:deviceToken];
    
    [SysTools syncNSUserDeafaultsByKey:AppToken withValue:deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"deviceTokenStr is %@",deviceTokenStr);
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    
    NSLog(@"%@",str);
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    
    
    NSString *action=[userInfo objectForKey:@"action"];
    UIViewController *controller=nil;
    if([self getCurrentRootViewController]!=nil){
        controller=[[self getCurrentRootViewController].childViewControllers objectAtIndex:[self getCurrentRootViewController].childViewControllers.count-1];
    }
    
    //私信页面和屏蔽私信推送不提醒
    if(action!=nil && (([XG_TYPE_MESSAGE isEqual:action] && controller!=nil && [controller isKindOfClass:[RCLetterController class]]) || [XG_TYPE_UNBLOCK isEqual:action] || [XG_TYPE_BLOCK isEqual:action])){
        WSLog(@"当前push不播放声音和振动");
    }else{
        if([SysTools isNotificationSoundOpen]){
            
                SystemSoundID soundID;
                NSURL *filePath   = [[NSBundle mainBundle] URLForResource:@"push" withExtension: @"m4a"];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
                AudioServicesPlaySystemSound(soundID);
            
        }
        if ([SysTools isNotificationShakeing]) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }
    
    
    //获取动态数量
    if([userInfo objectForKey:@"tipcount"]!=nil){
        [[RequestTools getInstance] doSetNewtipscount:CheckNilValue([userInfo objectForKey:@"tipcount"])];
    }

//    WSLog(@"%@",userInfo);
    //发送通知，当前有消息来了
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_RECEIVE object:nil];
    
    
    [self parsePush:userInfo type:2 state:application.applicationState];
}

#pragma mark 定位
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    NSLog(@"heading is %d--%f---%f",userLocation.isUpdating,userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f  %@,%@",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude,userLocation.title,userLocation.description);
    NSString *latitude=[NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    NSString *longitude=[NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    [[SendLocalTools getInstance] sendLocalToServer:latitude lon:longitude];
    
    
    //停止定位
    [_locService stopUserLocationService];
}



/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser{
    WSLog(@"开始定位：");
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser{
    
    self.isLocStart=NO;
    //上传通讯录
    [[SendLocalTools getInstance] sendAddresBookSuccessCallback:nil startCallBack:nil errorCallback:nil finishCallback:nil];
}
-(void)didFailToLocateUserWithError:(NSError *)error{
    //error =1 
//    WSLog(@"定位失败：%d,%@,%@,%@",error.code,error.domain,error.userInfo,error);
    //上传通讯录
    [[SendLocalTools getInstance] sendAddresBookSuccessCallback:nil startCallBack:nil errorCallback:nil finishCallback:nil];
    
}


#pragma mark 百度授权
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
//        WSLog(@"联网成功");
    }
    else{
//        WSLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
//        WSLog(@"授权成功");
        
        _locService=[[BMKLocationService alloc] init];
        _locService.delegate=self;
        [_locService startUserLocationService];
        self.isLocStart=YES;
    }
    else {
//        WSLog(@"onGetPermissionState %d",iError);
    }
}

//添加百度统计，主要为了获取错误日志详细信息
//-(void)addBaiduTongji{
//    //http://mtj.baidu.com/
//    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
//    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
//    statTracker.channelId = @"ReplaceMeWithYourChannel";//设置您的app的发布渠道
//    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch;//根据开发者设定的发送策略,发送日志
//    statTracker.logSendInterval = 1;  //为1时表示发送日志的时间间隔为1小时,当logStrategy设置为BaiduMobStatLogStrategyCustom时生效
//    statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
//    statTracker.sessionResumeInterval = 10;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
//    statTracker.shortAppVersion  = [SysTools getAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
//    statTracker.enableDebugOn = NO; //调试的时候打开，会有log打印，发布时候关闭
//    [statTracker startWithAppId:@"c47866d48d"];//设置您在mtj网站上添加的app的appkey,此处AppId即为应用的appKey
//}

-(UIViewController *)getCurrentTopViewController{
    UIViewController *controller=nil;
    if([self getCurrentRootViewController]!=nil){
        controller=[[self getCurrentRootViewController].childViewControllers objectAtIndex:[self getCurrentRootViewController].childViewControllers.count-1];
    }
    return controller;
}

-(UIViewController *)getCurrentRootViewController {
    
    UIViewController *result;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else result = topWindow.rootViewController;
    return result;
}



-(void)parsePush:(NSDictionary *)userInfo type:(int) fromType state:(UIApplicationState) curState{
    WSLog(@"%@",userInfo);
    if(![[LoginManager getInstance] isLogin]){
        return;
    }
    UIViewController *controller=nil;
    if([self getCurrentRootViewController]!=nil){
        controller=[[self getCurrentRootViewController].childViewControllers objectAtIndex:[self getCurrentRootViewController].childViewControllers.count-1];
    }
    //应用已死
    if(fromType==1){
        controller=nil;
    }
    
    
    NSString *action=[userInfo objectForKey:@"action"];
    //不管是否在前台，都需要发送通知
    //聊天
    //        if([XG_TYPE_MESSAGE isEqual:action]){
    //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_MESSAGE object:userInfo];
    //        }
    
    //添加好友
    if([XG_TYPE_ADD_FRIENDS isEqual:action]){
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_ADDFRIEND object:userInfo];
    }
    
    //赞
    if([XG_TYPE_ZAN isEqual:action] || [XG_TYPE_ZAN_COMMENT isEqual:action] || [XG_TYPE_ZAN_USER isEqual:action]){
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_ADDZAN object:userInfo];
    }
    
    //评论
    if([XG_TYPE_COMMENT isEqual:action]){
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_ADDCOMMENT object:userInfo];
    }
    
    
    if([XG_TYPE_BLOCK isEqual:action] || [XG_TYPE_UNBLOCK isEqual:action]){
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_BLOCKORUN object:userInfo];
    }
    
    //如果当前在前台，不做跳转处理
    if(curState==UIApplicationStateActive){
        return;
        
    }
    if([XG_TYPE_TOPIC_DETAIL isEqual:action]){
        TopicDetailController *detail=[[TopicDetailController alloc] init];
        detail.topicid=[userInfo objectForKey:@"routeid"];
        detail.comefrom = 1;
        //跳转到详情页
        
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }else if([XG_TYPE_SYSHTTP isEqual:action]){
        SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:[userInfo objectForKey:@"routeid"]]];
        if(controller!=nil){
            [controller.navigationController pushViewController:webView animated:YES];
        }else{
            webView.comefrom=1;
            //跳转到详情页
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:webView];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            self.window.rootViewController=navMain;
        }
        
    }
    
    //赞 或者 发布时@了你
    if([XG_TYPE_ZAN isEqual:action] || [XG_TYPE_ATUSER isEqual:action]){
        TopicDetailController *detail=[[TopicDetailController alloc] init];
        detail.topicid=[userInfo objectForKey:@"routeid"];
        detail.comefrom = 1;
        //跳转到详情页
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }
    
    // 评论了主题，或者发布评论@了你
    if([XG_TYPE_COMMENT isEqual:action] || [XG_TYPE_COMMENTATUSER isEqual:action] || [XG_TYPE_ZAN_COMMENT isEqual:action] || [XG_TYPE_Reposttopic isEqual:action]){
        TopicDetailController *detail=[[TopicDetailController alloc] init];
        detail.topicid=[userInfo objectForKey:@"routeid"];
        detail.startcommentid=[userInfo objectForKey:@"actionid"];
        detail.comefrom = 1;
        
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }
    
    //添加好友，或赞了你
    if([XG_TYPE_ADD_FRIENDS isEqual:action] || [XG_TYPE_ZAN_USER isEqual:action] || [XG_TYPE_Sysuserhomepage isEqual:action]){
        UserDetailController *detail = [[UserDetailController alloc] init];
        detail.comefrom = 1;
        if([XG_TYPE_Sysuserhomepage isEqual:action]){
            detail.uid=[userInfo objectForKey:@"routeid"];
        }else{
            detail.uid=[userInfo objectForKey:@"actionuid"];
        }
        
        //跳转到详情页
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }
    //聊天
    if([XG_TYPE_MESSAGE isEqual:action]){
        
//        LetterController *detail=[[LetterController alloc] init];
        RCLetterController *detail = [[RCLetterController alloc] init];
        detail.userid=[userInfo objectForKey:@"actionuid"];
        //跳转到详情页
        detail.comefrom = 1;
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
        
    }
    
    // 附近
    if([XG_TYPE_Sysnear isEqual:action]){
        SameCityController *detail = [[SameCityController alloc] init];
        //跳转到详情页
        detail.comefrom = 1;
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }
    
    //粉丝列表
    if([XG_TYPE_ADD_FOLLOW isEqual:action]){
        FansListController *detail = [[FansListController alloc] init];
        detail.info=[[LoginManager getInstance] getLoginInfo];
//        detail.userid=[userInfo objectForKey:@"actionuid"];
        //跳转到详情页
        detail.comefrom = 1;
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }
    
    // 系统推 话题和位置
    if([XG_TYPE_Syshuati isEqual:action] || [XG_TYPE_Syspoi isEqual:action]){
        ListTopicsController *detail = [[ListTopicsController alloc] init];
        //跳转到详情页
        detail.comefrom = 1;
        //未完，待确认
        detail.topicString=@"";
        if([XG_TYPE_Syspoi isEqual:action]){
            detail.poiid=[userInfo objectForKey:@"routeid"];
            detail.pageType=TopicWithPoiPage;
        }else{
            detail.topicString=[userInfo objectForKey:@"routeid"];
            detail.pageType=TopicWithDefault;
        }
        if (controller!=nil) {
            [controller.navigationController pushViewController:detail animated:YES];
        }
        else
        {
            UINavigationController *navMain = [[UINavigationController alloc]initWithRootViewController:detail];
            navMain.navigationBarHidden=NO;
            navMain.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            self.window.rootViewController=navMain;
        }
    }
    
}


#pragma mark 绑定IM
-(void)doConnection{
    if(![[LoginManager getInstance] isLogin]){
        return;
    }
    
    if(self.RCTokenStr==nil || [@"" isEqual:self.RCTokenStr]){
        [[SendLocalTools getInstance] connetIM];
        return;
    }
    
    NSString *userId=[[LoginManager getInstance] getUid];
    
    [MobClick event:@"RCConnectTotal" label:userId];
    
    AppDelegate *del=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if(self.isConnect){
        self.isConnect=NO;
        [RCIMClient reconnect:del];
        
    }else{
        [RCIMClient connect:self.RCTokenStr delegate:del];
    }
    
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:appdelegate object:userId];
    
    [[RCIMClient sharedRCIMClient] setConnectionStatusDelegate:appdelegate];
}

/**
 *  回调成功。
 *
 *  @param userId 当前登录的用户 Id，既换取登录 Token 时，App 服务器传递给融云服务器的用户 Id。
 */
- (void)responseConnectSuccess:(NSString*)userId{
    WSLog(@"连接成功：%@",userId);
    //融云连接成功
    [MobClick event:@"RCConnectSuccess" label:userId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.isConnect){
            return;
        }
        
        self.isConnect=YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_RC_CONNECT object:userId];
        

    });
}

/**
 *  回调出错。
 *
 *  @param errorCode 连接错误代码。
 */
- (void)responseConnectError:(RCConnectErrorCode)errorCode{
    NSInteger code=errorCode;
    //融云连接失败
    [MobClick event:@"RCConnectError" label:[NSString stringWithFormat:@"ErrorCode%d",(int)code]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isConnect=NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_RC_CONNECT_ERROR object:nil];
    });
}

/**
 *  收到消息的处理。
 *
 *  @param message 收到的消息实体。
 *  @param object  调用对象。
 */
-(void)responseOnReceived:(RCMessage*)message left:(int)nLeft object:(id)object{
    @try {
        
//        WSLog(@"接收消息：%d===senderID：%@====targetID:%@",nLeft,message.senderUserId,message.targetId);
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置本地消息记录
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setObject:message forKey:@"message"];
            [dict setObject:[NSString stringWithFormat:@"%d",nLeft] forKey:@"num"];
            [dict setObject:object forKey:@"other"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_RC_RECICEMESSAGE object:dict];
        });
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
}

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
-(void)responseConnectionStatus:(RCConnectionStatus)status{
    //在其它设备上登录
    if(status==ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT){
//        [self doConnection];
        //To do debug
//        -[UIKeyboardTaskQueue performTask:] may only be called from the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [[RCIMClient sharedRCIMClient] disconnect:NO];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"下线通知" message:@"主人您的账号在另一地点登录啦！要不是主人你登录的赶紧去修改密码吧，不然要被别人拐跑了呦~" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
            alert.tag=1;
            [alert show];
            
        });
    }
}


#pragma 网络链接改变时会调用的方法
-(void)reachabilityChanged:(NSNotification *)note
{
    WSLog(@"网络就爱你他");
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    //如果没有连接到网络就弹出提醒实况
    self.isReachable = YES;
    
    if(status == NotReachable)
    {
        self.isReachable = NO;
        self.isReachableWiFi = NO;
        self.isReachableWLAN = NO;
        
        self.NetWorkStatus=@"无网络";
    }
    else
    {
        self.isReachable = YES;
        if(status==ReachableViaWiFi){
            self.isReachableWiFi = YES;
            self.isReachableWLAN = NO;
            
            [[SendLocalTools getInstance] sendLocalData];
        }else if(status==ReachableViaWWAN){
            self.isReachableWLAN = YES;
            self.isReachableWiFi = NO;
        }
        [self doConnection];
        
        
        //延迟0.5秒，等待状态栏改变后再获取
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.NetWorkStatus = [self currentNetWorkStatusString];
        });
    }
}

// 循环获取状态栏图标，判断网络实际情况
- (NSString *)currentNetWorkStatusString
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    self.isReachable=NO;
                    self.isReachableWiFi=NO;
                    self.isReachableWLAN=NO;
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    self.isReachable=YES;
                    self.isReachableWiFi=NO;
                    self.isReachableWLAN=YES;
                    break;
                case 2:
                    state = @"3G";
                    self.isReachable=YES;
                    self.isReachableWiFi=NO;
                    self.isReachableWLAN=YES;
                    break;
                case 3:
                    state = @"4G";
                    self.isReachable=YES;
                    self.isReachableWiFi=NO;
                    self.isReachableWLAN=YES;
                    break;
                case 5:
                    state = @"WIFI";
                    self.isReachable=YES;
                    self.isReachableWiFi=YES;
                    self.isReachableWLAN=NO;
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    if (self.isReachableWiFi == YES) {
        [NOTIFICATION_CENTER postNotificationName:Notification_NetworkChange object:@(1)];
    }else{
        [NOTIFICATION_CENTER postNotificationName:Notification_NetworkChange object:@(0)];
    }
    return state;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==0){
            self.RCTokenStr=@"";
            self.isConnect=NO;
            [[LoginManager getInstance] loginOut];
        }else{
            [self doConnection];
        }
    }
}



- (NSString * )macString{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}

- (NSString *)idfaString {
    
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

- (NSString *)idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector( identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}


-(void)doShareNotice:(NSNotification *)info{
    TopicModel *model=info.object;
    if(model.shareType>0){
        [[NoticeTools getInstance] showShareNotice:model block:^{
            
        }];
    }
}

// 判断年龄问题
-(void)mobupdateConfig:(NSNotification *)info{
    NSString *userAgeVersion = [MobClick getConfigParams:@"showAgeNotice"];
    if([@"0" isEqual:userAgeVersion]){
        self.checkUserAge=NO;
    }else if([[SysTools getAppVersion] isEqual:userAgeVersion]){
        self.checkUserAge=YES;
    }
}
@end
