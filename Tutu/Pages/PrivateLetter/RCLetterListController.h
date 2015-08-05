//
//  RCLetterListController.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "RCLetterListCell.h"
#import "RCIMClient.h"
#import "RCSessionModel.h"

@interface RCLetterListController : BaseController<UITableViewDelegate,UITableViewDataSource,RCListItemClickDelegate>

@property(nonatomic,assign)BOOL fromRoot;

@end
