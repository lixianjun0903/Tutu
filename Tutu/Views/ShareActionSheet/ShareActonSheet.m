//
//  ShareActonSheet.m
//  Tutu
//
//  Created by gexing on 4/13/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "ShareActonSheet.h"
#import "UILabel+Additions.h"
#import "UIImage+ImageWithColor.h"

#import <TencentOpenAPI/TencentOAuth.h>

#define ShareActionSheetAnimationDuraion     0.2f
@interface  ShareActonSheet()
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *shareView;
@property(nonatomic,strong)UIView *tapView;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)TopicModel *model;
@property(nonatomic,strong)UIView *shareBgView;
@end
static ShareActonSheet *sheet;
@implementation ShareActonSheet
+ (ShareActonSheet *)instancedSheetWith:(TopicModel *)topicModel type:(ActionSheetButtonType)type{
    sheet = [[self alloc]init];
    sheet.model = topicModel;
    [sheet createSubviews:type];
    return sheet;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)createSubviews:(ActionSheetButtonType)type{
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _contentView.backgroundColor = [UIColor clearColor];
    _bgView = [[UIView alloc]initWithFrame:_contentView.frame];
    _bgView.backgroundColor = HEXCOLOR(0xB2B2B2);
    _bgView.alpha = 0.5;
    [_contentView addSubview:_bgView];
    
    _tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 280)];
    _tapView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_tapView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCancel:)];
    [_tapView addGestureRecognizer:tap];
    
    
    _shareBgView = [[UIView alloc]init];
    _shareBgView.frame = CGRectMake(0,ScreenHeight, ScreenWidth,0);
    _shareBgView.backgroundColor = HEXCOLOR(0xf8f8f8);
    _shareBgView.alpha = 0.9;
    [_contentView addSubview:_shareBgView];
    
    _shareView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight, ScreenWidth,0)];
    _shareView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_shareView];
    
    UILabel *titleLabel = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextBlackColor)];
    titleLabel.text = TTLocalString(@"TT_share_to");
    titleLabel.frame = CGRectMake(15, 15, 100, 12);
    [_shareView addSubview:titleLabel];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,titleLabel.mj_y, ScreenWidth, 108)];
    [_shareView addSubview:_scrollView];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    //创建分割线
    
    UIView *h_line = [[UIView alloc]initWithFrame:CGRectMake(0, _scrollView.max_y, ScreenWidth, 0.7)];
    h_line.backgroundColor = HEXCOLOR(0xdedede);
    [_shareView addSubview:h_line];
    
    CGFloat buttonWidth = 60;
    //水平间隔
    CGFloat buttonHGAP = ( ScreenWidth - buttonWidth * 4 ) / 5.F;
    
    [_scrollView setContentSize:CGSizeMake((buttonWidth + buttonHGAP) * 6 + buttonHGAP, _scrollView.mj_height)];
    
    //创建分享的按钮
    
    NSArray *imageNames = @[@"Icon-72@2x",@"sheet_qq",@"sheet_qzone",@"sheet_wechat_session",@"sheet_wechat_timeline",@"sheet_sina"];

    NSArray *titles = @[TTLocalString(@"TT_friend"),TTLocalString(@"TT_QQ_friend"),TTLocalString(@"TT_QQ_zone"),TTLocalString(@"TT_weixin_friend"),TTLocalString(@"TT_weixin_Moment"),TTLocalString(@"TT_sina_weibo")];
    
    for (int i = 0; i < 6; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.frame = CGRectMake(buttonHGAP + (buttonHGAP + buttonWidth) * i, 15, buttonWidth, buttonWidth);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 6.f;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        [_scrollView addSubview:btn];
        
        UILabel *label = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextBlackColor)];
        label.frame = CGRectMake(btn.mj_x, btn.max_y + 7, btn.mj_width, 12);
        label.text = titles[i];
        label.textAlignment = NSTextAlignmentCenter;
        [_scrollView addSubview:label];
        
    }
    
    NSString *collectionTitle = nil;
    if (sheet.model.favorite == YES) {
        collectionTitle = TTLocalString(@"TT_cancel_collectin");
    }else{
        collectionTitle = TTLocalString(@"TT_collection");
    }
    NSArray *images = @[@"home_topic_block",@"home_topic_report",@"home_topic_collect",@"home_topic_link"];
    NSArray *hl_images = @[@"home_topic_block_hl",@"home_topic_report_hl",@"home_topic_collect_hl",@"home_topic_link_hl"];
    NSArray *titles2 = @[TTLocalString(@"TT_block_ta"),TTLocalString(@"TT_bad_report"),collectionTitle,TTLocalString(@"TT_copy_link")];
    //创建其他功能按钮
    for (int i = 0; i < 4; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = imageNames.count + i;
        btn.frame = CGRectMake(buttonHGAP + (buttonHGAP + buttonWidth) * i, _scrollView.max_y + 17, buttonWidth, buttonWidth);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 6.f;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:hl_images[i]] forState:UIControlStateHighlighted];
        [_shareView addSubview:btn];
        
        UILabel *label = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextBlackColor)];
        label.frame = CGRectMake(btn.mj_x - 10, btn.max_y + 7, btn.mj_width + 20, 12);
        label.text = titles2[i];
        label.textAlignment = NSTextAlignmentCenter;
        [_shareView addSubview:label];
        
        if (i == 0) {
            _blockBtn = btn;
            _blockLabel = label;
        }else if (i == 1){
            _reportBtn = btn;
            _reportLabel = label;
        }else if (i == 2){
            _collectionBtn = btn;
            _collectionLabel = label;
        }else{
            _cpyBtn = btn;
            _cpyLabel = label;
        }

    }
    
    if (type == ActionSheetButtonTypeReportAndCopy) {
        [_blockBtn setHidden:YES];
        [_collectionBtn setHidden:YES];
        [_blockLabel setHidden:YES];
        [_collectionLabel setHidden:YES];
        _cpyBtn.frame = _reportBtn.frame;
        _reportBtn.frame = _blockBtn.frame;
        
       _cpyLabel.frame = _reportLabel.frame;
        _reportLabel.frame = _blockLabel.frame;
        
        
    }else if (type == ActionSheetButtonTypeCopy){
        
        [_blockBtn setHidden:YES];
        [_collectionBtn setHidden:YES];
        [_reportBtn setHidden:YES];
        [_blockLabel setHidden:YES];
        [_collectionLabel setHidden:YES];
        [_reportLabel setHidden:YES];
        
        _cpyBtn.frame = _blockBtn.frame;
        _cpyLabel.frame = _blockLabel.frame;
        
    }else{
    
    
    }
    
    //创建取消按钮
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0,280 - 40, ScreenWidth, 40);
    cancelBtn.tag = titles.count + titles2.count;
    [cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageWithColor:HEXCOLOR(0xf3f3f3)] forState:UIControlStateHighlighted];
    [cancelBtn setTitle:TTLocalString(@"TT_cancel") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    [_shareView addSubview:cancelBtn];
}
- (void)buttonClick:(UIButton *)sender{
    NSInteger tag = sender.tag;
    [self tapCancel:nil];
    if (tag == 10) {
        return;
    }else{
        //审核时判断，不能使用Web登录
//        if([SysTools getApp].checkUserAge){
            if( tag==ActionSheetTypeQQ || tag==ActionSheetTypeQQZone){
                if (![TencentOAuth iphoneQQInstalled] && ![TencentOAuth iphoneQQSupportSSOLogin]) {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No QQ" message:@"QQ haven't been install in your device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
            
            if(tag == ActionSheetTypeSina && ![SysTools APCheckIfAppInstalled2:@"sinaweibo://"]){
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Sina" message:@"Sina haven't been install in your device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
//        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(shareActionSheetButtonClick:)]) {
            [_delegate shareActionSheetButtonClick:tag];
        }
        if (tag == ActionSheetTypeCopyLink) {

        }
    }
}
- (void)tapCancel:(id)sender{
   [UIView animateWithDuration:ShareActionSheetAnimationDuraion animations:^{
       _shareView.frame = CGRectMake(0, ScreenHeight, _shareView.mj_width, 0);
       _shareBgView.frame = CGRectMake(0, ScreenHeight, _shareBgView.mj_width, 0);
   } completion:^(BOOL finished) {
       [_contentView removeFromSuperview];
       _contentView = nil;
   }];
}

- (void)showInWindow{
    UIWindow *window = ApplicationDelegate.window;
    [window addSubview:_contentView];
    [UIView animateWithDuration:ShareActionSheetAnimationDuraion animations:^{
        _shareView.frame = CGRectMake(0, ScreenHeight - 280, _shareView.mj_width, 280);
        _shareBgView.frame = CGRectMake(0, ScreenHeight - 280, _shareBgView.mj_width, 280);
    } completion:^(BOOL finished) {
    }];
}
@end
