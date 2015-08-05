//
//  SendLocalTools.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SendLocalTools.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "AddressBookDictionary.h"
#import "LinkManModel.h"
#import "AddressDB.h"
#import "RCMessageDBHelper.h"
#import "RCTempDBHelper.h"
#import "ASIHTTPRequest.h"
#import "UserInfoDB.h"
#import "SynchMarkDB.h"
#import "ApplyLeaveDB.h"

@implementation SendLocalTools

static SendLocalTools *_instance = nil;

+(SendLocalTools *)getInstance{
    if (_instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[SendLocalTools alloc] init];
        });
    }
    
    return _instance;
}


/****
 **上传通讯录
 ****/
-(void)sendAddresBookSuccessCallback:(void (^)(void))successCallback startCallBack:(void (^)(void))startCallback errorCallback:(void (^)(void))errorCallback finishCallback:(void (^)(void))finishCallback{
    if(![LoginManager getInstance].isLogin){
        return;
    }
    AddressBookDictionary * add = [[AddressBookDictionary alloc]init];
    NSString * content = [[add getContactsWithTime] JSONString];
    if(content==nil || [@"" isEqual:content] || content.length<3){
        return;
    }
    if(startCallback){
        startCallback();
    }
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    
    [dictionary setObject:content forKey:@"content"];
    [dictionary setObject:[SvUDIDTools UDID] forKey:@"deviceid"];
    [[RequestTools getInstance] post:API_COMMITADDRESSLIST filePath:nil fileKey:nil params:dictionary completion:^(NSDictionary *dict) {
        
        NSArray * contents = [[NSArray alloc] initWithArray:dict[@"data"][@"list"]];
        
        NSMutableArray * linksArray = [[NSMutableArray alloc]init];
        for (NSDictionary * dic in contents) {
            LinkManModel * model = [[LinkManModel alloc] initWithDictionary:dic];
            [linksArray addObject:model];
        }
        
        if (linksArray.count>0) {
            AddressDB *db=[[AddressDB alloc] init];
            BOOL isSave=[db saveListContanst:linksArray];
            WSLog(@"保存数据结果:%d",isSave);
            
        }
        //本地保存关系成功，存储记录当前时间
        NSString *time=dateTransformString(@"yyyy-MM-dd hh:mm:ss", [NSDate date]);
        [SysTools syncNSUserDeafaultsByKey:SYSContactsTime_KEY withValue:time];
        if(successCallback){
            successCallback();
        }
        
    } failure:^(ASIFormDataRequest *request, NSString *message) {
        if(errorCallback){
            errorCallback();
        }
    } finished:^(ASIFormDataRequest *request) {
        //        WSLog(@"%@",request.responseString);
        if(finishCallback){
            finishCallback();
        }
    }];
}


