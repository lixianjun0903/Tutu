//
//  SendTopicDelegate.h
//  Tutu
//
//  Created by zhangxinyao on 14-11-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "TopicModel.h"

@protocol SendTopicDelegate <NSObject>

@optional
//开始发主题，还未添加到网络
-(void)startPostTopic:(TopicModel *) model;

@optional
//成功发送主题，已保存到服务器
-(void)successPostTopic:(NSDictionary *)dict;


//用于回调更新视频的播放次数
- (void)updateViewsCount:(NSString *)topicid views:(NSInteger)count index:(NSInteger)index;

//开始发评论，还未添加到网络
-(void)startPostComment:(CommentModel *)model;

//成功发送评论，已保存到服务器
-(void)successPostComment:(NSDictionary *)dict;

//当topicCell上的元素更新后，需要把数据更新到数据源的数组中
- (void)updateModel:(TopicModel *)topicModel atIndex:(NSInteger)cellIndex;
- (void)updateModel:(TopicModel *)topicModel atIndex:(NSInteger)cellIndex refresh:(BOOL)isRefresh;
//当commentCell上的数据发生变化
- (void)commentDelete:(CommentModel *)commentModel atIndex:(NSIndexPath *)cellIndexPath;

- (void)commentLike:(CommentModel *)commentModel atIndex:(NSIndexPath *)cellIndexPath;

//分享按钮点击
- (void)shareTutuFriend:(TopicModel *)topicModel;
//用户的名称点击
- (void)nameClick:(TopicModel *)topicModel;

@end