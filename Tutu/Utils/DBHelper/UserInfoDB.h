//
//  UserInfoDB.h
//  Tutu
//  用户信息缓存管理，包含用户信息的增、删、改、查
//  Created by zhangxinyao on 15-3-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "UserInfo.h"


@interface UserInfoDB : NSObject{
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
- (BOOL) saveUser:(UserInfo *) item;
- (BOOL)saveUserInfoWithArr:(NSArray *)arr;

/**
 * @brief 保存一条记录
 *
 * @param user 需要保存的用户数据
 */
- (BOOL) updateUser:(UserInfo *) item;

/**
 * @brief 删除某一个用户
 *
 * @param uid
 */
- (BOOL) deleteUserInfoByUID:(NSString *) uid;

/**
 * @brief 查询单个用户
 *
 * @param uid
 */
- (UserInfo *) findWidthUID:(NSString *) uid;


/**
 * @brief 查询所有用户关系
 * 匹配私信列表时使用
 */
-(NSMutableDictionary *)findAllRelationDict;

/**
 *  查询最新的一条记录
 * uid缓存人id
 */
- (UserInfo *) findNewUserInfo;


/**
 *  查询最老的一条记录
 *  uid 缓存人id
 */
- (UserInfo *) findOldUserInfo;

/**
 * @brief 查询我的好友
 *
 * @param uid
 */
- (NSMutableArray *) findMyFriends;


/**
 * @brief 查询我的好友，模糊查询
 *
 * @param uid
 * @param queryString
 */
- (NSMutableArray *) findMyFriends:(NSString *)queryString;

/**
 * @brief 清空数据表，主题和评论
 *
 */
-(BOOL) clearTable;

@end
