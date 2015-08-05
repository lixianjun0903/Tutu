//
//  FFmpegClipVideo.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegBase.h"

typedef void(^ClipVideoDurationBlock) (NSString *clipVideoPath, double duration, NSError *error);

@interface FFmpegClipVideo : FFmpegBase

/**
 剪切视频播放时间长
 */
+ (void)clipVideoDuration:(NSString *)videoPath begin:(double)begin duration:(double)duration block:(ClipVideoDurationBlock) block;

@end
