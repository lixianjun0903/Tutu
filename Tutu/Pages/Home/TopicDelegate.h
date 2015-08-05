//
//  TopicDelegate.h
//  Tutu
//
//  Created by gexing on 4/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ShareActonSheet.h"
#import "CommentModel.h"

@protocol TopicDelegate <NSObject>
@optional

//回调首页，切换 热门和关注。
- (void)topicScrollIndex:(NSInteger)index;
//用于回调到列表页面，更新数据源,
- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index;

- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex;
/**
 *  topicCell上的数据发生变化后，更新下数据源里面的model.
 *
 *  @param model      主题model
 *  @param index      model 在数据源中的索引
 *  @param tabelIndex
 *  @param isReload   是否需要刷新页面。
 */
//头像点击
- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel;
- (void)topicPhoneNameClick:(id)sender;

//@符号点击
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel;//@符号点击

//转发用户点击
- (void)topicReportUserNameClick:(NSString *)userID nickName:(NSString *)name;

//滑动的位置和主题title点击

//首页关注页面位置主题点击
- (void)topicLocationAndHuaTiClick:(NSString *)topicid;

//#号点击
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel;//#号点击
//查看全文点击
- (void)topicDetailClick:(TopicModel *)topicModel;

//首页关注列表的滑动主题和位置点击
- (void)topicThemeTitleOrLocationClick:(TopicModel *)topicModel;

- (void)topicDetailClick:(TopicModel *)topicModel index:(NSInteger)index;
//评论数点击
- (void)topicCommentCountClick:(TopicModel *)topicModel;
//赞的数点击
- (void)topicLikeCountClick:(TopicModel *)topicModel index:(NSInteger)index;
//评论的头像点击
- (void)topicCommentAvatarClick:(CommentModel *)commentModel;
//某人的评论点击
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint) commentPoint;
//位置信息点击
- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel;
//分享类型的按钮点击（分享的逻辑都在cell里面做了处理，分享到tutu好友需要页面跳转，就代理出去了）
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index;
//话题的more点击
- (void)topicHuaTiMoreClick:(TopicModel *)topicModel;
//话题的莫个cell点击
- (void)topicHuaTiClick:(TopicModel *)topicModel index:(NSInteger)index;
@end
