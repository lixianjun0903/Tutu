//
//  RCTempDBHelper.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "RCTempDBHelper.h"

@implementation RCTempDBHelper

-(id)init{
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [RCTempManager defaultDBManager].dataBase;
    }
    //[self createDataBase];
    return self;
}

//
-(NSMutableArray *) findTempRCMessageList{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ ",RCT_MESSAGE_COLUMNS_WITHOUTID,RCT_MESSAGE];
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        NSDictionary *dict=[rs resultDictionary];
        
//        NSMutableDictionary *tDict=[[NSMutableDictionary alloc] init];
//        
//        for (NSString *key in [dict allKeys]) {
//            NSString *v=[dict objectForKey:key];
//            if([@"category_id" isEqual:key]||[@"is_top" isEqual:key]||[@"last_time" isEqual:key]||[@"top_time" isEqual:key]||[@"extra_column1" isEqual:key]||[@"extra_column2" isEqual:key]||[@"extra_column3" isEqual:key]){
//                if(v==nil){
//                    v=@"0";
//                }else{
//                    v=[NSString stringWithFormat:@"%lld",[v longLongValue]];
//                }
//            }else if(v==nil){
//                v=@"";
//            }else if([@"content" isEqual:key]){
//                v=[v stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
//                
////                v=[v stringByReplacingOccurrencesOfString:@"\"extra\":{\"" withString:@"\"extra\":\"{\""];
////                
////                
////                NSRange range = [v rangeOfString:@"\"extra\":"];
////                
////                if(range.location==NSNotFound){
////                    v=[v stringByReplacingOccurrencesOfString:@"\"}}" withString:@"\"}\"}"];
////                }else{
////                    v=[v stringByReplacingOccurrencesOfString:@",\"buttonlink\":\"\"}}" withString:@",\"buttonlink\":\"\"}\"}"];
////                }
////                
////                
////                ///////
////                v=[v stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
////                
////                v=[v stringByReplacingOccurrencesOfString:@"\"extra\":{\"" withString:@"\"extra\":\"{\""];
////                
////                
////                NSRange range = [v rangeOfString:@"\"extra\":"];
////                if(range.location>0){
////                    NSString *tv1=[v substringFromIndex:range.location+range.length];
////                    NSString *tv2=[v stringByReplacingOccurrencesOfString:tv1 withString:@"\"{}\"}"];
////                    
////                    tv1=[tv1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
////                    
////                    tv1=[tv1 stringByReplacingOccurrencesOfString:@"}}" withString:@"}\"}"];
////                    tv1=[tv1 stringByReplacingOccurrencesOfString:@"\\\"{" withString:@"{"];
////                    
////                    v=[NSString stringWithFormat:@"%@",tv2];
////                }
//                
//            }else{
//                v=CheckNilValue(v);
//            }
//            [tDict setObject:v forKey:key];
//        }
        
        [array addObject:dict];
    }
    [rs close];
    return array;
}

-(NSMutableArray *) findTempRCConversationList{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ ",RCT_CONVERSATION_COLUMNS,RCT_CONVERSATION];
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        NSDictionary *dict=[rs resultDictionary];
        
//        NSMutableDictionary *tDict=[[NSMutableDictionary alloc] init];
//        
//        for (NSString *key in [dict allKeys]) {
//            NSString *v=[dict objectForKey:key];
//            if([@"category_id" isEqual:key]||[@"is_top" isEqual:key]||[@"last_time" isEqual:key]||[@"top_time" isEqual:key]||[@"extra_column1" isEqual:key]||[@"extra_column2" isEqual:key]||[@"extra_column3" isEqual:key]){
//                if(v==nil){
//                    v=@"0";
//                }else{
//                    v=[NSString stringWithFormat:@"%lld",[v longLongValue]];
//                }
//            }else if(v==nil){
//                v=@"";
//            }else if([@"content" isEqual:key]){
//                v=[v stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
//            }
//            
//            
//            [tDict setObject:v forKey:key];
//        }
        
        [array addObject:dict];
    }
    [rs close];
    return array;
}

@end
