//
//  FocusUserController.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
typedef NS_ENUM(int, AboutType) {
    AboutFocusType=1,
    AboutLookType=2,
};

@interface FocusUserController : BaseController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *listTable;

@property (strong, nonatomic) NSString *apiString;
@property (assign, nonatomic) AboutType abouttype;
@property (strong, nonatomic) NSString *usernum;


@end
