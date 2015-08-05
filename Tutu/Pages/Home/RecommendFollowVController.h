//
//  RecommendFollowVController.h
//  Tutu
//
//  Created by gexing on 5/14/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "BaseController.h"

@interface RecommendFollowVController : BaseController
@property (strong, nonatomic) UITableView *mainTable;
@property (nonatomic) NSInteger type;//如果是type=0,就是应用进入时的推荐列表，如果type=1,就是首页关注里面的推荐列表
@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic,weak) BaseController *controller;
- (void)initModels:(NSDictionary *)dict;
@end