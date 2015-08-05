//
//  UserViewController.h
//  Tutu
//  用户信息，替换 UserDetailController
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "UserHeaderView.h"

#import "InfoTopicListController.h"
#import "UserFocusController.h"

@interface UserViewController : BaseController<UserTopicListDelegate,UserFocusListDelegate,UserViewHeaderDelegate>

@property(nonatomic,strong) UserInfo *user;
@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *nickname;


@end
