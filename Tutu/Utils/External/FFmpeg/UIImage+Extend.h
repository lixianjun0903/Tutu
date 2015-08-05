//
//  UIImage+Extend.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extend)

/**
 *  等比率缩放
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scale;

/**
 *  根据最小边等比率缩放图片
 */
+ (UIImage *)scaleImage:(UIImage *)image byMinSide:(double)minSide;

+ (CGFloat)getScaleWith:(CGFloat) sizeWidth size:(CGSize )size;

/**
 *  切割图片
 */
+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)bound;

/**
 *  根据宽度等比率切割成正方形图片
 */
+ (UIImage *)clipImageToSquare:(UIImage *)image byWidth:(double)width;

@end
