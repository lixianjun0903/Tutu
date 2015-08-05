//
//  FFmpegForVideoImage.h
//  Tutu
//
//  Created by zhangxinyao on 15-3-24.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFmpegBase.h"

typedef void(^FindVideoImage)(UIImage *img,int index);

@interface FFmpegForVideoImage : NSObject



-(void)findVideoImages:(NSURL *)videoURL number:(int)num width:(float) maxWidth progress:(FindVideoImage) block;

@end
