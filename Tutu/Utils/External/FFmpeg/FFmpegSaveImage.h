//
//  FFmpegSaveImage.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/25.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegBase.h"

typedef void(^GetImageDataBlock) (NSData *imgData,int index);

@interface FFmpegSaveImage : FFmpegBase

/**
 *  根据个数获取图片
 */
+ (NSMutableArray *)getImages:(int)count withVideo:(NSString *)videoPath;

/**
 *  根据个数获取图片
 */
+ (void)getImages:(int)count withVideo:(NSString *)videoPath withBlock:(GetImageDataBlock)block;

@end