////////////////////////////////////////////////////////
// 提交评论、主题
-(void)sendLocalData{
    AppDelegate *gate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if(!gate.isReachableWiFi){
        return;
    }
    if(![[LoginManager getInstance] isLogin]){
        return;
    }
    
    TopicCacheDB *db=[[TopicCacheDB alloc] init];
    NSMutableArray *arr=[db findTopicWithType:1];
    NSMutableArray *videoArr = [db findTopicWithType:5];
    NSMutableArray *commonArr=[db findLocalTopicComment];
    if(arr.count==0 && commonArr.count==0 && videoArr.count==0){
        return;
    }
    
    ASINetworkQueue *asi=[ASINetworkQueue queue];
    for (TopicModel *item in arr) {
        ASIFormDataRequest *req=[self sendTopic:item];
        if(req!=nil){
            [asi addOperation:req];
        }
    }
    
    for (TopicModel *item in videoArr) {
        if(checkFileIsExsis(item.videourl)){
            ASIFormDataRequest *req=[self sendVideoTopic:item];
            if(req!=nil){
                [asi addOperation:req];
            }
        }else{
            @try {
                //成功了
                TopicCacheDB *db=[[TopicCacheDB alloc] init];
                [db deleteTopicWithLoaclId:item.localid];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
    
    
    for (CommentModel *citem in commonArr) {
        [asi addOperation:[self sendCommon:citem]];
    }
    //开始运行
    [asi go];
    
    
    ApplyLeaveDB *applyDB=[[ApplyLeaveDB alloc] init];
    NSMutableArray *applyarr=[applyDB findAllApplyWithDel];
    
    NSMutableString * params = [NSMutableString stringWithFormat:@""];
    for (ApplyFriendModel *item in applyarr) {
        [params stringByAppendingFormat:@"%@,",item.frienduid];
    }
    [params appendString:@")"];
    if([params hasSuffix:@",)"]){
        [params replaceCharactersInRange:NSMakeRange(params.length-2, 2) withString:@""];
        [params stringByReplacingOccurrencesOfString:@",)" withString:@""];
    }
    WSLog(@"%@",params);
    [[RequestTools getInstance]post:API_friend_apply_delete filePath:nil fileKey:nil params:[@{@"frienduid" : params}mutableCopy] completion:^(NSDictionary *dict) {
        // 物理删除
        ApplyLeaveDB *applyDB=[[ApplyLeaveDB alloc] init];
        [applyDB delAllIsDelApplyDB];
    } failure:^(ASIFormDataRequest *request, NSString *message) {
        
    } finished:^(ASIFormDataRequest *request) {
        
    }];
}

-(ASIFormDataRequest *) sendTopic:(TopicModel *) topicmodel{
    //判断是否正在提交
    NSString *localtopicid=topicmodel.localid;
    if(localtopicid!=nil && ![@"" isEqual:localtopicid]){
        NSString *isLoadingLocal=[SysTools getValueFromNSUserDefaultsByKey:localtopicid];
        if(isLoadingLocal!=nil && ![@"" isEqual:isLoadingLocal]){
            return nil;
        }
        [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:localtopicid];
    }
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    if(topicmodel.commentList.count>0){
        CommentModel *cmModel=[topicmodel.commentList objectAtIndex:0];
        [params setValue:cmModel.comment forKey:@"commentcontent"];
        [params setValue:cmModel.pointX  forKey:@"commentlocationx"];
        [params setValue:cmModel.pointY forKey:@"commentlocationy"];
        [params setValue:cmModel.commentbg forKey:@"commenttxtframe"];
    }
    [params setValue:topicmodel.localid forKey:@"localtopicid"];
    
    ASIFormDataRequest *postRequest=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:API_ADD_TOPIC]];
    
    __block ASIFormDataRequest *brRequest = postRequest;
    [postRequest addRequestHeader:@"FROM" value:@"mobile"];
    [postRequest setTimeOutSeconds:HttpPostTimeOutSecond];
    
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [postRequest setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //QingguoStudent/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f,%@)",@"Tutu",[SysTools getAppVersion],[[UIDevice currentDevice] userAgentName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale,[SysTools getApp].NetWorkStatus];
    //    WSLog(@"%@",userAgent);
    [postRequest setUserAgentString:userAgent];
    
    //（不支持长连接）
    // 防止重复提交
    postRequest.shouldAttemptPersistentConnection = NO;
    
    
    if(topicmodel.sourcepath!=nil){
        [postRequest addFile:getDocumentsFilePath(topicmodel.sourcepath) forKey:@"content"];
    }
    for (NSString *key in params.allKeys) {
        [postRequest addPostValue:[params objectForKey:key] forKey:key];
    }
    [postRequest setCompletionBlock:^{
        NSDictionary *dict= [[brRequest responseData] objectFromJSONData];
        @try {
            NSString *code=[dict objectForKey:@"code"];
            if(code!=nil && [code intValue]==10000){
                //成功了
                TopicCacheDB *db=[[TopicCacheDB alloc] init];
                [db deleteTopicWithLoaclId:topicmodel.localid];
                
                
                NSDictionary *data = dict[@"data"];
                
                TopicModel *model = [TopicModel initTopicModelWith:data];
                model.localid = topicmodel.localid;
                model.nickname = topicmodel.nickname;
                model.shareType=topicmodel.shareType;
                model.shareUrl=topicmodel.sourcepath;
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Success object:model];
            }else{
                NSString *desc=[dict objectForKey:@"desc"];
                if(desc==nil || [@"" isEqual:desc]){
                    desc=Error_NetMessage;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Failed object:topicmodel];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:@""];
        }
    }];
    [postRequest setFailedBlock:^{
        [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:@""];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Failed object:topicmodel];
        
    }];
    return postRequest;
}


