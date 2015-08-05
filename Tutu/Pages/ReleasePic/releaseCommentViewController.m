//
//  releaseCommentViewController.m
//  Tutu
//
//  Created by gexing on 15/4/10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "releaseCommentViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UIPlaceHolderTextView.h"
#import "TTplayView.h"
#import "UMSocial.h"
#import "locationSearchViewController.h"
#import "topicSelectedViewController.h"
#import "TTLinkedTextView.h"
#import "UIDevice-Hardware.h"
#import "topicSelectedViewController.h"
#import "UserSearchController.h"
//#import "BMKPoiSearch.h"
#import <BaiduMapAPI/BMKPoiSearch.h>
#import "UIImage+Category.h"


@interface releaseCommentViewController ()<UMSocialUIDelegate,localDelegate,UITextViewDelegate,topicSelectedDelegate,SearchUserPageDelegate>
{

    TTLinkedTextView *releaseTextView;  //发布框
    UIImageView *userImage;    //用户头像
    UITapGestureRecognizer *tapRecognizer;  //用于隐藏键盘
    UIView *footerView;    //@,#父视图
    UIView *shareBackView;
    BOOL isShowBoard;
    CGRect oldFrame;
    
    UserInfo *atuser;
    BMKPoiInfo *poiInfo;
    topicHotModel *htModel;
    CGFloat w;
    
    BOOL isKana;   //是否匿名，默认为NO
    int shareType; //默认0
    
    
    // view 定义
    // 位置
    UIButton *addLocationBtn;
    UIButton *closeBtn;
    UIImageView *rightView;
    UIButton *btn2;
    
    // 匿名
    UIButton *anonymousBtn;

}
@end

