//
//  FFmpegSynthAudio.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegBase.h"

typedef void(^SuccessBlock)(NSString *exportPath);

@interface FFmpegSynthAudio : FFmpegBase

/**
 *  图片合成音频
 */
+ (void)synthAudio:(NSString *) audioPath withVideo:(NSString *) videoPath withBlock:(SuccessBlock) successBlock;

@end
