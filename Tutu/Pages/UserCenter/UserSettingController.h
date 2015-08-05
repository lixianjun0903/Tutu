//
//  UserSettingController.h
//  Tutu
//
//  Created by zhangxinyao on 14-11-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "LXActionSheet.h"
@interface UserSettingController : BaseController<UITextFieldDelegate,LXActionSheetDelegate>

@property(nonatomic , weak) UserInfo *userInfo;

@end
