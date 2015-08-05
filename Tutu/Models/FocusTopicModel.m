//
//  FocusTopicModel.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-14.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FocusTopicModel.h"

@implementation FocusTopicModel

-(FocusTopicModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _ids=CheckNilValue([dict objectForKey:@"ids"]);
            _idtext=CheckNilValue([dict objectForKey:@"idtext"]);
            _isfollow=[CheckNilValue([dict objectForKey:@"isfollow"]) boolValue];
            _viewcount=[CheckNilValue([dict objectForKey:@"viewcount"]) intValue];
            _viewhumancount=CheckNilValue([dict objectForKey:@"viewhumancount"]);
            
            
            
            _topiccount=[CheckNilValue([dict objectForKey:@"topiccount"]) intValue];
            _usercount=[CheckNilValue([dict objectForKey:@"usercount"]) intValue];
            
            _userlist=[self getUserModelList:[dict objectForKey:@"userlist"]];
            _topiclist=[self getTopicModelsWithArray:[dict objectForKey:@"topiclist"]];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}



-(NSMutableArray *)getTopicModelsWithArray:(NSArray *)listArray{
    if ([listArray isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if (listArray.count > 0) {
        NSMutableArray *models = [@[]mutableCopy];
        for (NSDictionary *dic in listArray) {
            if (dic.count > 0) {
                TopicModel *model = [TopicModel initTopicModelWith:dic];
                
                [models addObject:model];
            }
        }
        return models;
        
    }
    return nil;
}
-(NSMutableArray *)getUserModelList:(NSArray *)array{
    if ([array isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSMutableArray *mArr = [@[]mutableCopy];
    if (array.count > 0) {
        for(NSDictionary *dic in array) {
            UserInfo *model = [[UserInfo alloc] initWithMyDict:dic];
            [mArr addObject:model];
        }
        return mArr;
    }
    return nil;
}

@end
