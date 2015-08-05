//
//  LXActivity.h
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//
typedef NS_ENUM(NSInteger, ButtonType) {
    ButtonTypeTutu = 0,
    ButtonTypeQQ,
    ButtonTypeQQZone,
    ButtonTypeWechatSession,
    ButtonTypeWechatTimeline,
    ButtonTypeSina,
    ButtonTypeBlock,
    ButtonTypeReport,
    ButtonTypeFavorite,
    ButtonTypeCancel,
};
#import <UIKit/UIKit.h>
#import "TopicModel.h"

@protocol LXActivityDelegate <NSObject>
- (void)didClickOnImageIndex:(NSInteger )imageIndex item:(TopicModel *) objItem;
@optional
- (void)didClickOnCancelButton;
@end

@interface LXActivity : UIView


- (id)initWithDelegate:(id<LXActivityDelegate>)delegate model:(TopicModel *)model;
- (void)showInView:(UIView *)view;

@end
