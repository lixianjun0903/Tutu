//
//  FaceModel.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/18.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FaceModel.h"

@implementation FaceModel

-(FaceModel *)initWithMyDict:(NSDictionary *)item{
    self = [super init];
    if(self){
        @try {
            _typepic=[item objectForKey:@"typepic"];
            _itemList=[item objectForKey:@"list"];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

+(NSMutableArray *)getFaceList:(NSArray *)listArray{
    if (listArray==nil || [listArray isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if (listArray.count > 0) {
        NSMutableArray *models = [@[]mutableCopy];
        for (NSDictionary *dic in listArray) {
            if (dic.count > 0) {
                FaceModel *model = [[FaceModel alloc] initWithMyDict:dic];
                if(model!=nil){
                    [models addObject:model];
                }
            }
        }
        return models;
        
    }
    return nil;
}

@end
