//
//  UIImage+Category.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-21.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage(Category)


// 画水印
- (UIImage *) imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([self size]);
    }
#endif
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    //水印图
//    [mask drawInRect:rect];
    [mask drawInRect:CGRectMake(self.size.width-mask.size.width-10, self.size.height-mask.size.height-10, mask.size.width, mask.size.height)];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}


@end