@implementation releaseCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view.
    w=self.view.frame.size.width;
    
    [self initState];
    [self createView];
    [self handleKeyboard];
    
}
-(void)initState
{
    self.view.backgroundColor=UIColorFromRGB(SystemGrayColor);
    isKana=NO;
    shareType=0;

}
-(void)createView
{


    UIView *topview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,44)];
    //    [topview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common_nav7_bg"]]];
    [topview setBackgroundColor:UIColorFromRGB(OverlayViewColor)];
    [self.view addSubview:topview];
    
        UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setBackgroundColor:[UIColor clearColor]];
        backBtn.tag=BACK_BUTTON;
        [backBtn setFrame:CGRectMake(0,0, 44, 44)];
        backBtn.backgroundColor=[UIColor clearColor];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 16, 13, 16)];
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"backc_light"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [topview addSubview:backBtn];
    //
    //发布
    btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.tag=RIGHT_BUTTON;
    [btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(SCREEN_WIDTH-54, 0, 44, 44) ;
    [btn2 setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [btn2 setTitle:TTLocalString(@"TT_release") forState:UIControlStateNormal];
    [topview addSubview:btn2];

    
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topview.frame)+15, SCREEN_WIDTH, 140)];
    backView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:backView];
    //textView
    releaseTextView=[[TTLinkedTextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-90, CGRectGetHeight(backView.frame))];
    releaseTextView.delegate=self;
    [releaseTextView setPlaceholder:TTLocalString(@"TT_Add a description")];
    [releaseTextView setFont:TitleFont];
    [backView addSubview:releaseTextView];
    
    //头像
    userImage=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-64, 10, 64, 64)];
    userImage.backgroundColor=[UIColor whiteColor];
    userImage.image=self.passUserImage;
    userImage.userInteractionEnabled=YES;
    [userImage setContentMode:UIViewContentModeScaleAspectFit];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [userImage addGestureRecognizer:tap];
    [backView addSubview:userImage];
    
    UIButton *imageBtn=[[UIButton alloc]initWithFrame:userImage.frame];
    imageBtn.tag=imageBtnTag;
    [imageBtn setImage:[UIImage imageNamed:@"record_play_nor"] forState:UIControlStateNormal];
    [imageBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateHighlighted];
    [imageBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [imageBtn setImageEdgeInsets:UIEdgeInsetsMake((64-25)/2, (64-25)/2, (64-25)/2, (64-25)/2)];
    [backView addSubview:imageBtn];
    
    if (self.pageType==PhotoType) {
        [imageBtn setHidden:YES];
    }
    
    //设置圆角
    CALayer *layer=[userImage layer];
    layer.cornerRadius=5;
    [layer setMasksToBounds:YES];
    anonymousBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-50, CGRectGetMaxY(backView.frame)-CGRectGetMinY(backView.frame)-15-24, 50, 30)];
    //匿名按钮
    [anonymousBtn setImage:[UIImage imageNamed:@"no_anonymous"] forState:UIControlStateNormal];
    [anonymousBtn setImage:[UIImage imageNamed:@"no_anonymous"] forState:UIControlStateHighlighted];

    [anonymousBtn setImageEdgeInsets:UIEdgeInsetsMake((30-18)/2, 0, (30-18)/2, 50-18)];
    anonymousBtn.tag=anonymousBtnTag;
    [anonymousBtn setTitle:TTLocalString(@"topic_anonymous") forState:UIControlStateNormal];
    [anonymousBtn setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
    [anonymousBtn.titleLabel setFont:ListDetailFont];
    [anonymousBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [anonymousBtn setTitleEdgeInsets:UIEdgeInsetsMake(0,-anonymousBtn.imageView.frame.size.width,0,0)];
    [backView addSubview:anonymousBtn];
    
    //添加位置按钮
    addLocationBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(backView.frame)+1, SCREEN_WIDTH, 48)];
    addLocationBtn.backgroundColor=[UIColor whiteColor];
    [addLocationBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    addLocationBtn.tag=locationBtnTag;
    addLocationBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    addLocationBtn.contentVerticalAlignment=UIControlContentVerticalAlignmentTop;
    //设置图片位置
    [addLocationBtn setImage:[UIImage imageNamed:@"addLocaltion_nor"] forState:UIControlStateNormal];
    [addLocationBtn setImageEdgeInsets:UIEdgeInsetsMake(15, 17, 15,SCREEN_WIDTH-17-13)];
    //设置Label位置
    [addLocationBtn setTitle:TTLocalString(@"TT_add_location") forState:UIControlStateNormal];
    [addLocationBtn setTitleEdgeInsets:UIEdgeInsetsMake(15,13, 15, 48)];
    addLocationBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [addLocationBtn setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
    [addLocationBtn setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateHighlighted];

    rightView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-8,(CGRectGetHeight(addLocationBtn.frame)-14)/2, 8, 14)];
    rightView.image=[UIImage imageNamed:@"push_right"];
    rightView.userInteractionEnabled=NO;
    rightView.tag=1000;
    [addLocationBtn addSubview:rightView];
    [self.view addSubview:addLocationBtn];
    
    closeBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-48, CGRectGetMinY(addLocationBtn.frame), 48, 48) ];
    [closeBtn setImage:[UIImage imageNamed:@"location_close"] forState:UIControlStateNormal];
    [closeBtn setImageEdgeInsets:UIEdgeInsetsMake((48-17)/2, (48-17)/2, (48-17)/2, (48-17)/2)];
    [closeBtn setHidden:YES];
    closeBtn.tag=closeBtnTag;
    [closeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:closeBtn];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(addLocationBtn.frame)+15, 150, 30)];
    label.text=TTLocalString(@"TT_Synchronization to");
    label.font=ListDetailFont;
    [label sizeToFit];
    label.textColor=UIColorFromRGB(TextBlackColor);
    [self.view addSubview:label];
    
    
    shareBackView=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame)+10, SCREEN_WIDTH, 50)];
    shareBackView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview: shareBackView];
    
    CGFloat spacing=(SCREEN_WIDTH-3*44)/4;
    
    UIButton *QQBtn=[[UIButton alloc]initWithFrame:CGRectMake(spacing, 0, 44, 44)];
    [QQBtn setImage:[UIImage imageNamed:@"share_QQ_nor"] forState:UIControlStateNormal];
    [QQBtn setImage:[UIImage imageNamed:@"share_QQ"] forState:UIControlStateSelected];

