//
//  UILabel+Additions.h
//  
//
//  Created by lixiang on 13-11-5.
//  Copyright (c) 2013年 All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Additions)

- (void)adjustFontWithMaxWidth:(CGFloat)maxWidth;
+(UILabel *)labelWithSystemFont:(CGFloat)size textColor:(UIColor *)color;
+(UILabel *)labelWithBlodFont:(CGFloat)size textColor:(UIColor *)color;
+(CGFloat)labelHeightWithFontSize:(CGFloat)size;
-(CGSize)getLabelSize;
- (CGSize)getLineLabelSize;
@end
