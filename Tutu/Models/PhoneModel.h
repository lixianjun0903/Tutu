//
//  PhoneModel.h
//  Tutu
//
//  Created by gexing on 5/18/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface PhoneModel : BaseModel
@property(nonatomic,strong)NSString *typeName;
@property(nonatomic)int typeId;
@property(nonatomic)int isused;
+(PhoneModel *)initWithDic:(NSDictionary *)dic;
+(NSArray *)initModelsWithArray:(NSArray *)array;
@end
