//
//  PhoneModelSetVController.h
//  Tutu
//
//  Created by gexing on 5/14/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "BaseController.h"

@interface PhoneModelSetVController : BaseController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *mainTable;
@end