-(ASIFormDataRequest *) sendVideoTopic:(TopicModel *) topicmodel{
    //判断是否正在提交
    NSString *localtopicid=topicmodel.localid;
    if(localtopicid!=nil && ![@"" isEqual:localtopicid]){
        NSString *isLoadingLocal=[SysTools getValueFromNSUserDefaultsByKey:localtopicid];
        if(isLoadingLocal!=nil && ![@"" isEqual:isLoadingLocal]){
            return nil;
        }
        [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:localtopicid];
    }
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%f",topicmodel.times] forKey:@"videotimes"];
    [params setValue:@"5" forKey:@"type"];
    [params setValue:topicmodel.localid forKey:@"localtopicid"];
    [params setValue:topicmodel.topicDesc forKey:@"topicdesc"];
    if(topicmodel.poiId!=nil){
        [params setValue:topicmodel.poiId forKey:@"poiid"];
        [params setValue:topicmodel.location forKey:@"poitext"];
    }
    [params setValue:[NSString stringWithFormat:@"%d",(int)topicmodel.iskana] forKey:@"iskana"];
    
    
    ASIFormDataRequest *postRequest=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:API_ADD_TOPIC]];
    
    __block ASIFormDataRequest *brRequest = postRequest;
    [postRequest addRequestHeader:@"FROM" value:@"mobile"];
    [postRequest setTimeOutSeconds:HttpPostTimeOutSecond];
    
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [postRequest setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //QingguoStudent/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f,%@)",@"Tutu",[SysTools getAppVersion],[[UIDevice currentDevice] userAgentName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale,[SysTools getApp].NetWorkStatus];
    //    WSLog(@"%@",userAgent);
    [postRequest setUserAgentString:userAgent];
    
    //（不支持长连接）
    // 防止重复提交
    postRequest.shouldAttemptPersistentConnection = NO;
    
    
    if(topicmodel.sourcepath!=nil){
        if ([[NSFileManager defaultManager]fileExistsAtPath:getDocumentsFilePath(topicmodel.sourcepath)]) {
           [postRequest addFile:getDocumentsFilePath(topicmodel.sourcepath) forKey:@"content"];
        }
        if ([[NSFileManager defaultManager]fileExistsAtPath:topicmodel.videourl]) {
            [postRequest addFile:topicmodel.videourl forKey:@"video"];
        }
    }
    
    for (NSString *key in params.allKeys) {
        [postRequest addPostValue:[params objectForKey:key] forKey:key];
    }
    [postRequest setCompletionBlock:^{
        NSDictionary *dict= [[brRequest responseData] objectFromJSONData];
        @try {
            NSString *code=[dict objectForKey:@"code"];
            WSLog(@"%@",dict[@"desc"]);
            if(code!=nil && [code intValue]==10000){
//                NSDictionary *data = dict[@"data"];
//                TopicModel *model = [TopicModel initTopicModelWith:data];
                //成功了
                TopicCacheDB *db=[[TopicCacheDB alloc] init];
                [db deleteTopicWithLoaclId:topicmodel.localid];
                
                
                NSDictionary *data = dict[@"data"];
                
                TopicModel *model = [TopicModel initTopicModelWith:data];
                model.localid = topicmodel.localid;
                model.nickname = topicmodel.nickname;
                model.shareType=topicmodel.shareType;
                model.shareUrl=topicmodel.sourcepath;
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Success object:model];
            }else{
                NSString *desc=[dict objectForKey:@"desc"];
                if(desc==nil || [@"" isEqual:desc]){
                    desc=Error_NetMessage;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Failed object:topicmodel];
                
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:@""];
        }
    }];
    [postRequest setFailedBlock:^{
        WSLog(@"%@",brRequest.responseStatusMessage);
        [SysTools syncNSUserDeafaultsByKey:localtopicid withValue:@""];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Failed object:topicmodel];
    }];
    return postRequest;
}

