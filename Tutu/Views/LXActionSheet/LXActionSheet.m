//
//  LXActionSheet.m
//  LXActionSheetDemo
//
//  Created by lixiang on 14-3-10.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import "LXActionSheet.h"
#import "UIImage+ImageWithColor.h"
#import "UILabel+Additions.h"
#define CANCEL_BUTTON_COLOR                     [UIColor colorWithRed:53/255.00f green:53/255.00f blue:53/255.00f alpha:1]
#define DESTRUCTIVE_BUTTON_COLOR                [UIColor colorWithRed:185/255.00f green:45/255.00f blue:39/255.00f alpha:1]
#define OTHER_BUTTON_COLOR                      [UIColor whiteColor]
#define ACTIONSHEET_BACKGROUNDCOLOR             HEXCOLOR(SystemGrayColor)
#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define CORNER_RADIUS                           5

#define BUTTON_INTERVAL_HEIGHT                  8
#define BUTTON_HEIGHT                           40
#define BUTTON_INTERVAL_WIDTH                   15
#define BUTTON_WIDTH                            260
#define BUTTONTITLE_FONT                        [UIFont fontWithName:@"HelveticaNeue" size:18]
#define BUTTON_BORDER_WIDTH                     0.5f
#define BUTTON_BORDER_COLOR                     [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor


#define TITLE_INTERVAL_HEIGHT                   15
#define TITLE_HEIGHT                            35
#define TITLE_INTERVAL_WIDTH                    20
#define TITLE_WIDTH                             260
#define TITLE_FONT                              [UIFont fontWithName:@"Helvetica" size:14]
#define SHADOW_OFFSET                           CGSizeMake(0, 0.8f)
#define TITLE_NUMBER_LINES                      2

#define ANIMATE_DURATION                        0.25f

@interface LXActionSheet ()

@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic,assign) NSInteger postionIndexNumber;
@property (nonatomic,assign) BOOL isHadTitle;
@property (nonatomic,assign) BOOL isHadDestructionButton;
@property (nonatomic,assign) BOOL isHadOtherButton;
@property (nonatomic,assign) BOOL isHadCancelButton;
@property (nonatomic,assign) CGFloat LXActionSheetHeight;
@property (nonatomic,assign) id<LXActionSheetDelegate>delegate;

@end

@implementation LXActionSheet

#pragma mark - Public method



- (void)showInView:(UIView *)view
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}
-(void)showInCustomView:(UIView *)view{
    [view addSubview:self];
}

#pragma mark - CreatButtonAndTitle method

- (id)initWithTitle:(NSString *)title delegate:(id<LXActionSheetDelegate>)delegate otherButton:(NSArray *)buttons cancelButton:(NSString *)cancelButton{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        //生成LXActionSheetView
        self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.backGroundView.backgroundColor = HEXCOLOR(0xeeeeee);
        [self addSubview:self.backGroundView];
        
        //当显示的信息是设置中的缓存空间的时候，需要使用label的 attributedText 属性
        BOOL isCache = [title hasPrefix:@"清除储存"];
        UILabel *titleLabel = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(TextBlackColor)];
        titleLabel.frame = CGRectMake(0, 0, ScreenWidth, 0);
        if (title.length > 0) {
            titleLabel.frame = CGRectMake(0, 15, ScreenWidth, 15);
            titleLabel.text = title;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            if (isCache) {
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:title];
                [attributeString addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(TextBlackColor) range:NSMakeRange(0,6)];
                [attributeString addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(TextGrayColor) range:NSMakeRange(6,title.length - 6)];
                titleLabel.attributedText = attributeString;
            }
            [_backGroundView addSubview:titleLabel];
        }
        
        for (int i = 0; i < buttons.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [_backGroundView addSubview:btn];
            [btn setTitle:buttons[i] forState:UIControlStateNormal];
            [btn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateNormal];
            btn.layer.masksToBounds = YES;
            [btn.layer setCornerRadius:3.0f];
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            btn.tag = i;
            btn.frame = CGRectMake(15, titleLabel.max_y + 15 + 50 * i, ScreenWidth - 30, 40);
        }
       //创建取消按钮
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_backGroundView addSubview:cancelBtn];
        cancelBtn.layer.masksToBounds = YES;
        [cancelBtn.layer setCornerRadius:3.0f];
        [cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        cancelBtn.tag = buttons.count;
        [cancelBtn setTitle:cancelButton forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(15, titleLabel.max_y + 15 + 50 * buttons.count, ScreenWidth - 30, 40);
        
        CGFloat backgroundHeight = 0;
        if (titleLabel.text.length > 0) {
          backgroundHeight = titleLabel.max_y + 50 * (buttons.count + 1) + 20;
        }else{
          backgroundHeight = titleLabel.max_y + 50 * (buttons.count + 1) + 20;
        }
        _buttonCount = buttons.count;
        
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
            [self.backGroundView setFrame:CGRectMake(0,ScreenHeight - backgroundHeight,ScreenWidth,backgroundHeight)];
        } completion:^(BOOL finished) {
        }];
        
    }
    return self;
}
- (void)buttonClick:(UIButton *)sender{
    [self bk_performBlock:^(id obj) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnButtonIndex:tag:)]) {
            [self.delegate didClickOnButtonIndex:sender.tag tag:self.tag];
        }

    } afterDelay:ANIMATE_DURATION ];
        [self tappedCancel];
}
- (void)tappedCancel
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didClickOnBackground)]) {
            [self.delegate didClickOnBackground];
        }
    }
    [UIView animateWithDuration:ANIMATE_DURATION  animations:^{
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
