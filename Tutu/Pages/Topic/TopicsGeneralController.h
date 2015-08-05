//
//  TopicsGeneralController.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "FocusTopicModel.h"
#import "TopicDelegate.h"

#import "TopicCell.h"

typedef NS_ENUM(int, TopicWithTypePage) {
    TopicWithDefault=1,
    TopicWithPoiPage=2,
};


@protocol GeneralScrollDelegate <NSObject>

-(void)generalScrollDid:(UIScrollView *) scrollview type:(int) type;

-(void)loadDataByNet:(FocusTopicModel *) model;

-(void)openNewController:(UIViewController *)controller;

@end


@interface TopicsGeneralController : BaseController<UITableViewDataSource,UITableViewDelegate,TopicDelegate>

@property (weak, nonatomic) IBOutlet UITableView *listTable;

@property(nonatomic,strong) NSString * topicString;
@property(nonatomic,assign) int showType;
@property(nonatomic,assign) TopicWithTypePage pageType;

@property(nonatomic,strong) NSMutableArray *array;


@property(nonatomic,strong) NSString *startid;

@property(nonatomic,strong) id<GeneralScrollDelegate> delegate;


-(CGPoint) currentContentOffset;

-(void)refreshData;

-(void)setDataToView:(NSMutableArray *)arr;


//其它相关
@property(nonatomic,strong)TopicCell *currentPlayCell;
@property(nonatomic,weak)id <TopicDelegate>topicDelegate;
@property(nonatomic)BOOL isVisible;//当前的tableView是否可视.

@property(nonatomic)BOOL isCurrentPlayCellShow;//当前需要播放的cell是否在显示.

@end
