//
//  RCExportMessageModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCExportMessageModel.h"

@implementation RCExportMessageModel


-(RCExportMessageModel *)initWithMyDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        @try {
            self.relation_id = CheckNilValue([dict objectForKey:@"relation_id"]);
            self.target_id = CheckNilValue([dict objectForKey:@"target_id"]);
            self.category_id = [CheckNilValue([dict objectForKey:@"category_id"]) intValue];
            self.message_direction = [CheckNilValue([dict objectForKey:@"message_direction"]) intValue];
            self.read_status = [CheckNilValue([dict objectForKey:@"read_status"]) intValue];
            self.receive_time=CheckNilValue([dict objectForKey:@"receive_time"]);
            self.send_time=CheckNilValue([dict objectForKey:@"send_time"]);
            self.clazz_name=CheckNilValue([dict objectForKey:@"clazz_name"]);
            NSString *ext=[dict objectForKey:@"extra_content"];
            if([CheckNilValue(ext) isEqual:@""]){
                self.extra_content=nil;
            }else{
                self.extra_content=nil;//[dict objectForKey:@"extra_content"];
            }
            NSMutableDictionary *cdict=[[NSMutableDictionary alloc] init];
            NSString *cString=[dict objectForKey:@"content"];
            
            NSDictionary *contentdict=[[cString dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONData];
            for (NSString *key in contentdict.allKeys) {
                if([@"extra" isEqual:key]){
                    NSString *extra_str=[contentdict objectForKey:@"extra"];
                    if(![self.clazz_name isEqual:@"RC:ImgTextMsg"]){
                        [cdict setObject:@"{}" forKey:key];
                    }else{
                        [cdict setObject:[extra_str JSONString] forKey:key];
                    }
                }else if([key isEqual:@"content"] || [key isEqual:@"imageUri"] ){
                    if([self.clazz_name isEqual:@"RC:ImgMsg"] || [self.clazz_name isEqual:@"RC:VcMsg"]){
                        NSString *content=[contentdict objectForKey:key];
                        content=[content stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
                        [cdict setObject:content forKey:key];
                    }else{
                        [cdict setObject:[contentdict objectForKey:key] forKey:key];
                    }
                }else{
                    [cdict setObject:[contentdict objectForKey:key] forKey:key];
                }
            }
            self.content=cdict;
            self.send_status=[CheckNilValue([dict objectForKey:@"send_status"]) intValue];
            self.sender_id=CheckNilValue([dict objectForKey:@"sender_id"]);
            self.extra_column1=CheckNilValue([dict objectForKey:@"extra_column1"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


@end
