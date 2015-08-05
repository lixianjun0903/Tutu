//
//  RCTextMessage.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"
#define RCTextMessageTypeIdentifier             @"RC:TxtMsg"
/**
    文本消息类定义
 */
@interface RCTextMessage : RCMessageContent
/** 文本消息内容 */
@property(nonatomic, strong) NSString* content;
/**
 *  Push消息内容
 */
@property(nonatomic, strong) NSString* pushContent;

/**
 *  附加信息
 */
@property(nonatomic, strong) NSString* extra;

/**
    根据参数创建文本消息对象
    
    @param content  文本消息内容
 */
+(instancetype)messageWithContent:(NSString *)content;

@end
