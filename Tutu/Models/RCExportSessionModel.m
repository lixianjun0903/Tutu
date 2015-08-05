//
//  RCExportSessionModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCExportSessionModel.h"

@implementation RCExportSessionModel

-(RCExportSessionModel *)initWithMyDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        @try {
            self.target_id = CheckNilValue([dict objectForKey:@"target_id"]);
            self.category_id = [CheckNilValue([dict objectForKey:@"category_id"]) intValue];
            self.conversation_title = CheckNilValue([dict objectForKey:@"conversation_title"]);
            self.last_time = CheckNilValue([dict objectForKey:@"last_time"]);
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