//    [QQBtn setImage:[UIImage imageNamed:@"share_QQ_nor"] forState:UIControlStateHighlighted];
    [QQBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [QQBtn setImageEdgeInsets:UIEdgeInsetsMake((44-24)/2, (44-24)/2, (44-24)/2, (44-24)/2)];
    QQBtn.tag=shareToQQTag;
    [shareBackView addSubview:QQBtn];
    
    UILabel *QQlabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 50, 30)];
    QQlabel.text=TTLocalString(@"TT_QQ_zone");
    QQlabel.tag=QQBtn.tag+200;
    QQlabel.font=[UIFont systemFontOfSize:10];
    [QQlabel sizeToFit];
    QQlabel.textColor=UIColorFromRGB(shareTextClolor);
    QQlabel.center=CGPointMake(QQBtn.center.x, CGRectGetMaxY(QQBtn.frame)+CGRectGetHeight(QQlabel.frame)/2);
    [shareBackView addSubview:QQlabel];
    
    CGRect temp=shareBackView.frame;
    temp.size.height=CGRectGetHeight(QQBtn.frame)+CGRectGetHeight(QQlabel.frame)+10;
    shareBackView.frame=temp;
    
    UIButton *friendBtn=[[UIButton alloc]initWithFrame:CGRectMake(spacing+CGRectGetMaxX(QQBtn.frame), 0, 44, 44)];
    [friendBtn setImage:[UIImage imageNamed:@"share_friend_nor"] forState:UIControlStateNormal];
    [friendBtn setImage:[UIImage imageNamed:@"share_friend"] forState:UIControlStateSelected];

    [friendBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [friendBtn setImageEdgeInsets:UIEdgeInsetsMake((44-24)/2, (44-24)/2, (44-24)/2, (44-24)/2)];
    friendBtn.tag=shareToWeixinTag;
    [shareBackView addSubview:friendBtn];
    
    UILabel *friendLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    friendLabel.text=TTLocalString(@"TT_weixin_Moment");
    friendLabel.tag=friendBtn.tag+200;
    friendLabel.font=[UIFont systemFontOfSize:10];
    [friendLabel sizeToFit];
    friendLabel.textColor=UIColorFromRGB(shareTextClolor);
    friendLabel.center=CGPointMake(friendBtn.center.x, CGRectGetMaxY(QQBtn.frame)+CGRectGetHeight(QQlabel.frame)/2);
    [shareBackView addSubview:friendLabel];
    
    UIButton *weiboBtn=[[UIButton alloc]initWithFrame:CGRectMake(spacing+CGRectGetMaxX(friendBtn.frame), 0, 44, 44)];
    [weiboBtn setImage:[UIImage imageNamed:@"share_weibo_nor"] forState:UIControlStateNormal];
    [weiboBtn setImage:[UIImage imageNamed:@"share_weibo"] forState:UIControlStateSelected];

    //    [QQBtn setImage:[UIImage imageNamed:@"share_QQ_nor"] forState:UIControlStateHighlighted];
    [weiboBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [weiboBtn setImageEdgeInsets:UIEdgeInsetsMake((44-20)/2, (44-24)/2, (44-20)/2, (44-24)/2)];
    weiboBtn.tag=shareToWeiboTag;
    [shareBackView addSubview:weiboBtn];
    
    UILabel *weiboLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 50, 30)];
    weiboLabel.text=TTLocalString(@"TT_sina_weibo");
    weiboLabel.tag=weiboBtn.tag+200;
    weiboLabel.font=[UIFont systemFontOfSize:10];
    [weiboLabel sizeToFit];
    weiboLabel.textColor=UIColorFromRGB(shareTextClolor);
    weiboLabel.center=CGPointMake(weiboBtn.center.x, CGRectGetMaxY(QQBtn.frame)+CGRectGetHeight(QQlabel.frame)/2);
    [shareBackView addSubview:weiboLabel];
    
    
    footerView=[[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-45, SCREEN_WIDTH, 45)];
    //    [footerView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:footerView];
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,1)];
    lineView.backgroundColor=UIColorFromRGB(SystemGrayColor);
    [footerView addSubview:lineView];
    
    //@用户按钮
    UIButton *userBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 45)];
    userBtn.tag=userTag;
    [userBtn setImage:[UIImage imageNamed:@"user_get_nor"] forState:UIControlStateNormal];
    [userBtn setImage:[UIImage imageNamed:@"user_get"] forState:UIControlStateHighlighted];
    
    [userBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [userBtn setImageEdgeInsets:UIEdgeInsetsMake((45-17)/2, (45-17)/2, (45-17)/2, (45-17)/2)];
    [footerView addSubview:userBtn];

    
    //#话题按钮
    UIButton *topicBtn=[[UIButton alloc]initWithFrame:CGRectMake(45,0, 45, 45)];
    topicBtn.tag=topicTag;
    [topicBtn setImage:[UIImage imageNamed:@"topic_nor"] forState:UIControlStateNormal];
    [topicBtn setImage:[UIImage imageNamed:@"topic"] forState:UIControlStateHighlighted];
    [topicBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [topicBtn setImageEdgeInsets:UIEdgeInsetsMake((45-17)/2, (45-17)/2, (45-17)/2, (45-17)/2)];
    [footerView addSubview:topicBtn];
    

}

-(void)showImage:(UIImageView *)avatarImageView andPageType:(passPageType )pageType{
    [releaseTextView resignFirstResponder];
    UIImage *image=avatarImageView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldFrame=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;

    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldFrame];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    imageView.image=image;
    CALayer *layer=[imageView layer];
    layer.cornerRadius=0;
    [layer setMasksToBounds:YES];
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,(SCREEN_HEIGHT-SCREEN_WIDTH)/2, SCREEN_WIDTH, SCREEN_WIDTH);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
        if (pageType==videoType) {
            UIView *playView=[[UIView alloc] initWithFrame:imageView.frame];
            [playView setBackgroundColor:[UIColor clearColor]];
            [backgroundView addSubview:playView];
            
           TTplayView * ttMediaView=[[TTplayView alloc]init];
            [ttMediaView playVedio:self.videoPath];
         
            [playView addSubview:ttMediaView];


            ttMediaView.tag=2;
            [ttMediaView setContentMode:UIViewContentModeScaleAspectFill];
            CALayer *layer=[ttMediaView layer];
            layer.cornerRadius=0;
            [layer setMasksToBounds:YES];
            [playView addSubview:ttMediaView];
        }
    }];
}
-(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    TTplayView *temp=(TTplayView *)[tap.view viewWithTag:2];
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldFrame;
        backgroundView.alpha=0;
        temp.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}



