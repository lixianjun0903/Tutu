//
//  CommentModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "CommentModel.h"
//"commentid": "141415352810008",
//"uid": "10008",
//"nickname": "aaa",
//"avatartime": "0",
//"content": "heihei ",
//"locationx": "0.132812",
//"locationy": "0.286719",
//"txtframe": "cool_11@2x.png"

//@property(retain,nonatomic)NSString * commentid;
////主题编号
//@property(retain,nonatomic)NSString * topicid;
////发布人
//@property(retain,nonatomic)NSString * uid;
////1内容 2表情
//@property(retain,nonatomic)NSString * type;
////评论内容
//@property(retain,nonatomic)NSString * comment;
//@property(retain,nonatomic)NSString * commentbg;
//@property(retain,nonatomic)NSString * commentface;
//@property(retain,nonatomic)NSString * time;
//@property(retain,nonatomic)NSString * pid;
//@property(retain,nonatomic)NSString * pointX;
//@property(retain,nonatomic)NSString * pointY;
//
////关联
//@property(retain,nonatomic)NSString * nickname;
//@property(retain,nonatomic)NSString * avatar;

@implementation CommentModel

+(CommentModel *)initCommentModelWith:(NSDictionary *)dic{
    CommentModel *model = [[CommentModel alloc]init];
    model.commentid = CheckNilValue(dic[@"commentid"]);
    model.nickname = CheckNilValue( dic[@"nickname"]);
    model.uid = CheckNilValue(dic[@"uid"]);
    model.formataddtime = CheckNilValue(dic[@"formataddtime"]);
    model.avatar = CheckNilValue(dic[@"avatartime"]);
    model.pointX = [NSString stringWithFormat:@"%f",[CheckNilValue(dic[@"locationx"]) floatValue] * ScreenWidth];
    model.pointY = [NSString stringWithFormat:@"%f",[CheckNilValue(dic[@"locationy"]) floatValue] * ScreenWidth];
    model.comment = CheckNilValue( dic[@"content"]);
    model.commentbg = CheckNilValue(dic[@"txtframe"]);
    
    
    if(model.commentbg && [model.commentbg hasPrefix:@"input_22_00_"]){
        model.commentbg=[model.commentbg stringByReplacingOccurrencesOfString:@"input_22_00_" withString:@"input_22_01_"];
    }
    
    model.replypart = CheckNilValue(dic[@"replypart"]);
    
    model.islike = [dic[@"islike"] integerValue];
    model.likenum = [dic[@"likenum"] integerValue];
    
    model.scale = [NSString stringWithFormat:@"%f",[CheckNilValue(dic[@"scale"]) floatValue]];
    model.rotation = [NSString stringWithFormat:@"%f",[CheckNilValue(dic[@"rotation"]) floatValue]];
    
    NSDictionary *replyDic = dic[@"replydata"];
    if (replyDic) {
        model.replyName = CheckNilValue(replyDic[@"nickname"]);
        model.replyUid = CheckNilValue(replyDic[@"uid"]);
        model.replyContent = CheckNilValue(replyDic[@"content"]);
        model.replyFormataddtime = CheckNilValue(replyDic[@"formataddtime"]);
        model.replyTxtframe = CheckNilValue(replyDic[@"txtframe"]);
        model.replyCommentid = CheckNilValue(replyDic[@"commentid"]);
    }
    return model;
}
+(NSMutableArray *)getCommentModelList:(NSArray *)array{
    if ([array isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSMutableArray *mArr = [@[]mutableCopy];
    if (array.count > 0) {
        for(NSDictionary *dic in array) {
            CommentModel *model = [CommentModel initCommentModelWith:dic];
            [mArr addObject:model];
        }
        return mArr;
    }
    return nil;
}
@end
