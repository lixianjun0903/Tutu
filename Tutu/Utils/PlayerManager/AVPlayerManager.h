//
//  AVPlayerManager.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVPlayerManager : NSObject


+(AVPlayerManager *) getInstance;


-(void)clearPlayer;


-(void)addPlayer:(id) player forKye:(NSURL *)key;


-(void)removePlayer:(NSURL *)key;

@end
