//
//  RCUserInfo.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-16.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    用户信息类
 */
@interface RCUserInfo : NSObject
/** 用户ID */
@property(nonatomic, strong) NSString* userId;
/** 用户名*/
@property(nonatomic, strong) NSString* name;
/** 头像URL*/
@property(nonatomic, strong) NSString* portraitUri;

/**
    指派的初始化方法，根据给定字段初始化实例
    
    @param userId       用户ID
    @param username     用户名
    @param portrait     头像URL
 */
-(instancetype)initWithUserId:(NSString*)userId
                         name:(NSString*)username
                     portrait:(NSString*)portrait;
@end
