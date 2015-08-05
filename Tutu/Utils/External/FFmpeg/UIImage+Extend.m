//
//  UIImage+Extend.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UIImage+Extend.h"

@implementation UIImage (Extend)

/**
 *  等比率缩放
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scale
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *  根据最小边等比率缩放图片
 */
+ (UIImage *)scaleImage:(UIImage *)image byMinSide:(double)minSide;
{
    minSide+=2;
    double w=image.size.width;
    double h=image.size.height;
    double min=w<h?w:h;

    if (min==minSide) {
        return image;
    }
    double scale=minSide*1.0/min;
    UIImage *scaleImage=[self scaleImage:image toScale:scale];
    return scaleImage;
}
+ (CGFloat)getScaleWith:(CGFloat) sizeWidth size:(CGSize )size{
    double w=size.width;
    double h=size.height;
    double min=w<h?w:h;
    
    if (min==sizeWidth) {
        return 1.0;
    }
    return sizeWidth*1.0/min;
}

/**
 *  切割图片
 */
+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)bound
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, bound);
    UIImage *clipImage = [UIImage imageWithCGImage:imageRef];
    return clipImage;
}

/**
 *  根据宽度等比率切割成正方形图片
 */
+ (UIImage *)clipImageToSquare:(UIImage *)image byWidth:(double)width;
{
    UIImage *scaleImage=[self scaleImage:image byMinSide:width];
    double w=scaleImage.size.width;
    double h=scaleImage.size.height;
    if (w==h) {
        return scaleImage;
    }
    CGRect bound;
    if (w<h) {
        bound=CGRectMake(0, (h-w)/2, w, w);
    }
    else{
        bound=CGRectMake((w-h)/2, 0, h, h);
    }
    UIImage *clipImage=[self clipImage:scaleImage inRect:bound];
    return clipImage;
}

@end
