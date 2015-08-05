//
//  LoginManager.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "LoginManager.h"
#import "UserInfoDB.h"
#import "LoginViewController.h"
#import "UserModel.h"
#import "RCDBManager.h"

@implementation LoginManager

static LoginManager *_instance = nil;

+(LoginManager *)getInstance{
    if (_instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[LoginManager alloc] init];
        });
    }
    
    return _instance;
}

-(UserInfo *)doLoginWidthDict:(NSDictionary *)dict{
    UserInfo *udict=[UserInfo new];
    if (self) {
        @try {
            udict=[self parseDictData:dict];
            
            if(udict.uid){
                [SysTools syncNSUserDeafaultsByKey:LoginUID withValue:udict.uid];
                
                //删除旧数据
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userInfo"];
                [SysTools syncNSUserDeafaultsByKey:COOKIE_KEY withValue:nil];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[TutuDBManager defaultDBManager] close];
                //判断是否已经添加
                UserInfoDB *db=[[UserInfoDB alloc] init];
                if(![db findWidthUID:udict.uid])
                {
                    // 数据库不存在，添加
                    [db saveUser:udict];
                }
                
                // 同步个人信息
                // 同步好友信息
                [[SendLocalTools getInstance] synchronousLocalMessage];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
        }
    }
    
    
    if(udict.uid){
        [XGPush unRegisterDevice];
        
        [XGPush setAccount:udict.uid];
        [XGPush setTag:[NSString stringWithFormat:@"gender_%@",udict.gender]];
        
        
        [XGPush initForReregister:^{
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
        }];
        
        NSArray *arr=[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        if(arr!=nil && arr.count>0){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
            [SysTools syncNSUserDeafaultsByKey:COOKIE_KEY withValue:data];
        }
        
        //上传通讯录
        [[SendLocalTools getInstance] sendAddresBookSuccessCallback:nil startCallBack:nil errorCallback:nil finishCallback:nil];
        
        
        if(![SysTools getApp].isConnect){
            if(udict.token!=nil && ![@"" isEqual:udict.token]){
                [SysTools getApp].RCTokenStr=udict.token;
                [[SysTools getApp] doConnection];
            }else{
                //重新获取token
                [[SendLocalTools getInstance] connetIM];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Login_Sucess object:nil];
        
        return udict;
    }else{
        return nil;
    }
}

-(UserInfo *)parseDictData:(NSDictionary *)dict{
    return [[UserInfo alloc] initWithMyDict:dict];
}

-(void)saveInfoToDB:(UserInfo *)info{
    //判断是否已经添加
    UserInfoDB *db=[[UserInfoDB alloc] init];
    
    // 数据库不存在，添加
    [db saveUser:info];
}

-(UserInfo *)getLoginInfo{
    UserInfo *info=[UserInfo new];
    NSString *uid=[self getUid];
    if(uid){
        UserInfoDB *db=[[UserInfoDB alloc] init];
        return [db findWidthUID:uid];
    }
    return info;
}

-(NSString *)getUid{
    NSString *uid=[SysTools getValueFromNSUserDefaultsByKey:LoginUID];
    
    return uid;
}

-(BOOL)isLogin{
    BOOL checkLogin=false;
    NSArray *arr=[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    for (NSHTTPCookie *cookie in arr) {
        if([@"us" isEqual:cookie.name]){
            checkLogin = true;
        }
    }
    
    if (!checkLogin) {
        [self removeLoginInfo];
        return false;
    }
    
    if(![self getUid] || [@"" isEqual:[self getUid]]){
        //判断UserModel中是否登录
        UserInfo *info=[UserModel getFromLocal];
        
        //清除老数据
        [[UserModel shareUserModel] removeUser];
        
        if(info==nil || info.uid==nil || [@"" isEqual:info.uid]){
            [self removeLoginInfo];
            return false;
        }
    }
    return true;
}

// 登录失败使用
-(void)removeLoginInfo{
    if([SysTools getApp].isConnect){
        [SysTools getApp].isConnect=NO;
        [[RCIMClient sharedRCIMClient] disconnect:NO];
    }
    
    [[UserModel shareUserModel] removeUser];
    
    //移除本地key
    [SysTools removeNSUserDeafaultsByKey:LoginUID];
}


-(void)loginOut{
    [self removeLoginInfo];
    
    //关闭数据库
    [[TutuDBManager defaultDBManager] close];
    [[RCDBManager defaultDBManager] close];
    
    //清楚cookie
    [SysTools removeNSUserDeafaultsByKey:COOKIE_KEY];
    
    [ASIHTTPRequest clearSession];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *_tmpArray = [NSArray arrayWithArray:[cookieJar cookies]];
    for (id obj in _tmpArray) {
        [cookieJar deleteCookie:obj];
    }
    
    //先取消再注册
    [XGPush unRegisterDevice:^{
        [XGPush startApp:2200053278 appKey:@"IYA28LJT953H"];
        [XGPush setAccount:@""];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate registerXGPUSH:nil];
    } errorCallback:^{
        
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Login_Exit object:nil];
    LoginViewController * login = [[LoginViewController alloc] init];
    
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:login];
    nav.navigationBarHidden=YES;
    login.isRootPage = YES;
    [[SysTools getApp].window setRootViewController:nav];
}


#pragma 重新注册push
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
- (void)showLoginView:(id) target {
    LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:@"请先登录" delegate:self otherButton:@[@"确定"] cancelButton:@"取消"];
    sheet.tag = 10000;
    [sheet showInView:nil];
}
- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if (tag == 10000) {
        if (buttonIndex == 0) {
            LoginViewController * login = [[LoginViewController alloc] init];
            
            UINavigationController *nav=(UINavigationController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
            NSArray *viewControllers = nav.viewControllers;
            UIViewController *controller = [viewControllers firstObject];
            [controller.navigationController pushViewController:login animated:YES];

        }else{
        
        }
    }
}
@end
