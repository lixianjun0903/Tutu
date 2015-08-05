//
//  ImagesToVideo.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

typedef void(^SuccessBlock1)(BOOL success);

@interface ImagesToVideo : NSObject

/**
 *  图片合成视频
 */
+ (void)videoFromImageURL:(NSArray *)arrayImageURL toPath:(NSString *)path withCallbackBlock:(SuccessBlock1)callbackBlock;

@end
