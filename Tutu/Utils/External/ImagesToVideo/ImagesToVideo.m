//
//  ImagesToVideo.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ImagesToVideo.h"
#import "PhotoEditCell.h"

#define kFrameWidth 400

const CGSize frameSize = (CGSize){kFrameWidth, kFrameWidth};
const int frameRate = 1;
const int transitionFrameCount = 1;
const int framesToWaitBeforeTransition = 1;

/**
 *  每张播放时间（秒）
 *  1~10 3s/张，10~20 2s/张，20~30 1s/张
 */
int frameTime=1;
int frameCount=0;
SuccessBlock1 backBlock;

@implementation ImagesToVideo

/**
 *  图片合成视频
 */
+ (void)videoFromImageURL:(NSArray *)arrayImageURL toPath:(NSString *)path withCallbackBlock:(SuccessBlock1)callbackBlock
{
    NSLog(@"%@",path);
    
    // 1.设置播放时间戳
    frameCount=(int)arrayImageURL.count;
    int rate=frameCount/10;
    switch (rate) {
        case 0:
            frameTime=3;
            break;
        case 1:
            frameTime=2;
            break;
        case 2:
            frameTime=1;
            break;
        default:
            frameTime=1;
            break;
    }
    
    // 2.配置视频文件
    backBlock=callbackBlock;
    [self setVideo:path];
    
    // 3.获取帧图片并合并
    frameIndex=0;
    for (NSURL *url in arrayImageURL) {
        [self getImage:url];
    }
}

/**
 *  配置视频文件
 */
AVAssetWriter *videoWriter;
AVAssetWriterInput* writerInput;
AVAssetWriterInputPixelBufferAdaptor *adaptor;
CVPixelBufferRef buffer;
+ (void)setVideo:(NSString *)path
{
    NSError *error = nil;
    videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        if (backBlock) {
            backBlock(NO);
        }
        return;
    }
    NSParameterAssert(videoWriter);
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,AVVideoWidthKey: [NSNumber numberWithInt:frameSize.width],AVVideoHeightKey: [NSNumber numberWithInt:frameSize.height]};
    writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);
}

/**
 *  获取帧图片
 */
+ (void)getImage:(NSURL *)url
{
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset){
                 UIImage *image=[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                 UIImage *scaleImage=[UIImage scaleImage:image byMinSide:kFrameWidth];
                 [self writeFrame:scaleImage];
                 if (frameIndex==frameCount) {
                     [self markFinished];
                 }
             }
            failureBlock:^(NSError *error){
                NSLog(@"operation was not successfull!");
            }
     ];
}

/**
 *  写入帧图片
 */
int frameIndex=0;
+ (void)writeFrame:(UIImage *)image
{
    if(writerInput.readyForMoreMediaData)
    {
        NSLog(@"当前播放时间%i %i %is",frameIndex,frameRate,frameIndex*frameTime/frameRate);
        CMTime presentTime = CMTimeMake(frameIndex*frameTime, frameRate);
        if (image==nil) {
            return;
        }
        buffer = [self pixelBufferFromCGImage:[image CGImage] size:CGSizeMake(kFrameWidth, kFrameWidth)];
        if (buffer) {
            BOOL appendSuccess = [self appendToAdapter:adaptor pixelBuffer:buffer atTime:presentTime withInput:writerInput];
            NSAssert(appendSuccess, @"Failed to append");
            frameIndex++;
        }
        else {
            [self markFinished];
        }
    }
}

/**
 *  合成完毕
 */
+ (void)markFinished
{
    if(writerInput.readyForMoreMediaData)
    {
        [writerInput markAsFinished];
        [videoWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Successfully closed video writer");
            if (videoWriter.status == AVAssetWriterStatusCompleted) {
                if (backBlock) {
                    backBlock(YES);
                }
            } else {
                if (backBlock) {
                    backBlock(NO);
                }
            }
        }];
        CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
        NSLog (@"Done");
    }
}

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
                                      size:(CGSize)imageSize
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0 + (imageSize.width-CGImageGetWidth(image))/2,
                                           (imageSize.height-CGImageGetHeight(image))/2,
                                           CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (CVPixelBufferRef)crossFadeImage:(CGImageRef)baseImage
                           toImage:(CGImageRef)fadeInImage
                            atSize:(CGSize)imageSize
                         withAlpha:(CGFloat)alpha
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGRect drawRect = CGRectMake(0 + (imageSize.width-CGImageGetWidth(baseImage))/2,
                                 (imageSize.height-CGImageGetHeight(baseImage))/2,
                                 CGImageGetWidth(baseImage),
                                 CGImageGetHeight(baseImage));
    
    CGContextDrawImage(context, drawRect, baseImage);
    
    CGContextBeginTransparencyLayer(context, nil);
    CGContextSetAlpha( context, alpha );
    CGContextDrawImage(context, drawRect, fadeInImage);
    CGContextEndTransparencyLayer(context);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)presentTime
              withInput:(AVAssetWriterInput*)writerInput
{
    while (!writerInput.readyForMoreMediaData) {
        usleep(1);
    }
    
    return [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
}

@end
