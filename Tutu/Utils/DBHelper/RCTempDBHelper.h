//
//  RCTempDBHelper.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTempManager.h"


@interface RCTempDBHelper : NSObject{
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 * 数据表，主题表、评论表
 */
//- (void) createDataBase;



/**
 * @brief 查询私信详情，不带id
 * 返回dict
 */
-(NSMutableArray *) findTempRCMessageList;


/**
 * @brief 会话记录
 * 返回dict
 */
-(NSMutableArray *) findTempRCConversationList;


@end
