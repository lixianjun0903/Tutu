//
//  TutuPlayerView.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TutuPlayerView.h"
#import "DownLoadManager.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "M13ProgressViewBar.h"
#import "TCBlobDownloadManager.h"
#import "M13ProgressViewRing.h"
#import "HomeController.h"

@implementation TutuPlayerView{
    NSString *filePath;
    
    //下载完立即播放
    BOOL isDownloadAndPlay;
    
    //视频总时长
    CGFloat mduration;
    
    UIImageView *coverView;
    
    M13ProgressViewBar *progress;
    M13ProgressViewRing *_picProgress;
    UIButton *playButton;
}

-(id)initWithPath:(NSString *)path{
    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
        isDownloadAndPlay=NO;
        _canPlay=NO;
        
        
//        //封面
//        coverView=[[UIImageView alloc] initWithFrame:self.bounds];
//       // [coverView setImage:[UIImage imageNamed:@"topic_default"]];
//        [self addSubview:coverView];
        
//        _picProgress = [[M13ProgressViewRing alloc]initWithFrame:CGRectMake(0, 0, 76 * (ScreenWidth / 320.0f), 76 * (ScreenWidth / 320.0f))];
//        _picProgress.backgroundRingWidth = 8;
//        _picProgress.progressRingWidth = 8;
//        _picProgress.showPercentage = NO;
//        _picProgress.center = self.center;
//        [coverView addSubview:_picProgress];
        
        
        
        //下载进度
//        progress=[[M13ProgressViewBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,10)];
//        [progress setShowPercentage:NO];
//        [progress setShowCornerRadius:NO];
//        [progress setProgressBarThickness:10];
//        [progress setSecondaryColor:UIColorFromRGB(SystemGrayColor)];
//        [progress setPrimaryColor:UIColorFromRGB(SystemColor)];
//        [progress setProgress:0 animated:NO];
//        [self addSubview:progress];
//        
//        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [playButton setImage:[UIImage imageNamed:@"topic_paly_btn"] forState:UIControlStateNormal];
//        [playButton setFrame:CGRectMake(0, 0, 75, 75)];
//        [playButton setBackgroundColor:[UIColor clearColor]];
//        [playButton setCenter:self.center];
//        [self addSubview:playButton];
//        playButton.hidden=YES;
        
        
        self.player=[[MPMoviePlayerController alloc] init];
        
        _player.view.frame= self.bounds;
        _player.controlStyle = MPMovieControlStyleNone;
        _player.repeatMode=MPMovieRepeatModeOne;
        
        [_player setFullscreen:YES animated:YES];
        _player.view.userInteractionEnabled=NO;
        
        for (UIView *view in [_player.view subviews]) {
            [view setBackgroundColor:[UIColor clearColor]];
        }
        
        [_player.view setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_player.view];
        
        filePath=path;
        [self addMediaContent];
        
    }
    return self;
}

-(void)setCoverURL:(NSString *)url{
    if(!_canPlay){
        _picProgress.hidden=NO;
        [_picProgress setProgress:0.001 animated:YES];
        [coverView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"topic_default"]];
        [coverView sd_setImageWithURL:StrToUrl(url) placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            [_picProgress setProgress:receivedSize / [@(expectedSize) doubleValue] animated:YES];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_picProgress setHidden:YES];
        }];
    }
}

-(void)setCoverImage:(UIImage *)image{
    if(image){
        [coverView setImage:image];
        
        _picProgress.hidden=YES;
    }
}


- (void)setPlayerPath:(NSString *)path{
    filePath = path;
    [_picProgress setProgress:0 animated:NO];
    [self addMediaContent];
}


- (void)setProgress:(NSString *)url progress:(CGFloat)progressValue{
    if(url !=nil && [url isEqual:filePath]){
        [progress setProgress:progressValue animated:YES];
    }
}

- (BOOL)isDownloadFinish{
    return _canPlay;
}


-(void)setRepeatPlayer:(BOOL)isRepeat{
    if(isRepeat){
        
        //设置重复播放
        [_player setRepeatMode:MPMovieRepeatModeOne];
    }else{
        [_player setRepeatMode:MPMovieRepeatModeNone];
    }
}
-(void)startPlayer{
    WSLog(@"调用开始播放：%@",filePath);
    if(_canPlay){
        progress.hidden=YES;
        playButton.hidden=YES;
        
        [self.player prepareToPlay];
        [self.player play];
        
        [self addMovieCallBack];
    }else{
        isDownloadAndPlay=YES;
        [self startDownload:NO];
    }
}

-(void)startPlayer:(NSString *)url cover:(NSString *)imageurl{
    [self setCoverURL:imageurl];
    [self setPlayerPath:url];
    
    [self startPlayer];
    
}

