//
//  TopicCacheDB.h
//  Tutu
//
//  Created by zhangxinyao on 14-11-4.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
#import "TutuDBManager.h"
#import "TopicModel.h"
#import "CommentModel.h"


@interface TopicCacheDB : NSObject{
    FMDatabase * _db;
}


/**
 * @brief 创建数据库
 * 数据表，主题表、评论表
 */
- (void) createDataBase;

/**
 * @brief 保存一条记录
 *
 * @param user 需要保存的用户数据
 */
- (BOOL) saveTopic:(TopicModel *) item;

/**
 * @brief 修改主题中的发布人的备注
 *
 * @param user 修改备注时使用
 */
-(BOOL)updateTopicNickName:(NSString *) uid nickName:(NSString *) nickname;


// 保存主题评论
- (BOOL) saveTopicComment:(CommentModel *) item;

/**
 * @brief 删除主题,同时会删除主题评论
 *
 * @param topicid
 */
- (BOOL) deleteTopicByTopicID:(NSString *) topicID;
- (BOOL) deleteTopicByTopicID:(NSString *) topicID withType:(TopicStatusValue)type;

-(BOOL) deleteTopicWithLoaclId:(NSString *)localid;
-(BOOL) deleteCommonWithLoaclId:(NSString *)localid;


/**
 * @brief 查询主题评论
 *
 * @param topicid
 */
- (NSMutableArray *) findTopicCommentWithTopicId:(NSString *)topicid page:(int) page len:(int) length;
//查询为提交的评论
- (NSMutableArray *) findTopicCommentWithLocalTopicId:(NSString *)localtopicid;

/* *
 * 查询本地未上传的主题
 * 1 临时发布的图片主题
 * 5 临时发布的视频主题
 * */
- (NSMutableArray *) findTopicWithType:(int) topicType;
- (NSMutableArray *) findLocalTopicComment;


/**
 * 获取最新的一条记录
 * type 3/发布 4收藏
 */
-(TopicModel *)checkTopicModel:(NSString *)topicId topicStatus:(TopicStatusValue )type;


/**
 * 获取最新的一条记录
 * type 3/发布 4收藏
 */
-(TopicModel *)getNewTopicModel:(TopicStatusValue )type;


/**
 * 获取最后一条记录
 * type 3/发布 4收藏
 */
-(TopicModel *)getOldTopicModel:(TopicStatusValue )type;


/**
 * 获取最后一条记录
 * type 3/发布 4收藏
 */
-(NSMutableArray *)getCacheListWithType:(TopicStatusValue)type;

/**
 * 获取时间以后的列表
 * type 3/发布 4收藏
 */
-(NSMutableArray *)getCacheListWithType:(TopicStatusValue)type startTime:(NSString *)time;



/**
 * @brief 清空数据表，主题和评论
 *
 */
-(BOOL) clearTable;

@end