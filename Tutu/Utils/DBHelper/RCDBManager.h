//
//  RCDBManager.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-19.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "FMDatabaseAdditions.h"

#import "RCDBParamsDefines.h"

/**
 * @brief 对数据链接进行管理，包括链接，关闭连接
 * 可以建立长连接 长连接
 */
@interface RCDBManager : NSObject {
    
}
/// 数据库操作对象，当数据库被建立时，会存在次至
@property (nonatomic, readonly) FMDatabase * dataBase;  // 数据库操作对象

/// 单例模式 1、实际，2零时
+(RCDBManager *) defaultDBManager;


/// 关闭连接
- (void) close;

@end
