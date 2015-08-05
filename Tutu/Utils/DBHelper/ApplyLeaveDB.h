//
//  ApplyLeaveDB.h
//  Tutu
//
//  Created by zhangxinyao on 15-3-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutuDBManager.h"
#import "ApplyFriendModel.h"

@interface ApplyLeaveDB : NSObject{
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
- (BOOL) saveApplyToDB:(ApplyFriendModel *) item;
-(BOOL)saveApplyWithArr:(NSArray *)arr;
-(BOOL)saveApplyLeaveToDB:(ApplyModel *)item frienduid:(NSString *)uid;

/**
 * @brief 修改一条记录
 *
 * @param 需要保存的用户数据
 */
- (BOOL) updateApplyToDB:(ApplyFriendModel *) item;


//逻辑删除，修改isDel标记为1
-(BOOL)delApplyDBWidthArray:(NSMutableArray *) items;

//物理删除
-(BOOL)delApplyDB:(NSString *)uid;
-(BOOL)delApplyLeaveDB:(NSString *)uid;

// 根据isDel,直接删除所有待删除数据
-(BOOL)delAllIsDelApplyDB;

/**
 * @brief
 *
 * @param topicid
 */

- (ApplyFriendModel *) findNewModel;
- (ApplyFriendModel *) findOldModel;

- (ApplyFriendModel *) findModelWidthUID:(NSString *) friendUID;
- (NSMutableArray *)findAppModelWidthUID:(NSString *)friendUid;

//获取所有标记为删除的数据
- (NSMutableArray *)findAllApplyWithDel;


//获取说有本地是未读取状态的数据
// isread 0未读，1已读
- (NSMutableArray *)findAllApplyWithIsRead:(BOOL) isread;

// 设置未读标记为已读
-(BOOL)updateReadStatus:(NSMutableArray *) items;

/**
 * @brief 根据表类型获取表名称
 *
 * @param 表类型
 */
-(NSMutableArray *)findAllWithPage:(int)page len:(int)length;

/**
 * @brief 清空数据表，主题和评论
 *
 */
- (NSMutableArray *)findAllApplyModel;
-(BOOL) clearTable;

@end
