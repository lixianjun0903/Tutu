//
//  FFmpegSynthVideo.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/4.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegBase.h"

@interface FFmpegSynthVideo : FFmpegBase

@property(nonatomic,strong) NSString *videoPath;

/**
 *  图片合成视频
 */
- (void)synthImageToVideo:(NSArray *)arrayImage;

@end
