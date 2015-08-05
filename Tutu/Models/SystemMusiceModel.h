//
//  SystemMusiceModel.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseModel.h"

@interface SystemMusiceModel : BaseModel

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,assign)double duration;
@property(nonatomic,assign)double startDuration;


@end
