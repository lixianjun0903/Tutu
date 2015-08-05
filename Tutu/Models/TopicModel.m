//
//  TopicModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
//@property(retain,nonatomic)NSString * topicid;
//@property(retain,nonatomic)NSString * sourcepath;
//@property(retain,nonatomic)NSString * commentnum;
//@property(retain,nonatomic)NSString * time;
//@property(retain,nonatomic)NSString * zan;
//@property(retain,nonatomic)NSString * uid;
//
//
#import "TopicModel.h"
#import "CommentModel.h"
@implementation HuaTiModel
+(HuaTiModel *)initWithDic:(NSDictionary *)dic{
    HuaTiModel *model = [[HuaTiModel alloc]init];
    model.content = CheckNilValue(dic[@"content"]);
    model.huatitext = CheckNilValue(dic[@"huatitext"]);
    model.topicid = CheckNilValue(dic[@"topicid"]);
    return model;
}

+(NSMutableArray *)initModelWith:(NSArray *)array{
    NSMutableArray *arrayM = [@[]mutableCopy];
    for (NSDictionary *dic in array) {
        HuaTiModel *model = [HuaTiModel initWithDic:dic];
        [arrayM addObject:model];
    }
    return arrayM;
}


@end
@implementation TopicModel
+(TopicModel *)initTopicModelWith:(NSDictionary *)dic{
    @try {
        if (dic.count > 1) {
            TopicModel *model = [[TopicModel alloc]init];
            model.topicid = CheckNilValue(dic[@"topicid"]);
            model.type = [dic[@"type"]integerValue];//1表示图片，5表示视频，9表示话题
            if (model.type == 9) {
                model.huatilist = [HuaTiModel initModelWith:dic[@"huatilist"]];
                model.morelink = dic[@"morelink"];
            }else if (model.type == 20){//关注页面的滑动主题列表
                model.topicid = CheckNilValue(dic[@"topicid"]);
                model.newcount = [dic[@"newcount"] intValue];
                model.idtext = CheckNilValue(dic[@"idtext"]);
                model.topiclist = [HuaTiModel initModelWith:dic[@"topiclist"]];
                
            }else if (model.type == 21){//关注页面的滑动位置列表
                model.topicid = CheckNilValue(dic[@"topicid"]);
                model.newcount = [dic[@"newcount"] intValue];
                model.idtext = CheckNilValue(dic[@"idtext"]);
                model.poiId = CheckNilValue(dic[@"poiid"]);
                model.topiclist = [HuaTiModel initModelWith:dic[@"topiclist"]];
            }else{
                
                NSArray *reportUsers = dic[@"repostuserinfo"][@"userlist"];
                if (reportUsers.count > 0) {
                    NSMutableArray *arrayM = [@[]mutableCopy];
                    for (NSDictionary *dic in reportUsers) {
                        UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
                        [arrayM addObject:info];
                    }
                    model.userlist = arrayM;
                }
                model.reportTotal = [dic[@"repostuserinfo"][@"total"]intValue];
                
                model.uid = CheckNilValue(dic[@"uid"]);
                model.sourcepath = CheckNilValue(dic[@"content"]);
                model.time = CheckNilValue(dic[@"addtime"]);
                model.formattime = CheckNilValue(dic[@"formattime"]);
                model.zan = [NSString stringWithFormat:@"%d",[CheckNilValue(dic[@"likenum"]) intValue]];
                model.commentnum = [NSString stringWithFormat:@"%d",[CheckNilValue(dic[@"totalcomment"]) intValue]];
                model.avatar = [NSString stringWithFormat:@"%d",[CheckNilValue(dic[@"avatartime"]) intValue]];
                model.width = [CheckNilValue(dic[@"width"]) floatValue];
                model.height = [CheckNilValue(dic[@"height"]) floatValue];
                model.commentList = [CommentModel getCommentModelList:dic[@"hotcommentlist"]];
                
                //兼容 话题列表数据
                if([dic objectForKey:@"topiclist"]!=nil && [[dic objectForKey:@"topiclist"] isKindOfClass:[NSArray class]]){
                    model.commentList = [CommentModel getCommentModelList:dic[@"topiclist"]];
                }
                
                model.newcommentlist = [CommentModel getCommentModelList:dic[@"newcommentlist"]];
                model.client = CheckNilValue(dic[@"client"]);
                model.topicDesc = CheckNilValue(dic[@"desc"]);
                model.poiId = CheckNilValue(dic[@"poiid"]);
                NSString *remarkname = CheckNilValue(dic[@"remarkname"]);
                if (remarkname.length > 0) {
                    model.nickname = CheckNilValue(dic[@"remarkname"]);
                }else{
                    model.nickname = CheckNilValue(dic[@"nickname"]);
                }
                model.reposttopicid = CheckNilValue(dic[@"reposttopicid"]);
                model.roottopicid = CheckNilValue(dic[@"roottopicid"]);
                
                model.fromrepost = [dic[@"fromrepost"]intValue];
                
                
                model.createtime = CheckNilValue(dic[@"createtime"]);
                
                
                model.repostnum = [dic[@"repostnum"]intValue];
                
                
                model.userisrepost = [dic[@"userisrepost"]intValue];
                
                
                model.emptyCommentText = CheckNilValue(dic[@"emptycommenttxt"]);
                model.localid = CheckNilValue(dic[@"localtopicid"]);
                model.selectedIndex = 0;
                model.smallcontent = CheckNilValue(dic[@"smallcontent"]);
                model.location = CheckNilValue(dic[@"poitext"]);
                model.views = [(dic[@"views"]) intValue];
                if ([CheckNilValue(dic[@"islike"]) integerValue] == 1 ) {
                    model.isLike = YES;
                }else{
                    model.isLike = NO;
                }
                if ([CheckNilValue(dic[@"isfav"]) integerValue] == 1) {
                    model.favorite = YES;
                }else{
                    model.favorite = NO;
                }
                UserInfo *info = [[UserInfo alloc] initWithMyDict:dic[@"userinfo"]];
                model.userinfo = info;
                model.selectedIndex = 0;
                model.showtype = [dic[@"showtype"] integerValue];
                model.times = [dic[@"times"]floatValue];
                model.videourl = CheckNilValue(dic[@"videourl"]);
                model.iskana=[dic[@"iskana"] integerValue];
            }
            
            return model;
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return nil;
}
+(NSArray *)getTopicModelsWithArray:(NSArray *)listArray{
    if (listArray==nil || [listArray isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if (listArray.count > 0) {
        NSMutableArray *models = [@[]mutableCopy];
        for (NSDictionary *dic in listArray) {
            if (dic.count > 0) {
                TopicModel *model = [TopicModel initTopicModelWith:dic];
                if(model!=nil){
                    [models addObject:model];
                }
            }
        }
        return models;

    }
    return nil;
}
- (BOOL)isHasTopicid{
    return (CheckNilValue(self.topicid).length == 0)? NO :YES;
}
- (BOOL)isHasLocalid{
    return (CheckNilValue(self.localid).length == 0)? NO :YES;
}
+(NSMutableArray *)updateTopicModel:(TopicModel *)topicModel array:(NSMutableArray *)models{
   
    for (int i = 0; i < models.count; i ++) {
        TopicModel *model = models[i];
        if ([model.topicid isEqualToString:topicModel.topicid]) {
            [models replaceObjectAtIndex:i withObject:topicModel];
            break;
        }
    }
    return models;
}
+(NSMutableArray *)updateUserName:(UserInfo *)info array:(NSMutableArray *)models{
    for (int i = 0; i < models.count; i ++) {
        TopicModel *model = models[i];
        if ([info.uid isEqualToString:model.uid]) {
            model.nickname = info.remarkname;
        }
    }
    return models;
}
+(NSMutableArray *)updateUserPhoneName:(NSString *)phoneName array:(NSMutableArray *)models{

    NSString *currentUserUid = [[LoginManager getInstance]getUid];
    for (int i = 0; i < models.count; i ++) {
        TopicModel *model = models[i];
        if ([model.uid isEqualToString:currentUserUid]) {
            model.client = phoneName;
        }
    }
    return models;
}
+(NSMutableArray *)updateUserRelation:(UserInfo *)userinfo array:(NSMutableArray *)models{
    for (int i = 0; i < models.count; i ++) {
        TopicModel *model = models[i];
        if ([userinfo.uid isEqualToString:model.uid]) {
            model.userinfo.relation = userinfo.relation;
        }
    }
    return models;
}

+(NSMutableArray *)updateDeletedTopic:(TopicModel *)topicModel array:(NSMutableArray *)models{
    if (topicModel.topicid.length > 0) {
        NSMutableIndexSet *setM = [[NSMutableIndexSet alloc]init];
        for (int i = 0; i < models.count; i ++) {
            TopicModel *model = models[i];
            if ([model.topicid isEqualToString:topicModel.topicid]) {
                [setM addIndex:i];
            }
        }
        [models removeObjectsAtIndexes:setM];
    }else{
        if (topicModel.localid > 0) {
            NSMutableIndexSet *setM = [[NSMutableIndexSet alloc]init];
            for (int i = 0; i < models.count; i ++) {
                TopicModel *model = models[i];
                if ([model.localid isEqualToString:topicModel.localid]) {
                    [setM addIndex:i];
                }
            }
            [models removeObjectsAtIndexes:setM];
        }
    }
    return models;
}

@end
