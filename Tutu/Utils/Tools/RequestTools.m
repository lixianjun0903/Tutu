//
//  RequestTools.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RequestTools.h"
#import "ASIDownloadCache.h"
#import "UIDevice-Hardware.h"
#import "SvUDIDTools.h"
#import "SendLocalTools.h"
#import "RDVTabBarController.h"

@implementation RequestTools

static RequestTools *_instance = nil;

+(RequestTools *)getInstance{
    if (_instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[RequestTools alloc] init];
        });
    }
    
    return _instance;
}


-(void)get:(NSString *)url
   isCache:(BOOL)isCache
completion:(void (^)(NSDictionary *))completeBlock
   failure:(void (^)(ASIHTTPRequest *, NSString *))failBlock
  finished:(void (^)(ASIHTTPRequest *))finishBlock{
    UserInfo *info=[[LoginManager getInstance] getLoginInfo];
    if([LoginManager getInstance].isLogin){
        if([url rangeOfString:@"?"].length>0){
            url=[NSString stringWithFormat:@"%@&visituid=%@",url,info.uid];
        }else{
            url=[NSString stringWithFormat:@"%@?visituid=%@",url,info.uid];
        }
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    __block ASIHTTPRequest *brRequest = request;
    [request addRequestHeader:@"FROM" value:@"mobile"];
    [request setTimeOutSeconds:HttpTimeOutSecond];
    
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [request setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //www.tutuim.com/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f,%@)",@"www.tutuim.com",[SysTools getAppVersion],[[UIDevice currentDevice] userAgentName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale,[SysTools getApp].NetWorkStatus];
//    WSLog(@"%@",userAgent);
    [request setUserAgentString:userAgent];
    
    //设置缓存
     if (isCache) {
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
         [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
         //存本地
         [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
     }
    
    //（不支持长连接）
    // 防止重复提交
    request.shouldAttemptPersistentConnection = NO;
    
    
    [request setCompletionBlock:^{
        if([brRequest didUseCachedResponse])
        {
//            WSLog(@"使用缓存里面得数据");
        }
        @try {
            // \u0000
            NSDictionary *dict= [[brRequest responseData] objectFromJSONData];
            NSString *code=[dict objectForKey:@"code"];
            if(code!=nil && [code intValue]==10000){
                completeBlock(dict);
            }else{
                NSString *desc=[dict objectForKey:@"desc"];
                if(desc==nil || [@"" isEqual:desc]){
                    desc=Error_NetMessage;
                }
                failBlock(brRequest,desc);
            }
        }
        @catch (NSException *exception) {
            failBlock(brRequest,Error_NetMessage);
        }
        @finally {
            finishBlock(brRequest);
        }
    }];
    
    [request setFailedBlock:^{
        WSLog(@"%@",brRequest.responseStatusMessage);
        WSLog(@"%@",brRequest.responseString);
        WSLog(@"%@",brRequest.error);
        failBlock(brRequest,Error_NetMessage);
    
        finishBlock(brRequest);
    }];
    
    [request startAsynchronous];
    //上传本地数据,网络变为wifi时在处理
//    [[SendLocalTools getInstance] sendLocalData];
}


-(void)post:(NSString *)url
   filePath:(NSString *)filepath
    fileKey:(NSString *)key
     params:(NSMutableDictionary *)dict
 completion:(void (^)(NSDictionary *))completeBlock
    failure:(void (^)(ASIFormDataRequest *, NSString *))failBlock
   finished:(void (^)(ASIFormDataRequest *))finishBlock{
    
    //判断是否正在提交
    NSString *localtopicid=[dict objectForKey:@"localtopicid"];
    if(localtopicid!=nil && ![@"" isEqual:localtopicid]){
        NSString *isLoadingLocal=[SysTools getValueFromNSUserDefaultsByKey:localtopicid];
        if(isLoadingLocal!=nil && ![@"" isEqual:isLoadingLocal]){
            return;
        }
        [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:localtopicid];
    }
    
    
    UserInfo *info=[[LoginManager getInstance] getLoginInfo];
    if([LoginManager getInstance].isLogin){
        if([url rangeOfString:@"?"].length>0){
            url=[NSString stringWithFormat:@"%@&visituid=%@",url,info.uid];
        }else{
            url=[NSString stringWithFormat:@"%@?visituid=%@",url,info.uid];
        }
    }
    
    ASIFormDataRequest *postRequest=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    __block ASIFormDataRequest *brRequest = postRequest;
    [postRequest addRequestHeader:@"FROM" value:@"mobile"];
    [postRequest setTimeOutSeconds:HttpPostTimeOutSecond];
    
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [postRequest setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //www.tutuim.com/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f,%@)",@"www.tutuim.com",[SysTools getAppVersion],[[UIDevice currentDevice] userAgentName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale,[SysTools getApp].NetWorkStatus];
    //    WSLog(@"%@",userAgent);
    [postRequest setUserAgentString:userAgent];
    
    //（不支持长连接）
    // 防止重复提交
    postRequest.shouldAttemptPersistentConnection = NO;
    
    
    if(filepath!=nil && key !=nil){
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
           [postRequest addFile:filepath forKey:key];
        }
    }
    for (NSString *key in dict.allKeys) {
        // To Do  特殊的content是文件路径
        if([key isEqual:@"contentFile"]){
            NSString *videoPath = dict[@"contentFile"];
            if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]) {
                [postRequest addFile:videoPath forKey:@"video"];
            }
        }else{
            [postRequest addPostValue:[dict objectForKey:key] forKey:key];
        }
    }
    
    
    [postRequest setCompletionBlock:^{
        // 出现以下数据，无法解析
        //  "replycommentid": "0\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
        NSDictionary *dict= [[brRequest responseData] objectFromJSONData];
        
        @try {
            NSString *code=[dict objectForKey:@"code"];
            if(code!=nil && [code intValue]==10000){
                completeBlock(dict);
            }else{
                NSString *desc=[dict objectForKey:@"desc"];
                if(desc==nil || [@"" isEqual:desc]){
                    desc=Error_NetMessage;
                }
                failBlock(brRequest,desc);
            }
        }
        @catch (NSException *exception) {
            failBlock(brRequest,Error_NetMessage);
        }
        @finally {
            finishBlock(brRequest);
            [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:@""];
        }
    }];
    [postRequest setFailedBlock:^{
        WSLog(@"%@",brRequest.responseStatusMessage);
        failBlock(brRequest,Error_NetMessage);
        
        finishBlock(brRequest);
        
        [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:@""];
    }];
    [postRequest startAsynchronous];
    
    //上传本地数据,网络变为wifi时在处理
//    [[SendLocalTools getInstance] sendLocalData];
}


#pragma 全局消息数量管理
-(void)setNewsCountWithDict:(NSDictionary *)dict{
    if(dict){
        [self doSetNewFanscount:[dict objectForKey:@"newfanscount"]];
        [self doSetNewfollowtopiccount:[dict objectForKey:@"newfollowtopiccount"]];
        [self doSetNewhottopiccount:[dict objectForKey:@"newhottopiccount"]];
        [self doSetNewtipscount:[dict objectForKey:@"newtipscount"]];
        [self doSetNewfollowpoicount:[dict objectForKey:@"newfollowpoicount"]];
        [self doSetNewfollowhtcount:[dict objectForKey:@"newfollowhtcount"]];
    }
}

-(void)doCleanMessageNum{
    _newfanscount=@"";
    _newtipscount=@"";
    _newhottopiccount=@"";
    _newfollowtopiccount=@"";
    _newfollowhtcount=@"";
    _newfollowpoicount=@"";
}

-(void)doSetNewfollowtopiccount:(NSString *)newfollowcount{
    if(newfollowcount==nil || [@"" isEqual:newfollowcount]||[@"0" isEqual:newfollowcount]){
        self.newfollowtopiccount=@"";
        self.newfollowhtcount=@"";
        self.newfollowpoicount=@"";
        
        
        RDVTabBarController *controller = [self getMainController];
        if(controller!=nil){
            controller.homenum=0;
            controller.menum=[self getNewfanscount];
            [controller checkNewcount];
        }
        
        return;
    }
    self.newfollowtopiccount=newfollowcount;
}
-(void)doSetNewFanscount:(NSString *)newfriendcount{
    if(newfriendcount==nil || [@"" isEqual:newfriendcount]){
        self.newfanscount=@"";
        
        RDVTabBarController *controller = [self getMainController];
        if(controller!=nil){
            controller.menum=[self getNewfollowpoicount]+[self getNewfollowhtcount];
        }
        return;
    }
    self.newfanscount=newfriendcount;
}
-(void)doSetNewhottopiccount:(NSString *)newhotcount{
    if(newhotcount==nil || [@"" isEqual:newhotcount]){
        self.newhottopiccount=@"";
        return;
    }
    self.newhottopiccount=newhotcount;
}
-(void)doSetNewtipscount:(NSString *)newtipscount{
    if(newtipscount==nil || [@"" isEqual:newtipscount]){
        self.newtipscount=@"";
        
        RDVTabBarController *controller = [self getMainController];
        if(controller!=nil){
            controller.feednum=0;
        }

        return;
    }
    self.newtipscount=newtipscount;
}


-(void)doSetNewfollowpoicount:(NSString *)newfollowpoicount{
    if(newfollowpoicount==nil || [@"" isEqual:newfollowpoicount]){
        self.newfollowpoicount=@"";
        
        
        RDVTabBarController *controller = [self getMainController];
        if(controller!=nil){
            controller.menum=[self getNewfollowhtcount]+[self getNewfanscount];
        }

        return;
    }
    self.newfollowpoicount=newfollowpoicount;
}

-(void)doSetNewfollowhtcount:(NSString *)newfollowhtcount{
    if(newfollowhtcount==nil || [@"" isEqual:newfollowhtcount]){
        self.newfollowhtcount=@"";
        
        
        RDVTabBarController *controller = [self getMainController];
        if(controller!=nil){
            controller.menum=[self getNewfollowpoicount]+[self getNewfanscount];
        }
        return;
    }
    self.newfollowhtcount=newfollowhtcount;
}




///////////////////////////////////////////////////
-(int)getNewfollowtopiccount{
    if(self.newfollowtopiccount==nil || [@"" isEqual:self.newfollowtopiccount]){
        return 0;
    }
    @try {
        return [self.newfollowtopiccount intValue];
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
    }
}

-(int)getNewfanscount{
    if(self.newfanscount==nil || [@"" isEqual:self.newfanscount]){
        return 0;
    }
    @try {
        return [self.newfanscount intValue];
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
    }
}

-(int)getNewhottopiccount{
    if(self.newhottopiccount==nil || [@"" isEqual:self.newhottopiccount]){
        return 0;
    }
    @try {
        return [self.newhottopiccount intValue];
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
    }
}


-(int)getMessagesNum{
    @try {
        
        int unReadNum=(int)[[RCIMClient sharedRCIMClient] getTotalUnreadCount];
        return unReadNum;
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
        
    }
}

-(int)getTipsNum{
    if(self.newtipscount==nil || [@"" isEqual:self.newtipscount]){
        return 0;
    }
    @try {
        return [self.newtipscount intValue];
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
        
    }
}

-(int)getNewfollowhtcount{
    if(self.newfollowhtcount==nil || [@"" isEqual:self.newfollowhtcount]){
        return 0;
    }
    @try {
        return [self.newfollowhtcount intValue];
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
        
    }
}

-(int)getNewfollowpoicount{
    if(self.newfollowpoicount==nil || [@"" isEqual:self.newfollowpoicount]){
        return 0;
    }
    @try {
        return [self.newfollowpoicount intValue];
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
        
    }
}


-(int)getAllNewsNum{
    if(![[LoginManager getInstance] isLogin]){
        return 0;
    }
    int count=0;
    @try {
//        if(self.newfollowtopiccount==nil || [@"" isEqual:self.newfollowtopiccount]){
//            count=count+0;
//        }else{
//            count=count+[self.newfollowtopiccount intValue];
//        }
        
        if(self.newfanscount==nil || [@"" isEqual:self.newfanscount]){
            count=count+0;
        }else{
            count=count+[self.newfanscount intValue];
        }
        
//        if(self.newhottopiccount==nil || [@"" isEqual:self.newhottopiccount]){
//            count=count+0;
//        }else{
//            count=count+[self.newhottopiccount intValue];
//        }
//        
//        if(self.newtipscount==nil || [@"" isEqual:self.newtipscount]){
//            count=count+0;
//        }else{
//            count=count+[self.newtipscount intValue];
//        }
//        
//        if(self.newfollowpoicount!=nil || ![@"" isEqual:self.newfollowpoicount]){
//            count=count+[self.newfollowpoicount intValue];
//        }
//        
//        if(self.newfollowhtcount!=nil || ![@"" isEqual:self.newfollowhtcount]){
//            count=count+[self.newfollowhtcount intValue];
//        }
        
        int unReadNum=(int)[[RCIMClient sharedRCIMClient] getTotalUnreadCount];
        count=count+ unReadNum;
    }
    @catch (NSException *exception) {
        return count;
    }
    @finally {
        return count;
    }
}


-(RDVTabBarController *)getMainController{
    
    if([[SysTools getApp] getCurrentRootViewController]!=nil){
        UIViewController *controller=[[SysTools getApp] getCurrentRootViewController].childViewControllers[0];
        if([controller isKindOfClass:[RDVTabBarController class]])
        {
            return (RDVTabBarController*)controller;
        }
    }
    return nil;
}

@end
