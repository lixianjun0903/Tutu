//
//  TopicModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseModel.h"
#import "ActivityModel.h"
#import "UserInfo.h"
typedef NS_ENUM(NSInteger, TopicStatusValue) {
    TopicStatusSend=3,
    TopicStatusCollection=4,
};

@interface HuaTiModel : BaseModel
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *huatitext;
@property(nonatomic,strong)NSString *topicid;

@end

@interface TopicModel : BaseModel

@property(retain,nonatomic)NSString * topicid;
@property(retain,nonatomic)NSString * sourcepath;
@property(nonatomic,strong)NSString *smallcontent;
@property(retain,nonatomic)NSString * commentnum;
@property(retain,nonatomic)NSString * time;
@property(retain,nonatomic)NSString *formattime;
@property(retain,nonatomic)NSString * zan;
@property(retain,nonatomic)NSString * uid;
@property(nonatomic)int views;
@property(nonatomic,strong)NSString *location;
@property(nonatomic,strong)NSString *remarkname;
@property(nonatomic,strong)NSString *client;
@property(nonatomic,strong)NSString *topicDesc;
//主题类型，1图片、5视频
@property(nonatomic)NSInteger type;
@property(nonatomic,strong)NSString *videourl;
@property(nonatomic)CGFloat times;
@property(nonatomic,strong)NSString *poiId;
@property(nonatomic)NSInteger iskana; //1是匿名，0 是默认，正常

@property(nonatomic)CGFloat width;
@property(nonatomic)CGFloat height;
@property(nonatomic)BOOL isLike;
@property(nonatomic,strong)NSString *emptyCommentText;
@property(nonatomic)BOOL isUploadFailed;

//当前选中的索引
@property(nonatomic)NSInteger selectedIndex;
//是否收藏
@property(nonatomic) BOOL favorite;

//关联数据
@property(retain,nonatomic)NSString * nickname;
@property(retain,nonatomic)NSString * avatar;

//本地存储使用
@property(retain,nonatomic)NSString * localid;

//type=1为零时数据，type=0，为缓存数据
@property(retain,nonatomic)NSString * topicType;

// 主题本地分类 topicStatus==3我的发布数据，topicStatus=4为我的收藏数据
@property(retain,nonatomic)NSString * topicStatus;



@property(nonatomic,strong)NSMutableArray *huatilist;
@property(nonatomic,strong)NSString *morelink;


//***********************主要用户关注列表中的滑动位置和话题列表**************
@property(nonatomic,strong)NSString *idtext;
@property(nonatomic)int newcount;
@property(nonatomic,strong)NSMutableArray *topiclist;//关注页面的主题列表

//***************************end*******************************************

//热门评论列表
@property(retain,nonatomic)NSMutableArray * commentList;
//new评论列表
@property(retain,nonatomic)NSMutableArray * newcommentlist;
@property(nonatomic)NSInteger showtype;

@property(nonatomic)CGFloat progress;

@property(nonatomic,strong)UserInfo *userinfo;
@property(nonatomic,strong)NSArray *userlist;//转发的用户列表
@property(nonatomic)int reportTotal;//转发的总数


@property(nonatomic,strong)NSString *reposttopicid;//被转发的主题
@property(nonatomic,strong)NSString *roottopicid;//被转发的源主题。
@property(nonatomic)int fromrepost;//是否为转发主题，0不是，1是。
@property(nonatomic,strong)NSString *createtime;//转发主题的时间
@property(nonatomic)int repostnum; //转发的次数

@property(nonatomic)int userisrepost;//源主题是否被当前用户转发。




// 分享位置
// 1 QQ空间 2微信朋友圈 3新浪微博
@property(nonatomic,assign)int shareType;
@property(nonatomic,strong)NSString * shareUrl;

+(TopicModel *)initTopicModelWith:(NSDictionary *)dic;
+(NSArray *)getTopicModelsWithArray:(NSArray *)listArray;
- (BOOL)isHasTopicid;
- (BOOL)isHasLocalid;
/**
 *  更新数组中某个topicmodel
 *
 *  @param topicModel 用来替换的topicmodel
 *  @param models     传人的可变数组
 *
 *  @return 返回替换后的数组
 */
+(NSMutableArray *)updateTopicModel:(TopicModel *)topicModel array:(NSMutableArray *)models;
/**
 *  更新列表中主题发布者的昵称
 *
 *  @param info   主题发布者的信息
 *  @param models 传人需要变更的数据源数组
 *
 *  @return 返回变更后的数组
 */
+(NSMutableArray *)updateUserName:(UserInfo *)info array:(NSMutableArray *)models;
/**
 *  修改手机名称后，更新数据源中的手机标识
 *
 *  @param phoneName 变更后的名称
 *  @param models    数据源数组
 *
 *  @return 返回变更后的数组
 */
+(NSMutableArray *)updateUserPhoneName:(NSString *)phoneName array:(NSMutableArray *)models;
/**
 *  更新数据源中用户的关系   relation
 *
 *  @param userinfo 传人的用户信息
 *  @param models   传人的数据源
 *
 *  @return 返回变更后的数据源
 */
+(NSMutableArray *)updateUserRelation:(UserInfo *)userinfo array:(NSMutableArray *)models;
/**
 *  删除主题列表中已删除的主题
 *
 *  @param topicModel 需要删除的主题
 *  @param models   数据源数组
 *
 *  @return 返回变更后的数据源
 */
+(NSMutableArray *)updateDeletedTopic:(TopicModel *)topicModel array:(NSMutableArray *)models;

@end