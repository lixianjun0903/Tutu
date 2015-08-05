//
//  InsetsLabel.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/20.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsetsLabel : UILabel

@property(nonatomic) UIEdgeInsets insets;
-(id) initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets) insets;
-(id) initWithInsets: (UIEdgeInsets) insets;

@end
