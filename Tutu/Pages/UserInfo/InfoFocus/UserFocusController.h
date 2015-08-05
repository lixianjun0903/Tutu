//
//  UserFocusController.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "UserFocusCell.h"

@protocol UserFocusListDelegate <NSObject>

-(void)focusScrollViewDidView:(UIScrollView *)focusScrollView;
-(void)openController:(UIViewController *)controller;

@end

@interface UserFocusController : BaseController<UITableViewDataSource,UITableViewDelegate,UserFocusTopicDelegate>

@property (strong ,nonatomic) id<UserFocusListDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *listTable;

@property (nonatomic ,strong) NSString *uid;

@property (nonatomic ,assign) CGFloat tableHeaderHeight;


@end
