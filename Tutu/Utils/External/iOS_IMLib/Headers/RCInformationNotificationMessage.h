//
//  RCInformationNotificationMessage.h
//  iOS-IMLib
//
//  Created by xugang on 14/12/4.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCNotificationMessage.h"

#define RCInformationNotificationMessageIdentifier  @"RC:InfoNtf"
/**
 *  通知消息类
 */
@interface RCInformationNotificationMessage : RCNotificationMessage

/**
 *  消息内容
 */
@property(nonatomic, strong) NSString *message; // // 消息内容。 "用户<span userId=\"2123123">哇哈哈</span>邀请你为好友，<a href=\"rong:dslkfjsldjfl/ksdfhkjh\">同意</a>"
/**
 *  附加信息。
 */
@property(nonatomic, strong) NSString *extra; // // 附加信息。
/**
 *  构造方法
 *
 *  @param message 消息内容
 *  @param extra   附加信息。
 *
 *  @return 类实例
 */
+(instancetype)notificationWithMessage:(NSString*)message
                                 extra:(NSString*)extra;

@end
