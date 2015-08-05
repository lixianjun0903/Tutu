//
//  ShareCustomView.h
//  Tutu
//
//  Created by gexing on 14/12/10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserInfo.h"

@protocol ShareCustomViewDelegate <NSObject>

- (void)shareButtonClick:(UIButton *)btn title:(NSString *)title content:(NSString *)content message:(NSString *)message uid:(UserInfo *)user;


@end
@interface ShareCustomView :UIView

@property(nonatomic,weak)id <ShareCustomViewDelegate> delegate;
@property(nonatomic,strong)UIView *backGroundView;
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)UserInfo *user;
@property(nonatomic,strong)NSString *imageURL;

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *descLabel;
- (id)initWithDelegate:(id<ShareCustomViewDelegate>)delegate imageURL:(NSString *)url uid:(UserInfo *)user;

//特殊标题专用
- (id)initWithDelegate:(id<ShareCustomViewDelegate>)delegate imageURL:(NSString *)url uid:(UserInfo *)userInfo title:(NSString *) sharetitle message:(NSString *)content;

- (void)showInView:(UIView *)view;
- (void)shareViewDismiss;
@end
