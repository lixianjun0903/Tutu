//
//  RCRichContentMessage.h
//  RongIM
//
//  Created by Gang Li on 10/17/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "RCMessageContent.h"
#import <UIKit/UIKit.h>
#define RCRichContentMessageTypeIdentifier      @"RC:ImgTextMsg"
/**
    图文消息
 */
@interface RCRichContentMessage : RCMessageContent

/**
 *  Push消息内容
 */
@property(nonatomic, strong) NSString* pushContent;
/** 标题 */
@property(nonatomic, strong)NSString *title;
/** 摘要 */
@property(nonatomic, strong)NSString *digest;
/** 图片URL */
@property(nonatomic, strong)NSString *imageURL;
/** 扩展信息 */
@property(nonatomic, strong)NSString *extra;

/**
    根据给定消息创建新消息
 
    @param  title       标题
    @param  digest      摘要
    @param  imageURL    图片URL
    @param  extra       扩展信息
 */
+(instancetype)messageWithTitle:(NSString *) title
                         digest:(NSString *)digest
                       imageURL:(NSString *)imageURL
                          extra:(NSString *)extra;
@end
