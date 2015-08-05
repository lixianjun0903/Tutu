//
//  VoiceManager.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-20.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@protocol VoiceManager;
//录音
typedef void(^VoiceStartRecordBlock)(CGFloat duration);
typedef void(^PauseRecordBlock)(NSURL *fileURL,NSError *error);
typedef void(^StopRecordBlock)(NSURL *fileURL,NSError *error);

//播放
typedef void(^StartPlayVoiceBlock)();
typedef void(^StopPlayVoiceBlock)(NSURL *fileURL,NSError *error);
typedef void(^PausePlayVoiceBlock)(NSURL *fileURL,NSError *error);

@interface VoiceManager : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>


+(id)getInstance;


-(void)setBlockWith:(VoiceStartRecordBlock) startBlock pause:(PauseRecordBlock) pauseBlock stop:(StopRecordBlock) stopBlock;

//开始录音
-(void)startRecordVoice;

//停止录制
-(void)stopRecordVoice;

//暂停录制
-(void)pauseRecordVoice;
-(void)reStartRecordVoice;

//播放声音
-(void)playerVoice:(NSURL *)voiceFile data:(NSData *) fileData startBlock:(StartPlayVoiceBlock)startPlayBlock stopBlock:(StopPlayVoiceBlock)stopPlayBlock pause:(PausePlayVoiceBlock)pauseBlock;

-(void)resetState;

//停止播放
-(void)stopPlayerVoice;

@end
