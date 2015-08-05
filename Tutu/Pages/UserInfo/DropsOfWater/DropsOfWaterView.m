//
//  DropsOfWaterView.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "DropsOfWaterView.h"

@interface DropsOfWaterView()
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
    CGFloat w;
    CGFloat dFoffsetY;
}
@end


@implementation DropsOfWaterView

@synthesize view = _view;

- (void)stretchHeaderForTableView:(CGFloat )width withView:(UIView*)view
{
    w=width;
    _view = view;
    
    initialFrame       = _view.frame;
    defaultViewHeight  = initialFrame.size.height;
    dFoffsetY= 250-defaultViewHeight;
}

- (void)scrollViewDidScroll:(UIScrollView * )scrollView
{
    CGRect f = _view.frame;
    f.size.width = w;
    _view.frame = f;

    if(scrollView.contentOffset.y < dFoffsetY) {
        CGFloat offsetW = (dFoffsetY-scrollView.contentOffset.y);
        
        initialFrame.origin.y = 0;
        initialFrame.size.height = defaultViewHeight + ABS(offsetW);
        _view.frame = initialFrame;
    }else{
        
        initialFrame.origin.y = dFoffsetY - scrollView.contentOffset.y;
        _view.frame = initialFrame;
    }
}

- (void)resizeView
{
    WSLog(@"有重置吗：");
    initialFrame.size.width = w;
    initialFrame.origin.y=dFoffsetY;
    initialFrame.size.height =w;
    initialFrame.origin.x=0;
    _view.frame = initialFrame;
}

@end
