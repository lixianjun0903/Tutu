//
//  AreaDBHelper.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceNameModel.h"
#import "AreaDBManager.h"

@interface AreaDBHelper : NSObject{
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 */
- (void) createDataBase;


//查询城市信息
- (NSMutableArray *) findProvince;

//查询城市信息
- (NSMutableArray *) findCitysWithProId:(PlaceNameModel *)model;

//查询城市信息
- (NSMutableArray *) findAreasWithCityId:(NSString *)cityid;

@end
