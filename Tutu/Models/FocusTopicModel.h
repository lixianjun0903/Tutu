//
//  FocusTopicModel.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-14.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface FocusTopicModel : BaseModel

@property(nonatomic,strong) NSString *ids;
@property(nonatomic,strong) NSString *idtext;
@property(nonatomic,assign) BOOL isfollow;
//观看数
@property(nonatomic,assign) int viewcount;
@property(nonatomic,strong) NSString * viewhumancount;

//帖子数
@property(nonatomic,assign) int topiccount;
//用户关注数
@property(nonatomic,assign) int usercount;


@property(nonatomic,strong) NSMutableArray *userlist;

@property(nonatomic,strong) NSMutableArray *topiclist;


// 分享时使用
@property(nonatomic,strong) TopicModel *topicModel;



-(FocusTopicModel *) initWithMyDict:(NSDictionary *)dict;

@end
