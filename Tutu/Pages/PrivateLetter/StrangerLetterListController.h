//
//  StrangerLetterListController.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/11.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

#import "RCLetterListCell.h"
#import "RCIMClient.h"
#import "RCSessionModel.h"

@interface StrangerLetterListController : BaseController<UITableViewDelegate,UITableViewDataSource,RCListItemClickDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end
