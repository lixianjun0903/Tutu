//
//  ApplyFriendModel.h
//  Tutu
//
//  Created by gexing on 3/19/15.
//  Copyright (c) 2015 zxy. All rights reserved.

//

#import "BaseModel.h"

@interface ApplyModel : BaseModel;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *frienduid;
@property(nonatomic,strong)NSString *applymsg;
@property(nonatomic)BOOL isme;
@property(nonatomic,retain) NSString *addtime;
@end

@interface ApplyFriendModel : BaseModel

@property(nonatomic,strong)NSString *frienduid;
@property(nonatomic) NSInteger relation;
@property(nonatomic,strong)NSString *nickname;
@property(nonatomic,strong)NSString *avatartime;
@property(nonatomic,strong)NSString *gender;
@property(nonatomic,strong)NSString *sign;
@property(nonatomic)NSInteger isblock;
@property(nonatomic)NSInteger age;
@property(nonatomic)NSInteger userhonorlevel;
@property(nonatomic)NSInteger topicblock;
@property(nonatomic,strong)NSString *applymsg;
//    0等待验证 1已添加  2添加好友   3接受申请
@property(nonatomic)NSInteger applystatus;
@property(nonatomic)NSInteger applytype;
@property(nonatomic,strong)NSString *applytime;
@property(nonatomic,strong)NSMutableArray *applymsglist;
@property(nonatomic)BOOL isSelected;
@property(nonatomic,strong)NSString *inputText;


@property(nonatomic,retain) NSString *uptime;
// 数据库使用
// 1 删除，默认是0
@property(nonatomic,assign)BOOL isDel;

// 是否已读 0未读，1已读
@property(nonatomic,assign)BOOL isread;



+(ApplyFriendModel *)initWithDic:(NSDictionary *)dic;
+(UserInfo *)convertToUserInfo:(ApplyFriendModel *)model;
@end
