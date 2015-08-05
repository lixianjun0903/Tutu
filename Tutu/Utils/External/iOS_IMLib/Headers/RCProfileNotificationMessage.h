//
//  RCProfileNotificationMessage.h
//  iOS-IMLib
//
//  Created by xugang on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCNotificationMessage.h"

#define RCProfileNotificationMessageIdentifier   @"RC:ProfileNtf"
/**
 *  资料变更消息
 */
@interface RCProfileNotificationMessage : RCNotificationMessage
/**
 *  资料变更的操作名。
 */
@property(nonatomic, strong) NSString *operation; // 资料变更的操作名。
/**
 *  资料变更的数据，可以为任意格式，如 JSON。
 */
@property(nonatomic, strong) NSString *data; // 资料变更的数据，可以为任意格式，如 JSON。
/**
 *  附加信息。
 */
@property(nonatomic, strong) NSString *extra; // 附加信息。
/**
 *  构造方法
 *
 *  @param operation 资料变更的操作名。
 *  @param data      资料变更的数据，可以为任意格式，如 JSON。
 *  @param extra     附加信息。
 *
 *  @return 类实例
 */
+(instancetype)notificationWithOperation:(NSString*)operation
                                 data:(NSString*)data
                                   extra:(NSString*)extra;


@end
