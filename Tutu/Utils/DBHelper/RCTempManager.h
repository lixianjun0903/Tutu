//
//  RCTempManager.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "RCDBParamsDefines.h"

/**
 * @brief 对数据链接进行管理，包括链接，关闭连接
 * 可以建立长连接 长连接
 */
@interface RCTempManager : NSObject {
    
}
/// 数据库操作对象，当数据库被建立时，会存在次至
@property (nonatomic, readonly) FMDatabase * dataBase;  // 数据库操作对象

/// 单例模式 1、实际，2零时
+(RCTempManager *) defaultDBManager;

// 关闭数据库
- (void) close;

@end
