//
//  ListMenuView.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-8.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ListMenuView.h"

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

@interface ListMenuView ()

@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic,assign) NSInteger postionIndexNumber;
@property (nonatomic,assign) BOOL isHadTitle;
@property (nonatomic,assign) BOOL isHadShareButton;
@property (nonatomic,assign) BOOL isHadCancelButton;
@property (nonatomic,assign) CGFloat LXActivityHeight;
@property (nonatomic,assign) id<ListMenuDelegate>delegate;

@end

@implementation ListMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public method

- (id)initWithTitle:(NSString *)title delegate:(id<ListMenuDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray item:(TopicModel *)model
{
    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        
    }
    return self;
}
- (id)initWithDelegate:(id<ListMenuDelegate>)delegate items:(NSArray *) array{
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
        
        [self createSubviews:array];
    }
    return self;
}
- (void)createSubviews:(NSArray *) titles{
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 0)];
    self.backGroundView.backgroundColor = HEXCOLOR(0xeeeeee);
    [self addSubview:self.backGroundView];
   
    int h=15;
    //创建,收藏按钮,屏蔽的按钮，举报按钮，取消按钮
    for (int i = 0; i < titles.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(15, 15 + 50 * i,SCREEN_WIDTH - 30, 40);
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        btn.tag = i;
        btn.layer.masksToBounds = YES;
        [btn.layer setCornerRadius:4.0f];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        
        //设置取消的按钮字体色为红色,其他的为黑色
        if (i == (titles.count-1)) {
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateNormal];
        }
        [self.backGroundView addSubview:btn];
        h=h+50;
    }
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, ScreenHeight - h, ScreenWidth, h)];
        
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
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnIndex:type:)]) {
        [_delegate didClickOnIndex:button.tag type:self.tag];
    }
    [self tappedCancel];
}

- (void)tappedCancel
{
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