//
//  ImagesToVideo2.m
//  Tutu
//
//  Created by zhanglingyu on 15/4/23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ImagesToVideo2.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kFrameWidth 640

CGSize const DefaultFrameSize                             = (CGSize){kFrameWidth, kFrameWidth};
NSInteger const DefaultFrameRate                          = 1;
//过渡帧个数
NSInteger const TransitionFrameCount                      = 25;
//等待过渡帧的个数
NSInteger const FramesToWaitBeforeTransition              = 10;
//是否添加动画效果
BOOL const DefaultTransitionShouldAnimate                 = NO;

/**
 *  每张播放时间（秒）
 *  1~10 3s/张，10~20 2s/张，20~30 1s/张
 */
@implementation ImagesToVideo2

/**
 *  图片合成视频
 */
+ (void)videoFromImage:(NSArray *)arrayAsset toPath:(NSString *)path withCallbackBlock:(SuccessBlock)callbackBlock
{
    NSLog(@"%@",path);
    
    [self writeImageAsMovie:arrayAsset
                     toPath:path
                       size:DefaultFrameSize
                        fps:DefaultFrameRate
         animateTransitions:DefaultTransitionShouldAnimate
          withCallbackBlock:callbackBlock];
    
}

+ (void)writeImageAsMovie:(NSArray *)array
                   toPath:(NSString*)path
                     size:(CGSize)size
                      fps:(int)fps
       animateTransitions:(BOOL)shouldAnimateTransitions
        withCallbackBlock:(SuccessBlock)callbackBlock
{
    int frameTime=1;
    int frameCount=(int)array.count;
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

    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    if (error) {
        if (callbackBlock) {
            callbackBlock(NO);
        }
        return;
    }
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:size.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:size.height]};
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //保存图片到沙盒，解决内存溢出问题
    NSMutableArray *pathArr=[[NSMutableArray alloc] init];
    for (ALAsset *asset in array) {
        UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        NSString *filePath=[SysTools writeImageToDocument:[UIImage scaleImage:image byMinSide:kFrameWidth] fileName:asset.defaultRepresentation.filename];
        image=nil;
        [pathArr addObject:filePath];
    }
    
    
    CVPixelBufferRef buffer;
    CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);
    
    CMTime presentTime = CMTimeMake(0, fps);
    
    int i = 0;
    while (1)
    {
        
        if(writerInput.readyForMoreMediaData){
            
//            NSLog(@"i=%i fps=%i 当前播放时间:%is",i,fps,i*frameTime/fps);
            presentTime = CMTimeMake(i*frameTime, fps);
            
            if (i >= [array count]) {
                buffer = NULL;
            } else {

//                ALAsset *asset=array[i];
                
//                UIImage *image=[UIImage scaleImage:[UIImage imageWithCGImage:asset.aspectRatioThumbnail] byMinSide:kFrameWidth];
                NSData *image = [NSData dataWithContentsOfFile:[pathArr objectAtIndex:i]];
                buffer = [self pixelBufferFromCGImage:[[UIImage imageWithData:image] CGImage] size:DefaultFrameSize];
            }
            
            if (buffer) {
                //append buffer
                
                BOOL appendSuccess = [self appendToAdapter:adaptor
                                                          pixelBuffer:buffer
                                                               atTime:presentTime
                                                            withInput:writerInput];
                NSAssert(appendSuccess, @"Failed to append");
                
                if (shouldAnimateTransitions && i + 1 < array.count) {
                    
                    //Create time each fade frame is displayed
                    CMTime fadeTime = CMTimeMake(1, fps*TransitionFrameCount);
                    
                    //Add a delay, causing the base image to have more show time before fade begins.
                    for (int b = 0; b < FramesToWaitBeforeTransition; b++) {
                        presentTime = CMTimeAdd(presentTime, fadeTime);
                    }
                    
                    //Adjust fadeFrameCount so that the number and curve of the fade frames and their alpha stay consistant
                    NSInteger framesToFadeCount = TransitionFrameCount - FramesToWaitBeforeTransition;
                    
//                    ALAsset *asset=array[i];
//                    UIImage *image=[UIImage scaleImage:[UIImage imageWithCGImage:asset.aspectRatioThumbnail] byMinSide:kFrameWidth];
                    
                    NSData *imageData = [NSData dataWithContentsOfFile:[pathArr objectAtIndex:i]];
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    NSData *imageData2 = [NSData dataWithContentsOfFile:[pathArr objectAtIndex:i+1]];
                    UIImage *image2 = [UIImage imageWithData:imageData2];
                    
//                    ALAsset *asset2=array[i+1];
//                    UIImage *image2=[UIImage scaleImage:[UIImage imageWithCGImage:asset2.aspectRatioThumbnail] byMinSide:kFrameWidth];
                    
                    //Apply fade frames
                    for (double j = 1; j < framesToFadeCount; j++) {
                        
                        buffer = [self crossFadeImage:[image CGImage]
                                                         toImage:[image2 CGImage]
                                                          atSize:DefaultFrameSize
                                                       withAlpha:1];//j/framesToFadeCount
                        
                        BOOL appendSuccess = [self appendToAdapter:adaptor
                                                                  pixelBuffer:buffer
                                                                       atTime:presentTime
                                                                    withInput:writerInput];
                        presentTime = CMTimeAdd(presentTime, fadeTime);
                        
                        NSAssert(appendSuccess, @"Failed to append");
                    }
                }
                
                i++;
            } else {
                
                //Finish the session:
                [writerInput markAsFinished];
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"Successfully closed video writer");
                    if (videoWriter.status == AVAssetWriterStatusCompleted) {
                        if (callbackBlock) {
                            callbackBlock(YES);
                        }
                    } else {
                        if (callbackBlock) {
                            callbackBlock(NO);
                        }
                    }
                }];
                
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                NSLog (@"Done");
                break;
            }
        }
    }
    
    //清空沙盒中的图片
    for (NSString *imagePath in pathArr) {
        deleteFileByPath(imagePath);
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
