//
//  RCExportSessionModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCExportSessionModel : NSObject

@property (retain,nonatomic)NSString * target_id;
@property (assign,nonatomic)int category_id;
@property (retain,nonatomic)NSString * conversation_title;
@property (retain,nonatomic)NSString * last_time;
@property (retain,nonatomic)NSString * extra_column1;

-(RCExportSessionModel *)initWithMyDict:(NSDictionary *)dict;

@end
