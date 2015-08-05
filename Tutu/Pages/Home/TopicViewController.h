//
//  TopicViewController.h
//  Tutu
//
//  Created by gexing on 4/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

typedef NS_ENUM(NSInteger, TopicListType) {
    TopicListTypeHot = 0,
    TopicListTypeFollow,
};

#import "BaseController.h"
#import "ThemeCell.h" 
#import "HuaTiLocationCell.h"
#import "TopicCell.h"
static NSString *topicCell = @"TopicCell";
static NSString *themeCell = @"ThemeCell";
static NSString *huaTiLocationCell = @"HuaTiLocationCell";
@interface TopicViewController : BaseController<UITableViewDataSource,UITableViewDelegate,TopicDelegate>
@property (strong, nonatomic) UITableView *mainTable;
@property(nonatomic,strong)NSMutableArray *dataArrayM;
@property(nonatomic)TopicListType topicType;
@property(nonatomic,strong)UITableViewCell *currentPlayCell;
@property(nonatomic,weak)id <TopicDelegate>topicDelegate;
@property(nonatomic)BOOL isVisible;//当前的tableView是否可视.

@property(nonatomic)BOOL isCurrentPlayCellShow;//当前需要播放的cell是否在显示.
-(void)getcurrentPlayCell;
@end
