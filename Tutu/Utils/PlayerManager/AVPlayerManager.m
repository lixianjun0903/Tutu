//
//  AVPlayerManager.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "AVPlayerManager.h"
#import "TTplayView.h"

@implementation AVPlayerManager{
    NSMutableDictionary *dict;
}

static AVPlayerManager *instance=nil;

+(AVPlayerManager *)getInstance{
    if(instance==nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance=[[AVPlayerManager alloc] init];
        });
    }
    return instance;
}

-(id)init{
    self=[super init];
    
    dict=[[NSMutableDictionary alloc] init];
    
    return self;
}


-(void)clearPlayer{
    if(dict){
        for (NSURL *key in dict.allKeys) {
            TTplayView *play=[dict objectForKey:key];
            [play stopVideo];
        }
        
        [dict removeAllObjects];
    }
}


-(void)addPlayer:(id) player forKye:(NSURL *)key{
    if(dict==nil && key!=nil){
        dict=[[NSMutableDictionary alloc] init];
    }
    
    [dict setObject:player forKey:key];
}


-(void)removePlayer:(NSURL *)key{
    if(dict && key!=nil){
        [dict removeObjectForKey:key];
    }
}


@end
