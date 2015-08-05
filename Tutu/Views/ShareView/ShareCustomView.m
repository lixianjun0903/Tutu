//
//  ShareCustomView.m
//  Tutu
//
//  Created by gexing on 14/12/10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ShareCustomView.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Additions.h"
#import "UIImage+ImageWithColor.h"
@implementation ShareCustomView

- (id)initWithDelegate:(id<ShareCustomViewDelegate>)delegate imageURL:(NSString *)url uid:(UserInfo *)userInfo{
    
    return [self initWithDelegate:delegate imageURL:url uid:userInfo title:nil message:nil];
}

- (id)initWithDelegate:(id<ShareCustomViewDelegate>)delegate imageURL:(NSString *)url uid:(UserInfo *)userInfo title:(NSString *) sharetitle message:(NSString *)content{

    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        self.user = userInfo;
        self.imageURL=url;
        
        if(sharetitle==nil){
            sharetitle=WebCopy_ShareTuFriendTitle;
        }
        if(content==nil){
            content=WebCopy_ShareTuFriendDesc;
        }
        
        [self createSubviews:sharetitle message:content];
    }
    return self;
}
- (void)showInView:(UIView *)view{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

- (void)createSubviews:(NSString *)title message:(NSString *) content{
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 275) / 2.0, ScreenHeight, 275, 0)];
    self.backGroundView.backgroundColor = HEXCOLOR(0xeeeeee);
    [self.backGroundView.layer setCornerRadius:3.0f];
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backGroundView addSubview:btn];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 70, 70)];
    [imageView sd_setImageWithURL:StrToUrl(_imageURL) placeholderImage: [UIImage imageNamed:@"topic_default"]];
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView.layer setCornerRadius:2.0f];
    [self.backGroundView addSubview:imageView];
    
    _titleLabel = [UILabel labelWithSystemFont:17 textColor:HEXCOLOR(TextBlackColor)];
    _titleLabel.frame = CGRectMake(imageView.max_x + 15, imageView.mj_y, 160, 0);
    _titleLabel.text = title;
    CGSize titleLabelSize = [_titleLabel getLabelSize];
    _titleLabel.frame = CGRectMake(_titleLabel.mj_x, _titleLabel.mj_y, titleLabelSize.width, titleLabelSize.height);
    [self.backGroundView addSubview:_titleLabel];
    
    _descLabel = [UILabel labelWithSystemFont:13 textColor:HEXCOLOR(TextGrayColor)];
    _descLabel.frame = CGRectMake(_titleLabel.mj_x, _titleLabel.max_y + 10, 150,0);
    _descLabel.text = content;
    CGSize descLabelSize = [_descLabel getLabelSize];
    _descLabel.frame = CGRectMake(_descLabel.mj_x,_descLabel.mj_y,descLabelSize.width,descLabelSize.height);
    [self.backGroundView addSubview:_descLabel];
   
    UIView *kuangView = [[UIView alloc]initWithFrame:CGRectMake(imageView.mj_x, imageView.max_y + 20, self.backGroundView.mj_width - 30 , 36)];
    kuangView.layer.masksToBounds = YES;
    [kuangView.layer setCornerRadius:2.0f];
    kuangView.layer.borderColor = HEXCOLOR(SystemColor).CGColor;
    kuangView.layer.borderWidth = 0.7f;
    [self.backGroundView addSubview:kuangView];
    
    
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, kuangView.mj_width - 20 , 36)];
    _textField.placeholder = @"说两句吧";
    _textField.textColor = HEXCOLOR(TextGrayColor);
    [kuangView addSubview:_textField];
    NSArray *titles = @[@"取消",@"确定"];
    CGFloat butonWidth = 118;
    for (int i = 0; i < 2; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(15 + ((self.backGroundView.mj_width / 2.0f - butonWidth - 15) * 2 + butonWidth) * i , kuangView.max_y + 20, butonWidth, 40);
        btn.layer.masksToBounds = YES;
        [btn.layer setCornerRadius:btn.mj_height / 2.0f];
        if (i == 0) {
        [btn setBackgroundImage:[UIImage imageWithColor:HEXCOLOR(0xdddddd)] forState:UIControlStateNormal];
        }else{
        
        [btn setBackgroundImage:[UIImage imageWithColor:HEXCOLOR(SystemColor)] forState:UIControlStateNormal];
        }
        [self.backGroundView addSubview:btn];
        
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.mj_x, ScreenHeight - 185 -215,self.backGroundView.mj_width, 215)];
        //btn.frame = CGRectMake(0, 0, _backGroundView.mj_width, _backGroundView.mj_height);
    } completion:^(BOOL finished) {
    }];
    
}
- (void)buttonClick:(UIButton *)btn{
    if (btn.tag != 1) {
        [self tappedCancel];
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(shareButtonClick:title:content:message:uid:)]) {
        [_delegate shareButtonClick:btn title:CheckNilValue(_titleLabel.text) content:CheckNilValue(_descLabel.text) message:_textField.text uid:_user];
    }
}
- (void)shareViewDismiss{
    [self tappedCancel];
}
- (void)hidenKeyboard{

    [[[UIApplication sharedApplication]keyWindow ]endEditing:YES];
}
- (void)tappedCancel{
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.mj_x,ScreenHeight ,self.backGroundView.mj_width,self.backGroundView.mj_height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}
@end
