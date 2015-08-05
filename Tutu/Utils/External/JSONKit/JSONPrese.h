//
//  JSONPrese.h
//  GexingParentAssistant
//
//  Created by zhangxinyao on 14-1-10.
//  Copyright (c) 2014年 张 新耀. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HXAddtions)

+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;

+(NSString *) jsonStringWithArray:(NSArray *)array;

+(NSString *) jsonStringWithString:(NSString *) string;

+(NSString *) jsonStringWithObject:(id) object;

@end
