//
//  RCConversation.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMessageContent.h"
#import "RCStatusDefine.h"

/*!
    @class RCConversation 会话类，用于描述会话的类
 */
@interface RCConversation : NSObject
/*!
    会话类型 @see RCConversationType
 */
@property(nonatomic, assign) RCConversationType conversationType;
/*!
    会话 Id
 */
@property(nonatomic, strong) NSString* targetId;
/*!
    会话名称
 */
@property(nonatomic, strong) NSString* conversationTitle;
/*!
    会话中未读消息数
 */
@property(nonatomic, assign) NSInteger unreadMessageCount;
/*!
    当前会话是否置顶
 */
@property(nonatomic, assign) BOOL isTop;
/*!
    消息阅读状态 @see RCReceivedStatus
 */
@property(nonatomic, assign) RCReceivedStatus receivedStatus;
/*!
    消息发送状态 @see RCSentStatus
 */
@property(nonatomic, assign) RCSentStatus sentStatus;
/*!
    消息接收时间
 */
@property(nonatomic, assign) long long receivedTime;
/*!
    消息发送时间
 */
@property(nonatomic, assign) long long sentTime;
/*!
    消息草稿，尚未发送的消息内容
 */
@property(nonatomic, strong) NSString* draft;
/*!
    会话实体名
 */
@property(nonatomic, strong) NSString* objectName;
/*!
    发送消息用户Id
 */
@property(nonatomic, strong) NSString* senderUserId;
/*!
    发送消息用户名
 */
@property(nonatomic, strong) NSString* senderUserName;
/*!
    当前会话最近一条消息Id
 */
@property(nonatomic, strong) NSString* lastestMessageId;
/*!
    当前会话最近一条消息实体
 */
@property(nonatomic, strong) RCMessageContent* lastestMessage;
/**
 *  会话的json数据
 */
@property(nonatomic, strong) NSDictionary *jsonDict;

/**
    根据JSON 字典创建会话实体
 
    @param  json    存储会话属性的字典
 */
+(instancetype)conversationWithProperties:(NSDictionary*)json;
@end
