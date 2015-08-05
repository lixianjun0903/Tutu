//
//  FFmpegBase.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/4.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegBase.h"

@implementation FFmpegBase

/**
 *  RGB24顺时针旋转90度
 */
void rotate90_RGB24_CLW(Byte *des,Byte *src,int width,int height)
{
    if(!des||!src||*des==(Byte)'!')
    {
        return;
    }
    int n=0;
    int linesize=width*3;
    int i,j;
    for (j=0; j<width; j++) {
        for (i=height; i>0; i--) {
            memcpy(&des[n], &src[linesize*(i-1)+j*3-3], 3);
            n+=3;
        }
    }
}

/**
 *  BGR24顺时针旋转90度
 */
void rotate90_BGR24_CLW(Byte *des,Byte *src,int width,int height)
{
    if(!des||!src)
    {
        return;
    }
    int n=0;
    int linesize=width*3;
    int i,j;
    for (j=width; j>0; j--) {
        for (i=0; i<height; i++) {
            memcpy(&des[n], &src[linesize*i+j*3-3], 3);
            n+=3;
        }
    }
}

/**
 *  从AVPicture中获取image
 */
+ (UIImage *)imageFromAVPicture:(AVPicture)picture width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, picture.data[0], picture.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       picture.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}

/**
 *  从AVFrame中获取image
 */
+ (UIImage *)imageFromAVFrame:(AVFrame *)frame width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, frame->data[0], frame->linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       frame->linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}

/**
 *  保存图片.jpg
 */
+ (void)saveImageToJPG:(UIImage *)image
{
    static int i=0;
    NSString *filePath = [NSString stringWithFormat:@"/Users/zhanglingyu/Desktop/test/%i.jpg",i++];
    NSLog(@"%@",filePath);
    BOOL result = [UIImageJPEGRepresentation(image,1.0) writeToFile: filePath atomically:YES];
    if(result){
        NSLog(@"%i.jpg保存成功！",i);
    }else{
        NSLog(@"%i.jpg保存失败！",i);
    }
}

/**
 *  指针指向开始播放时间
 */
+ (int)seekTime:(AVFormatContext *)ifmt_ctx type:(int)type begin:(double)begin
{
    //视频文件流的坐标
    int videoIndex;
    //遍历文件的各个流，找到一个视频文件流，并记录该流的编码信息
    //AVMEDIA_TYPE_VIDEO,AVMEDIA_TYPE_AUDIO
    if((videoIndex=av_find_best_stream(ifmt_ctx, type, -1, -1, NULL, 0))<0){
        av_log(NULL, AV_LOG_ERROR, "\n未找到视频文件流！");
        return 0;
    }
    AVRational timeBase = ifmt_ctx->streams[videoIndex]->time_base;
    int64_t targetFrame = (int64_t)(timeBase.den / timeBase.num * begin);
    avformat_seek_file(ifmt_ctx, videoIndex, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    return 1;
}

@end
