//
//  AmrDataConverter.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-17.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "interf_dec.h"
#include "interf_enc.h"


/**
 *  AMR和WAV转换类
 */
@interface AmrDataConverter : NSObject


+(AmrDataConverter*)shareAmrDataConverter;
/**
 *  AMR转换成WAVE格式的音频.
 *
 *  @param data AMR格式数据
 *
 *  @return WAVE格式数据
 */
-(NSData*) DecodeAMRToWAVE:(NSData*) data;
/**
 *  WAVE转换成AMR格式音频
 *
 *  @param data           WAVE格式数据  注意声音的采样率  AVNumberOfChannelsKey =1 AVLinearPCMBitDepthKey=16
 *  @param nChannels      默认传入1。
 *  @param nBitsPerSample 默认传入16。
 *
 *  @return AMR格式数据
 */
-(NSData*) EncodeWAVEToAMR:(NSData*) data channel:(int)nChannels  nBitsPerSample:(int)nBitsPerSample;
@end