-(void)stopPlayer{
    if(_player){
        [self.player stop];
    }
    isDownloadAndPlay=NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setStartTime:(CGFloat)time{
    if(_player){
        [self setRepeatPlayer:NO];
        [_player setCurrentPlaybackTime:time];
    }
}

-(void)startDownload:(BOOL)isPlay{
    /*
    isDownloadAndPlay=isPlay;
    if (_canPlay) {
        return;
    }
    if(filePath && !checkFileIsExsis(filePath) && [filePath hasPrefix:@"http://"]){
        _canPlay=NO;
        
        [[TCBlobDownloadManager sharedDownloadManager] startDownloadWithURL:[NSURL URLWithString:filePath] customPath:getVideoPath() firstResponse:^(NSURLResponse *response) {
            
        } progress:^(float receivedLength, float totalLength,NSString *videoURL) {            if(totalLength>0)
            {
                if (_playDelegate && [_playDelegate respondsToSelector:@selector(downloadVedioProgress:vedioUrl:)]) {
                    [ _playDelegate downloadVedioProgress:receivedLength / totalLength vedioUrl:videoURL];
                }
                //[progress setProgress:receivedLength/totalLength animated:NO];
            }
        } error:^(NSError *error) {
            
        } complete:^(BOOL downloadFinished, NSString *pathToFile,NSString *videoURL) {
            WSLog(@"下载完成%d",isPlay);
            progress.hidden=YES;
            if (_playDelegate && [_playDelegate respondsToSelector:@selector(downloadVedioSuccess:)]) {
                [_playDelegate downloadVedioSuccess:videoURL];
            }
            _canPlay=YES;
            
            NSString *temp=[[DownLoadManager getInstance] getVideoNameByURL:filePath temp:YES];
            
            NSString *release=[[DownLoadManager getInstance] getVideoNameByURL:filePath temp:NO];
            
            BOOL isRename=[[NSFileManager defaultManager] moveItemAtPath:temp toPath:release error:nil];
            if(isRename){
                filePath=release;
                
                progress.hidden=YES;
                
                [self setPlayerPath:filePath];
                
                
//                AppDelegate *app=[SysTools getApp];
//                UIViewController *curController=[app getCurrentTopViewController];
//                WSLog(@"%@",curController);
                //下载完成自动播放
                if(isDownloadAndPlay && _player!=nil){
                    [self startPlayer];
                }
            }
        }];
    }
     */
}

-(UIImage *)getCurImage{
    UIImage *thumbnail = [_player thumbnailImageAtTime:_player.currentPlaybackTime timeOption:MPMovieTimeOptionNearestKeyFrame];
    return thumbnail;
}

-(CGFloat)getDuration{
    if(mduration>0){
        return mduration;
    }
    NSURL *movieURL = _player.contentURL;
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化视频媒体文件
    CGFloat minute = 0, second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    minute=(int)second/60;

    return second;
}

-(CGFloat)getCurDuration{
    return [_player currentPlaybackTime];
}


-(void)addMediaContent{
    AppDelegate *app=[SysTools getApp];
    if(!app.isReachableWiFi){
        playButton.hidden=YES;
    }else{
        playButton.hidden=NO;
    }
    
    //本地文件，直接添加到文件
    if(filePath && (checkFileIsExsis(filePath) || checkFileIsExsis(getVideoNameByURL(filePath, NO)))){
        //网络视频
        if([filePath hasPrefix:@"http://"]){
            [self.player setContentURL:[NSURL fileURLWithPath:getVideoNameByURL(filePath, NO)]];
        }else{
            //本地录制视频
            [self.player setContentURL:[NSURL fileURLWithPath:filePath]];
        }
        _canPlay=YES;
        
        playButton.hidden=YES;
    }else if(filePath!=nil && [filePath hasPrefix:@"http://"]){
        //非本地文件，网络文件，先添加到下载
        _canPlay=NO;
        [self startDownload:NO];
    }
}

- (BOOL)isLocalVedio:(NSString *)vedioUrl{
    if(vedioUrl && (checkFileIsExsis(vedioUrl) || checkFileIsExsis(getVideoNameByURL(vedioUrl, NO)))){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark -------------------视频播放委托--------------------
-(void)addMovieCallBack{
    // 注册一个播放结束的通知，当播放结束时，监听到并且做一些处理
    //播放器自带有播放结束的通知，在此仅仅只需要注册观察者监听通知即可。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    //可以获取视频时长了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MovieDurationCallback:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:_player];
    
    //网络状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieNetChangeCallBack:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    //当视频开始播放时会发送
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
}

/*
 @method 当视频播放完毕释放对象
 */
-(void)myMovieFinishedCallback:(NSNotification*)notify
{
    WSLog(@"播放结束%@----%@",filePath,_player.contentURL);
//    [self startPlayer];
}

/*
 @method 当前可以获取到总时长
 */
-(void)MovieDurationCallback:(NSNotification*)notify
{
    NSLog(@"可以获取长度了");
    mduration=_player.duration;
    WSLog(@"%d", [self.player repeatMode]);
}

//网络状态发生改变
-(void)myMovieNetChangeCallBack:(NSNotification *)notify{
    MPMoviePlayerController *player = notify.object;
    MPMovieLoadState loadState = player.loadState;
    
    //找不到视频文件
    if(loadState == MPMovieLoadStateUnknown){
        
    }
    
    //可以播放
    if(loadState == MPMovieLoadStatePlayable){
        
    }
    
    // 缓冲几乎完成
    if(loadState == MPMovieLoadStatePlaythroughOK){
//        [self hideLoading];
    }
    
    //状态为缓冲中
    if(loadState == MPMovieLoadStateStalled){
        
    }
}

//视频播放状态发送改变
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    MPMoviePlayerController *player = notification.object;
    MPMoviePlaybackState playState = player.playbackState;
    
    //停止
    if(playState==MPMoviePlaybackStateStopped){
        
    }
    //播放
    if(playState==MPMoviePlaybackStatePlaying){
        
    }
    //暂停
    if(playState==MPMoviePlaybackStatePaused){
        
    }
    //中断
    if(playState==MPMoviePlaybackStateInterrupted){
        
    }
    //下一个
    if(playState==MPMoviePlaybackStateSeekingForward){
        
    }
    //前一个
    if(playState==MPMoviePlaybackStateSeekingBackward){
        
    }
}
#pragma mark -------------------视频播放委托结束--------------------



-(void)cleanMediaView{
    [self stopPlayer];
    
    //停止下载

}


-(void)destory{
    [self stopPlayer];
    
    [_player.view removeFromSuperview];
    
    _player=nil;
    
    //移除所有监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)dealloc{
    //移除所有监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
