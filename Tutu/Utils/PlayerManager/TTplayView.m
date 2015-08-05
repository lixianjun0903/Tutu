//
//  TTplayView.m
//  Tutu
//
//  Created by fengchuangao on 15/2/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TTplayView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "AVPlayerManager.h"

static TTplayView *ttplayView;
@implementation TTplayView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)avPlayer {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setAvPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
        self.userInteractionEnabled = NO;
        ((AVPlayerLayer *)[self layer]).videoGravity = AVLayerVideoGravityResizeAspectFill;
        ((AVPlayerLayer*)[self layer]).masksToBounds = YES;
    }
    return self;
}

+(BOOL)isDownloadFinish:(NSString *)filePath{
    if (filePath.length == 0) {
        return NO;
    }
    NSString *absolutePath = nil;
    if ([filePath hasPrefix:@"http://"] || [filePath hasPrefix:@"https://"]) {
        NSString *fileName = [[NSURL URLWithString:filePath] lastPathComponent];
        absolutePath = [NSString stringWithFormat:@"%@/%@",getVideoPath(),fileName];
    }else{
        absolutePath = filePath;
    }
    if (checkFileIsExsis(absolutePath)) {
        return YES;
    }else{
        return NO;
    }
}

- (void)playVedio:(NSString *)url{
    //关闭所有正常开启的播放
    [[AVPlayerManager getInstance] clearPlayer];
    
    NSURL *videoUrl = nil;
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        NSString *fileName = [[NSURL URLWithString:url] lastPathComponent];
        videoUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",getVideoPath(),fileName]];
    }else{
        videoUrl = [NSURL fileURLWithPath:url];
    }
    self.playUrl = videoUrl;
    self.movieAsset = [AVURLAsset assetWithURL:self.playUrl];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.movieAsset];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.avPlayer play];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(replayVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    
    
    [[AVPlayerManager getInstance] addPlayer:self forKye:videoUrl];
    /*
    if(url && (checkFileIsExsis(url) || checkFileIsExsis(getVideoNameByURL(url, NO)))){
        //网络视频
        if([url hasPrefix:@"http://"]){
            videoUrl = [NSURL fileURLWithPath:getVideoNameByURL(url, NO)];
        }else{
            //本地录制视频
            videoUrl = [NSURL fileURLWithPath:url];
        }
        self.playUrl = videoUrl;
        self.movieAsset = [AVURLAsset assetWithURL:self.playUrl];
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.movieAsset];
        self.avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self.avPlayer play];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(replayVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    }
     */
}
- (void)replayVideo:(NSNotification *)notifi{
    AVPlayerItem *playerItem = [notifi object];
    [playerItem seekToTime:kCMTimeZero];
    [self.avPlayer play];
    
    
    [[AVPlayerManager getInstance] addPlayer:self forKye:self.playUrl];
    
    
}
- (void)stopVideo{
    [self.avPlayer pause];
    self.avPlayer = [AVPlayer playerWithPlayerItem:nil];
    [NOTIFICATION_CENTER removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if(self.playUrl!=nil){
        [[AVPlayerManager getInstance] removePlayer:self.playUrl];
    }
}
-(UIImage *)getCurImage{
    
    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
        CMTime time = self.playerItem.currentTime;
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        CGImageRef thumb = [imageGenerator copyCGImageAtTime:time
                                                  actualTime:NULL
                                                       error:NULL];
        UIImage *image = [UIImage imageWithCGImage:thumb];
        return image;
    }
    return nil;
}

-(CGFloat)getSumDurtion
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.playUrl options:opts];  // 初始化视频媒体文件
    CGFloat minute = 0, second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    minute=(int)second/60;
    
    return second;

}

-(CGFloat)getCurDuration{
    AVPlayerItem *currentItem = self.avPlayer.currentItem;
    CMTime cmTime = currentItem.currentTime;
    CGFloat second = CMTimeGetSeconds(cmTime);
    return second;
}
@end
