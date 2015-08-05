//
//  VoiceManager.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-20.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "VoiceManager.h"

static VoiceManager *_instance=nil;

@implementation VoiceManager{
    //开始录音
    NSURL *tmpFile;
    AVAudioRecorder *recorder;
    BOOL recording;
    VoiceStartRecordBlock startRecordBlock;
    PauseRecordBlock pauseRecordBlock;
    StopRecordBlock stopRecordBlock;
    
    StartPlayVoiceBlock startPlayBlock;
    StopPlayVoiceBlock stopPlayBlock;
    PausePlayVoiceBlock pausePlayBlock;
    
    AVAudioPlayer *audioPlayer;
    
    NSTimer *voiceTimer;
}

+(VoiceManager *)getInstance{
    if(_instance==nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[VoiceManager alloc] init];
        });
    }
    return _instance;
}

#pragma mark 录制相关
-(void)setBlockWith:(VoiceStartRecordBlock)startBlock pause:(PauseRecordBlock)pauseBlock stop:(StopRecordBlock)stopBlock{
    startRecordBlock=startBlock;
    pauseRecordBlock=pauseBlock;
    stopRecordBlock=stopBlock;
}

-(void)startRecordVoice{
    if (!recording) {
        recording = YES;
        tmpFile = [NSURL fileURLWithPath:
                   [NSTemporaryDirectory() stringByAppendingPathComponent:
                    [NSString stringWithFormat: @"%@.%@",
                     @"tempAudio",
                     @"m4a"]]];
        [self recordToFile];
        [recorder prepareToRecord];
        [recorder record];
        
        if (voiceTimer) {
            [voiceTimer invalidate];
            voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
        }else
        {
            voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];

        }
           }else{
        [recorder stop];
        recording=NO;
    }
}


-(void)stopRecordVoice{
//    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [voiceTimer invalidate];
    
    recording = NO;
    
    //设置会话有效或者无效 ，是一个同步的过程，会阻塞线程，  屏蔽调暂时没有已知影响
//        [audioSession setActive:NO error:nil];
    [recorder stop];
    if(stopRecordBlock){
        
        stopRecordBlock(tmpFile,nil);
        
    }
}

//暂停
-(void)pauseRecordVoice{
    if(recording){
        [recorder pause];
        recording=NO;
        if(pauseRecordBlock){
            pauseRecordBlock(tmpFile,nil);
        }
    }
}

-(void)resetState
{
    [recorder stop];
}


-(void)reStartRecordVoice{
    if(!recording){
        [recorder record];
        recording=YES;
    }
}


//动态显示时间
-(void)timerDiscount{
    CGFloat duration=(CGFloat)recorder.currentTime;
    startRecordBlock(duration);
}



-(void)recordToFile{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[tmpFile path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[tmpFile path] error:&err];
    }
    
    err = nil;
    if([tmpFile.path hasSuffix:@".m4a"]){
        recorder = [[ AVAudioRecorder alloc] initWithURL:tmpFile settings:[SysTools getRecorderSettingDict] error:&err];
    }else{
        recorder = [[ AVAudioRecorder alloc] initWithURL:tmpFile settings:[SysTools getAudioRecorderSettingDict] error:&err];
    }
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    
    [recorder record];
    recorder.meteringEnabled = YES;
    
    //时间
    [recorder recordForDuration:(NSTimeInterval) 60];
}






#pragma mark 播放相关
-(void)stopPlayerVoice{
    [audioPlayer stop];
}

-(void)playerVoice:(NSURL *)voiceFile data:(NSData *)fileData startBlock:(StartPlayVoiceBlock)sstartPlayyBlock stopBlock:(StopPlayVoiceBlock)sstopPlayBlock pause:(PausePlayVoiceBlock)pauseBlock{
    startPlayBlock=sstartPlayyBlock;
    stopPlayBlock=sstopPlayBlock;
    pausePlayBlock=pauseBlock;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if(audioPlayer!=nil && [audioPlayer isPlaying]){
        [audioPlayer stop];
        
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    
    NSError *error;
    if(fileData!=nil){
        audioPlayer=[[AVAudioPlayer alloc]initWithData:fileData error:&error];
    }else{
        audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:voiceFile
                                                          error:&error];
    }
    audioPlayer.delegate=self;
    audioPlayer.volume=1;
    audioPlayer.numberOfLoops=-1;
    if (error) {
        NSLog(@"error:%@",[error description]);
        if(stopPlayBlock){
            stopPlayBlock(voiceFile,error);
        }
        
        return;
    }
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    
    //准备播放
    [audioPlayer prepareToPlay];
    //播放
    [audioPlayer play];
    
    if(startPlayBlock){
        startPlayBlock();
    }
}



#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        //没黑屏幕
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (![audioPlayer isPlaying]) {//没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}


#pragma mark 播放停止、失败
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    WSLog(@"走了完成的代理-----");
    
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [audioPlayer stop];
    
    if(stopPlayBlock){
        stopPlayBlock(player.url,nil);
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    WSLog(@"走了失败的代理-----");
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    
    if(stopPlayBlock){
        stopPlayBlock(player.url,error);
    }
}

// 当音频播放过程中被中断时
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    // 当音频播放过程中被中断时，执行该方法。比如：播放音频时，电话来了！
    // 这时候，音频播放将会被暂停。
    if(pausePlayBlock){
        pausePlayBlock(player.url,nil);
    }
}

// 当中断结束时
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
    // AVAudioSessionInterruptionFlags_ShouldResume 表示被中断的音频可以恢复播放了。
    // 该标识在iOS 6.0 被废除。需要用flags参数，来表示视频的状态。
    
    NSLog(@"中断结束，恢复播放");
    if (flags == AVAudioSessionInterruptionOptionShouldResume && player != nil){
        [player play];
        if(startPlayBlock){
            startPlayBlock();
        }
    }
}

@end
