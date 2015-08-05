//
//  AddressDB.h
//  Tutu
//
//  Created by 刘大治 on 14/12/10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "LinkManModel.h"

@interface AddressDB : NSObject{
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 * 数据表，通讯录关系表
 */
- (void) createDataBase;


/**
 * @brief 保存一条关系记录
 *
 * @param user 需要保存的用户数据
 */
//使用存储过程，一次插入所有数据
- (BOOL) saveListContanst:(NSMutableArray *) arr;

/**
 * @brief 修改一条关系记录
 *
 * @param model 需要修改的全部
 */
- (BOOL) updateContanst:(LinkManModel *)model;

//查询跟我的关系
- (LinkManModel *) findModelWithMyTutuId:(NSString *) mytutuid lid:(NSString *) localid phones:(NSArray *)phones;


-(NSMutableArray *)findAllContacts;

@end