//
//  MyFriendViewController.h
//  Tutu
//
//  Created by feng on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//


typedef void(^UpdateFriendListBlock)(id data , NSInteger type);
#import "MyFriendCell.h"
#import "LXActionSheet.h"
#import "NavBaseController.h"
#import "AddFriendHeadCell.h"
@interface MyFriendViewController : NavBaseController<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,MyFriendCellDelegate,LXActionSheetDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSString    *uid;
@property(nonatomic,strong)UITableView *mainTable;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic) NSInteger comeForm;

@end
