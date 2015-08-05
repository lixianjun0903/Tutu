//
//  RCVoiceMessage.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"
#define RCVoiceMessageTypeIdentifier            @"RC:VcMsg"
/**
    声音消息
 */
@interface RCVoiceMessage : RCMessageContent
/** 音频原始数据 注意声音的采样率  AVNumberOfChannelsKey =1 AVLinearPCMBitDepthKey=16*/
@property(nonatomic, strong) NSData* wavAudioData;
/** 时长 */
@property(nonatomic, assign) long duration;
/**
 *  Push消息内容
 */
@property(nonatomic, strong) NSString* pushContent;
/**
 *  附加信息
 */
@property(nonatomic, strong) NSString* extra;
/**
    由指定信息创建声音消息实例
 
    @param  audioData   音频数据
    @param  duration    时长
 */
+(instancetype)messageWithAudio:(NSData *)audioData
                       duration:(long)duration;
@end
