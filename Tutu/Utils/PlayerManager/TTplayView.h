//
//  TTplayView.h
//  Tutu
//
//  Created by fengchuangao on 15/2/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface TTplayView : UIView
+(BOOL)isDownloadFinish:(NSString *)filePath;
- (void)playVedio:(NSString *)url;
- (void)stopVideo;
-(UIImage *)getCurImage;
-(CGFloat)getCurDuration;
-(CGFloat)getSumDurtion;
//@property(nonatomic,strong) MPMoviePlayerController *player;
@property(nonatomic,strong) AVPlayer *avPlayer;
@property(nonatomic,strong) AVPlayerItem *playerItem;
@property(nonatomic,strong) AVAsset *movieAsset;
@property(nonatomic,strong) NSURL *playUrl;

@end
