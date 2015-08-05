//
//  AreaDBHelper.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AreaDBHelper.h"

@implementation AreaDBHelper

- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [AreaDBManager defaultDBManager].dataBase;
        
    }
    [self createDataBase];
    return self;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase {
//    // TODO: 插入新的数据库
//    NSString * sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ \
//                      (uid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, \
//                      nickname text, \
//                      avatar text, \
//                      funnum integer NOT NULL DEFAULT 0, \
//                      attentionnum integer NOT NULL DEFAULT 0, \
//                      area text,\
//                      sex text,\
//                      token text)",kUserTableName];
//    //        BOOL res = [_db executeUpdate:sql];
//    [_db executeUpdate:sql];
}

-(NSMutableArray *)findProvince{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM T_province order by cast(prosort as int) asc"];
    
    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    while ([rs next]) {
        PlaceNameModel *placeModel=[PlaceNameModel new];
        placeModel.prosort=[rs stringForColumn:@"prosort"];
        placeModel.proname=[rs stringForColumn:@"proname"];
        placeModel.proremark=[rs stringForColumn:@"proremark"];
        [array addObject:placeModel];
    }
    [rs close];
    return array;
}

-(NSMutableArray *)findCitysWithProId:(PlaceNameModel *)pnm{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT B.* FROM T_Province A,T_city B "];
    query = [query stringByAppendingFormat:@" WHERE B.proid = A.prosort and B.proid=%@ ORDER BY cast(citysort as int) asc ",pnm.prosort];
    
    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    while ([rs next]) {
        CityModel *model=[CityModel new];
        model.citysort=[rs stringForColumn:@"citysort"];
        model.proid=[rs stringForColumn:@"proid"];
        model.cityname=[rs stringForColumn:@"cityname"];
        model.pname=pnm.proname;
        
        
        [array addObject:model];
        
    }
    [rs close];
    
    if([@"直辖市" isEqual:pnm.proremark]){
        NSMutableArray *items=[self findAreasWithCityId:((CityModel *)[array objectAtIndex:0]).citysort];
        [array removeAllObjects];
        for (AreaModel *item in items) {
            CityModel *cm=[CityModel new];
            cm.proid=pnm.prosort;
            cm.cityname=item.zonename;
            cm.citysort=item.cityid;
            cm.pname=pnm.proname;
            [array addObject:cm];
        }
    
    }
    return array;
}

-(NSMutableArray *)findAreasWithCityId:(NSString *)cityid{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT B.* FROM T_City A,T_zone B "];
    query = [query stringByAppendingFormat:@" WHERE A.citysort = B.Cityid and A.citysort=%@ ORDER BY cast(zoneid as int) asc ",cityid];
    
    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    while ([rs next]) {
        AreaModel *model=[AreaModel new];
        model.cityid=[rs stringForColumn:@"cityid"];
        model.zoneid=[rs stringForColumn:@"zoneid"];
        model.zonename=[rs stringForColumn:@"zonename"];
        [array addObject:model];
    }
    [rs close];
    return array;
}

@end
