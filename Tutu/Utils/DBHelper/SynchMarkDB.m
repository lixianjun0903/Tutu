//
//  SynchMarkDB.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-13.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "SynchMarkDB.h"

@implementation SynchMarkDB

- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [TutuDBManager defaultDBManager].dataBase;
    }
    [self createDataBase];
    return self;
}


/**
 * @brief 创建数据库
 */
- (void) createDataBase {
    NSString * sql1 = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ \
                       (auid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \
                       tablename VARCHAR, \
                       addtime VARCHAR, \
                       tabletype VARCHAR, \
                       synchtime VARCHAR)",TutuSynchMark];
    
    
    [_db executeUpdate:sql1];
    
    
    
    //添加列
    // 判断列不存在
    //    if(![self checkColumnName:TutuUserInfo columnName:@"invittime"]){
    //        NSString *addColumnSql1 = [NSString stringWithFormat:
    //                                   @"ALTER TABLE %@ ADD COLUMN invittime VARCHAR",TutuUserInfo];
    //        [_db executeUpdate:addColumnSql1];
    //    }
}

-(BOOL)saveSynchData:(EnumTableType)tabletype withTime:(NSString *)synchtime{
    if(![@"0" isEqual:[self findWidthUID:tabletype]])
    {
        return [self updateSynchMark:tabletype withTime:synchtime];
    }

    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",TutuSynchMark];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:30];
    if (tabletype>0) {
        [keys appendString:@"tabletype,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%d",(int)tabletype]];
    }else {
        return NO;
    }
    
    [keys appendString:@"tablename,"];
    [values appendString:@"?,"];
    [arguments addObject:[self getTableNameByType:tabletype]];
    
    
    int time=[[NSDate new] timeIntervalSince1970];
    [keys appendString:@"addtime,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",time]];
    
    [keys appendString:@"synchtime,"];
    [values appendString:@"?,"];
    [arguments addObject:synchtime];
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
    //    WSLog(@"%@",query);
    //    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    return isOK;
}



-(BOOL)updateSynchMark:(EnumTableType)tabletype withTime:(NSString *)synchtime{
    NSMutableString * query = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",TutuSynchMark];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if (tabletype<1){
        return NO;
    }
    
    if(synchtime!=nil){
        [query appendString:@"synchtime=?,"];
        [arguments addObject:synchtime];
    }
    
    [query appendString:@")"];
    if([query hasSuffix:@",)"]){
        [query replaceCharactersInRange:NSMakeRange(query.length-2, 2) withString:@" "];
        [query stringByReplacingOccurrencesOfString:@",)" withString:@""];
    }
    //    WSLog(@"%@",query);
    [query appendFormat:@" where tabletype = %d ",(int)tabletype];
    
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    return isOK;
}
-(NSString *)findWidthUID:(EnumTableType)tableType{
    NSString *synchtime=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuSynchMark];
    query = [query stringByAppendingFormat:@" where tabletype = %d ",(int)tableType];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    if ([rs next]) {
        synchtime=[self parseResultSet:rs];
    }
    [rs close];
    
    if(synchtime==nil || [@"" isEqual:synchtime]){
        synchtime=@"0";
    }
    return synchtime;
}



//////////////////////////////////////////////////////////////////////////

-(NSString *)parseResultSet:(FMResultSet *)rs{
    @try {
        return CheckNilValue([rs stringForColumn:@"synchtime"]);
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return nil;
}


//////////////////////////////////////////////////////////////////////////

//检查列是否存在
-(BOOL) checkColumnName:(NSString *) tableName columnName:(NSString *) column{
    BOOL isExists=NO;
    NSString * query = [NSString stringWithFormat:@"select * from %@ limit 0",tableName];
    @try {
        FMResultSet * rs = [_db executeQuery:query];
        [rs intForColumn:column];
        NSMutableDictionary *dict=[rs columnNameToIndexMap];
        if(dict!=nil && [dict objectForKey:column]!=nil){
            isExists=YES;
        }
        [rs close];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return isExists;
}

-(NSString *)getTableNameByType:(EnumTableType ) type{
    NSString *name=@"";
    switch (type) {
        case SynchMarkTypeTopicCollection:
            name=TutuTopic;
            break;
        case SynchMarkTypeTopicSend:
            name=TutuTopic;
            break;
        case SynchMarkTypeUserInfo:
            name=TutuUserInfo;
            break;
        default:
            break;
    }
    return name;
}


//////////////////////////////////////////////////////////////////////////
-(BOOL) clearTable{
    NSString * query = [NSString stringWithFormat:@"delete from %@ ;\
                        update sqlite_sequence SET seq = 0 where name = '%@'",TutuSynchMark,TutuSynchMark];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    BOOL isOK=[_db executeUpdate:query];
    return isOK;
}
@end
