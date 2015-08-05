//
//  RCExportMessageModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCExportMessageModel : NSObject

@property (retain,nonatomic)NSString * relation_id;
@property (retain,nonatomic)NSString * target_id;
@property (assign,nonatomic)int  category_id;
@property (assign,nonatomic)int message_direction;
@property (assign,nonatomic)int read_status;
@property (retain,nonatomic)NSString * receive_time;
@property (retain,nonatomic)NSString * send_time;
@property (retain,nonatomic)NSString * clazz_name;
@property (retain,nonatomic)NSDictionary * extra_content;
@property (retain,nonatomic)NSDictionary * content;
@property (assign,nonatomic)int send_status;
@property (retain,nonatomic)NSString * sender_id;
@property (retain,nonatomic)NSString * extra_column1;

-(RCExportMessageModel *)initWithMyDict:(NSDictionary *)dict;


@end
