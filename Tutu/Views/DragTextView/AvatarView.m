//
//  AvatarView.m
//  Tutu
//
//  Created by feng on 14-10-31.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AvatarView.h"


static AvatarView *avatarView;
@implementation AvatarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (AvatarView *)sharedAvatar{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avatarView = [[AvatarView alloc]initWithFrame:CGRectMake(0, 0, 58, 58)];
        avatarView.center = CGPointMake(ScreenWidth / 2.0,64 );
        avatarView.button = [[UIButton alloc]init];
        avatarView.button.frame = avatarView.bounds;
        [avatarView addSubview:avatarView.button];
        [avatarView.button.layer setCornerRadius:avatarView.mj_width / 2.0];
        [avatarView.button addTarget:avatarView action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        avatarView.button.layer.masksToBounds = YES;
        [avatarView.button setBackgroundImage:[UIImage imageNamed:@"avatar_default"] forState:UIControlStateNormal];
        avatarView.avatarImage = [[UIImageView alloc]init];
        avatarView.avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
        avatarView.avatarImage.layer.borderWidth = 2.0;
        avatarView.avatarImage.layer.masksToBounds = YES;
        [avatarView.avatarImage.layer setCornerRadius:avatarView.mj_width / 2.0];
        avatarView.avatarImage.frame = avatarView.bounds;
        [avatarView addSubview:avatarView.avatarImage];
        [[UIApplication sharedApplication].keyWindow addSubview:avatarView];
    });
    return avatarView;
}

- (void)avatarViewShow{
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows)
        if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self];
            break;
        }
}

- (void)avatarViewDismiss{
    [self removeFromSuperview];
}
- (void)buttonClick:(id)sender{
    if (_target && [_target respondsToSelector:@selector(gotoUserCenter)]) {
        [_target gotoUserCenter];
    }
}
@end
