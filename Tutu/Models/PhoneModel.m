//
//  PhoneModel.m
//  Tutu
//
//  Created by gexing on 5/18/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "PhoneModel.h"

@implementation PhoneModel
+(PhoneModel *)initWithDic:(NSDictionary *)dic{
    PhoneModel *model = [[PhoneModel alloc]init];
    model.typeId = [dic[@"typeid"]intValue];
    model.typeName = dic[@"typename"];
    model.isused = [dic[@"isused"]intValue];
    return model;
}
+(NSArray *)initModelsWithArray:(NSArray *)array{
    NSMutableArray *mArray = [@[]mutableCopy];
    for (NSDictionary *dic in array) {
        PhoneModel *model = [PhoneModel initWithDic:dic];
        [mArray addObject:model];
    }
    return (NSArray *)mArray;
}
@end
