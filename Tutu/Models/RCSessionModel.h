//
//  RCSessionModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCSessionModel : NSObject

/*!
 本地数据
 */
@property(nonatomic, strong) NSString* uid;
@property(nonatomic, strong) NSString* nickname;
@property(nonatomic, strong) NSString* remarkname;
@property(nonatomic, assign) int isblock;
@property(nonatomic, assign) int topicblock;
@property(nonatomic, assign) int relation;
@property(nonatomic, assign) int isblockme;
@property(nonatomic, assign) long long lastmsgtime;
@property(nonatomic, strong) NSString *lastmsg;



//额外字段，不参与model逻辑使用，只做传值
@property(nonatomic, assign) int cansendmessage;
@property(nonatomic, strong) NSString *errormsg;

//等级
@property (nonatomic,assign) int userhonorlevel;
@property (nonatomic,assign) int isauth;


@property (nonatomic,assign) BOOL canchat;



/*!
 融云数据
 */
@property(nonatomic, strong) RCConversation * rcconversation;


-(RCSessionModel *)initWithMyDict:(NSDictionary *)dict;

@end