-(void)buttonClick:(UIButton *)sender
{

    UILabel *tempLabel=(UILabel *)[self.view viewWithTag:sender.tag+200];
    for (UIView *view in shareBackView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *b=(UIButton *)view;
            if (b.tag!=sender.tag) {
                b.selected=NO;
            }
        }
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *l=(UILabel *)view;
            l.textColor=UIColorFromRGB(shareTextClolor);
        }
    }
    
    switch (sender.tag) {
        case BACK_BUTTON:  //回到上级界面
        {
            [self goBack:sender];
        }
            break;
            
        case RIGHT_BUTTON:  //发布
        {
            //主题发布
            [self playerSoundWith:@"send"];
            
            
            [self postTopic];
        }
            break;
        case imageBtnTag:  //视频播放
        {
            [self showImage:userImage andPageType:videoType];
        }
            break;

        case anonymousBtnTag:
        {
            if (sender.selected) {
                //不匿名
                [sender setImage:[UIImage imageNamed:@"no_anonymous"] forState:UIControlStateNormal];
                isKana=NO;
            }else
            {
                [sender setImage:[UIImage imageNamed:@"anonymous"] forState:UIControlStateNormal];
                isKana=YES;
            }
            sender.selected=!sender.selected;
            
        }
            break;
            
        case locationBtnTag:  //添加位置
        {
            locationSearchViewController *lv=[[locationSearchViewController alloc]init];
            lv.delegate=self;
            if(poiInfo!=nil){
                lv.poiInfo=poiInfo;
            }
            [self.navigationController pushViewController:lv animated:YES];
            
        }
            break;
        case closeBtnTag:  //删除位置
        {
            self.poitext=@"";
            self.poiid=@"";
            poiInfo=nil;
            
            [rightView setHidden:NO];
            [addLocationBtn setImage:[UIImage imageNamed:@"addLocaltion_nor"] forState:UIControlStateNormal];
            [addLocationBtn setTitle:TTLocalString(@"TT_my_location") forState:UIControlStateNormal];
            [addLocationBtn setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
            [closeBtn setHidden:YES];
        }
            break;
        case shareToQQTag:  //分享到QQ
        {
            sender.selected=!sender.selected;
            if (sender.selected) {
                //分享
                tempLabel.textColor=UIColorFromRGB(TextBlackColor);
                shareType=1;
            }
            else
            {
                //取消分享
                tempLabel.textColor=UIColorFromRGB(shareTextClolor);
                shareType=0;
            }
        }
            break;
        case shareToWeiboTag:  //分享到微博
        {
            sender.selected=!sender.selected;

            if (sender.selected) {
                //分享
                tempLabel.textColor=UIColorFromRGB(TextBlackColor);
                shareType=3;
            }
            else
            {
                //取消分享
                tempLabel.textColor=UIColorFromRGB(shareTextClolor);
                shareType=0;
            }
        }
            break;
        case shareToWeixinTag:  //分享到微信
        {

            sender.selected=!sender.selected;
            if (sender.selected) {
                //分享
                tempLabel.textColor=UIColorFromRGB(TextBlackColor);
                shareType=2;
            }
            else
            {
                //取消分享
                tempLabel.textColor=UIColorFromRGB(shareTextClolor);
                shareType=0;
            }
        }
            break;
        case topicTag:
        {
            //#按钮
            topicSelectedViewController *topic=[[topicSelectedViewController alloc]init];
            topic.delegate=self;
            [self.navigationController pushViewController:topic animated:YES];

        }
            break;
        case userTag:
        {
            //@按钮
            UserSearchController *searchUser=[[UserSearchController alloc] init];
            searchUser.delegate=self;
            [self.navigationController pushViewController:searchUser animated:YES];
        }
            break;
        default:
            break;
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];

}
-(void)dealloc{
//        [releaseTextView removeObserver:self forKeyPath:@"text"];

}
-(void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: UIKeyboardDidShowNotification object:nil];
    //解除键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: UIKeyboardDidHideNotification object:nil];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];

}
#pragma mark keyboard notification
- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    [self.view addGestureRecognizer:tapRecognizer];
    self.view.userInteractionEnabled=YES;
}

