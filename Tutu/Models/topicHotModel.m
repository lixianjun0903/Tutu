//
//  topicHotModel.m
//  Tutu
//
//  Created by gexing on 15/4/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "topicHotModel.h"

@implementation topicHotModel

+(topicHotModel *)initWithMyDict:(NSDictionary *)dict;
{
    topicHotModel *model=[[topicHotModel alloc]init];
    model.htid=CheckNilValue(dict[@"htid"]);
    model.httext=CheckNilValue(dict[@"httext"]);
    model.isfollow=CheckNilValue(dict[@"isfollow"]);
    model.htviewcount=CheckNilValue(dict[@"viewcount"]);
    model.topiccount=CheckNilValue(dict[@"topiccount"]);
    model.picurl=CheckNilValue(dict[@"picurl"]);
    model.joinusercount=CheckNilValue(dict[@"joinusercount"]);
    return model;
}
@end
