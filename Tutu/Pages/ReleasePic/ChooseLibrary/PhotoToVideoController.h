//
//  PhotoToVideoController.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^GetEditModelBlock)(NSMutableArray *arrayEditModel);

@interface PhotoToVideoController : BaseController

@property(nonatomic,strong) ALAssetsGroup *group;
@property(nonatomic,strong) NSMutableArray *arrayEditModel;

- (instancetype)initWithBlock:(GetEditModelBlock)block;

@end
