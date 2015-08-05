//
//  CoverHeaderView.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-27.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "CoverHeaderView.h"

@implementation CoverHeaderView

- (void)awakeFromNib {
    // Initialization code
    
    [self.titleLabel setFont:ListTitleFont];
    [self.titleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
}

-(void)setTitle:(NSString *)title{
    [self.titleLabel setText:title];
}

@end