-(ASIFormDataRequest *)sendCommon:(CommentModel *)model {
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setValue:model.topicid forKey:@"topicid"];
    if(model.pid){
        [params setValue:model.pid forKey:@"replycommentid"];
    }
    [params setValue:model.pointX  forKey:@"locationx"];
    [params setValue:model.pointY forKey:@"locationy"];
    [params setValue:model.commentbg forKey:@"txtframe"];
    [params setValue:model.comment forKey:@"content"];
    
    NSString *url=API_ADD_COMMENT;
    UserInfo * userInfo=[[LoginManager getInstance] getLoginInfo];
    if([LoginManager getInstance].isLogin){
        if([url rangeOfString:@"?"].length>0){
            url=[NSString stringWithFormat:@"%@&visituid=%@",url,userInfo.uid];
        }else{
            url=[NSString stringWithFormat:@"%@?visituid=%@",url,userInfo.uid];
        }
    }
    ASIFormDataRequest *postRequest=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    __block ASIFormDataRequest *brRequest = postRequest;
    [postRequest addRequestHeader:@"FROM" value:@"mobile"];
    [postRequest setTimeOutSeconds:HttpTimeOutSecond];
    
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [postRequest setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //QingguoStudent/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f,%@)",@"Tutu",[SysTools getAppVersion],[[UIDevice currentDevice] userAgentName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale,[SysTools getApp].NetWorkStatus];
    //    WSLog(@"%@",userAgent);
    [postRequest setUserAgentString:userAgent];
    
    //（不支持长连接）
    // 防止重复提交
    postRequest.shouldAttemptPersistentConnection = NO;
    
    for (NSString *key in params.allKeys) {
        [postRequest addPostValue:[params objectForKey:key] forKey:key];
    }
    [postRequest setCompletionBlock:^{
        NSDictionary *dict= [[brRequest responseData] objectFromJSONData];
        @try {
            NSString *code=[dict objectForKey:@"code"];
            if(code!=nil && [code intValue]==10000){
                //成功了
                TopicCacheDB *db=[[TopicCacheDB alloc] init];
                [db deleteCommonWithLoaclId:model.localid];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Notifcation_Topic_Comment_Send_Success object:dict];
            }else{
                NSString *desc=[dict objectForKey:@"desc"];
                if(desc==nil || [@"" isEqual:desc]){
                    desc=Error_NetMessage;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Notifcation_Topic_Comment_Send_Failed object:model];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }];
    [postRequest setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:Notifcation_Topic_Comment_Send_Failed object:model];
    }];
    return postRequest;
}



-(void)sendLocalToServer:(NSString *)latitude lon:(NSString *) longitude{
    [SysTools getApp].latitude=[latitude doubleValue];
    [SysTools getApp].longitude=[longitude doubleValue];
    [SysTools getApp].locSuccess=YES;
    
    if(![[LoginManager getInstance] isLogin]){
        return;
    }
    [[RequestTools getInstance] get:API_LOCATION(latitude,longitude,@"",@"",@"") isCache:NO completion:^(NSDictionary *dict) {
        //        WSLog(@"%@",dict);
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"定位提交：%@",request.responseString);
    }];
}

-(void)connetIM{
    [[RequestTools getInstance] get:API_GET_TOKEN isCache:NO completion:^(NSDictionary *dict) {
        NSDictionary *item=[dict objectForKey:@"data"];
        NSString *token=[item objectForKey:@"token"];
        UserInfo *model=[[LoginManager getInstance] getLoginInfo];
        model.token=token;
        [[LoginManager getInstance] saveInfoToDB:model];
        
        AppDelegate *del=[SysTools getApp];
        del.RCTokenStr=token;
        [del doConnection];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];

}


-(BOOL)checkExportIMData{
    if(![LoginManager getInstance].isLogin){
        return YES;
    }
    
    NSString *isExportIMData =[NSString stringWithFormat:@"ExportIMData%@",[[LoginManager getInstance] getUid]];
    NSString *data =  [SysTools getValueFromNSUserDefaultsByKey:isExportIMData];
    
    if([CheckNilValue(data) isEqual:@"1"]){
        return YES;
    }else{
        NSString *path=getDocumentsFilePath([NSString stringWithFormat:@"/%@/%@/%@",RCKey,[[LoginManager getInstance] getUid],@"RCTemp.db"]);
        //判断文件是否存在，存在说明已经下载成功
        if(checkFileIsExsis(path)){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                RCTempDBHelper *tempDB=[[RCTempDBHelper alloc] init];
                NSMutableArray *messageArr=[tempDB findTempRCMessageList];
                NSMutableArray *conversationArr=[tempDB findTempRCConversationList];
                
                RCMessageDBHelper *db=[[RCMessageDBHelper alloc] init];
                //清空数据
                [db clearAllMessage];
                
                BOOL saveMessage=[db saveTempDBToMessage:messageArr];
                BOOL saveConversation=[db saveTempDBToConversation:conversationArr];
                
                //回调或者说是通知主线程刷新，
                if(saveMessage && saveConversation){
                    [SysTools syncNSUserDeafaultsByKey:isExportIMData withValue:@"1"];
                }
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:path error:nil];
                
            });
        }
    }
    
    return [self checkhadExportIMData:nil];
}

