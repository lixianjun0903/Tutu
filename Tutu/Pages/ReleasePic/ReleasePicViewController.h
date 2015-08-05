//
//  ReleasePicViewController.h
//  Tutu
//
//  Created by feng on 14-10-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TTLinkedTextView.h"
#import "SendTopicDelegate.h"
#import "TopicCacheDB.h"

#import "topicSelectedViewController.h"
#import "UserSearchController.h"

@interface ReleasePicViewController : BaseController<UIGestureRecognizerDelegate,UITextViewDelegate,SearchUserPageDelegate,topicSelectedDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)UIImage *releaseImage;

@property(nonatomic)CGFloat  duration;

@property(nonatomic,assign) NSInteger pageType;
@property(nonatomic,assign) CGPoint commentPoint;

@property(nonatomic,retain) CommentModel *commentModel;
@property(nonatomic,retain) TopicModel *topicModel;


@property (strong, nonatomic) UICollectionView *listCollectionView;
@property (nonatomic) int comeFrom;//0,表示从首页调整过来，1，表示从详情页跳转过来，2，表示详情列表页面调整过来 3,,表示从话题列表页面

@end
