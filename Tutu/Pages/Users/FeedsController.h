//
//  FeedsController.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "FeedsCell.h"

@interface FeedsController : BaseController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,FeedHeaderClickDelegate>

@property(nonatomic,assign) BOOL fromRoot;

@end
