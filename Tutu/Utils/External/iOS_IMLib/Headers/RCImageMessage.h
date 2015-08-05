//
//  RCImageMessage.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"
#import <UIKit/UIKit.h>
#define RCImageMessageTypeIdentifier            @"RC:ImgMsg"
/**
    图片消息类定义
 */
@interface RCImageMessage : RCMessageContent
/**
 *  Push消息内容
 */
@property(nonatomic, strong) NSString* pushContent;
/**
 *  附加信息
 */
@property(nonatomic, strong) NSString* extra;
/** 缩略图 */
@property(nonatomic, strong) UIImage* thumbnailImage;
/** 实际图片URL */
@property(nonatomic, strong) NSString* imageUrl;
/** 原始图 */
@property(nonatomic, strong) UIImage* originalImage;
/**
    根据给定的图片创建消息实例
    
    @param image      原始图片
 */
+(instancetype)messageWithImage:(UIImage *)image;
/**
    根据跟定的图片URL创建消息实例
    
    @param  imageURI    图片URL
 */
+(instancetype)messageWithImageURI:(NSString *)imageURI;

@end
