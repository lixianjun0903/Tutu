//
//  DownLoadManager.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpServer.h"

#define HttpServerPort 22345

@protocol DownLoadManager;
typedef void(^DownloadStart)(NSString *videoURL);
typedef void(^DownloadFail)(NSString *videoURL);
typedef void(^DownloadBytesReceived)(unsigned long long size, unsigned long long total);
typedef void(^DownloadFinish)(NSString *videoURL);

@interface DownLoadManager : NSObject


+(DownLoadManager *)getInstance;



/**
 * 开启本地server
 * 必须启动应用就调用didFinishLaunchingWithOptions
 * 否则本地连接无法访问
 */
-(void)startServer;


/**
 * 获取系统访问路径
 */
-(NSString *)getLocalHost;

/**
 * fileName 文件名称，如xxx.mp4
 **/
-(NSString *)getLocalHost:(NSString *)fileName;

-(void)addSimpleDownload:(NSString *)videoURL start:(DownloadStart) startBlock receive:(DownloadBytesReceived) receiveBlock fail:(DownloadFail) failBlock finish:(DownloadFinish) finishBlock;

-(void)addDownLoad:(NSString *)videoURL start:(DownloadStart) startBlock receive:(DownloadBytesReceived) receiveBlock fail:(DownloadFail) failBlock finish:(DownloadFinish) finishBlock;


/**
 * 根据视频网络路径，获取视频本地路径
 * videoURL 视频路径
 * istemp 是临时文件，还是正式文件
 */
-(NSString *)getVideoNameByURL:(NSString *) videoUrl temp:(BOOL) istemp;

@end
