//
//  BlackListController.h
//  Tutu
//  设置————》隐私———》黑名单
//  Created by zhangxinyao on 15-3-18.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface BlackListController : BaseController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *listTable;

@end
