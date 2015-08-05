//
//  CommentModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface CommentModel : BaseModel


//评论编号
@property(retain,nonatomic)NSString * commentid;
//主题编号
@property(retain,nonatomic)NSString * topicid;
//发布人
@property(retain,nonatomic)NSString * uid;
//1内容 2表情
@property(retain,nonatomic)NSString * type;
//评论内容
@property(retain,nonatomic)NSString * comment;
@property(retain,nonatomic)NSString * commentbg;

    @property(nonatomic,strong)NSString *replypart;

@property(nonatomic)NSInteger likenum;
@property(nonatomic)NSInteger islike;

@property(nonatomic,strong) NSString *formataddtime;
//replyData

@property(nonatomic,strong)NSString *replyName;
@property(nonatomic,strong)NSString *replyUid;
@property(nonatomic,strong)NSString *replyTxtframe;
@property(nonatomic,strong)NSString *replyCommentid;
@property(nonatomic,strong)NSString *replyFormataddtime;
@property(nonatomic,strong)NSString *replyContent;

//此处只用到了commentbg,commentface后期去掉。
@property(retain,nonatomic)NSString * time;
@property(retain,nonatomic)NSString * pid;
@property(retain,nonatomic)NSString * pointX;
@property(retain,nonatomic)NSString * pointY;

//关联
@property(retain,nonatomic)NSString * nickname;
@property(retain,nonatomic)NSString * avatar;


//本地存储使用
@property(retain,nonatomic)NSString * localtopicid;
@property(retain,nonatomic)NSString * localid;

//当前评论时间
@property(retain,nonatomic)NSString * invideotime;


@property(retain,nonatomic)NSString *  scale;
@property(retain,nonatomic)NSString * rotation;
@property(nonatomic) int comeFrom; //0,表示从首页调整过来，1，表示从详情页跳转过来，2，表示详情列表页面调整过来

+(CommentModel *)initCommentModelWith:(NSDictionary *)dic;
+(NSMutableArray *)getCommentModelList:(NSArray *)array;
@end