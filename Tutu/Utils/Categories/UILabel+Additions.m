//
//  UILabel+Additions.m
//
//
//  Created by lixiang on 13-11-5.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (Additions)

- (void)adjustFontWithMaxWidth:(CGFloat)maxWidth {
    CGSize stringRect;
    CGSize maxSize = CGSizeMake(maxWidth, MAXFLOAT);
    if (CGSizeEqualToSize(maxSize, CGSizeZero)) {
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringRect = [self.text boundingRectWithSize:self.frame.size options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.font} context:NULL];
#else
        stringRect = [self.text sizeWithFont:self.font
                           constrainedToSize:self.frame.size
                               lineBreakMode:NSLineBreakByWordWrapping];
#endif
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringRect = [self.text boundingRectWithSize:maxSize options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.font} context:NULL];
#else
        stringRect = [self.text sizeWithFont:self.font
                           constrainedToSize:maxSize
                               lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    CGRect frame = self.frame;
    frame.size.width = stringRect.width;
    if (stringRect.height > frame.size.height) {
        frame.size.height = stringRect.height;
    }
    self.frame = frame;
    
    NSInteger lines = (int)stringRect.height / self.font.xHeight;
    self.numberOfLines = lines;
}

+(UILabel *)labelWithSystemFont:(CGFloat)size textColor:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    return label;
}
+(UILabel *)labelWithBlodFont:(CGFloat)size textColor:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    return label;
}
+(CGFloat)labelHeightWithFontSize:(CGFloat)FontSize{
    NSString *string = @"labelHeight";
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:FontSize] forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}
-(CGSize)getLabelSize{
    CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.mj_width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.numberOfLines = 0;
    return size;
}
- (CGSize)getLineLabelSize{
    CGSize size = [self.text sizeWithFont:self.font];
    return size;
}
@end
