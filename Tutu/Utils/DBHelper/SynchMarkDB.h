//
//  SynchMarkDB.h
//  Tutu
//
//  Created by zhangxinyao on 15-3-13.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"


//用于时间的分类
typedef NS_ENUM(NSInteger, EnumTableType) {
    SynchMarkTypeTopicSend=1,
    SynchMarkTypeTopicCollection=2,
    SynchMarkTypeUserInfo=3,
    SynchMarkTypeApplyLeave=4,
    SynchMarkTypeTopic=5, // 更新时间
};


@interface SynchMarkDB : NSObject{
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 * 数据表，主题表、评论表
 */
- (void) createDataBase;

/**
 * @brief 保存一条记录
 *
 * @param user 需要保存的用户数据
 */
- (BOOL) saveSynchData:(EnumTableType ) tabletype withTime:(NSString *)synchtime;

/**
 * @brief 修改一条记录
 *
 * @param 需要保存的用户数据
 */
- (BOOL) updateSynchMark:(EnumTableType) tabletype withTime:(NSString *)synchtime;


/**
 * @brief 
 *
 * @param topicid
 */
- (NSString *) findWidthUID:(EnumTableType) tableType;


/**
 * @brief 根据表类型获取表名称
 *
 * @param 表类型
 */
-(NSString *)getTableNameByType:(EnumTableType ) type;

/**
 * @brief 清空数据表，主题和评论
 *
 */
-(BOOL) clearTable;

@end

