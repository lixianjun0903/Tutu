//
//  SessionModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionModel : NSObject


@property (nonatomic , retain) NSString *avatartime;
@property (nonatomic , retain) NSString *count;
@property (nonatomic , retain) NSString *message;
@property (nonatomic , retain) NSString *messageid;
@property (nonatomic , retain) NSString *nickname;
@property (nonatomic , retain) NSString *uid;
@property (nonatomic , retain) NSString *uptime;
@property (nonatomic , assign) BOOL isBlock;

-(SessionModel *)initWithMyDict:(NSDictionary *)dict;

@end
