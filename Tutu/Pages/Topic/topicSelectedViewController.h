//
//  topicSelectedViewController.h
//  Tutu
//
//  Created by gexing on 15/4/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NavBaseController.h"
#import "topicHotModel.h"

typedef NS_ENUM(NSInteger, SearchType)
{
    topicType=1,
    userType=2,
};

@protocol topicSelectedDelegate <NSObject>

-(void)sendText:(topicHotModel *) htModel;

@end

@interface topicSelectedViewController :NavBaseController

@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISearchDisplayController *strongSearchDisplayController;
@property(nonatomic,strong)UITableView *mainTable;
@property(nonatomic,assign)id<topicSelectedDelegate>delegate;

@end
