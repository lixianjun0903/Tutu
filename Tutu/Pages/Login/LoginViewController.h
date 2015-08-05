//
//  LoginViewController.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "UMSocial.h"
#import "YHShakeUITextField.h"
#import <TencentOpenAPI/TencentOAuth.h>

//登陆界面颜色
//button点击高亮颜色
#define QQNumberTextColor 0x8CDAC3

//登陆手机号密码下的线颜色
#define LoginLineColor 0xA9E5D5
//Or的颜色
#define LoginOrColor 0xABE3D2
#define LoginOrLineColor 0xBEECDF
#define LoginBackgrouColor 0xEDFAF6

#define LoginButtonBg 0x52CBAB
#define LoginButtonBgHD 0x91dec9
#define LoginTextHelight 0xa9e5d5
#define RegisterTextHelight 0xa0e2d0

//QQ登陆框颜色
#define QQLoginAroundColor 0x86DBC4


@interface LoginViewController : BaseController<TencentSessionDelegate>{
    NSMutableArray* _permissions;
}

//输入框后的View
@property (weak, nonatomic) IBOutlet UIView *inputBackGroundView;
//分割线和or
@property (weak, nonatomic) IBOutlet UIView *lineOrView;
//底部注册和游客按钮
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UIButton *forgetButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *sinaLoginButton;
@property(nonatomic)BOOL isRootPage;



@property (weak, nonatomic) IBOutlet UIButton *registButton;

@property (weak, nonatomic) IBOutlet UIImageView *orLineImage;


@property (weak, nonatomic) IBOutlet UILabel *orlabel;

@property (weak, nonatomic) IBOutlet UIImageView *itemLineView;

@property (weak, nonatomic) IBOutlet UIView *topView;



@end
