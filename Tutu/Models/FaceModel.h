//
//  FaceModel.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/18.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface FaceModel : BaseModel

@property(nonatomic, strong) NSString *typepic;
@property(nonatomic, strong) NSArray *itemList;

-(FaceModel *)initWithMyDict:(NSDictionary *) item;

+(NSMutableArray *) getFaceList:(NSArray *)arr;

@end
