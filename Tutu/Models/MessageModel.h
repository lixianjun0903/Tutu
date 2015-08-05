//
//  MessageModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMessageModel;

@interface MessageModel : NSObject

@property (nonatomic , retain) NSString *uid;
@property (nonatomic , retain) NSString *messageid;
@property (nonatomic , retain) NSString *content;
@property (nonatomic , retain) NSString *addtime;
@property (nonatomic , retain) NSString *avatartime;


@property (nonatomic , retain) NSString *type;
@property (nonatomic , retain) SMessageModel *messagepictext;


-(MessageModel *)initWithMyDict:(NSDictionary *)dict;

-(NSArray *)getMessageArray:(NSArray *)listArray;

@end


@interface SMessageModel : NSObject


@property (nonatomic , retain) NSString *title;
@property (nonatomic , retain) NSString *content;
@property (nonatomic , retain) NSString *pic;
@property (nonatomic , retain) NSString *contentlink;
@property (nonatomic , retain) NSString *buttontext;
@property (nonatomic , retain) NSString *buttonlink;

@property (nonatomic , retain) NSString *width;
@property (nonatomic , retain) NSString *height;

-(SMessageModel *)initWithMyDict:(NSDictionary *)dict;

@end