-(BOOL)checkhadExportIMData:(HadExportIMData) block{
    NSString *noExportIMData =[NSString stringWithFormat:@"NOExportIMData%@",[[LoginManager getInstance] getUid]];
    NSString *nodata =  [SysTools getValueFromNSUserDefaultsByKey:noExportIMData];
    if([CheckNilValue(nodata) isEqual:@"1"]){
        if(block){
            block(0);
        }
        return YES;
    }
    RCMessageDBHelper *db=[[RCMessageDBHelper alloc] init];
    RCMessage *item=[db findLastMessage];
    NSString *senduid=@"";
    NSString *getuid=@"";
    NSString *sendtime=@"";
    if(item!=nil && item.messageId>0){
        senduid=item.senderUserId;
        getuid=item.targetId;
        sendtime=[NSString stringWithFormat:@"%lld",item.sentTime];
    }
    
    [[RequestTools getInstance] get:API_Check_ExportHistroy(senduid,getuid,sendtime) isCache:NO completion:^(NSDictionary *dict) {
        if(block){
            block(1);
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [SysTools syncNSUserDeafaultsByKey:noExportIMData withValue:@"1"];
        if(block){
            block(0);
        }
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"%@",request.responseString);
    }];
    return NO;
}

-(BOOL) checkExportIMPause{
    NSString *isExportIMDataTotal=[NSString stringWithFormat:@"isExportIMDataTotal%@",[[LoginManager getInstance] getUid]];
    NSString *total=[SysTools getValueFromNSUserDefaultsByKey:isExportIMDataTotal];
    if(total!=nil){
        return YES;
    }else{
        return NO;
    }
}

-(void)exportIMData:(StartDownloadBlock)startBlock receive:(ReceiveSizeBlock)receive finish:(FinishBlock)finishBlock{
    if([self checkExportIMData]){
        return;
    }
    //上层方法已经验证code==10000，否则此处需要验证
    startBlock();
    [self exportIMDataReceive:receive finish:finishBlock];
}

