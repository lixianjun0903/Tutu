//
//  UIImageView+Gif.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/31.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UIImageView+Gif.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+GIF.h"

@implementation UIImageView(Gif)


-(void)setImageWithLocalName:(NSString *)fileName{
    
    if(fileName){
        [self setImage:[UIImage sd_animatedGIFNamed:fileName]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
