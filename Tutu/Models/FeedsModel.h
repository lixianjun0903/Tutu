//
//  FeedsModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedsModel : NSObject

@property (nonatomic , retain) NSString *tipid;
@property (nonatomic , retain) NSString *action;
@property (nonatomic , retain) NSString *actionuid;
@property (nonatomic , retain) NSString *actionid;
@property (nonatomic , retain) NSString *data;
@property (nonatomic , retain) NSString *routeid;
@property (nonatomic , retain) NSString *addtime;
@property (nonatomic , retain) NSString *avatartime;
@property (nonatomic , retain) NSString *nickname;
@property (nonatomic , retain) NSString *read;


//等级
@property (nonatomic,assign) int userhonorlevel;
@property (nonatomic,assign) int isauth;


-(FeedsModel *)initWithMyDict:(NSDictionary *)dict;

@end
