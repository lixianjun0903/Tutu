//
//  UserDetailController.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

#import "UserHeaderCell.h"
#import "UserInfoCell.h"
#import "HFStretchableTableHeaderView.h"
#import "TopicDetailListController.h"

#import "LXActionSheet.h"
#import "XHImageViewer.h"
#import "NewFriendViewController.h"

@interface UserDetailController : BaseController<UITableViewDataSource,UITableViewDelegate,UserHeaderCellDelegate,LXActionSheetDelegate,XHImageViewerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UserInfoCellItemDelegate,TopicDetailListControllerDelegate>


@property (retain,nonatomic) UIActivityIndicatorView *activityView;
@property (retain,nonatomic) HFStretchableTableHeaderView *stretchableTableHeaderView;

@property(nonatomic)NSInteger comefrom;

@property(nonatomic ,assign)BOOL fromRoot;


@property (retain,nonatomic) NSString *uid;
@property (retain,nonatomic) NSString *nickName;
@property (retain,nonatomic) UserInfo *user;

@property(nonatomic,strong) BackBlock backBlock;

@end
