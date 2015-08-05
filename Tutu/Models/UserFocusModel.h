//
//  UserFocusModel.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface UserFocusModel : BaseModel
@property(nonatomic,strong) NSString *fid;      //关注列表排序Id
@property(nonatomic,strong) NSString *restype;  //关注类型：1为话题，2为位置
@property(nonatomic,strong) NSString *resid;    //关注的id：restype=1，表示resid为话题id
@property(nonatomic,strong) NSString *title;    //标题


@property(nonatomic,strong) NSString *viewcount;
@property(nonatomic,strong) NSString *viewhumancount;

@property(nonatomic,strong) NSString *usercount;
@property(nonatomic,strong) NSString *topiccount;
@property(nonatomic,strong) NSArray *topiclist;



//
// 个人页关注，以下字段不适用
//
@property(nonatomic,strong) NSString *content;  //图片

@property(nonatomic,strong) NSString *height;

@property(nonatomic,strong) NSString *width;

@property(nonatomic,strong) NSString *desc;     //内容描述

@property(nonatomic,assign) BOOL isfollow; //0未关注，1已关注

@property(nonatomic,strong) NSString *newnum;   //新消息数量

@property(nonatomic,strong) NSString *isread;




-(UserFocusModel *) initWithMyDict:(NSDictionary *)dict;

-(NSMutableArray *)getWithArray:(NSArray *)listArray;

@end


@interface UserFocusTopicModel : BaseModel

@property(nonatomic,strong) NSString * topicid;
@property(nonatomic,strong) NSString * content;
@property(nonatomic,strong) NSString * height;
@property(nonatomic,strong) NSString * width;

-(UserFocusTopicModel *) initWithMyDict:(NSDictionary *)dict;

-(NSMutableArray *)getWithArray:(NSArray *)listArray;

@end