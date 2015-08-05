//
//  SendLocalTools.h
//  Tutu
//
//  Created by zhangxinyao on 14-11-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDevice-Hardware.h"
#import "SvUDIDTools.h"

#import "TopicCacheDB.h"

@protocol SendLocalTools;

typedef void(^StartDownloadBlock)();
typedef void(^ReceiveSizeBlock)(long long size,long long total);
typedef void(^FinishBlock)(int isSuccess);
typedef void(^HadExportIMData) (int isExport);

@class ASIFormDataRequest;
@interface SendLocalTools : NSObject

+(SendLocalTools *) getInstance;



///////////////////////////////////////////
// 本方法只在后台运行，发送网络请求和网络变化2种情况
// 提交本地未提交[主题、评论]到服务器
///////////////////////////////////////////
-(void)sendLocalData;

//上传位置信息
-(void)sendLocalToServer:(NSString *)latitude lon:(NSString *) longitude;


///////////////////////////////////////////
// 上传本地通讯录
///////////////////////////////////////////
- (void)sendAddresBookSuccessCallback:(void (^)(void)) successCallback startCallBack:(void (^)(void)) startCallback errorCallback:(void (^)(void)) errorCallback finishCallback:(void (^)(void)) finishCallback;


//连接融云
-(void)connetIM;


//导入聊天数据
-(BOOL)checkExportIMData;

// 网络判断，有没有下载的内容
-(BOOL)checkhadExportIMData:(HadExportIMData) block;

//判断是否暂停或连接中断但未下载完
-(BOOL) checkExportIMPause;
-(void)exportIMData:(StartDownloadBlock) startBlock receive:(ReceiveSizeBlock) receive finish:(FinishBlock) finishBlock;
// 重新导入
// 添加返回参数，方便设置中暂停
-(ASIFormDataRequest *)exportIMDataReceive:(ReceiveSizeBlock)receive finish:(FinishBlock)finishBlock;


/**
 * 设置常用联系人条件
 * 更新时间
 */
-(void)setFavContacts:(NSString *)uid;


//上传视频主题
-(ASIFormDataRequest *) sendVideoTopic:(TopicModel *) topicmodel;
//上传图片主题
-(ASIFormDataRequest *) sendTopic:(TopicModel *) topicmodel;


// 同步数据
// 1、个人资料
// 2、好友数据
// 3、好友申请
// 4、输入框
// 5、表情
-(void)synchronousLocalMessage;

// 同步好友信息
-(void) synchronousFriendList;


//下载输入框数据
-(void)synchronousInputList:(FinishBlock) block;

//下载表情数据
-(void)synchronousFaceList:(FinishBlock) block;

@end
