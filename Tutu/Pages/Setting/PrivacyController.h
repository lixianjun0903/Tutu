//
//  PrivacyController.h
//  Tutu
//  设置————》隐私
//  Created by zhangxinyao on 15-3-18.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface PrivacyController : BaseController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *listTable;


@property (assign, nonatomic) int fromPage;

@end
