//
//  FocusListDetailController.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "UserFocusCell.h"
#import "LXActionSheet.h"
#import "ListTopicsController.h"

@protocol SettingReadDelegate <NSObject>

-(void)setReadStatus:(TopicWithTypePage ) type;

@end


@interface FocusListDetailController : BaseController<UITableViewDataSource,UITableViewDelegate,UserFocusTopicDelegate,LXActionSheetDelegate>

@property(nonatomic,strong) UserInfo *info;


@property(nonatomic,strong) id<SettingReadDelegate> delegate;

//
@property(nonatomic,assign) TopicWithTypePage pageType;

@end
