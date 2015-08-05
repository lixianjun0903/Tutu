//
//  FansListController.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "UserFansCell.h"
#import "LXActionSheet.h"

@interface FansListController : BaseController<UITableViewDataSource,UITableViewDelegate,FansCellDelegate,LXActionSheetDelegate>

@property(nonatomic,strong) UserInfo *info;
@property(nonatomic,assign) int comefrom;

@end
