//
//  ImagesToVideo2.h
//  Tutu
//
//  Created by zhanglingyu on 15/4/23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(BOOL success);

@interface ImagesToVideo2 : NSObject

/**
 *  图片合成视频
 */
+ (void)videoFromImage:(NSArray *)arrayAsset toPath:(NSString *)path withCallbackBlock:(SuccessBlock)callbackBlock;

@end
