//
//  RCClientDelegate.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-12.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMessage.h"
#import "RCUserInfo.h"
#import "RCDiscussion.h"
#import "RCStatusDefine.h"

/**
 *  连接服务器的回调。
 */
@protocol RCConnectDelegate <NSObject>

/**
 *  回调成功。
 *
 *  @param userId 当前登录的用户 Id，既换取登录 Token 时，App 服务器传递给融云服务器的用户 Id。
 */
- (void)responseConnectSuccess:(NSString*)userId;

/**
 *  回调出错。
 *
 *  @param errorCode 连接错误代码。
 */
- (void)responseConnectError:(RCConnectErrorCode)errorCode;
@end

/**
 *  执行操作的回调。
 */
@protocol RCOperationDelegate <NSObject>

/**
 *  执行成功。
 *
 *  @param object 调用对象。
 */
- (void)responseOperateSuccess:(id)object;

/**
 *  执行出错。
 *
 *  @param errorCode 执行错误代码。
 *  @param object 调用对象。
 */
- (void)responseOperateError:(RCErrorCode)errorCode object:(id)object;
@end

/**
 *  发送消息的回调。
 */
@protocol RCSendMessageDelegate <NSObject>

/**
 *  发送消息成功。
 *
 *  @param errorCode    状态码。
 *  @param messageId 消息 Id。
 *  @param object    调用对象。
 */
- (void)responseSendMessageStatus:(RCErrorCode)errorCode messageId:(long)messageId object:(id)object;
@optional

/**
 *  发送消息进度。图片或视频类需要上传的消息会有上传进度。
 *
 *  @param progress 发送消息的进度值，0-100。
 *  @param messageId 消息 Id。
 *  @param object    调用对象。
 */
-(void)responseProgress:(int)progress messageId:(long)messageId object:(id)object;

/**
 *  发送消息出错。
 *
 *  @param errorCode 发送消息错误代码。
 *  @param messageId  消息 Id。
 *  @param object     调用对象。
 */
-(void)responseError:(int)errorCode messageId:(long)messageId object:(id)object;
@end

/**
 *  创建讨论组的回调。
 */
@protocol RCCreateDiscussionDelegate <NSObject>

/**
 *  创建讨论组成功。
 *
 *  @param discussInfo 创建的讨论组信息。
 *  @param object      调用对象。
 */
- (void)responseCreateDiscussionSuccess:(RCDiscussion*)discussInfo object:(id)object;

/**
 *  创建讨论组出错。
 *
 *  @param errorCode 创建讨论组错误代码。
 */
- (void)responseCreateDiscussionError:(RCErrorCode)errorCode;
@end

/**
 *  下载文件的回调。
 */
@protocol RCDownloadMediaDelegate <NSObject>

/**
 *  下载进度。
 *
 *  @param progress 进度值，范围为 0 - 100。
 *  @param object   调用对象。
 */
-(void)responseProgress:(int)progress object:(id)object;

/**
 *  下载文件成功。
 *
 *  @param localMediaPath 下载的文件的本地路径。
 */
-(void)responseSuccess:(NSString*)localMediaPath;

/**
 *  下载文件出错。
 *
 *  @param errorCode 下载文件错误代码。
 *  @param object    调用对象。
 */
-(void)responseError:(int)errorCode object:(id)object;
@end

/**
 *  获取用户信息的回调。
 */
@protocol RCGetUserInfoDelegate<NSObject>

/**
 *  获取用户信息成功。
 *
 *  @param userInfo 获取的用户信息。
 */
-(void)responseGetUserInfoSuccess:(RCUserInfo*)userInfo;

/**
 *  获取用户信息出错。
 *
 *  @param errorCode 获取用户信息错误代码。
 */
-(void)responseGetUserInfoError:(RCErrorCode)errorCode;
@end

/**
 *  获取讨论组信息的回调。
 */
@protocol RCGetDiscussionDelegate<NSObject>

/**
 *  获取讨论组信息成功。
 *
 *  @param discussionInfo 获取的讨论组信息。
 *  @param object         调用对象。
 */
-(void)responseDiscussionInfoSuccess:(RCDiscussion*)discussionInfo object:(id)object;

/**
 *  获取用户信息出错。
 *
 *  @param errorCode 获取用户信息错误代码。
 *  @param object 调用对象。
 */
-(void)responseDiscussionInfoError:(RCErrorCode)errorCode object:(id)object;
@end

/**
 *  接收消息的监听器。
 */
@protocol RCReceiveMessageDelegate <NSObject>

/**
 *  收到消息的处理。
 *
 *  @param message 收到的消息实体。
 *  @param object  调用对象。
 */
-(void)responseOnReceived:(RCMessage*)message left:(int)nLeft object:(id)object;
@end

/**
 *  连接状态监听器，以获取连接相关状态。
 */
@protocol RCConnectionStatusDelegate <NSObject>

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
-(void)responseConnectionStatus:(RCConnectionStatus)status;
@end

/**
 *  重新连接状态监听器，以获取连接相关状态。
 */
@protocol RCReconnectStatusDelegate <NSObject>

/**
 *  重新连接状态监听器，以获取连接相关状态。
 *
 *  @param status 重新连接状态。
 */
-(void)reconnectStatus:(int)status;

@end









