//
//  TopicDetailListController.h
//  Tutu
//
//  Created by gexing on 14/12/3.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
typedef NS_ENUM(NSInteger, TopicType) {
    TopicTypeList,//我的主题列表
    TopicTypeFavoriteList,//我收藏的主题列表
};



@protocol TopicDetailListControllerDelegate <NSObject>
@optional
- (void)topicModelsChange:(NSArray *)topicModels;

- (void)favoriteModelsChange:(NSArray *)models;

- (void)deleteTopicModelAtIndex:(NSInteger)index;

- (void)deleteFavoriteAtIndex:(NSInteger)index;

@end

#import "BaseController.h"
#import "TopicCollectionCell.h"
#import "ReleasePicViewController.h"
#import "LXActionSheet.h"
@interface TopicDetailListController : BaseController<SendTopicDelegate,LXActionSheetDelegate,UIGestureRecognizerDelegate,TopicDelegate>

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollection;
@property(nonatomic,strong)NSArray *dataArray;
@property(nonatomic,strong)NSMutableArray *mutableArray;
@property(nonatomic) NSInteger currentIndex;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic)TopicType topicType;
@property(nonatomic,weak)id <TopicDetailListControllerDelegate>delegate;

@property(nonatomic,strong)TopicCollectionCell *currentCell;
@property(nonatomic,strong)TopicCollectionCell *lastCell;
@property(nonatomic,strong)UIButton *commentButton;
- (void)hidenCommentButton;
- (void)showCommentButton;
- (void)resetTableContentOffset;
@end

