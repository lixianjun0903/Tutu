//
//  ApplyFriendModel.m
//  Tutu
//
//  Created by gexing on 3/19/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "ApplyFriendModel.h"

@implementation ApplyModel
+(ApplyModel *)initWithDiction:(NSDictionary *)dict{
    ApplyModel *model = [[ApplyModel alloc]init];
    model.uid = dict[@"uid"];
    model.isme = [dict[@"isme"]boolValue];
    model.applymsg = dict[@"applymsg"];
    model.addtime = CheckNilValue(dict[@"addtime"]);
    return model;
}

@end

@implementation ApplyFriendModel
+(ApplyFriendModel *)initWithDic:(NSDictionary *)dic{
    ApplyFriendModel *model = [[ApplyFriendModel alloc]init];
    model.frienduid = dic[@"frienduid"];
    model.relation = [dic[@"relation"] integerValue];
    NSString *remarkname = dic[@"remarkname"];
    if (remarkname.length > 0) {
        model.nickname = remarkname;
    }else{
        model.nickname = dic[@"nickname"];
    }
    model.nickname = dic[@"nickname"];
    model.avatartime = dic[@"avatartime"];
    model.gender = dic[@"gender"];
    model.sign = dic[@"sign"];
    model.isblock = [dic[@"isblock"]integerValue];
    model.age = [dic[@"age"]integerValue];
    model.userhonorlevel = [dic[@"userhonorlevel"]integerValue];
    model.topicblock = [dic[@"topicblock"]integerValue];
    model.applymsg = dic[@"applymsg"];
    model.applystatus = [dic[@"applystatus"]integerValue];
    model.applytype = [dic[@"applytype"]integerValue];
    model.applytime = dic[@"applytime"];
    
    
    model.uptime = CheckNilValue(dic[@"uptime"]);
    model.isread = [CheckNilValue(dic[@"isread"]) boolValue];
    
    NSArray *list = dic[@"applymsglist"];
    NSMutableArray *mArray = [@[]mutableCopy];
    for (NSDictionary *dict in list) {
        ApplyModel *m = [ApplyModel initWithDiction:dict];
        [mArray addObject:m];
    }
    model.isSelected = NO;
    model.applymsglist = mArray;
    return model;

}
+(UserInfo *)convertToUserInfo:(ApplyFriendModel *)model{
    UserInfo *info = [[UserInfo alloc]init];
    info.uid = model.frienduid;
    info.nickname = model.nickname;
    info.relation = FormatString(@"%lu", (long)model.relation);
    info.avatartime = model.avatartime;
    info.sign = model.sign;
    info.gender = model.gender;
    info.isBlock = model.isblock;
    info.age = FormatString(@"%lu", (long)model.age);
    info.topicblock = model.topicblock;
    info.userhonorlevel = (int)model.userhonorlevel;
    return info;
}

@end
