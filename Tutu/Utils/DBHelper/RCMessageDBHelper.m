//
//  RCMessageDBHelper.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-19.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCMessageDBHelper.h"
#import "RCExportMessageModel.h"
#import "RCExportSessionModel.h"

@implementation RCMessageDBHelper

-(id)init{
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [RCDBManager defaultDBManager].dataBase;
    }
    //[self createDataBase];
    return self;
}

-(BOOL)saveConversation:(NSArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        int failCount=0;
        for (NSDictionary *dict in arr) {
            RCExportSessionModel *item=[[RCExportSessionModel alloc] initWithMyDict:dict];
            if(item!=nil || item.target_id!=nil){
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(target_id,category_id,conversation_title,draft_message,is_top,last_time,top_time,extra_column1) VALUES (%@,%d,%@,%@,%@,%@,%@,%@)",RCT_CONVERSATION
                                 ,item.target_id
                                 ,item.category_id
                                 ,nil
                                 ,nil
                                 ,@"0"
                                 ,item.last_time
                                 ,nil
                                 ,item.extra_column1];
//                NSArray *items=[[NSArray alloc] initWithObjects:
//                                item.target_id,
//                                [NSString stringWithFormat:@"%d",item.category_id],
//                                item.conversation_title,
//                                @"",@"0",
//                                item.last_time,@"0",item.extra_column1, nil];
//                BOOL a = [_db executeUpdate:sql withArgumentsInArray:items];
                BOOL a = [_db executeUpdate:sql];
                if (!a) {
                    WSLog(@"%@",sql);
                    NSLog(@"插入列表失败1");
                    failCount=failCount+1;
                }else{
                    WSLog(@"插入列表成功😊😊😊😊😊");
                }
            }
            
        }
        if(failCount==arr.count){
            isRollBack=YES;
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
        }else{
            [_db rollback];
        }
    }
    
    return !isRollBack;
}


-(BOOL)saveRCTMessage:(NSArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        int failCount=0;
        for (NSDictionary *dict in arr) {
            RCExportMessageModel *item=[[RCExportMessageModel alloc] initWithMyDict:dict];
            if(item!=nil || item.target_id!=nil){
                
                NSString *str=CheckNilValue([item.content JSONString]);
                NSString *ext_str=nil;
                if(item.extra_content!=nil)
                {
                    ext_str = CheckNilValue([item.extra_content JSONString]);
                }
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(target_id,category_id,message_direction,read_status,receive_time,send_time,clazz_name,content,send_status,sender_id,extra_content,extra_column1) VALUES (%@,%d,%d,%d,%@,%@,'%@',replace('%@','\\/','\/'),%d,%@,%@,%d)",RCT_MESSAGE
                                 ,item.target_id
                                 ,item.category_id
                                 ,item.message_direction
                                 ,item.read_status
                                 ,item.receive_time
                                 ,item.send_time
                                 ,item.clazz_name
                                 ,str
                                 ,item.send_status
                                 ,item.sender_id
                                 ,ext_str
                                 ,1
                                 ];
                
                
//                BOOL a = [_db executeUpdate:sql withArgumentsInArray:items];
                BOOL a = [_db executeUpdate:sql];
                WSLog(@"%@",sql);
                if (!a) {
                    NSLog(@"插入内容失败1");
                    failCount=failCount+1;
                }
            }
        }
        
        if(failCount==arr.count){
            isRollBack=YES;
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
        }else{
            [_db rollback];
        }
    }
    
    return !isRollBack;
}


-(BOOL)saveTempDBToConversation:(NSArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        int failCount=0;
        for (NSDictionary *dict in arr) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (%@)",RCT_CONVERSATION,RCT_CONVERSATION_COLUMNS_ADDNum];
            BOOL a = [_db executeUpdate:sql withParameterDictionary:dict];
            if (!a) {
                NSLog(@"插入失败1");
                failCount=failCount+1;
            }else{
//                WSLog(@"会话：😊😊😊😊😊😊😊😊😊");
            }
        }
        if(failCount==arr.count){
            isRollBack=YES;
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
        }else{
            [_db rollback];
        }
    }
    
    return !isRollBack;
}

-(BOOL)saveTempDBToMessage:(NSArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        int failCount=0;
        for (NSDictionary *dict in arr) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",RCT_MESSAGE,RCT_MESSAGE_COLUMNS_WITHOUTID,RCT_MESSAGE_COLUMNS_ADDNum];
            BOOL a = [_db executeUpdate:sql withParameterDictionary:dict];
            if (!a) {
                NSLog(@"插入失败1");
                failCount=failCount+1;
            }else{
//                WSLog(@"详情：😊😊😊😊😊😊😊😊😊");
            }
        }
        
        if(failCount==arr.count){
            isRollBack=YES;
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
        }else{
            [_db rollback];
        }
    }
    
    return !isRollBack;
}

-(RCMessage *)findLastMessage{
    RCMessage *rcmessage=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",RCT_MESSAGE];
    query = [query stringByAppendingFormat:@" order by sentTime asc limit 1 "];
    //    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        rcmessage=[self parseResultSet:rs];
    }
    [rs close];
    return rcmessage;
}


-(BOOL)clearAllMessage{
    NSString * query = [NSString stringWithFormat:@"delete from %@ ;\
                        update sqlite_sequence SET seq = 0 where name = '%@';",RCT_CONVERSATION,RCT_CONVERSATION];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    
    query = [query stringByAppendingFormat:@";delete from %@ ;\
             update sqlite_sequence SET seq = 0 where name = '%@';",RCT_MESSAGE,RCT_MESSAGE];
    BOOL isOK=[_db executeUpdate:query];
    return isOK;

}

-(RCMessage *)parseResultSet:(FMResultSet *) rs{
    RCMessage *item=[[RCMessage alloc] init];
    @try {
        item.messageId=[[rs stringForColumn:@"id"] intValue];
        item.targetId=[rs stringForColumn:@"target_id"];
        item.senderUserId=[rs stringForColumn:@"sender_id"];
        item.receivedTime=[[rs stringForColumn:@"receive_time"] longLongValue];
        item.sentTime=[[rs stringForColumn:@"send_time"] longLongValue];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return item;
}


@end
