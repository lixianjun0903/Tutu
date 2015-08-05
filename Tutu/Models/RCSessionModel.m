//
//  RCSessionModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCSessionModel.h"

@implementation RCSessionModel


-(RCSessionModel *)initWithMyDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        @try {
            self.uid = CheckNilValue([dict objectForKey:@"uid"]);
            self.nickname = CheckNilValue([dict objectForKey:@"nickname"]);
            self.isblock=[CheckNilValue([dict objectForKey:@"isblock"]) intValue];
            self.topicblock=[CheckNilValue([dict objectForKey:@"topicblock"]) intValue];
            self.relation=[CheckNilValue([dict objectForKey:@"relation"]) intValue];
            self.isblockme=[CheckNilValue([dict objectForKey:@"isblockme"]) intValue];
            self.lastmsgtime = [CheckNilValue([dict objectForKey:@"lastmsgtime"]) longLongValue];
            self.lastmsg = CheckNilValue([dict objectForKey:@"lastmsg"]);
            self.userhonorlevel=[CheckNilValue([dict objectForKey:@"userhonorlevel"]) intValue];
            self.isauth=[CheckNilValue([dict objectForKey:@"isauth"]) intValue];

            self.canchat=[CheckNilValue([dict objectForKey:@"canchat"]) boolValue];
            
            self.remarkname=CheckNilValue([dict objectForKey:@"remarkname"]);
            
            if(self.remarkname!=nil && ![@"" isEqual:self.remarkname]){
                self.nickname=self.remarkname;
            }
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
