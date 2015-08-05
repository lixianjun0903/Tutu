//
//  MessageModel.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel


-(MessageModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _uid=CheckNilValue([dict objectForKey:@"uid"]);
            _messageid=CheckNilValue([dict objectForKey:@"messageid"]);
            _content=CheckNilValue([dict objectForKey:@"content"]);
            _addtime=CheckNilValue([dict objectForKey:@"addtime"]);
            _avatartime=CheckNilValue([dict objectForKey:@"avatartime"]);
            
            _type=CheckNilValue([dict objectForKey:@"type"]);
            if([@"2" isEqual:_type]){
                NSDictionary *nsdict=[dict objectForKey:@"messagepictext"];
                if(nsdict!=nil && nsdict.count>0){
                    _messagepictext=[[SMessageModel alloc] initWithMyDict:nsdict];
                }else{
                    _messagepictext=nil;
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

-(NSArray *)getMessageArray:(NSArray *)listArray{
    if (listArray.count > 0) {
        NSMutableArray *models = [@[]mutableCopy];
        for (NSDictionary *dic in listArray) {
            if (dic.count > 0) {
                [models addObject:[[MessageModel alloc] initWithMyDict:dic]];
            }
        }
        return models;
        
    }
    return nil;
}


@end


@implementation SMessageModel


-(SMessageModel *)initWithMyDict:(NSDictionary *)dict{
    self=[self init];
    if(self){
        @try {
            _title=CheckNilValue([dict objectForKey:@"title"]);
            _content=CheckNilValue([dict objectForKey:@"content"]);
            _pic=CheckNilValue([dict objectForKey:@"pic"]);
            _contentlink=CheckNilValue([dict objectForKey:@"contentlink"]);
            _buttontext=CheckNilValue([dict objectForKey:@"buttontext"]);
            _buttonlink=CheckNilValue([dict objectForKey:@"buttonlink"]);
            
            
            _width=CheckNilValue([dict objectForKey:@"width"]);
            _height=CheckNilValue([dict objectForKey:@"height"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


@end
