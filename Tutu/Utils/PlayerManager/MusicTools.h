//
//  MusicTools.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SystemMusiceModel.h"

@interface MusicTools : NSObject

+(MusicTools *)getInstance;

- (void) QueryAllMusic;


- (NSMutableArray *)querySystemMusic;

@end
