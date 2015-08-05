//
//  FriendSearchController.h
//  Tutu
//
//  Created by feng on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RecommentCell.h"
#import "NavBaseController.h"
#import "LXActionSheet.h"
#import "UserFansCell.h"

@interface FriendSearchController : NavBaseController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RecommentCellDeletage,LXActionSheetDelegate,FansCellDelegate>


@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISearchDisplayController *strongSearchDisplayController;

@end
