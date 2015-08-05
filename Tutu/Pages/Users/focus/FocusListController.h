//
//  FocusListController.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

#import "UserFansCell.h"
#import "LXActionSheet.h"
#import "FocusListDetailController.h"

@interface FocusListController : BaseController<UITableViewDataSource,UITableViewDelegate,FansCellDelegate,LXActionSheetDelegate,SettingReadDelegate>

@property(nonatomic,strong) UserInfo *info;

@end
