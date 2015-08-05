//
//  UserModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "UserModel.h"
#import "XGPush.h"
#import "SendLocalTools.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UserInfoDB.h"
@implementation UserModel

static UserModel * _gcUserCenter;


+(UserModel *) shareUserModel{
    
    @synchronized(self){
        
        if(_gcUserCenter == nil){
            _gcUserCenter = [[self alloc] init];
            [self getFromLocal];
        }
    }
    
    return _gcUserCenter;
    
}

- (void)logout{

    [[RequestTools getInstance] get:API_ADD_SIGNOUT isCache:NO completion:^(NSDictionary *dict) {
        
        //先取消注册，再注册
        [self removeUser];
        [XGPush unRegisterDevice];
        [XGPush startApp:2200053278 appKey:@"IYA28LJT953H"];
        [XGPush setAccount:@""];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate registerXGPUSH:nil];
        
        LoginViewController * login = [[LoginViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:login];
        //        nav.navigationBarHidden=YES;
        [appDelegate.window setRootViewController:nav];
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}

//获取本地序列化对象
+(UserInfo *) getFromLocal
{
    UserInfo *newInfo=nil;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if(!is_null(data)){
        //反序列化 取对象
        _gcUserCenter = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if(_gcUserCenter!=nil){
            newInfo=[UserInfo new];
            newInfo.addtime=_gcUserCenter.addtime;
            newInfo.age=_gcUserCenter.age;
            newInfo.area=_gcUserCenter.area;
            newInfo.avatartime=_gcUserCenter.avatartime;
            newInfo.birthday=_gcUserCenter.birthday;
            newInfo.city=_gcUserCenter.city;
            newInfo.gender=_gcUserCenter.gender;
            newInfo.isBlock=[_gcUserCenter.isblock boolValue];
            newInfo.nickname=_gcUserCenter.nickname;
            newInfo.province=_gcUserCenter.province;
            newInfo.relation=_gcUserCenter.relation;
            newInfo.sign=_gcUserCenter.sign;
            newInfo.uid=_gcUserCenter.uid;
            newInfo.logintype=_gcUserCenter.logintype;
            newInfo.isbind_weibo=_gcUserCenter.isbind_weibo;
            newInfo.isbind_qq=_gcUserCenter.isbind_qq;
            newInfo.isbind_phone=_gcUserCenter.isbind_phone;
            newInfo.token=_gcUserCenter.token;
            newInfo.locationstatus=_gcUserCenter.locationstatus;
            
            UserInfoDB *db=[[UserInfoDB alloc] init];
            [db saveUser:newInfo];
            
            [SysTools syncNSUserDeafaultsByKey:LoginUID withValue:newInfo.uid];
            
        }
    }
    return newInfo;
}


//重置所有属性
-(void) removeUser
{
    _gcUserCenter.addtime =@"";
    _gcUserCenter.age =@"";
    _gcUserCenter.area=@"";
    _gcUserCenter.avatartime=@"";
    _gcUserCenter.birthday=@"";
    _gcUserCenter.city=@"";
    _gcUserCenter.gender =@"";
    _gcUserCenter.isblock =@"";
    _gcUserCenter.nickname=@"";
    _gcUserCenter.province=@"";
    _gcUserCenter.relation=@"";
    _gcUserCenter.sign=@"";
    _gcUserCenter.uid = @"";
    
    _gcUserCenter.logintype=@"";
    _gcUserCenter.isbind_weibo=@"";
    _gcUserCenter.isbind_qq=@"";
    _gcUserCenter.isbind_phone=@"";
    
    _gcUserCenter.token=@"";
    
    _gcUserCenter.locationstatus = @"";
    
    
//    if([SysTools getApp].isConnect){
//        [SysTools getApp].isConnect=NO;
//        [[RCIMClient sharedRCIMClient] disconnect:NO];
//    }
//    
//    
//    [ASIHTTPRequest clearSession];
//    
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *_tmpArray = [NSArray arrayWithArray:[cookieJar cookies]];
//    for (id obj in _tmpArray) {
//        [cookieJar deleteCookie:obj];
//    }
    
    [SysTools removeNSUserDeafaultsByKey:@"userInfo"];
    [SysTools syncNSUserDeafaultsByKey:COOKIE_KEY withValue:nil];
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:Login_Exit object:nil];
    
//    [SysTools setSoundEffectClose:NO];
//    [SysTools setNotificationShakeing:NO];
//    [SysTools setNotificationSoundOpen:YES];
}

//保存对象到NSUserDefaults中,每次修改内容，均调用此方法
-(void) saveToLocal
{
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:_gcUserCenter];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"userInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma 下列所有方法都是为了确保只有一个实例
+(id) allocWithZone:(NSZone *) zone{
    if(_gcUserCenter == nil){
        
        _gcUserCenter = [super allocWithZone:zone];
    }
    
    return _gcUserCenter;
}


#pragma 序列化有用
- (id) copyWithZone:(NSZone *)zone{
    
    return _gcUserCenter;
    
}

#pragma 序列化对象使用
- (id)initWithCoder:(NSCoder *)coder{
    
    _gcUserCenter = [super init];
    if(_gcUserCenter){
        
        _gcUserCenter.uid = [coder decodeObjectForKey:@"uid"];
        _gcUserCenter.nickname = [coder decodeObjectForKey:@"nickname"];
        
        _gcUserCenter.birthday = [coder decodeObjectForKey:@"birthday"];
        _gcUserCenter.province = [coder decodeObjectForKey:@"province"];
        _gcUserCenter.city = [coder decodeObjectForKey:@"city"];
        _gcUserCenter.area = [coder decodeObjectForKey:@"area"];
        _gcUserCenter.gender = [coder decodeObjectForKey:@"gender"];
        _gcUserCenter.sign = [coder decodeObjectForKey:@"sign"];
        _gcUserCenter.avatartime=[coder decodeObjectForKey:@"avatartime"];
        
        _gcUserCenter.addtime=[coder decodeObjectForKey:@"addtime"];
        _gcUserCenter.age=[coder decodeObjectForKey:@"age"];
        _gcUserCenter.isblock=[coder decodeObjectForKey:@"isblock"];
        _gcUserCenter.relation=[coder decodeObjectForKey:@"relation"];
        
        
        _gcUserCenter.logintype=[coder decodeObjectForKey:@"logintype"];
        _gcUserCenter.isbind_phone=[coder decodeObjectForKey:@"isbind_phone"];
        _gcUserCenter.isbind_qq=[coder decodeObjectForKey:@"isbind_qq"];
        _gcUserCenter.isbind_weibo=[coder decodeObjectForKey:@"isbind_weibo"];
        _gcUserCenter.locationstatus = [coder decodeObjectForKey:@"locationstatus"];
        _gcUserCenter.token=[coder decodeObjectForKey:@"token"];
    }
    
    return _gcUserCenter;
}
- (void)encodeWithCoder:(NSCoder *)coder{
    //    [super encodeWithCoder:coder];
    [coder encodeObject:_gcUserCenter.uid forKey:@"uid"];
    [coder encodeObject:_gcUserCenter.nickname forKey:@"nickname"];
    [coder encodeObject:_gcUserCenter.birthday forKey:@"birthday"];
    [coder encodeObject:_gcUserCenter.province forKey:@"province"];
    [coder encodeObject:_gcUserCenter.city forKey:@"city"];
    [coder encodeObject:_gcUserCenter.area forKey:@"area"];
    [coder encodeObject:_gcUserCenter.gender forKey:@"gender"];
    [coder encodeObject:_gcUserCenter.sign forKey:@"sign"];
    [coder encodeObject:_gcUserCenter.avatartime forKey:@"avatartime"];
    
    [coder encodeObject:_gcUserCenter.addtime forKey:@"addtime"];
    [coder encodeObject:_gcUserCenter.age forKey:@"age"];
    [coder encodeObject:_gcUserCenter.isblock forKey:@"isblock"];
    [coder encodeObject:_gcUserCenter.relation forKey:@"relation"];
    
    
    [coder encodeObject:_gcUserCenter.logintype forKey:@"logintype"];
    [coder encodeObject:_gcUserCenter.isbind_weibo forKey:@"isbind_weibo"];
    [coder encodeObject:_gcUserCenter.isbind_qq forKey:@"isbind_qq"];
    [coder encodeObject:_gcUserCenter.isbind_phone forKey:@"isbind_phone"];
    
    [coder encodeObject:_gcUserCenter.token forKey:@"token"];
}




#pragma 重新注册push
+ (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}


+ (void)registerPushForIOS8{
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

@end
