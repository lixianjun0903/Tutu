//
//  DropsOfWaterView.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropsOfWaterView : NSObject

@property (nonatomic,retain) UIView* view;

- (void)stretchHeaderForTableView:(CGFloat )w withView:(UIView*)view;
- (void)scrollViewDidScroll:(UIScrollView *)ttscrollView;
- (void)resizeView;


@end
