//
//  LXActivity.m
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import "LXActivity.h"
#import "UILabel+Additions.h"
#import "UIImage+ImageWithColor.h"
#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define ACTIONSHEET_BACKGROUNDCOLOR             HEXCOLOR(0xecebf1)
#define ANIMATE_DURATION                        0.25f

#define CORNER_RADIUS                           5
#define SHAREBUTTON_BORDER_WIDTH                0.5f
#define SHAREBUTTON_BORDER_COLOR                [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor
#define SHAREBUTTONTITLE_FONT                   [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]

#define CANCEL_BUTTON_COLOR                     [UIColor colorWithRed:53/255.00f green:53/255.00f blue:53/255.00f alpha:1]

#define SHAREBUTTON_WIDTH                       50
#define SHAREBUTTON_HEIGHT                      50
#define SHAREBUTTON_INTERVAL_WIDTH              42.5
#define SHAREBUTTON_INTERVAL_HEIGHT             35

#define SHARETITLE_WIDTH                        50
#define SHARETITLE_HEIGHT                       20
#define SHARETITLE_INTERVAL_WIDTH               42.5
#define SHARETITLE_INTERVAL_HEIGHT              SHAREBUTTON_WIDTH+SHAREBUTTON_INTERVAL_HEIGHT
#define SHARETITLE_FONT                         [UIFont fontWithName:@"Helvetica" size:15]

#define TITLE_INTERVAL_HEIGHT                   15
#define TITLE_HEIGHT                            35
#define TITLE_INTERVAL_WIDTH                    30
#define TITLE_WIDTH                             260
#define TITLE_FONT                              [UIFont fontWithName:@"Helvetica" size:10]
#define SHADOW_OFFSET                           CGSizeMake(0, 0.8f)
#define TITLE_NUMBER_LINES                      2

#define BUTTON_INTERVAL_HEIGHT                  20
#define BUTTON_HEIGHT                           45
#define BUTTON_INTERVAL_WIDTH                   45
#define BUTTON_WIDTH                            240
#define BUTTONTITLE_FONT                        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
#define BUTTON_BORDER_WIDTH                     0.5f
#define BUTTON_BORDER_COLOR                     [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor


@interface UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color;
@end


@implementation UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end

@interface LXActivity ()

@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic,assign) NSInteger postionIndexNumber;
@property (nonatomic,assign) BOOL isHadTitle;
@property (nonatomic,assign) BOOL isHadShareButton;
@property (nonatomic,assign) BOOL isHadCancelButton;
@property (nonatomic,assign) CGFloat LXActivityHeight;
@property (nonatomic,assign) id<LXActivityDelegate>delegate;
@property (nonatomic,assign) TopicModel * objItem;

@end

@implementation LXActivity

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public method

- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray item:(TopicModel *)model
{
    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        
    }
    return self;
}
- (id)initWithDelegate:(id<LXActivityDelegate>)delegate model:(TopicModel *)model{
    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        if (model) {
            self.objItem = model;
        }
        [self createSubviews];
    }
    return self;
}
- (void)createSubviews{
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 0)];
    self.backGroundView.backgroundColor = HEXCOLOR(0xeeeeee);
    [self addSubview:self.backGroundView];
    UILabel *titleLabel = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextBlackColor)];
    titleLabel.frame = CGRectMake(0, 20,ScreenWidth, 12);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.backGroundView addSubview:titleLabel];
    titleLabel.text = @"分享到";
    
    NSArray *imageNames = @[@"Icon-72@2x",@"sheet_qq",@"sheet_qzone",@"sheet_wechat_session",@"sheet_wechat_timeline",@"sheet_sina"];
    NSArray *titles = @[@"Tutu好友",@"QQ好友",@"QQ空间",@"微信好友",@"微信朋友圈",@"新浪微博"];
    CGFloat originx = 35.0;
    
    CGFloat buttonWidth = 60;
    
    CGFloat horizontalSpace = (ScreenWidth - originx * 2 - buttonWidth * 3) / 2.0f;
    
    

    //创建分享的按钮
    for (int i = 0; i < imageNames.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn setBackgroundImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(originx + (buttonWidth + horizontalSpace) * (i % 3), 51 + i / 3 * (buttonWidth + 38), 60, 60);
        [self.backGroundView addSubview:btn];
        
        UILabel *label = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(SystemGrayColor)];
        label.bounds = CGRectMake(0, 0, 60, 12);
        label.center = CGPointMake(btn.center.x, btn.center.y + 46);
        label.text = titles[i];
        label.textColor = HEXCOLOR(TextGrayColor);
        label.textAlignment = NSTextAlignmentCenter;
        [self.backGroundView addSubview:label];
    }
    //创建取消按钮
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancel setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateHighlighted];
    cancel.tag = ButtonTypeCancel;
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    cancel.frame = CGRectMake(15, 255, ScreenWidth - 15 * 2, 40);
    [cancel.layer setCornerRadius:3.0f];
    cancel.layer.masksToBounds = YES;
    [cancel setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.backGroundView addSubview:cancel];
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, ScreenHeight - 310, ScreenWidth, 310)];
        
    } completion:^(BOOL finished) {
    }];

}
- (void)showInView:(UIView *)view
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

#pragma mark - Praviate method

- (void)buttonClick:(UIButton *)button
{
    if (button.tag == ButtonTypeCancel) {
        [self tappedCancel];
        return;
    }
    [self bk_performBlock:^(id obj) {
        if (_delegate && [_delegate respondsToSelector:@selector(didClickOnImageIndex:item:)]) {
            [_delegate didClickOnImageIndex:button.tag item:self.objItem];
        }
    } afterDelay:ANIMATE_DURATION];
    [self tappedCancel];
}

- (void)tappedCancel
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnCancelButton)]) {
        [_delegate didClickOnCancelButton];
    }
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)tappedBackGroundView
{
    //
    
}

@end
