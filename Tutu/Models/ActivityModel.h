//
//  ActivityModel.h
//  Tutu
//
//  Created by gexing on 14/12/9.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityModel : BaseModel
@property(nonatomic,strong)NSString *gotourl;
@property(nonatomic)NSInteger displaystyle;
@property(nonatomic)NSInteger buttonCount;
@property(nonatomic,strong)NSString *btnOneTitle;
@property(nonatomic,strong)NSString *btnOneUrl;
@property(nonatomic,strong)NSString *btnTwoTitle;
@property(nonatomic,strong)NSString *btnTwoUrl;
+(ActivityModel *)initWithDic:(NSDictionary *)dic;
@end
