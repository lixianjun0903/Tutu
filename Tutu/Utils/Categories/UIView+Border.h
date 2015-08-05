//
//  UIView+UIView_Border.h
//  Tutu
//
//  Created by gaoyong on 14/10/30.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Border)

- (void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth andViewWidth:(CGFloat) viewWidth;
@end
