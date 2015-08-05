//
//  MusicTools.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "MusicTools.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicTools


static MusicTools *_instance;

+(MusicTools *)getInstance{
    if (_instance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[MusicTools alloc] init];
        });
    }
    
    return _instance;
}


- (void) QueryAllMusic
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    NSLog(@"count = %lu", (unsigned long)itemsFromGenericQuery.count);
    for (MPMediaItem *song in itemsFromGenericQuery)
    {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSString *songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSLog (@"Title:%@, Aritist:%@，assetURL:%@", songTitle, songArtist,song.assetURL);
    }
}

-(NSMutableArray *)querySystemMusic{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery)
    {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSString *songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSURL *url=[song valueForProperty:MPMediaItemPropertyAssetURL];
//        NSString *time=[song valueForProperty:MPMediaItemPropertyPlaybackDuration];
        
        NSLog (@"Title:%@, Aritist:%@，assetURL:%@, time：%f", songTitle, songArtist,song.assetURL,song.playbackDuration);
        
        SystemMusiceModel *model=[[SystemMusiceModel alloc] init];
        model.name=songTitle;
        model.url=url;
        model.duration=song.playbackDuration;
        model.startDuration=0;
        [arr addObject:model];
    }
    
    return arr;
}


@end
