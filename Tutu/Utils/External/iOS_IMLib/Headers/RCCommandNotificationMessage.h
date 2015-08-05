//
//  RCCommandNotificationMessage.h
//  iOS-IMLib
//
//  Created by xugang on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCNotificationMessage.h"

#define RCCommandNotificationMessageIdentifier   @"RC:CmdNtf"
/**
 *  命令消息类
 */
@interface RCCommandNotificationMessage : RCNotificationMessage
/**
 *  命令名。
 */
@property(nonatomic, strong) NSString *name; // 命令名。
/**
 *  命令数据，可以为任意格式，如 JSON。
 */
@property(nonatomic, strong) NSString *data; // 命令数据，可以为任意格式，如 JSON。
/**
 *  构造方法
 *
 *  @param name 命令名。
 *  @param data 命令数据，可以为任意格式，如 JSON。
 *
 *  @return 类实例
 */
+(instancetype)notificationWithName:(NSString*)name
                                    data:(NSString*)data;

@end
