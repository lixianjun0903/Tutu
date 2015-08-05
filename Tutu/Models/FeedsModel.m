//
//  FeedsModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "FeedsModel.h"

@implementation FeedsModel


-(FeedsModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _tipid=CheckNilValue([dict objectForKey:@"tipid"]);
            _action=CheckNilValue([dict objectForKey:@"action"]);
            _data=CheckNilValue([dict objectForKey:@"data"]);
            _routeid=CheckNilValue([dict objectForKey:@"routeid"]);
            _addtime=CheckNilValue([dict objectForKey:@"addtime"]);
            _actionuid=CheckNilValue([dict objectForKey:@"actionuid"]);
            _actionid=CheckNilValue([dict objectForKey:@"actionid"]);
            _avatartime=CheckNilValue([dict objectForKey:@"avatartime"]);
            _nickname=CheckNilValue([dict objectForKey:@"nickname"]);
            _read=CheckNilValue([dict objectForKey:@"read"]);
            _userhonorlevel=[CheckNilValue([dict objectForKey:@"userhonorlevel"]) intValue];
            _isauth=[CheckNilValue([dict objectForKey:@"isauth"]) intValue];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
