//
//  FFmpegBase.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/4.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Extend.h"
#import "Tools.h"

//ffmpeg头文件

#include "libavutil/avutil.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"
#include "libavformat/avformat.h"
#include "libavdevice/avdevice.h"
#include "libswresample/swresample.h"

#include "libavutil/opt.h"
#include "libavutil/imgutils.h"

#include "libavutil/opt.h"
#include "libavutil/channel_layout.h"
#include "libavutil/parseutils.h"
#include "libavutil/samplefmt.h"
#include "libavutil/fifo.h"
#include "libavutil/intreadwrite.h"
#include "libavutil/dict.h"
#include "libavutil/mathematics.h"
#include "libavutil/pixdesc.h"
#include "libavutil/avstring.h"
#include "libavutil/imgutils.h"
#include "libavutil/timestamp.h"
#include "libavutil/bprint.h"
#include "libavutil/time.h"

#include "libavfilter/avcodec.h"
#include "libavfilter/avfilter.h"
#include "libavfilter/buffersrc.h"
#include "libavfilter/buffersink.h"


@interface FFmpegBase : NSObject

/**
 *  RGB24顺时针旋转90度
 */
void rotate90_RGB24_CLW(Byte *des,Byte *src,int width,int height);

/**
 *  BGR24顺时针旋转90度
 */
void rotate90_BGR24_CCW(Byte *des,Byte *src,int width,int height);

/**
 *  从AVPicture中获取image
 */
+ (UIImage *)imageFromAVPicture:(AVPicture)picture width:(int)width height:(int)height;

/**
 *  从AVFrame中获取image
 */
+ (UIImage *)imageFromAVFrame:(AVFrame *)frame width:(int)width height:(int)height;

/**
 *  保存图片.jpg
 */
+ (void)saveImageToJPG:(UIImage *)image;

/**
 *  指针指向开始播放时间
 */
+ (int)seekTime:(AVFormatContext *)ifmt_ctx type:(int)type begin:(double)begin;

@end
