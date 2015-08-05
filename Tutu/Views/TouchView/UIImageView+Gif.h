//
//  UIImageView+Gif.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/31.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView(Gif)

// 不需要文件后缀名 如，.gif
-(void)setImageWithLocalName:(NSString *)fileName;

@end
