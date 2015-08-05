//
//  CameraActionSheet.m
//  Tutu
//
//  Created by feng on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//



#define CONTENT_VIEW_HEIGHT    162
#define SELE_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define CONTENT_VIEW_COLOR                     [UIColor whiteColor]
#import "CameraActionSheet.h"

@implementation CameraActionSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithDelegate:(id <CameraActionSheetDelegate>)delegate titles:(NSArray *)titles;{
    self = [super initWithFrame:CGRectMake(0, 0,ScreenWidth, ScreenHeight)];
    if (self) {
        self.cameraDelegate = delegate;
        self.backgroundColor = SELE_COLOR;
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight, ScreenWidth, 0)];
        _contentView.backgroundColor = CONTENT_VIEW_COLOR;
        [self addSubview:_contentView];
        [self createBtnWithTitles:titles];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
- (void)tappedCancel
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.contentView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}
- (void)createBtnWithTitles:(NSArray *)titles{
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self.contentView addGestureRecognizer:tapGesture2];

    int i = 0;
    for (NSString *title in titles) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor grayColor]];
        [_contentView addSubview:btn];
        if (i == 0) {
            btn.frame = CGRectMake(20, 20,ScreenWidth - 40 , 40);
        }else if (i == 1){
            btn.frame = CGRectMake(20, 64,ScreenWidth - 40 , 40);
        }else{
            btn.frame = CGRectMake(20, 105,ScreenWidth - 40 , 40);
        }
        i ++ ;
    }
    [self.contentView setFrame:CGRectMake(0, ScreenHeight   , ScreenWidth, 0)];
    [UIView animateWithDuration:0.25 animations:^{
        [self.contentView setFrame:CGRectMake(0, ScreenHeight - CONTENT_VIEW_HEIGHT, ScreenWidth, CONTENT_VIEW_HEIGHT)];
    } completion:^(BOOL finished) {
    }];
}
- (void)showInView:(UIView *)view
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}
- (void)buttonClick:(UIButton *)btn{
    if (_cameraDelegate && [_cameraDelegate respondsToSelector:@selector(cameraActionSheetButtonClick:)]) {
        [_cameraDelegate cameraActionSheetButtonClick:btn.tag];
    }
        [self tappedCancel];
}
@end
