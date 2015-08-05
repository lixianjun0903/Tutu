//
//  UserSearchController.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-19.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NavBaseController.h"

@protocol SearchUserPageDelegate <NSObject>

-(void)tableItemClick:(UserInfo *)user;

@end

@interface UserSearchController : NavBaseController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    
}

@property (nonatomic , strong) id<SearchUserPageDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *mainTable;


@end
