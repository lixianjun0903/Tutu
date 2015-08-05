//
//  TopicCollectionCell.h
//  Tutu
//
//  Created by feng on 14-10-22.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicModel.h"
#import "CommentModel.h"
#import "TopicDetailController.h"
#import "TopicDelegate.h"
@interface TopicCollectionCell : UICollectionViewCell <TopicDelegate>
@property(nonatomic,strong)TopicModel *topicModel;
@property(nonatomic)NSInteger cellIndexPathRow;
@property(nonatomic,weak)id <SendTopicDelegate> delegate;
@property(nonatomic,weak)id <TopicDelegate> topicDelegate;
@property(nonatomic,weak)id controller;
@property(nonatomic,strong)TopicDetailController *topicController;
@property(nonatomic)BOOL isTopicDetailList;

- (void)loadCellWithModel:(TopicModel *)model;
//cell滑动
@end
