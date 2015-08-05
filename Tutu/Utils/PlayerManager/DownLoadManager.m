//
//  DownLoadManager.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "DownLoadManager.h"
#import "ASINetworkQueue.h"

@interface DownLoadManager(){
    HTTPServer *httpServer;
    
    NSMutableArray *tempArr;
    NSMutableArray *runArr;
}

@end

@implementation DownLoadManager


static DownLoadManager *_instance = nil;

+(DownLoadManager *)getInstance{
    if (_instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[DownLoadManager alloc] init];
        });
    }
    
    return _instance;
}


-(void)startServer{
    
    // Create server using our custom MyHTTPServer class
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:HttpServerPort];
    
    // Serve files from our embedded Web folder
    [httpServer setDocumentRoot:getVideoPath()];
    
    NSError *error;
    if([httpServer start:&error])
    {
        WSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
    }
    else
    {
        WSLog(@"Error starting HTTP Server: %@", error);
    }
}


-(NSString *)getLocalHost{
    return [NSString stringWithFormat:@"http://127.0.0.1:%d/",HttpServerPort];
}

-(NSString *)getLocalHost:(NSString *)fileName{
    return [NSString stringWithFormat:@"%@%@",[self getLocalHost],fileName];
}


-(void)addSimpleDownload:(NSString *)videoURL start:(DownloadStart)startBlock receive:(DownloadBytesReceived)receiveBlock fail:(DownloadFail)failBlock finish:(DownloadFinish)finishBlock{
    if([CheckNilValue(videoURL) isEqual:@""]){
        return;
    }
    
    NSString *videoName=[self getVideoNameByURL:videoURL temp:YES];
    NSString *localPath=[NSString stringWithFormat:@"%@/%@",getVideoPath(),videoName];
    if(checkFileIsExsis(localPath)){
        if(finishBlock){
            finishBlock(videoURL);
        }
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:videoURL]];
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [request setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //www.tutuim.com/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f)",@"www.tutuim.com",[SysTools getAppVersion],[[UIDevice currentDevice] modelName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale];
    //    WSLog(@"%@",userAgent);
    [request setUserAgentString:userAgent];
    [request setDownloadDestinationPath:localPath];
    
    [request setFailedBlock:^{
        if(failBlock){
            failBlock(videoURL);
        }
    }];
    [request setShouldResetDownloadProgress:YES];
    __block long long receiveSize=0;
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        receiveSize=receiveSize+size;
        if(receiveBlock){
            receiveBlock(receiveSize,total);
        }
    }];
    
    [request setCompletionBlock:^{
        if(finishBlock){
            finishBlock(localPath);
        }
    }];
    [request setStartedBlock:^{
        if(startBlock){
            startBlock(videoURL);
        }
    }];
    [request startAsynchronous];
}


-(void)addDownLoad:(NSString *)videoName start:(DownloadStart)startBlock receive:(DownloadBytesReceived)receiveBlock fail:(DownloadFail)failBlock finish:(DownloadFinish)finishBlock{
    NSString *localPath=[NSString stringWithFormat:@"%@/%@",getVideoPath(),videoName];
    if(checkFileIsExsis(localPath)){
        if(finishBlock){
            finishBlock(videoName);
        }
        return;
    }
    
    NSString *api=API_GET_UserOldMESSAGE;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api]];
    NSData *cookies=[SysTools getValueFromNSUserDefaultsByKey:COOKIE_KEY];
    if(cookies!=nil){
        NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:cookies];
        [request setRequestCookies:(NSMutableArray *)arr2];
    }
    
    //www.tutuim.com/<软件版本号>/ios(<手机型号>，<IMEI>，<IMSI>，<系统版本信息>，<屏幕分辨率>,<屏幕尺寸>,<像素密度>)
    NSString *userAgent=[NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f)",@"www.tutuim.com",[SysTools getAppVersion],[[UIDevice currentDevice] modelName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale];
    //    WSLog(@"%@",userAgent);
    [request setUserAgentString:userAgent];
    [request setDownloadDestinationPath:localPath];
    
    [request setFailedBlock:^{
        if(failBlock){
            failBlock(videoName);
        }
    }];
    [request setShouldResetDownloadProgress:YES];
    __block long long receiveSize=0;
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        receiveSize=receiveSize+size;
        if(receiveBlock){
            receiveBlock(receiveSize,total);
        }
    }];
    
    [request setCompletionBlock:^{
        if(finishBlock){
            finishBlock(videoName);
        }
    }];
    [request setStartedBlock:^{
        if(startBlock){
            startBlock(videoName);
        }
    }];
    
    ASINetworkQueue *networkQueue = [[ASINetworkQueue alloc] init];
    [networkQueue reset];
  //  [networkQueue setQualityOfService:NSQualityOfServiceBackground];
    [networkQueue setShowAccurateProgress:YES];
    
    // To do 设置代理相关方法
    
    //设置下载队列属性，设置为1只允许下完一首再下另一首，默认是并行下载不分前后
    [networkQueue setMaxConcurrentOperationCount:4];
    
    [self checkArr:networkQueue.operations url:request.url];
    
    [networkQueue addOperation:request];
    [networkQueue go];
}

/**
 * 检查队列是否已存在
 **/
-(BOOL)checkArr:(NSArray *)arr url:(NSURL *)url{
    BOOL isExists=NO;
    for (ASIHTTPRequest *item in arr) {
        if([item.url isEqual:url]){
            [item cancel];
            isExists=YES;
        }
    }
    return isExists;
}


-(NSString *)getVideoNameByURL:(NSString *)videoUrl temp:(BOOL)istemp{
    if (videoUrl) {
        if(istemp){
            return [NSString stringWithFormat:@"%@/%@.temp",getVideoPath(),md5(videoUrl)];
        }else{
            return [NSString stringWithFormat:@"%@/%@.mp4",getVideoPath(),md5(videoUrl)];
        }
    }
    return nil;
}

@end