-(ASIFormDataRequest *)exportIMDataReceive:(ReceiveSizeBlock)receive finish:(FinishBlock)finishBlock{
    NSString *path=getDocumentsFilePath([NSString stringWithFormat:@"/%@/%@/%@",RCKey,[[LoginManager getInstance] getUid],@"RCTemp.db"]);
    NSString *_tempPath=getDocumentsFilePath([NSString stringWithFormat:@"/%@/%@/%@",RCKey,[[LoginManager getInstance] getUid],@"RCTemp.temp"]);
    NSString *isExportIMData =[NSString stringWithFormat:@"ExportIMData%@",[[LoginManager getInstance] getUid]];
    
    NSString *isExportIMDataTotal=[NSString stringWithFormat:@"isExportIMDataTotal%@",[[LoginManager getInstance] getUid]];

    WSLog(@"请求接口:%@",API_GET_UserOldMESSAGE);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_GET_UserOldMESSAGE]];
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [request setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //www.tutuim.com/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f)",@"www.tutuim.com",[SysTools getAppVersion],[[UIDevice currentDevice] userAgentName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale];
    //    WSLog(@"%@",userAgent);
    [request setUserAgentString:userAgent];
    [request setTimeOutSeconds:HttpTimeOutSecond];
    [request setNumberOfTimesToRetryOnTimeout:3];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setShowAccurateProgress:YES];
    [request setDownloadDestinationPath:path];
    [request setShouldResetDownloadProgress:YES];
    
    //支持断点续传
    [request setTemporaryFileDownloadPath:_tempPath];
    [request setAllowResumeForFileDownloads:YES];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    // Test if file already exists (partly downloaded) to set HTTP `bytes` header or not
    if (![fm fileExistsAtPath:_tempPath]) {
        [fm createFileAtPath:_tempPath
                    contents:nil
                  attributes:nil];
    }
    else {
        long long receiveValue = [[fm attributesOfItemAtPath:_tempPath error:nil] fileSize];
        
//        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", receiveSize];
//        WSLog(@"获取的已下载大小：%@",range);
        NSString *totalValue=[SysTools getValueFromNSUserDefaultsByKey:isExportIMDataTotal];
        if(totalValue!=nil && ![@"" isEqual:totalValue]){
            receive(receiveValue,[totalValue longLongValue]);
        }
        
    }

    __block ASIFormDataRequest *reQ=request;
    __block long long receiveSize = 0;
    //一定要设置，不设置setDownloadSizeIncrementedBlock获取到的是1
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders) {
//         WSLog(@"返回：%@",responseHeaders);
//        WSLog(@"请求：%@",reQ.requestHeaders);
    }];
    __block BOOL isStart=NO;
    [request setDownloadSizeIncrementedBlock:^(long long size) {
        WSLog(@"总大小size:%lld",size);
        //验证第一个执行的回调
        if(size>1 && !isStart && [LoginManager getInstance].isLogin){
            isStart=YES;
        }
    }];
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        receiveSize = receiveSize + size;
//        WSLog(@"进度bytes=%lld   total:%lld   receiveSize:%lld ",size,total,receiveSize);
        receive(receiveSize,total);
        
        [SysTools syncNSUserDeafaultsByKey:isExportIMDataTotal withValue:[NSString stringWithFormat:@"%lld",total]];
    }];
    [request setFailedBlock:^{
        WSLog(@"下载数据失败！");
        finishBlock(NO);
    }];
    [request setCompletionBlock:^{
        if(checkFileIsExsis(path)){
            RCTempDBHelper *tempDB=[[RCTempDBHelper alloc] init];
            NSMutableArray *messageArr=[tempDB findTempRCMessageList];
            NSMutableArray *conversationArr=[tempDB findTempRCConversationList];
            
            RCMessageDBHelper *db=[[RCMessageDBHelper alloc] init];
            //清空数据
            [db clearAllMessage];
            
            //对数据做处理
            //            BOOL saveMessage=[db saveRCTMessage:messageArr];
            //            BOOL saveConversation= [db saveConversation:conversationArr];
            
            //不对数据做处理
            BOOL saveMessage=[db saveTempDBToMessage:messageArr];
            BOOL saveConversation=[db saveTempDBToConversation:conversationArr];
            
            if(saveMessage && saveConversation){
                [SysTools syncNSUserDeafaultsByKey:isExportIMData withValue:@"1"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:path error:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DOWNLOAD_IMDATA_SUCCESS object:self];
                
            }
        }
        [SysTools removeNSUserDeafaultsByKey:isExportIMDataTotal];
        
        NSString *fileMessage=[[reQ responseHeaders] objectForKey:@"Content-Disposition"];
        //获取filename=的位置
        NSRange range = [fileMessage rangeOfString:@"filename="];
        //开始截取
        NSString *fileName = [fileMessage substringFromIndex:range.location + range.length];
        [[RequestTools getInstance] get:API_DownLoad_Success(fileName) isCache:NO completion:^(NSDictionary *dict) {
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
        
        finishBlock(YES);
        
    }];
    
    [request startAsynchronous];
    
    return request;
}


/**
 * 设置常用联系人条件，更新时间
 */
-(void)setFavContacts:(NSString *)uid{
    UserInfoDB *db=[[UserInfoDB alloc] init];
    UserInfo *info = [db findWidthUID:uid];
    if(info && info.uid!=nil && ![@"" isEqual:info.uid]){
        info.nickname=info.realname;
        info.followtime=[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
        [db updateUser:info];
    }
}


//
-(void)synchronousLocalMessage{
    // 同步个人信息
    [self synchronousSelfInfo];
    
    // 同步好友信息
    [self synchronousFriendList];
    
    // 同步好友申请信息
//    [self synchronousApplyList];
    
    // 缓存输入框和表情数据
    [self synchronousInputList:nil];
    [self synchronousFaceList:nil];
}

-(void)synchronousSelfInfo{
    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    
    NSString *time=[db findWidthUID:SynchMarkTypeUserInfo];
    NSString *api=[NSString stringWithFormat:@"%@?localupdatetime=%@",API_GET_SELFINFO,time];
    
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        @try {
            if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                NSDictionary *item=[dict objectForKey:@"data"];
                UserInfo *user=[[LoginManager getInstance] parseDictData:[item objectForKey:@"userinfo"]];
                [[LoginManager getInstance] saveInfoToDB:user];
                
                //保存更新时间
                NSString *time=[item objectForKey:@"updatetime"];
                [db saveSynchData:SynchMarkTypeUserInfo withTime:time];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
    }];
}

- (void)synchronousFriendList{
    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    NSString *localUpdateTime=[db findWidthUID:SynchMarkTypeUserInfo];
    UserInfoDB *userinfoDB = [[UserInfoDB alloc]init];
    NSString *localNewTime = [userinfoDB findNewUserInfo].addtime;
    NSString *localLastTime = [userinfoDB findNewUserInfo].addtime;
    
    WSLog(@"%@",API_Sync_My_Friend(localNewTime, localLastTime, localUpdateTime));
    [[RequestTools getInstance]get:API_Sync_My_Friend(localNewTime, localLastTime, localUpdateTime) isCache:NO completion:^(NSDictionary *dict) {
        NSDictionary *data = dict[@"data"];
        @try {
            NSArray *addlist = data[@"addlist"];
            NSArray *dellist = data[@"dellist"];
            NSString *updatetime = [data[@"updatetime"] stringValue];
            
            NSMutableArray *addArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dic in addlist) {
                UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
                [addArr addObject:info];
            }
            if(addArr && addArr.count>0){
                // 事务提交
                [userinfoDB saveUserInfoWithArr:addArr];
            }
            
            NSMutableString *friendID = [[NSMutableString alloc] init];
            // 拼接uid
            
            for (NSDictionary *dic in dellist) {
                UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
                
                if(![[[LoginManager getInstance] getUid] isEqual:info.uid]){
                    [friendID appendFormat:@"%@,",info.uid];
                }
            }
            if(friendID!=nil && ![@"" isEqual:friendID]){
                [friendID appendString:@")"];
                if([friendID hasSuffix:@",)"]){
                    [friendID replaceCharactersInRange:NSMakeRange(friendID.length-2, 2) withString:@""];
                    [friendID stringByReplacingOccurrencesOfString:@",)" withString:@""];
                }
                //一次删除
                [userinfoDB deleteUserInfoByUID:friendID];
            }
            
            
            
            [db updateSynchMark:SynchMarkTypeUserInfo withTime:updatetime];
            
            //如果一次没有导入完成，继续导入
            if(addlist!=nil && addlist.count==200){
                [self synchronousFriendList];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
    }];
}


-(void)synchronousApplyList{
    ApplyLeaveDB *db = [[ApplyLeaveDB alloc] init];
    NSString *new = [db findNewModel].uptime;
    NSString *old = [db findOldModel].uptime;
    
//    WSLog(@"接口：%@",API_Get_friend_applylis(new,old));
    [[RequestTools getInstance]get:API_Get_friend_applylis(new,old) isCache:NO completion:^(NSDictionary *dict) {
            NSArray *datas = dict[@"data"];
        NSMutableArray *arr=[[NSMutableArray alloc] init];
        for (NSDictionary  *dic in datas) {
            ApplyFriendModel *model = [ApplyFriendModel initWithDic:dic];
            [arr addObject:model];
//            [db saveApplyToDB:model];
        }
        if(arr && arr.count>0){
            [db saveApplyWithArr:arr];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"申请数据：\n%@",request.responseString);
    }];
}

// 下载应用中的输入框
-(void)synchronousInputList:(FinishBlock) block{
    [[RequestTools getInstance] get:API_Get_InputList isCache:YES completion:^(NSDictionary *dict) {
        NSDictionary *cacheDict=[SysTools getValueFromNSUserDefaultsByKey:API_Get_InputList];
        if(cacheDict!=nil && ![cacheDict isEqual:dict]){
            [SysTools syncNSUserDeafaultsByKey:CheckInputUpdate withValue:@"1"];
        }
        
        [SysTools syncNSUserDeafaultsByKey:API_Get_InputList withValue:dict];
        if(block){
            block(1);
        }
        
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
    }];
}
//同步表情数据
-(void)synchronousFaceList:(FinishBlock) block{
    
    [[RequestTools getInstance] get:API_Get_FaceList isCache:YES completion:^(NSDictionary *dict) {
        NSDictionary *cacheDict=[SysTools getValueFromNSUserDefaultsByKey:API_Get_FaceList];
        if(cacheDict!=nil && ![cacheDict isEqual:dict]){
            [SysTools syncNSUserDeafaultsByKey:CheckFaceUpdate withValue:@"1"];
        }
        
        [SysTools syncNSUserDeafaultsByKey:API_Get_FaceList withValue:dict];
        if(block){
            block(1);
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
//        WSLog(@"%@",request.responseString);
    }];
}

@end
