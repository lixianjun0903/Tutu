//
//  RCMessageDBHelper.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-19.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCDBManager.h"


@interface RCMessageDBHelper : NSObject{
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 * 数据表，主题表、评论表
 */
//- (void) createDataBase;


//解析插入
-(BOOL)saveConversation:(NSArray *)arr;

//解析插入消息
-(BOOL)saveRCTMessage:(NSArray *)arr;


/**
 * @brief 添加聊天记录
 * 数据表，主题表、评论表
 */
-(BOOL)saveTempDBToConversation:(NSArray *)arr;

/**
 * @brief 会话记录
 * 数据表，主题表、评论表
 */
-(BOOL)saveTempDBToMessage:(NSArray *)arr;



/**
 * @brief 查询最旧的记录
 * 
 */
-(RCMessage *)findLastMessage;

-(BOOL)clearAllMessage;


@end