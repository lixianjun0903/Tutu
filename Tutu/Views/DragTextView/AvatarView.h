//
//  AvatarView.h
//  Tutu
//
//  Created by feng on 14-10-31.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AvatarViewDelegate <NSObject>

- (void)gotoUserCenter;

@end
@interface AvatarView : UIView
@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)UIImageView *avatarImage;
@property(nonatomic,weak)id <AvatarViewDelegate> target;
+ (AvatarView *)sharedAvatar;
- (void)avatarViewShow;
- (void)avatarViewDismiss;
@end