//键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    WSLog(@"keyboard=%f",keyboardHeight);
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect toolbarFrame = footerView.frame;
                         toolbarFrame.origin.y = self.view.bounds.size.height
                         - keyboardHeight - toolbarFrame.size.height;
                         footerView.frame = toolbarFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         //让dataScrollView滚动到底部
                     }
     ];
    
    [self.view addGestureRecognizer:tapRecognizer];
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect toolbarFrame = footerView.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height-CGRectGetHeight(footerView.frame);
    footerView.frame = toolbarFrame;
    
    [UIView commitAnimations];
    
    [self.view removeGestureRecognizer:tapRecognizer];
}

//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [releaseTextView resignFirstResponder];
}
-(void)tapClick:(UIGestureRecognizer *)tap
{
    [releaseTextView resignFirstResponder];
    [self showImage:userImage andPageType:PhotoType];
}


#pragma mark 搜索用户代理
-(void)tableItemClick:(UserInfo *)user{
    atuser=user;
    
    NSUInteger pointLocation=releaseTextView.selectedRange.location;
    
    NSMutableString *tempStr=[[NSMutableString alloc]initWithString:releaseTextView.text];
    

    NSString *string=[NSString stringWithFormat:@"<atuser>%@</atuser> ",user.realname];
    [tempStr insertString:string atIndex:pointLocation];
    
    [releaseTextView setText:tempStr];
    [releaseTextView setSelectedRange:NSMakeRange(pointLocation+string.length-16,0)];
    
    [releaseTextView setFont:TitleFont];
}

