//
//  SessionModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SessionModel.h"

@implementation SessionModel


-(SessionModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _avatartime=CheckNilValue([dict objectForKey:@"avatartime"]);
            _count=CheckNilValue([dict objectForKey:@"count"]);
            _message=CheckNilValue([dict objectForKey:@"message"]);
            _messageid=CheckNilValue([dict objectForKey:@"messageid"]);
            _nickname=CheckNilValue([dict objectForKey:@"nickname"]);
            _uid=CheckNilValue([dict objectForKey:@"uid"]);
            _uptime=CheckNilValue([dict objectForKey:@"uptime"]);
            _isBlock=[CheckNilValue([dict objectForKey:@"isBlock"]) boolValue];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


@end

