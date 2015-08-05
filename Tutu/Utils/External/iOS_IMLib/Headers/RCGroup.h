//
//  RCGroup.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-9-6.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    群信息
 */
@interface RCGroup : NSObject
/** 群ID */
@property(nonatomic, strong) NSString* groupId;
/** 群名称 */
@property(nonatomic, strong) NSString* groupName;
/** 群头像URL */
@property(nonatomic, strong) NSString* portraitUri;

/**
    指派的初始化方法
    
    @param  groupId     群ID
    @param  groupName   群名称
    @param  portraitUri 群头像URI
 */
-(instancetype)initWithGroupId:(NSString*)groupId
                     groupName:(NSString*)groupName
                   portraitUri:(NSString*)portraitUri;
@end