//话题回调
-(void)sendText:(topicHotModel *)hotModel
{
    htModel=hotModel;
    NSUInteger pointLocation=releaseTextView.selectedRange.location;
    NSMutableString *tempStr=[[NSMutableString alloc]initWithString:releaseTextView.text];
    [tempStr insertString:[NSString stringWithFormat:@"#%@ ",htModel.httext] atIndex:pointLocation];
    
    [releaseTextView setText:tempStr];
    [releaseTextView setSelectedRange:NSMakeRange(pointLocation+htModel.httext.length+2,0)];
    
    [releaseTextView setFont:TitleFont];
}


-(void)searchPoiItemClick:(BMKPoiInfo *)info{
    poiInfo=info;
    self.poitext=info.name;
    [rightView setHidden:YES];
    [closeBtn setHidden:NO];
    [addLocationBtn setImage:[UIImage imageNamed:@"addLocaltion"] forState:UIControlStateNormal];
    [addLocationBtn setTitle:self.poitext forState:UIControlStateNormal];
    [addLocationBtn setTitleColor:UIColorFromRGB(DrakGreenNickNameColor) forState:UIControlStateNormal];
}


-(void)postTopic{
    NSString *filename=[NSString stringWithFormat:@"%@.jpg",dateTransformStringAsYMDByFormate([NSDate new],@"yyyyMMddhhmmss")];
    //保存图片
    NSString *filePath=[SysTools writeImageToDocument:self.passUserImage fileName:filename];
    
    //保存图片到本地，并且添加水印
    UIImage *saveImage=[UIImage imageWithContentsOfFile:filePath];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library saveImage:[saveImage imageWithWaterMask:[UIImage imageNamed:@"watermark"] inRect:CGRectZero] toAlbum:@"Tutu" withCompletionBlock:^(NSError *error) {
        
    }];
    
    if (self.pageType==videoType) {
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:self.videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
            
        }];
    }
    
    TopicModel *tempModel=[TopicModel new];
    tempModel.topicid=@"";
    tempModel.localid=[NSString stringWithFormat:@"lt%d%@",(int)[[NSDate date] timeIntervalSince1970],[[LoginManager getInstance]getUid] ];
    tempModel.sourcepath=[NSString stringWithFormat:@"/images/%@",filename];
    tempModel.commentnum=@"0";
    tempModel.time=dateTransformString(@"yyyy-MM-dd hh:mm:ss",[NSDate date]);
    tempModel.zan=@"0";
    tempModel.uid=[[LoginManager getInstance]getUid];
    tempModel.width=w;
    tempModel.height=w;
    tempModel.isLike=NO;
    tempModel.nickname=[[LoginManager getInstance]getLoginInfo].nickname;
    tempModel.avatar=[[LoginManager getInstance]getLoginInfo].avatartime;
    tempModel.emptyCommentText=WebCopy_Post_Topic_Start;
    tempModel.topicDesc=[releaseTextView getUploadText];
    tempModel.formattime = @"刚刚";
    tempModel.shareType=shareType;
    UserInfo *info = [[UserInfo alloc]init];
    info.userhonorlevel = [[[LoginManager getInstance] getLoginInfo ] userhonorlevel];
    info.isauth = [LoginManager getInstance].getLoginInfo.isauth;
    info.relation = @"4";
    info.nickname = [LoginManager getInstance].getLoginInfo.nickname;
    info.remarkname = [LoginManager getInstance].getLoginInfo.remarkname;
    tempModel.userinfo = info;
    NSString *phoneName = [UserDefaults valueForKey:UserDefaults_PhoneName_Key];
    if (phoneName.length == 0) {
        phoneName = [[UIDevice currentDevice] modelName];
    }
    tempModel.client = phoneName;
    tempModel.topicStatus=@"3";
    
    if (isKana) {
        tempModel.iskana = 1;
        tempModel.nickname = TTLocalString(@"topic_anonymous");
    }else{
        tempModel.iskana = 0;
    }
    if (poiInfo) {
        tempModel.poiId = poiInfo.uid;
        tempModel.location = poiInfo.name;
    }
    
    // 必须设置为1，否则未发布成功个人页，不能查询到
    tempModel.topicType=@"1";
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    if(self.pageType==PhotoType){
        tempModel.type = 1;
        
        [params setValue:@"1" forKey:@"type"];
    }else{
        tempModel.type= 5;
        tempModel.times=[self.videoDurtion floatValue];
        tempModel.videourl=self.videoPath;
        
        // 上传视频
        [params setValue:self.videoPath forKey:@"contentFile"];
        [params setValue:self.videoDurtion forKey:@"videotimes"];
        [params setValue:@"5" forKey:@"type"];
        [params setValue:tempModel.localid forKey:@"localtopicid"];
    }
    [params setValue:tempModel.topicDesc forKey:@"topicdesc"];
    if(poiInfo!=nil){
        [params setValue:poiInfo.uid forKey:@"poiid"];
        [params setValue:poiInfo.name forKey:@"poitext"];
    }
    [params setValue:[NSString stringWithFormat:@"%d",isKana] forKey:@"iskana"];
    
    btn2.userInteractionEnabled=NO;
    [[RequestTools getInstance] post:API_ADD_TOPIC filePath:filePath fileKey:@"content" params:params completion:^(NSDictionary *dict) {
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            NSLog(@"%@",dict);
            //成功发送主题
            NSDictionary *data = dict[@"data"];
            TopicModel *model = [TopicModel initTopicModelWith:data];
            model.formattime = TTLocalString(@"TT_just");
            model.localid = tempModel.localid;
            model.nickname = tempModel.nickname;
            model.shareType=shareType;
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Success object:model];
        }
    } failure:^(ASIFormDataRequest *request, NSString *message) {
        tempModel.emptyCommentText=message;
        @try {
            TopicCacheDB *db=[[TopicCacheDB alloc] init];
            [db saveTopic:tempModel];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Send_Failed object:tempModel];
        }
    } finished:^(ASIFormDataRequest *request) {
        btn2.userInteractionEnabled=YES;
    }];
    btn2.userInteractionEnabled=NO;
    
    //开始发送主题
    [NOTIFICATION_CENTER postNotificationName:Notification_Topic_Send object:tempModel];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//判断删除键
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    //#按钮
    if([@"#" isEqual:text]){
        topicSelectedViewController *topic=[[topicSelectedViewController alloc]init];
        topic.delegate=self;
        [self.navigationController pushViewController:topic animated:YES];
    }

    if([@"@" isEqual:text]){
        //@按钮
        UserSearchController *searchUser=[[UserSearchController alloc] init];
        searchUser.delegate=self;
        [self.navigationController pushViewController:searchUser animated:YES];
    }
    
    if( [text length] == 0 ) {
        // 没有内容
        if (range.length < 1 ) {
            return YES;
        }
        else {
            return [releaseTextView doDelete];
        }
    }
    //点击了非删除键
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
