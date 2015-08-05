//
//  UserFocusModel.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserFocusModel.h"

@implementation UserFocusModel

-(UserFocusModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _fid=CheckNilValue([dict objectForKey:@"fid"]);
            _resid=CheckNilValue([dict objectForKey:@"resid"]);
            _restype=CheckNilValue([dict objectForKey:@"restype"]);
            _title=CheckNilValue([dict objectForKey:@"title"]);
            _content=CheckNilValue([dict objectForKey:@"content"]);
            _height=CheckNilValue([dict objectForKey:@"height"]);
            _width=CheckNilValue([dict objectForKey:@"width"]);
            _desc=CheckNilValue([dict objectForKey:@"desc"]);
            _isfollow=[CheckNilValue([dict objectForKey:@"isfollow"]) boolValue];
            _newnum=CheckNilValue([dict objectForKey:@"newnum"]);
            _isread=CheckNilValue([dict objectForKey:@"isread"]);
            _viewhumancount = CheckNilValue([dict objectForKey:@"viewhumancount"]);
            _viewcount=CheckNilValue([dict objectForKey:@"viewcount"]);
            _usercount=CheckNilValue([dict objectForKey:@"usercount"]);
            _topiccount=CheckNilValue([dict objectForKey:@"topiccount"]);
            
            
            _topiclist=[[UserFocusTopicModel alloc] getWithArray:[dict objectForKey:@"topiclist"]];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


-(NSMutableArray *)getWithArray:(NSArray *)listArray{
    if ([listArray isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if (listArray.count > 0) {
        NSMutableArray *models = [@[]mutableCopy];
        for (NSDictionary *dic in listArray) {
            if (dic.count > 0) {
                UserFocusModel *model = [[UserFocusModel alloc] initWithMyDict:dic];
                [models addObject:model];
            }
        }
        return models;
        
    }
    return nil;
}
@end


@implementation UserFocusTopicModel
-(UserFocusTopicModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _topicid= CheckNilValue([dict objectForKey:@"topicid"]);
            _content=CheckNilValue([dict objectForKey:@"content"]);
            _height=CheckNilValue([dict objectForKey:@"height"]);
            _width=CheckNilValue([dict objectForKey:@"width"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


-(NSMutableArray *)getWithArray:(NSArray *)listArray{
    if ([listArray isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if (listArray.count > 0) {
        NSMutableArray *models = [@[]mutableCopy];
        for (NSDictionary *dic in listArray) {
            if (dic.count > 0) {
                UserFocusTopicModel *model = [[UserFocusTopicModel alloc] initWithMyDict:dic];
                [models addObject:model];
            }
        }
        return models;
        
    }
    return nil;
}


@end
