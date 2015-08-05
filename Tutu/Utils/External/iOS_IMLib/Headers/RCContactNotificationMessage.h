//
//  RCContactNotificationMessage.h
//  iOS-IMLib
//
//  Created by xugang on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCNotificationMessage.h"

#define RCContactNotificationMessageIdentifier             @"RC:ContactNtf"

#define ContactNotificationMessage_ContactOperationRequest @"Request" // 加好友请求。
#define ContactNotificationMessage_ContactOperationAcceptResponse @"AcceptResponse" // 加好友请求。
#define ContactNotificationMessage_ContactOperationRejectResponse @"RejectResponse" // 加好友请求。

/**
 *  好友消息类。
 */
@interface RCContactNotificationMessage : RCNotificationMessage
/**
 *  操作名，对应 ContactOperationXxxx，或自己传任何字符串。
 */
@property(nonatomic, strong) NSString *operation; // 操作名，对应 ContactOperationXxxx，或自己传任何字符串。
/**
 *  请求者或者响应者的 UserId。
 */
@property(nonatomic, strong) NSString *sourceUserId; // 请求者或者响应者的 UserId。
/**
 *  被请求者或者被响应者的 UserId。
 */
@property(nonatomic, strong) NSString *targetUserId; // 被请求者或者被响应者的 UserId。
/**
 *  请求或者响应消息，如添加理由或拒绝理由。
 */
@property(nonatomic, strong) NSString *message; // 请求或者响应消息，如添加理由或拒绝理由。
/**
 *  附加信息。
 */
@property(nonatomic, strong) NSString *extra; // 附加信息。
/**
 *  构造方法
 *
 *  @param operation    操作名，对应 ContactOperationXxxx，或自己传任何字符串。
 *  @param sourceUserId 请求者或者响应者的 UserId。
 *  @param targetUserId 被请求者或者被响应者的 UserId。
 *  @param message      请求或者响应消息，如添加理由或拒绝理由。
 *  @param extra        附加信息。
 *
 *  @return 类实例
 */
+(instancetype)notificationWithOperation:(NSString*)operation
                          sourceUserId:(NSString *)sourceUserId
                                    targetUserId:(NSString *)targetUserId
                                 message:(NSString*)message
                                   extra:(NSString*)extra;


@end
