//
//  TutuPlayerView.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
@protocol TutuPlayerViewDeleage <NSObject>

- (void)downloadVedioProgress:(CGFloat)progress vedioUrl:(NSString *)url;
- (void)downloadVedioSuccess:(NSString *)url;
@end

@interface TutuPlayerView : UIView
{
    
}

@property(nonatomic)BOOL canPlay;
// 当前播放器
// player.duration 视频总时长
// player.currentPlaybackTime 当前播放时间点
@property(nonatomic,strong) MPMoviePlayerController *player;

@property(nonatomic,weak) id <TutuPlayerViewDeleage> playDelegate;
/**
 * 初始视频播放view
 * path,可是本地文件路径(完整路径)
 * 网络视频（根据下载情况确定，直接传视频名称或视频id）
 */
-(id)initWithPath:(NSString *) path;


/**
 * 设置封面图片
 * 仅当目前视频不可播放时显示，（视频未下载完成）
 */
-(void)setCoverURL:(NSString *)url;
-(void)setCoverImage:(UIImage *)image;


/**
 * 是否重复播
 * 默认不重复播放
 */
-(void)setRepeatPlayer:(BOOL) isRepeat;
/**
 *  设置播发路径
 *
 *  @param path 播放路径
 */
- (void)setPlayerPath:(NSString *)path;


/**
 * 设置视频下载进度
 */
- (void)setProgress:(NSString *) url progress:(CGFloat ) progressValue;

- (BOOL) isDownloadFinish;
- (BOOL)isLocalVedio:(NSString *)vedioUrl;

/**
 * 开始播放视频
 **/
-(void)startPlayer;

//test
-(void)startPlayer:(NSString *)url cover:(NSString *) imageurl;

/**
 * 停止播放
 **/
-(void)stopPlayer;

/**
 * 开始播放时间
 **/
-(void)setStartTime:(CGFloat)time;


/**
 * 开始下载
 **/
-(void)startDownload:(BOOL) isPlay;



/**
 * 获取当前播放的图片
 */
-(UIImage *)getCurImage;

-(CGFloat)getDuration;
-(CGFloat)getCurDuration;


//清空播放器
-(void)cleanMediaView;

-(void)destory;

@end
