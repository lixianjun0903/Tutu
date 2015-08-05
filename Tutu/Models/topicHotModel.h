//
//  topicHotModel.h
//  Tutu
//
//  Created by gexing on 15/4/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface topicHotModel : NSObject
@property(nonatomic,strong)NSString *htid;
@property(nonatomic,strong)NSString *httext;
@property(nonatomic,strong)NSString *isfollow;
@property(nonatomic,strong)NSString *htviewcount;
@property(nonatomic,strong)NSString *topiccount;
@property(nonatomic,strong)NSString *htusercount;
@property(nonatomic,strong)NSString *picurl;
@property(nonatomic,strong)NSString *joinusercount;

+(topicHotModel *)initWithMyDict:(NSDictionary *)dict;

@end
