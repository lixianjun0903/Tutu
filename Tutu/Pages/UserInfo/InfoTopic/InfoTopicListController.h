//
//  InfoTopicListController.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "TopicCollectionViewCell.h"
#import "TopicDetailListController.h"

@protocol UserTopicListDelegate <NSObject>

-(void)topicScrollDidView:(UIScrollView *)topicScrollView;

-(void)openController:(UIViewController *)controller;

@end


@interface InfoTopicListController : BaseController<UICollectionViewDataSource,UICollectionViewDelegate,TopicDetailListControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;

@property (strong , nonatomic) id<UserTopicListDelegate> delegate;

@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) UserInfo *user;
@property (nonatomic,assign) int dataType;
@property (nonatomic,assign) BOOL isMySelf;


-(void)setTitleHeight:(CGFloat) height;


-(void)setLocalData:(NSMutableArray *)arr;

@end
