//
//  TopicCell.m
//  Tutu
//
//  Created by gexing on 1/6/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//


#import "UILabel+Additions.h"
#import "M13ProgressViewRing.h"
#import "LoginViewController.h"
#import "TopicDetailController.h"
#import "UIImageView+WebCache.h"
#import "ShareTutuFriendsController.h"
#import "LineLayout.h"
#import "CommentCollectionCell.h"
#import "UserDetailController.h"
#import "SVWebViewController.h"
#import "HomeController.h"
#import "M13ProgressViewBar.h"
#import "DownLoadManager.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "UIImage+Category.h"
#import "UIButton+WebCache.h"
#import "SVProgressHUD.h"
#import "UserDetailController.h"
#import "TTExtendLabel.h"
#import "AWEasyVideoPlayer.h"


#define Horizontal_Space  53.2

#define HotFlagOriginX   (ScreenWidth / 2.0f - 80)
#define DESC_FONT             15   //描述的字体

#define LOCATION_TAG_HEIGHT       12   //位置图标的高

#define DETAIL_BTN_HEIGHT         16   //详情按钮的高


#define AVATAR_DESC_GAP           15   //头像到描述的间隔

#define DESC_TOP_GAP              (AVATAR_DESC_GAP * 2 + 40) //  描述到顶部的间隔

#define TOPIC_PIC_HEIGHT          ScreenWidth    //图片的高度

#define BUTTOM_GAP                (80 + 40)   //图片到底部的间隔

#define DESC_DETAIL_BTN_GAP       12   //描述到详情按钮的间隔
#define DETAIL_BTN_LOCATION_GAP   15   //详情按钮到location的间隔
#define DESC_PIC_GAP              15   //描述到图片的间隔

#define DESC_LOCATION_GAP         10   //描述到location的间隔


#define DETAIL_BTN_PIC_GAP        15  //详情按钮到图片的间隔
#define LOCATION_PIC_GAP          15  //location到图片的间隔

#define DESC_MAX_HEIGHT           145   //描述的最大高度

static NSString *commentCollectionCell = @"commentAvatar";
@implementation TopicCell

- (void)buttonClick:(UIButton *)sender{
    if (sender == _detailBtn) {
        if (!_isDetail) {
            if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicDetailClick:)]) {
                [_topicDelegate topicDetailClick:_topicModel];
            }
            if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicDetailClick:index:)]) {
                [_topicDelegate topicDetailClick:_topicModel index:_cellIndex];
            }
        }
    }else if (sender == _avatarBtn ){
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAvatarOrNicknameClick:)]) {
            [_topicDelegate topicAvatarOrNicknameClick:_topicModel];
        }
    }
}
//位置信息点击
- (void)locationClick:(id)sender{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicLoctionClick:topic:)]) {
        [_topicDelegate topicLoctionClick:_topicModel.location topic:_topicModel];
    }
}
- (void)awakeFromNib {
    self.contentView.backgroundColor = HEXCOLOR(SystemGrayColor);
    for (int i = 0; i < 3; i ++) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:view];
        if (i == 1) {
            _headerView = view;
            _headerView.frame = CGRectMake(0, 0, ScreenWidth, 220);
        }else if (i == 2){
            _middleView = view;
            _middleView.frame = CGRectMake(0, _headerView.max_y, ScreenWidth, ScreenWidth + 105);
            _middleView.backgroundColor = [UIColor whiteColor];
        }else{
            _topView = view;
            _topView.frame = CGRectMake(0, 0, ScreenWidth, 0);
        }
    }
    
    //创建转发消息显示
    
    UIImageView *reportImageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 11,12, 10)];
    [_topView addSubview:reportImageIcon];
    reportImageIcon.image = [UIImage imageNamed:@"topic_report_icon"];
    UIView*topline = [[UIView alloc]initWithFrame:CGRectMake(0,31, ScreenWidth, 0.7)];
    topline.backgroundColor = HEXCOLOR(ItemLineColor);
    [_topView addSubview:topline];
    
    
    //创建头像
    UIImageView *avatarBg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 40, 40)];
    avatarBg.image = [UIImage imageNamed:@"avatar_default"];
    [_headerView addSubview:avatarBg];
    
    _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _avatarBtn.frame = CGRectMake(10, 15, 40, 40);
    _avatarBtn.userInteractionEnabled = NO;
    _avatarBtn.layer.masksToBounds = YES;
    _avatarBtn.layer.cornerRadius = _avatarBtn.mj_width / 2.f;
    [_avatarBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_avatarBtn];
   //创建昵称
    
    
    _nameLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(DrakGreenNickNameColor)];
    [_headerView addSubview:_nameLabel];
    _nameLabel.userInteractionEnabled = YES;
    _nameLabel.frame = CGRectMake(_avatarBtn.max_x + 10, 15, 10, 21);
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nameTap:)];
    [_nameLabel addGestureRecognizer:nameTap];
   
    _vipImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.max_x,_nameLabel.mj_y , 16, 16)];
    [_headerView addSubview:_vipImageView];
    _vipImageView.image = [UIImage imageNamed:@"user_certification"];
    _vipImageView.hidden = YES;
    _levelImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.max_x + 10, 19 , 20, 13)];
    _levelImageView.image = [UIImage imageNamed:@"user_level1"];
    
    [_headerView addSubview:_levelImageView];
  
    _addFollowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addFollowBtn setImage:[UIImage imageNamed:@"topic_add_follow"] forState:UIControlStateNormal];
    [_headerView addSubview:_addFollowBtn];
    [_addFollowBtn addTarget:self action:@selector(addFollowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _addFollowBtn.frame = CGRectMake(33,0, 27, 30);
    _addFollowBtn.contentEdgeInsets = UIEdgeInsetsMake(12, 0, 2, 11);
    
    UILabel *watchLabel = [UILabel labelWithSystemFont:12 textColor:HEXCOLOR(TextGrayColor)];
    watchLabel.text = TTLocalString(@"topic_watch_count");
    watchLabel.textAlignment = NSTextAlignmentRight;
    watchLabel.frame = CGRectMake(ScreenWidth - 110, 40, 100, 13);
    [_headerView addSubview:watchLabel];
    
    _watchCount = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(TextBlackColor)];
    _watchCount.frame = CGRectMake(ScreenWidth / 2.0f,18,ScreenWidth / 2.0f - 10, 15);
    _watchCount.textAlignment = NSTextAlignmentRight;
    _watchCount.text = @"1000";
    [_headerView addSubview:_watchCount];
    
    UIImageView *timeFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_time_icon"]];
    timeFlag.frame = CGRectMake(_avatarBtn.max_x + 10, _nameLabel.max_y + 8, 10, 10);
    [_headerView addSubview:timeFlag];
   
    //时间戳
    _stampLabel = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextGrayColor)];
    _stampLabel.numberOfLines = 1;
    _stampLabel.frame = CGRectMake(timeFlag.max_x + 2, timeFlag.mj_y -1,30, 12);
    [_headerView addSubview:_stampLabel];
    
    //手机型号
    
    _phoneFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phone_icon"]];
    _phoneFlag.frame = CGRectMake(_stampLabel.max_x + 12,timeFlag.mj_y, 7, 10);
    [_headerView addSubview:_phoneFlag];
    
    _phoneName = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextGrayColor)];
    _phoneName.numberOfLines = 1;
    _phoneName.userInteractionEnabled = YES;
    _phoneName.frame = CGRectMake(_phoneFlag.max_x + 3, _stampLabel.mj_y, 100, 12);
    [_headerView addSubview:_phoneName];
    
    UITapGestureRecognizer *phoneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(phoneNameClick:)];
    [_phoneName addGestureRecognizer:phoneTap];
    
    //主题描述
//    _titleLabel = [TTExtendLabel labelWithSystemFont:DESC_FONT textColor:HEXCOLOR(0x333333)];
    _titleLabel = [[TTExtendLabel alloc]init];
    _titleLabel.frame = CGRectMake(10, _avatarBtn.max_y + AVATAR_DESC_GAP, ScreenWidth - 20, 100);
    _titleLabel.font = [UIFont systemFontOfSize:DESC_FONT];
    [_headerView addSubview:_titleLabel];
   
    _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _detailBtn.frame = CGRectMake(12, _titleLabel.max_y + 12, 65,DETAIL_BTN_HEIGHT);
    [_detailBtn setTitleColor:HEXCOLOR(0x279E7E) forState:UIControlStateNormal];
    _detailBtn.titleLabel.font = [UIFont systemFontOfSize:DESC_FONT];
    _detailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_detailBtn setTitle:TTLocalString(@"topic_look_all") forState:UIControlStateNormal];
    [_detailBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_detailBtn];
    
    _locationFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_location_icon"]];
    _locationFlag.frame = CGRectMake(10,_detailBtn.max_y + 15, 9,LOCATION_TAG_HEIGHT);
    [_headerView addSubview:_locationFlag];
    
    _addressLabel = [UILabel labelWithSystemFont:13 textColor:HEXCOLOR(DrakGreenNickNameColor)];
    _addressLabel.numberOfLines = 1;
    _addressLabel.userInteractionEnabled = YES;
    _addressLabel.frame = CGRectMake(_locationFlag.max_x + 4, _locationFlag.mj_y - 5, ScreenWidth - 30, 14);
    [_headerView addSubview:_addressLabel];
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locationClick:)];
    [_addressLabel addGestureRecognizer:locationTap];
    
    //创建middleView上面的视图
    
    _topicPicView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_default"]];
    _topicPicView.userInteractionEnabled = YES;
    _topicPicView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
    _topicPicView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired  = 1;
    [_topicPicView addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
     [_topicPicView addGestureRecognizer:doubleTapGesture];
    
     [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [_middleView addSubview:_topicPicView];
    
    _picProgress = [[M13ProgressViewRing alloc]initWithFrame:CGRectMake(0, 0, 76 * (ScreenWidth / 320.0f), 76 * (ScreenWidth / 320.0f))];
    _picProgress.backgroundRingWidth = 8;
    _picProgress.progressRingWidth = 8;
    _picProgress.showPercentage = NO;
    _picProgress.center = _topicPicView.center;
    [_topicPicView addSubview:_picProgress];
    
    //重新加载的按钮
    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadButton addTarget:self action:@selector(reloadImage:) forControlEvents:UIControlEventTouchUpInside];
    _reloadButton.bounds = CGRectMake(0, 0, 74 * (ScreenWidth / 320.0f), 80 * (ScreenWidth / 320.0f));
    _reloadButton.center = _picProgress.center;
    [_reloadButton setBackgroundImage:[UIImage imageNamed:@"pic_reload"] forState:UIControlStateNormal];
    [_reloadButton setHidden:YES];
    [_topicPicView addSubview:_reloadButton];
    
    if (iOS7) {
        _videoProgress=[[M13ProgressViewBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,5)];
        [_videoProgress setShowPercentage:NO];
        [_videoProgress setShowCornerRadius:NO];
        [_videoProgress setProgressBarThickness:5];
        [_videoProgress setSecondaryColor:UIColorFromRGB(SystemGrayColor)];
        [_videoProgress setPrimaryColor:UIColorFromRGB(SystemColor)];
        [_videoProgress setProgress:0.005 animated:NO];
        [_middleView  addSubview:_videoProgress];
        [_videoProgress setHidden:YES];
    }
    
    [self createFootView];
    

    
    _videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_video_icon"]];
    _videoIcon.frame = CGRectMake(ScreenWidth - 38, 10, 28, 18);
    [_middleView addSubview:_videoIcon];
    
    
    _commentDefaultView = [[UIView alloc]initWithFrame:CGRectMake(0, _topicPicView.max_y, ScreenWidth, 65)];
    [_middleView addSubview:_commentDefaultView];
    
    //创建再次上传的按钮，当上传失败后，点击再次上传。
   
    _reUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _reUploadBtn.frame = CGRectMake(0, 0, _commentDefaultView.mj_width, _commentDefaultView.mj_height);
    _reUploadBtn.backgroundColor = [UIColor whiteColor];
    [_commentDefaultView addSubview:_reUploadBtn];
    [_reUploadBtn addTarget:self action:@selector(reUploadTopic:) forControlEvents:UIControlEventTouchUpInside];
    
   
    _reUploadLabel = [UILabel labelWithSystemFont:15 textColor:[UIColor clearColor]];
    _reUploadLabel.frame = CGRectMake(0, 25, ScreenWidth, 16);
    _reUploadLabel.textAlignment = NSTextAlignmentCenter;
    

    NSString *string0 = TTLocalString(@"TT_network_not_ok");
    NSString *string1 = TTLocalString(@"TT_click_retry");
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:FormatString(@"%@%@", string0,string1)];

    [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, string0.length)];
    [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x9B9A9B) range:NSMakeRange(0, string0.length )];
    [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(string0.length,string1.length)];
    [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x719FEB) range:NSMakeRange(string0.length,string1.length)];
    _reUploadLabel.attributedText = mStr;
    
    
    _commentDefaultIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"comment_label_default"]];
    _commentDefaultIcon.frame = CGRectMake(0, 19, 58, 26);
    [_commentDefaultView addSubview:_commentDefaultIcon];
    
    _commentDefaultLabel = [UILabel labelWithSystemFont:15 textColor:HEXCOLOR(0x999999)];
    _commentDefaultLabel.frame = CGRectMake(0, 25, 100, 16);
    [_commentDefaultView addSubview:_commentDefaultLabel];
    
    _collectionViewbg = [[UIView alloc]initWithFrame:CGRectMake(0, _topicPicView.max_y - 4, ScreenWidth, 67)];
    _collectionViewbg.backgroundColor = [UIColor clearColor];
    [_middleView addSubview:_collectionViewbg];
    
    [_commentDefaultView addSubview:_reUploadLabel];
   
    LineLayout* lineLayout = [[LineLayout alloc] init];
    _commentCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 67) collectionViewLayout:lineLayout];
    [_commentCollectionView registerClass:[CommentCollectionCell class] forCellWithReuseIdentifier:commentCollectionCell];
    _commentCollectionView.decelerationRate = 0.0f;
    _commentCollectionView.delegate = self;
    _commentCollectionView.scrollsToTop = NO;
    _commentCollectionView.dataSource = self;
    _commentCollectionView.showsHorizontalScrollIndicator = NO;
    _commentCollectionView.showsVerticalScrollIndicator = NO;
    _commentCollectionView.backgroundColor = [UIColor clearColor];
    _commentCollectionView.scrollsToTop = NO;
    [_collectionViewbg addSubview:_commentCollectionView];
    
    _hotFlag = [[UIView alloc]initWithFrame:CGRectMake(HotFlagOriginX, 18, 45, 42)];
    _hotFlag.backgroundColor = [UIColor clearColor];
    UIImageView *flag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_hot_comment_flag"]];
    flag.frame = CGRectMake(15, 0, 15, 25);
    [_hotFlag addSubview:flag];
    [_collectionViewbg addSubview:_hotFlag];
    
    UILabel *hotLabel = [UILabel labelWithSystemFont:10 textColor:HEXCOLOR(TextGrayColor)];
    hotLabel.frame = CGRectMake(0, flag.max_y + 5, _hotFlag.mj_width, 12);
    hotLabel.textAlignment = NSTextAlignmentCenter;
    hotLabel.text = TTLocalString(@"topic_wonderful_comment");
    [_hotFlag addSubview:hotLabel];
    
    
   //添加赞和取消赞的视图
    _addZanView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_zan_add"]];
    _addZanView.bounds = CGRectMake(0, 0, 100, 100);
    _addZanView.center = CGPointMake(ScreenWidth / 2.0f, ScreenWidth / 2.0f);
    _addZanView.tag = 100;
    [_middleView addSubview:_addZanView];
    UIImage *zanCancelImage = [UIImage imageNamed:@"topic_zan_cancel"];
    CGFloat scale = 3.0f;
    _cancelZanView = [[UIImageView alloc]initWithImage:zanCancelImage];
    _cancelZanView.bounds = CGRectMake(0, 0, zanCancelImage.size.width / scale, zanCancelImage.size.height / scale);
    _cancelZanView.tag = 101;
    _cancelZanView.center = _addZanView.center;
    [_middleView addSubview:_cancelZanView];
    _addZanView.hidden = YES;
    _cancelZanView.hidden = YES;
    
    _commentControl = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentControl.frame = CGRectMake(ScreenWidth - 95, _topicPicView.mj_height - 36, 85,25);
    // _commentControl.contentEdgeInsets = UIEdgeInsetsMake(9, 14, 9, 14);
    [_middleView addSubview:_commentControl];
    [_commentControl addTarget:self action:@selector(controlComment:) forControlEvents:UIControlEventTouchUpInside];
   
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"topic_paly_btn"] forState:UIControlStateNormal];
    CGFloat playBtnWidth = 75 * ScreenWidth / 320.0f;
    _playButton.bounds = CGRectMake(0, 0, playBtnWidth, playBtnWidth);
    [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.center = CGPointMake(ScreenWidth / 2.0f, ScreenWidth / 2.0f);
    [_playButton setHidden:YES];
    [_middleView addSubview:_playButton];
    

    
}
- (void)nameTap:(UITapGestureRecognizer *)tap{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAvatarOrNicknameClick:)]) {
        [_topicDelegate topicAvatarOrNicknameClick:_topicModel];
    }
}
//添加关注按钮点击

#pragma mark  关注按钮点击

- (void)addFollowBtnClick:(id)sender{
    
    if ([[LoginManager getInstance]isLogin]) {
        
        if ([_topicModel.userinfo.relation intValue] == 3) {
 
        }else if ([_topicModel.userinfo.relation intValue] == 0 || [_topicModel.userinfo.relation intValue] == 1){
            [[RequestTools getInstance]get:API_ADD_Follow_User(_topicModel.uid) isCache:NO completion:^(NSDictionary *dict) {
                if ([_topicModel.userinfo.relation intValue] == 0) {
                    [_addFollowBtn setImage:[UIImage imageNamed:@"topic_followed"] forState:UIControlStateNormal];
                    _topicModel.userinfo.relation = @"2";
                }else{
                    [_addFollowBtn setImage:[UIImage imageNamed:@"topic_each other_follow"] forState:UIControlStateNormal];
                    _topicModel.userinfo.relation = @"3";
                }
                if (_isDetail) {
                   [[NoticeTools getInstance]postAddFocus:_topicModel.userinfo];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
            
        }else if ([_topicModel.userinfo.relation intValue] == 2 || [_topicModel.userinfo.relation intValue] == 3){
            [[RequestTools getInstance]get:API_DEL_Follow_User(_topicModel.uid) isCache:NO completion:^(NSDictionary *dict) {
                
               [_addFollowBtn setImage:[UIImage imageNamed:@"topic_add_follow"] forState:UIControlStateNormal];
                if ([_topicModel.userinfo.relation intValue] == 2) {
                    _topicModel.userinfo.relation = @"0";
                }else{
                    _topicModel.userinfo.relation = @"1";
                }
                if (_isDetail) {
                    [[NoticeTools getInstance]postAddFocus:_topicModel.userinfo];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
        }
 
    }else{
        [[LoginManager getInstance] showLoginView:nil];
    }

}

#pragma mark - 手机名称点击

- (void)phoneNameClick:(id)sender{
    if ([[LoginManager getInstance]isLogin]) {
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPhoneNameClick:)]) {
            [_topicDelegate topicPhoneNameClick:nil];
        }
    }else{
        [[LoginManager getInstance]showLoginView:nil];
    }

}

#pragma mark- 网络切换到3g环境，弹出的播放按钮点击

- (void)playButtonClick:(id)sender{
    if (ApplicationDelegate.isReachableWiFi) {
        _isAutoPlay = YES;
        [self playVideo];
        [_playButton setHidden:YES];
    }else{
        _isVedioSuccess = [AWEasyVideoPlayer isDownloadFinish:_topicModel.videourl];
        if (!_isVedioSuccess) {
            LXActionSheet *sheet = [[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_can_not_wifi_message") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
            sheet.tag = 7777;
            [sheet showInView:nil];
        }else{
            _isAutoPlay = YES;
            [self playVideo];
            [_playButton setHidden:YES];
        }
    }

}
//控制评论显示或者隐藏

#pragma mark- 控制评论的显示隐藏

- (void)controlComment:(id)sender{
    _isShowComment = !_isShowComment;
    _commentBgView.hidden = !_isShowComment;
    if (_isShowComment) {
        [_commentControl setImage:[UIImage imageNamed:@"topic_comment_start"] forState:UIControlStateNormal];
    }else{
        [_commentControl setImage:[UIImage imageNamed:@"topic_comment_stop"] forState:UIControlStateNormal];
    }
}
- (void)createFootView{
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0,_topicPicView.mj_height + 65, ScreenWidth, 40)];
    [_middleView addSubview:_footerView];
    
    NSArray *hl_imageNames = @[@"topic_comment_icon_hl",@"topic_zan_hl",@"topic_zhuanfa",@"topic_more_icon_hl",];
    NSArray *imageNames = @[@"topic_comment_icon",@"topic_zan",@"topic_zhuanfa_hl",@"topic_more_icon",];
    CGFloat width = ScreenWidth / 4.f;
    for (int i = 0; i < 4; i ++) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(width * i, 0,width, _footerView.mj_height)];
        [_footerView addSubview:bgView];
        
        //创建分割线
        if (i > 0) {
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,(_footerView.mj_height - 15) / 2.f, 1, 15)];
            lineView.backgroundColor = HEXCOLOR(0xdedede);
            [bgView addSubview:lineView];
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(bgView.mj_width / 2.0 - 38 - 3,(_footerView.mj_height - 36) / 2.f,78,36);
        [btn setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 40)];
      //  [btn setBackgroundColor:[UIColor redColor]];
        [btn setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:hl_imageNames[i]] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn addTarget:self action:@selector(footerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [bgView addSubview:btn];
        
        UILabel *label = [UILabel labelWithSystemFont:13 textColor:HEXCOLOR(0x333333)];
        label.frame = CGRectMake(bgView.mj_width / 2.0f + 3, (_footerView.mj_height - 14) / 2.f, 45, 14);
        [bgView addSubview:label];
        
        switch (i) {
            case 0:
                _commentCountLabel = label;
                break;
            case 1:
                _likeCountBtn = btn;
                _likeCountLabel = label;
                break;
            case 2:
                _reportBtn = btn;
                _reportLabel = label;
                break;
            case 3:
                label.text = TTLocalString(@"topic_more");
                break;
                
            default:
                break;
        }

    }
}

#pragma mark - 分享页面上的按钮点击
/**
 *  更多按钮点击
 *
 *  @param index 当tag 0 - 5，为分享按钮， 6 - 9 为其他功能
 */
- (void)shareActionSheetButtonClick:(NSInteger)index{
    if (index <= 5) {
        if (index == ActionSheetTypeTutu) {
            if (self.currentUserInfo.uid.length > 0) {
                if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicShareButtonClick:type:index:)]) {
                    [_topicDelegate topicShareButtonClick:_topicModel type:ActionSheetTypeTutu index:_cellIndex];
                }
            }else{
                [self showLoginView];
            }
        }else{
            NSString *shareText=@"95后、00后都在玩Tutu，快来围观吐槽吧！";
            NSString *shareURL=[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@",SHARE_TOPIC_HOST],_topicModel.topicid];
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
            [UMSocialData defaultData].extConfig.qqData.url = shareURL;
            [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
            [UMSocialData defaultData].extConfig.sinaData.urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:shareURL];
            BOOL hasDesc=![@"" isEqual:_topicModel.topicDesc];
            
            NSArray *types=@[UMShareToWechatSession];
            switch (index) {
                case ActionSheetTypeWXFriend:
                    shareText = hasDesc?_topicModel.topicDesc : [NSString stringWithFormat:@"%@的主题",_topicModel.nickname];
                    [UMSocialData defaultData].extConfig.title = WebCopy_ShareTitle(_topicModel.nickname);
                    types=@[UMShareToWechatSession];
                    break;
                    
                case ActionSheetTypeWXSection:
                    types=@[UMShareToWechatTimeline];
                    [UMSocialData defaultData].extConfig.title = WebCopy_ShareTitle(_topicModel.nickname);
                    shareText = hasDesc?_topicModel.topicDesc :WebCopy_ShareWeixinTimelineDesc;
                    break;
                case ActionSheetTypeQQ:
                    [UMSocialData defaultData].extConfig.title = WebCopy_ShareTitle(_topicModel.nickname);
                    shareText = hasDesc?_topicModel.topicDesc :WebCopy_ShareQQDesc;
                    types=@[UMShareToQQ];
                    break;
                case ActionSheetTypeQQZone:
                    types=@[UMShareToQzone];
                    [UMSocialData defaultData].extConfig.title = WebCopy_ShareTitle(_topicModel.nickname);
                    shareText = hasDesc?_topicModel.topicDesc :WebCopy_ShareZoneDesc;
                    break;
                case ActionSheetTypeSina:
                    types=@[UMShareToSina];
                    //添加视频地址
                    if(_topicModel!=nil && _topicModel.type==5){
                        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:_topicModel.videourl];
                    }else{
                        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:_topicModel.sourcepath];
                    }
                    [UMSocialData defaultData].extConfig.title = WebCopy_ShareTitle(_topicModel.nickname);
                    shareText = hasDesc?_topicModel.topicDesc :[NSString stringWithFormat:@"%@ %@",WebCopy_ShareSinaDesc,shareURL];
                    break;
                    
                default:
                    break;
            }
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            
            [manager downloadImageWithURL:[NSURL URLWithString:_topicModel.sourcepath] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                UMSocialUrlResource *resourece = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:_topicModel.sourcepath];
                image = [image imageWithWaterMask:[UIImage imageNamed:@"watermark"] inRect:CGRectZero];
                
               UIViewController *controller = ApplicationDelegate.window.rootViewController;
                
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:types content:shareText image:image location:nil urlResource:resourece presentedController:controller completion:^(UMSocialResponseEntity *response){
                    //            WSLog(@"分享状态：%@，返回数据：%@",response.message,response.data);
                    if (response.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"分享成功！");
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_success") duration:2];
                    }else{
                        // Todo
                        [SVProgressHUD showSuccessWithStatus:@"TT_share_faild" duration:2];
                    }
                    
                }];
                
            }];
            
        }
 
    }else if (index == 6){//屏蔽他的内容
        //屏蔽莫人的主题，只在登录后才有权限
        if (self.currentUserInfo.uid.length > 0) {
            [[RequestTools getInstance]get:API_BLOCK_USER_FEED(_topicModel.uid) isCache:NO completion:^(NSDictionary *dict) {
                UserInfo *userinfo = [[UserInfo alloc]init];
                userinfo.uid = _topicModel.uid;
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_TOPIC object:userinfo];
            } failure:^(ASIHTTPRequest *request, NSString *message) {
            } finished:^(ASIHTTPRequest *request) {
            }];
        }else{
            [self showLoginView];
        }
    }else if (index == 7){//不良内容举报
        [[RequestTools getInstance] get:API_REPORTTOPIC(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
             [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_report_success") duration:1.0f];
        } failure:^(ASIHTTPRequest *request, NSString *message) {
           
        } finished:^(ASIHTTPRequest *request) {
            
        }];

    }else if (index == 8){//收藏
        //收藏主题，只在登录后才有权限
        if (self.currentUserInfo.uid.length > 0) {
            //当已经收藏，需要取消收藏
            if (_topicModel.favorite == YES) {
                [[RequestTools getInstance]get:API_TOPIC_FAVORITE_DELETE(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                    if ([dict[@"code"]intValue] == 10000) {
                        _topicModel.favorite = NO;
                        if (_isDetail) {
                            [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                        }
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_cancel_collection_success") duration:1.f];
                    }
                } failure:^(ASIHTTPRequest *request, NSString *message) {
                    
                } finished:^(ASIHTTPRequest *request) {
                    
                }];
            }else{
                [[RequestTools getInstance]get:API_TOPIC_FAVORITE_ADD(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                    if ([dict[@"code"]intValue] == 10000) {
                        _topicModel.favorite = YES;
                        if (_isDetail) {
                            [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                        }
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_collection_success") duration:1.0];
                    }
                } failure:^(ASIHTTPRequest *request, NSString *message) {
                    
                } finished:^(ASIHTTPRequest *request) {
                    
                }];
            }
        }else{
            [self showLoginView];
        }
    }else{//复制链接
        
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicShareButtonClick:type:index:)]) {
            [_topicDelegate topicShareButtonClick:_topicModel type:ActionSheetTypeCopyLink index:_cellIndex];
        }
    }
}

#pragma mark - 图片加载失败后，点击再次加载图片

- (void)reloadImage:(id)sender{
    [_reloadButton setHidden:YES];
    [_picProgress setHidden:NO];
    _picProgressValue = 0.f;
    [_topicPicView sd_setImageWithURL:StrToUrl(_topicModel.sourcepath) placeholderImage:[UIImage imageNamed:@"topic_default"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = receivedSize / [@(expectedSize) doubleValue];
        if (progress - _picProgressValue > 0.05) {
            _picProgressValue = progress;
            [_picProgress setProgress:_picProgressValue animated:YES];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [_picProgress setHidden:YES];
        if (error) {
            [_reloadButton setHidden:NO];
            _isPicSuccess = NO;
        }else{
            _isPicSuccess = YES;
        }
    }];
}

#pragma mark - 计算cell的高度

+ (CGFloat)getCellHeight:(TopicModel *)model isDetail:(BOOL)isDetail{
    
    TTExtendLabel *label = [[TTExtendLabel alloc]init];
    label.frame = CGRectMake(10, 0, ScreenWidth - 20, 100);
    label.font = [UIFont systemFontOfSize:DESC_FONT];
    [label setExtendText:model.topicDesc];
    CGFloat titleLabelHeight = label.contentHeight;
    if (model.topicDesc.length == 0) {
        titleLabelHeight = 0;
    }
    if (isDetail) {
        if (model.location.length == 0) {
            return  DESC_TOP_GAP + titleLabelHeight + DESC_PIC_GAP + TOPIC_PIC_HEIGHT + BUTTOM_GAP;
        }else{
            return DESC_TOP_GAP + titleLabelHeight + DESC_LOCATION_GAP + LOCATION_TAG_HEIGHT + LOCATION_PIC_GAP + TOPIC_PIC_HEIGHT + BUTTOM_GAP;
        }
    }else{
        if (titleLabelHeight > DESC_MAX_HEIGHT) {
            titleLabelHeight = DESC_MAX_HEIGHT;
            if (model.location.length == 0) {
                return DESC_TOP_GAP + titleLabelHeight + DETAIL_BTN_LOCATION_GAP + DETAIL_BTN_HEIGHT+ DETAIL_BTN_PIC_GAP + TOPIC_PIC_HEIGHT + BUTTOM_GAP;
            }else{
                return DESC_TOP_GAP + titleLabelHeight + DESC_DETAIL_BTN_GAP + DETAIL_BTN_HEIGHT + DETAIL_BTN_LOCATION_GAP + LOCATION_TAG_HEIGHT + LOCATION_PIC_GAP + TOPIC_PIC_HEIGHT + BUTTOM_GAP;
            }
        }else{
            if (model.location.length == 0) {
                return DESC_TOP_GAP + titleLabelHeight + DESC_PIC_GAP + TOPIC_PIC_HEIGHT + BUTTOM_GAP;
            }else{
                return DESC_TOP_GAP + titleLabelHeight + DESC_LOCATION_GAP + LOCATION_TAG_HEIGHT + LOCATION_PIC_GAP + TOPIC_PIC_HEIGHT + BUTTOM_GAP;
            }
        }
    }
}

#pragma mark- 创建顶部的有多少人转发的label
//创建转发描述的label
- (UILabel *)createReportDescLabel:(int)totalReportCount{
    UILabel *descLabel = [UILabel labelWithSystemFont:13 textColor:HEXCOLOR(TextGrayColor)];
    NSString *desc = @"";
    if (totalReportCount <= 3) {
        desc = TTLocalString(@"topic_repost_this_topic");
        descLabel.text = desc;
    }else{
        desc = FormatString(@"%@%d%@",TTLocalString(@"topic_etc") ,totalReportCount,TTLocalString(@"topic_somebody_repost"));
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:desc];
        [string addAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(TextGrayColor),NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, 1)];
        [string addAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(SystemColor),NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(1, IntToString(totalReportCount).length)];
        [string addAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(TextGrayColor),NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(IntToString(totalReportCount).length + 1,8)];
        descLabel.attributedText = string;
        
    }
    CGSize size = [desc sizeWithFont:descLabel.font];
    descLabel.frame = CGRectMake(0, 0, size.width, size.height);
    return descLabel;
}
//转发的用户名点击

- (void)reportUserNameClick:(UIGestureRecognizer *)sender{
    UserInfo *info = _topicModel.userlist[sender.view.tag];
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicReportUserNameClick:nickName:)]) {
        NSString *name = info.remarkname.length > 0 ? info.remarkname : info.nickname;
        [_topicDelegate topicReportUserNameClick:info.uid nickName:name];
    }
}

//通过model来加载cell的内容

#pragma mark - 通过topicModel加载 cell

- (void)loadCellWithModel:(TopicModel *)topicModel{
    _topicModel = topicModel;
    
    _isAutoPlay = ![UserDefaults boolForKey:UserDefaults_is_Close_AutoPlay_Under_Wifi];

    //创建，顶部的转发视图，
    if (_isShowReportView && _topicModel.reportTotal > 0) {
        _topView.frame = CGRectMake(0, 0, ScreenWidth, 32);
        [_topView setHidden:NO];
        [[_topView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UILabel class]]) {
               [(UILabel *)obj removeFromSuperview];
            }
        }];
        //转发文字描述的最大宽度,转发的人的昵称，分别放在label上，点击label后，通过label的tag，找到对应用户的uid;
        CGFloat maxWidth = 0;
        
        CGFloat gap = 0;
        if (_topicModel.userlist.count > 3) {
            gap = 160;
        }else{
            gap = 120;
        }
        if (_topicModel.userlist.count == 1) {
            maxWidth = ScreenWidth - gap ;
        }else if (_topicModel.userlist.count == 2){
            maxWidth = (ScreenWidth - gap) / 2;
        }else if (_topicModel.userlist.count == 3){
            maxWidth = (ScreenWidth - gap) / 3;
        }
        CGFloat totalWidth = 0;
        
        NSInteger userCount = 0;
        if (_topicModel.userlist.count <= 3) {
            userCount = _topicModel.userlist.count;
        }else{
            userCount = 3;
        }
        
        for (int i = 0; i < userCount; i ++) {
            UILabel *nameLabel = [UILabel labelWithSystemFont:13 textColor:HEXCOLOR(SystemColor)];
            nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            nameLabel.textColor = HEXCOLOR(SystemColor);
            nameLabel.tag = i;
            nameLabel.userInteractionEnabled = YES;
            [_topView addSubview:nameLabel];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reportUserNameClick:)];
            [nameLabel addGestureRecognizer:tap];
            UserInfo *userinfo = _topicModel.userlist[i];
            NSString *name = userinfo.nickname;
            if (userinfo.remarkname.length > 0) {
                name = userinfo.remarkname;
            }
            if (i < _topicModel.userlist.count - 1) {
               name = FormatString(@"%@、",name);
            }
            nameLabel.text = name;
            CGSize size = [nameLabel.text sizeWithFont:nameLabel.font];
            if (size.width > maxWidth) {
                size.width = maxWidth;
            }
            nameLabel.frame = CGRectMake(27 + totalWidth, 10,size.width, size.height);
            totalWidth = size.width + totalWidth;
        }
        //创建尾部的描述label;
        UILabel *descLabel = [self createReportDescLabel:_topicModel.reportTotal];
        descLabel.frame = CGRectMake(totalWidth + 29, 10, descLabel.mj_width, descLabel.mj_height);
        [_topView addSubview:descLabel];
        
    }else{
        _topView.frame = CGRectMake(0, 0, ScreenWidth, 0);
        [_topView setHidden:YES];
    }
   

    [_videoProgress setHidden:YES];
    
    CGSize nameSize = [_topicModel.nickname sizeWithFont:[UIFont systemFontOfSize:16]];
    if (nameSize.width > ScreenWidth - 160) {
        nameSize.width = ScreenWidth - 160;
    }
    _nameLabel.frame = CGRectMake(_nameLabel.mj_x, _nameLabel.mj_y, nameSize.width, _nameLabel.mj_height);
    
    //是否显示VIP图标
    if (_topicModel.userinfo.isauth) {
        [_vipImageView setHidden:NO];
        _vipImageView.frame = CGRectMake(_nameLabel.max_x + 5, _nameLabel.mj_y + 3,16, 16);
    }else{
        [_vipImageView setHidden:YES];
        _vipImageView.frame = CGRectMake(_nameLabel.max_x + 5, _nameLabel.mj_y + 3, 0, 0);
    }
    
    _levelImageView.frame = CGRectMake(_vipImageView.max_x + 5, _levelImageView.mj_y, _levelImageView.mj_width, _levelImageView.mj_height);
    _levelImageView.image = [UIImage imageNamed:FormatString(@"user_level%d", _topicModel.userinfo.userhonorlevel)];
    
    //  relation   0:没有关系 1：对方添加我未好友 2：我添加对方为好友 3:互为好友 4：我自己
    
    [_addFollowBtn setHidden:NO];
    
    if ([_topicModel.userinfo.relation intValue] == 3) {
        [_addFollowBtn setImage:[UIImage imageNamed:@"topic_each other_follow"] forState:UIControlStateNormal];
    }else if ([_topicModel.userinfo.relation intValue] == 0 || [_topicModel.userinfo.relation intValue] == 1){
        [_addFollowBtn setImage:[UIImage imageNamed:@"topic_add_follow"] forState:UIControlStateNormal];
    }else if ([_topicModel.userinfo.relation intValue] == 2){
        [_addFollowBtn setImage:[UIImage imageNamed:@"topic_followed"] forState:UIControlStateNormal];
    }
    
    if ([_topicModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {
        [_addFollowBtn setHidden:YES];
    }
    //并且当前用户不是匿名的时候，显示 添加关注按钮
    if (_topicModel.iskana == 1) {
        [_addFollowBtn setHidden:YES];
    }
    
    if (_topicModel.userisrepost == 0) {//用户未转发
        [_reportBtn setImage:[UIImage imageNamed:@"topic_zhuanfa"] forState:UIControlStateNormal];
    }else{//用户已转发
        [_reportBtn setImage:[UIImage imageNamed:@"topic_zhuanfa_hl"] forState:UIControlStateNormal];
    }
    
    if (_topicModel.repostnum > 0) {
        _reportLabel.text = FormatString(@"%d", _topicModel.repostnum);
    }else{
        _reportLabel.text = TTLocalString(@"topic_repost");
    }
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(resetUploadTopicStatus) name:Notification_Topic_Send_Failed object:nil];
    
   
    _levelImageView.image = nil;
    [_levelImageView setImage:[UIImage imageNamed:FormatString(@"user_level%d", _topicModel.userinfo.userhonorlevel)]];
    
    [self setCommentDefaultView];
    
    //每次加载，默认cell显示评论
    
    _isShowComment = YES;
    
    _isTargetCell = NO;//是否是目标cell，目标cell就是当前视图中，需要滚动播放评论的cell。初始值都是NO;
    
    _isVedioSuccess = NO;//是否可以滑动，初始值为NO;
    
    _isPicSuccess = NO;
    
    _isCanScroll = NO;
    
    [_commentControl setImage:[UIImage imageNamed:@"topic_comment_start"] forState:UIControlStateNormal];
    
    _likeCountLabel.text = _topicModel.zan;
    
    if ([_topicModel.commentnum integerValue] > 0) {
        _commentCountLabel.text = _topicModel.commentnum;
    }else{
        _commentCountLabel.text = TTLocalString(@"topic_comment");
    }
    if ([_topicModel.zan integerValue] > 0) {
        _likeCountLabel.text = _topicModel.zan;
    }else{
        _likeCountLabel.text = TTLocalString(@"topic_zan");
    }
    
    
    //当为匿名的时候，不显示用户级别,用户的名称为「匿名」，用户的头像，名称不可点击。
    if (_topicModel.iskana == 1) {
        _avatarBtn.userInteractionEnabled = NO;
        _nameLabel.userInteractionEnabled = NO;
        _nameLabel.textColor = HEXCOLOR(TextBlackColor);
        _nameLabel.text = TTLocalString(@"topic_anonymous");
        [_avatarBtn setBackgroundImage:[UIImage imageNamed:@"home_topic_niming"] forState:UIControlStateNormal];
        [_levelImageView setHidden:YES];
        [_vipImageView setHidden:YES];
    }else{
        _avatarBtn.userInteractionEnabled = YES;
        _nameLabel.userInteractionEnabled = YES;
        [_levelImageView setHidden:NO];
        _nameLabel.textColor = HEXCOLOR(0x279d7d);
        [_avatarBtn sd_setBackgroundImageWithURL:StrToUrl([SysTools getHeaderImageURL:_topicModel.uid time:_topicModel.avatar]) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        if (_topicModel.userinfo.remarkname.length > 0) {
            _nameLabel.text = _topicModel.userinfo.remarkname;
        }else{
            _nameLabel.text = _topicModel.userinfo.nickname;
        }
        
    }
    
    [_titleLabel setExtendText:_topicModel.topicDesc];
    
    __weak TopicCell *weakSelf = (TopicCell *)self;
    [_titleLabel setExntedBlock:^(NSString *linkedString,TTExtendLabelLinkType type){
        if (type == TTExtendLabelLinkTypeAt) {
            if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
                [weakSelf.topicDelegate topicAtClick:linkedString topicModel:weakSelf.topicModel];
            }
        }else if(type == TTExtendLabelLinkTypePoundSign){
            if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
                [weakSelf.topicDelegate topicPoundSignClick:linkedString topicModel:weakSelf.topicModel];
            }
        }
        else if(type == TTExtendLabelLinkTypeURL){
            WSLog(@"点击了链接：%@",linkedString);
        }
    }];
    
    //计算时间戳的的大小
    CGFloat stampLabelWidth = [_topicModel.formattime sizeWithFont:_stampLabel.font].width;
    _stampLabel.text = _topicModel.formattime;
    _stampLabel.frame = CGRectMake(_stampLabel.mj_x, _stampLabel.mj_y, stampLabelWidth, _stampLabel.mj_height);
    if (_topicModel.client.length > 0) {
        [_phoneName setHidden:NO];
        [_phoneFlag setHidden:NO];
        _phoneName.text = _topicModel.client;
        _phoneFlag.frame = CGRectMake(_stampLabel.max_x + 12,_phoneFlag.mj_y, 7, 10);
        _phoneName.frame = CGRectMake(_phoneFlag.max_x + 3, _stampLabel.mj_y, 100 * ScreenScale, 12);
    }else{
        [_phoneFlag setHidden:YES];
        [_phoneName setHidden:YES];
    }
    CGFloat titleHeight = _titleLabel.contentHeight;
    if (_topicModel.topicDesc.length == 0) {
        titleHeight = 0;
    }
    if (_isDetail) {
        [_detailBtn setHidden:YES];
        _titleLabel.frame = CGRectMake(_titleLabel.mj_x, _titleLabel.mj_y, _titleLabel.mj_width, titleHeight);
        if (_topicModel.location.length == 0) {
            [_locationFlag setHidden:YES];
            [_addressLabel setHidden:YES];
            _headerView.frame = CGRectMake(0,_topView.max_y, ScreenWidth, _titleLabel.max_y + DESC_PIC_GAP);
        }else{
            [_locationFlag setHidden:NO];
            [_addressLabel setHidden:NO];
            _locationFlag.frame = CGRectMake(_locationFlag.mj_x, _titleLabel.max_y + DESC_LOCATION_GAP, _locationFlag.mj_width, _locationFlag.mj_height);
            _addressLabel.frame = CGRectMake(_addressLabel.mj_x,_locationFlag.mj_y , _addressLabel.mj_width, _addressLabel.mj_height);
            _headerView.frame = CGRectMake(0, _topView.max_y, ScreenWidth, _locationFlag.max_y + LOCATION_PIC_GAP);
        }
    }else{
        [_detailBtn setHidden:YES];
        _titleLabel.frame = CGRectMake(_titleLabel.mj_x, _titleLabel.mj_y, _titleLabel.mj_width, titleHeight);
        if (titleHeight > DESC_MAX_HEIGHT) {
            _titleLabel.frame = CGRectMake(_titleLabel.mj_x, _titleLabel.mj_y, _titleLabel.mj_width, DESC_MAX_HEIGHT);
            [_detailBtn setHidden:NO];
            _detailBtn.frame = CGRectMake(_detailBtn.mj_x, _titleLabel.max_y + DESC_DETAIL_BTN_GAP, _detailBtn.mj_width, _detailBtn.mj_height);
            if (_topicModel.location.length == 0) {
                [_locationFlag setHidden:YES];
                [_addressLabel setHidden:YES];
                _headerView.frame = CGRectMake(0, _topView.max_y, ScreenWidth, _detailBtn.max_y + DETAIL_BTN_PIC_GAP);
            }else{
                [_locationFlag setHidden:NO];
                [_addressLabel setHidden:NO];
                _locationFlag.frame = CGRectMake(_locationFlag.mj_x, _detailBtn.max_y + DETAIL_BTN_LOCATION_GAP, _locationFlag.mj_width, _locationFlag.mj_height);
                _addressLabel.frame = CGRectMake(_addressLabel.mj_x,_locationFlag.mj_y , _addressLabel.mj_width, _addressLabel.mj_height);
                _headerView.frame = CGRectMake(0, _topView.max_y, ScreenWidth, _locationFlag.max_y + LOCATION_PIC_GAP);
            }
        }else{
            if (_topicModel.location.length == 0) {
                [_locationFlag setHidden:YES];
                [_addressLabel setHidden:YES];
                _headerView.frame = CGRectMake(0, _topView.max_y, ScreenWidth, _titleLabel.max_y + DESC_PIC_GAP);
            }else{
                [_locationFlag setHidden:NO];
                [_addressLabel setHidden:NO];
                _locationFlag.frame = CGRectMake(_locationFlag.mj_x, _titleLabel.max_y + DESC_LOCATION_GAP, _locationFlag.mj_width, _locationFlag.mj_height);
                _addressLabel.frame = CGRectMake(_addressLabel.mj_x,_locationFlag.mj_y , _addressLabel.mj_width, _addressLabel.mj_height);
                _headerView.frame = CGRectMake(0, _topView.max_y, ScreenWidth, _locationFlag.max_y + LOCATION_PIC_GAP);
            }
        }
    }
 
    _middleView.frame = CGRectMake(0, _headerView.max_y, ScreenWidth, _middleView.mj_height);
    
    [_reUploadBtn setUserInteractionEnabled:YES];
   
    if (_topicModel.isUploadFailed) {
        [_reUploadBtn setHidden:NO];
        [_reUploadLabel setHidden:NO];
        [_commentDefaultLabel setHidden:YES];
        [_commentDefaultIcon setHidden:YES];
        
        NSString *string0 = TTLocalString(@"TT_network_not_ok");
        NSString *string1 = TTLocalString(@"TT_click_retry");
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:FormatString(@"%@%@", string0,string1)];
        
        [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, string0.length)];
        [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x9B9A9B) range:NSMakeRange(0, string0.length )];
        [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(string0.length,string1.length)];
        [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x719FEB) range:NSMakeRange(string0.length,string1.length)];
        _reUploadLabel.attributedText = mStr;
    }else{
        [_reUploadBtn setHidden:YES];
        [_reUploadLabel setHidden:YES];
        [_commentDefaultIcon setHidden:NO];
        [_commentDefaultLabel setHidden:NO];
    }
    if (_commentBgView) {
        [_commentBgView removeFromSuperview];
        _commentBgView = nil;
    }
    _addZanView.hidden = YES;
    _cancelZanView.hidden = YES;
    _length = 20;//第一次加载50条
    
    _hotFlag.frame = CGRectMake(HotFlagOriginX, _hotFlag.mj_y, _hotFlag.mj_width, _hotFlag.mj_height);
    
    //type==1 为图片。type==5为视频
    
    //当观看数为0时设置为1
    if (_topicModel.views == 0) {
        _topicModel.views = 1;
    }
    [_videoIcon setHidden:YES];
    
    [_playButton setHidden:YES];
    
    if (_topicModel.type ==5) {
        _videoIcon.hidden = NO;
       //检测视频是否下载完成
        
        if (_isAutoPlay) {
            [_playButton setHidden:YES];
        }else{
            [_playButton setHidden:NO];
        }
        _isVedioSuccess = [AWEasyVideoPlayer isDownloadFinish:_topicModel.videourl];
        
        //_isVedioSuccess为NO，说明视频未下载完成，需要下载视频
        
        if (!_isVedioSuccess) {
            [_videoProgress setHidden:NO];
            [_videoProgress setProgress:0.001 animated:NO];
            
            if (ApplicationDelegate.isReachableWiFi && ApplicationDelegate.isAutoPlay) {
                [self startDownVedio];
            }
            if (!ApplicationDelegate.isReachableWiFi) {
                [_playButton setHidden:NO];
                [[TCBlobDownloadManager sharedInstance]cancelAllDownloadsAndRemoveFiles:NO];
            }
        }
        _topicPicView.contentMode = UIViewContentModeScaleAspectFill;
        _topicPicView.layer.masksToBounds = YES;
    }else if(_topicModel.type == 1){
        _topicPicView.contentMode = UIViewContentModeScaleAspectFit;
    }
    _watchCount.text = FormatString(@"%d", _topicModel.views);
    _addressLabel.text = _topicModel.location;
    [_commentCollectionView reloadData];
    _currentCommetnIndex = 0;
    
    
    
    if (_topicModel.isLike == YES) {
        [_likeCountBtn setImage:[UIImage imageNamed:@"topic_zan_hl"] forState:UIControlStateNormal];
    }else{
        [_likeCountBtn setImage:[UIImage imageNamed:@"topic_zan"] forState:UIControlStateNormal];
    }
    
    // 下载图片
   
    [_topicPicView setImage:nil];
    
    [_picProgress setProgress:0 animated:NO];
    
    [_reloadButton setHidden:YES];
    
    if ([_topicModel isHasTopicid]) {
        [_picProgress setHidden:NO];
        _picProgressValue = 0.0f;
        [_topicPicView sd_setImageWithURL:StrToUrl(_topicModel.sourcepath) placeholderImage:[UIImage imageNamed:@"topic_default"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {

            CGFloat progress = receivedSize / [@(expectedSize) doubleValue];
            if (progress - _picProgressValue > 0.05) {
                _picProgressValue = progress;
                [_picProgress setProgress:_picProgressValue animated:YES];
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_picProgress setHidden:YES];
            if (error == nil) {
                _isPicSuccess = YES;
            }else{
                _isPicSuccess = NO;
                [_reloadButton setHidden:NO];
            }
        }];
    }else{
        _watchCount.text = @"0";
        [_topicPicView removeFromSuperview];
        _topicPicView = nil;
        _topicPicView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_default"]];
        _topicPicView.userInteractionEnabled = YES;
        _topicPicView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
        _topicPicView.contentMode = UIViewContentModeScaleAspectFit;
        [_middleView insertSubview:_topicPicView atIndex:0];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapGesture.numberOfTapsRequired = 1;
        singleTapGesture.numberOfTouchesRequired  = 1;
        [_topicPicView addGestureRecognizer:singleTapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [_topicPicView addGestureRecognizer:doubleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        [_watchCount setHidden:NO];
        
        UIImage *image = nil;
        image = [UIImage imageWithContentsOfFile:getDocumentsFilePath(_topicModel.sourcepath)];
        [_picProgress setHidden:YES];
        if (image) {
           [_topicPicView setImage:image];
        }
    }
    _currentCommetnIndex = 0;
    
    //让延迟执行 滑动评论头像，因为滑动评论头像是通过设置collection的contentoffset，collectionView reload 是异步的需要时间。
    
    [self bk_performBlock:^(id obj) {
        [self scrollAvatarToIndex:_currentCommetnIndex animation:NO];
    } afterDelay:0.1];
    
    //延迟2s后再显示评论内容
    
    [self bk_performBlock:^(id obj) {
        _isCanScroll = YES;
    } afterDelay:1.f];
    [NOTIFICATION_CENTER removeObserver:self];

}

#pragma mark- 点赞的动画

- (void)addAnimationToView:(UIView *)targetView{
    [targetView setHidden:NO];
    [UIView animateWithDuration:0.15 animations:^{
        targetView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            targetView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                targetView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                CGPoint likeCountBtnCenter = CGPointMake(_likeCountBtn.mj_width - 49, _likeCountBtn.mj_height / 2.f);
                CGPoint toMiddelViewPoint = [_likeCountBtn convertPoint:likeCountBtnCenter toView:_middleView];
                [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    targetView.center = toMiddelViewPoint;
                    targetView.transform = CGAffineTransformMakeScale(0.12, 0.12);
                } completion:^(BOOL finished) {
                    targetView.hidden = YES;
                    targetView.center = CGPointMake(ScreenWidth / 2.0f, ScreenWidth /2.0f );
                    targetView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
            }];
        }];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  //  WSLog(@"----%f",scrollView.contentOffset.x);
    [self setHotFlagViewFrame:scrollView.contentOffset];
}
- (void)setHotFlagViewFrame:(CGPoint)offset{
    _hotFlag.frame = CGRectMake(HotFlagOriginX - offset.x, _hotFlag.mj_y, _hotFlag.mj_width, _hotFlag.mj_height);
}

#pragma mark 评论滑动时，发出通知,让评论延迟4秒，再滚动

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    [NOTIFICATION_CENTER postNotificationName:Comment_Scroll_BeginDragging object:nil];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self bk_performBlock:^(id obj) {
        [self findTheCenterCommentAvatar];
    } afterDelay:0.1];
    
    if (_topicModel.commentList.count > 1 && _currentCommetnIndex == 0 ) {
        [self beginRefreshComment];
    }else{
        [self prepareToLoadMoreComment];
    }
    //WSLog(@"------%f",_commentCollectionView.contentOffset.x);
}
//找到视图中间的那个评论图像。

/**
 *  中间的滑动评论是用collectin的线性布局来作的，collectin的pageEnabel属性是对整行起作用的，为了保证每次滑动结束，评论头像都能在
 最中间的位置，在scrollViewDidEndDecelerating方法调用时，重新设置了collection的offset.保证头像是在最中间的位置。
 */
- (void)findTheCenterCommentAvatar{
    NSArray *items = [_commentCollectionView visibleCells];
    for (CommentCollectionCell *cell in items) {
        [cell hidenSelectedView];
        CGRect rect = [cell convertRect:cell.avatarView.frame toView:_collectionViewbg];
        if (CGRectContainsPoint(rect, CGPointMake(ScreenWidth / 2.0f, _commentCollectionView.mj_height / 2.0f)) ) {
            NSIndexPath *indexpath = [_commentCollectionView indexPathForCell:cell];
            _currentCommetnIndex = indexpath.row + 1;
            if (_topicModel.commentList.count == 1 && indexpath.row ==1) {
                [cell hidenSelectedView];
            }else{
                [cell showSelectedView];
            }
            [_commentCollectionView setContentOffset:CGPointMake((_currentCommetnIndex -1) * Horizontal_Space, 0) animated:YES];
            [self scrollCommentToIndex:_currentCommetnIndex - 1 animation:YES];
        }
    }

}

// 该方法是在timer下，重复的执行。所以，可以时时的去判断视频是否下载完成。
//同时滑动下面的评论图像和评论内容。
//值得注意的是每次滚动完后，_currentCommetnIndex ++;所以评论图像的索引总比实际值大1.
- (void)scrollAvatarAndComment{
    
    if (!_isTargetCell) {
        return;
    }
   
    //当为视频的时候，需要视频下载完成才能播放评论，当时图片的时候需要图片下载完成才能播放评论
    if (_topicModel.type == 5) {
        _isVedioSuccess = [TTplayView isDownloadFinish:_topicModel.videourl];
        if (_isVedioSuccess && _isShowComment && _isCanScroll && _isAutoPlay) {
            if (_currentCommetnIndex < _topicModel.commentList.count && _topicModel.commentList.count > 0) {
                [self scrollAvatarToIndex:_currentCommetnIndex animation:YES];
                [self scrollCommentToIndex:_currentCommetnIndex animation:YES];
                _currentCommetnIndex ++;
            }
        }
    }else if(_topicModel.type == 1 ){

        if (_isPicSuccess && _isShowComment && _isCanScroll) {
            if (_currentCommetnIndex < _topicModel.commentList.count && _topicModel.commentList.count > 0) {
                [self scrollAvatarToIndex:_currentCommetnIndex animation:YES];
                [self scrollCommentToIndex:_currentCommetnIndex animation:YES];
                _currentCommetnIndex ++;
                
            }
        }
    }
}
/**
 *  滑动头像
 *
 *  @param index    滑到莫个索引
 *  @param animaton 是否需要动画
 */
- (void)scrollAvatarToIndex:(NSInteger)index animation:(BOOL)animaton{
    if (_topicModel.commentList.count > index) {
        [_commentCollectionView setContentOffset:CGPointMake(Horizontal_Space * index, 0) animated:animaton];
      //  [self scrollCommentToIndex:index animation:animaton];
        if (_currentCommetnIndex > 0) {
            CommentCollectionCell *cell = (CommentCollectionCell *)[_commentCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentCommetnIndex - 1 inSection:0]];
             [cell hidenSelectedView];
        }
        CommentCollectionCell *cell1 = (CommentCollectionCell *)[_commentCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentCommetnIndex inSection:0]];
        [cell1 showSelectedView];

        
        [self bk_performBlock:^(id obj) {
            [self prepareToLoadMoreComment];
        } afterDelay:0.1f];
    }
}


/**
 *  滑动评论
 *
 *  @param index     滑动到对应的索引
 *  @param animation 是否动画
 */
- (void)scrollCommentToIndex:(NSInteger)index animation:(BOOL)animation{
    if (_topicModel.commentList.count > index) {
        
        //防止cell复用，移除后重新创建
        if (_commentBgView) {
            [_commentBgView removeFromSuperview];
            _commentBgView = nil;
        }
        if (_topicModel.commentList.count > 0) {
            _commentBgView = [[UIImageView alloc]init];
            _commentBgView.frame = CGRectMake(0, 0, 140, 140);
            _commentBgView.userInteractionEnabled = YES;
            _commentBgView.hidden = !_isShowComment;
            [_middleView insertSubview:_commentBgView belowSubview:_commentControl];
            UITapGestureRecognizer *commentTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTap:)];
            [_commentBgView addGestureRecognizer:commentTap];
            
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
            [_commentBgView addGestureRecognizer:longGesture];
            
            _commentLabel = [[TTExtendLabel alloc] initWithFrame:CGRectMake(20, 40, 100, 60)];
            _commentLabel.backgroundColor = [UIColor clearColor];
            _commentLabel.userInteractionEnabled = NO;
            _commentLabel.numberOfLines = 0;
            [_commentBgView addSubview:_commentLabel];
        }
        
        CommentModel *model = _topicModel.commentList[index];
       [SysTools getEmotionImage:model.commentbg imageView:_commentBgView];
        if (model.comment.length > 0) {
            [self calculateCommentLabelFontAndFrame:model];
        }
        [_commentBgView addSubview:_commentLabel];
        
        _commentBgView.center = [self getCommentViewCenter:CGPointMake([model.pointX floatValue],  [model.pointY floatValue])];
        if ([model.scale  floatValue]==0) {
            model.scale=[NSString stringWithFormat:@"%d",1];
        }
        [SysTools  transferView:_commentBgView scaleNum:1.f];
        [SysTools  transferView:_commentBgView scaleNum:[model.scale floatValue]];
        [_commentBgView setNeedsDisplay];
        
        if (index == _topicModel.commentList.count - 1) {
            [self bk_performBlock:^(id obj) {
                if (_isCanScroll && _topicModel.type !=9 ) {
                    [_commentBgView removeFromSuperview];
                }
            } afterDelay:3];
        }
        
    }
}
//计算评论label的字体大小，和frame
/**
 *  计算评论的文字的大小，
 *
 *  @param model 评论的model。
 */
- (void)calculateCommentLabelFontAndFrame:(CommentModel *)model{
    CGFloat fontSize = MaxFontSize;
    NSString *totalStr = [NSString stringWithFormat:@"%@%@",CheckNilValue(model.replypart),model.comment];
    _commentLabel.font = [UIFont systemFontOfSize:fontSize];
    [_commentLabel setExtendText:totalStr];
    CGSize labelSize = CGSizeMake(_commentLabel.mj_width, _commentLabel.contentHeight);
    
    while (labelSize.height > 60) {
        fontSize --;
        if (fontSize < MinFontSize) {
            fontSize = MinFontSize;
            break;
        }
        _commentLabel.font = [UIFont systemFontOfSize:fontSize];
        [_commentLabel setExtendText:totalStr];
        labelSize = CGSizeMake(_commentLabel.mj_width,_commentLabel.contentHeight);
    }
    fontSize -- ;
    if (labelSize.height > 60.0f) {
        labelSize.height = 60.0f;
    }
    _commentLabel.font = [UIFont systemFontOfSize:fontSize];
    [_commentLabel setExtendText:totalStr];
    _commentLabel.frame = CGRectMake(20, 40 + (60- labelSize.height) / 2.0, 100, labelSize.height);
    
    UIColor *color = [SysTools getCommentColor:model.commentbg];
    
     [_commentLabel setTextColor:color];
    [_commentLabel setExtendText:totalStr];
    
}

//开始加载更多的评论
- (void)prepareToLoadMoreComment{
    if (_topicModel.commentList.count -1 == _currentCommetnIndex) {
        [self beginLoadMoreComment];
    }
}
//向前加载更多评论
- (void)beginRefreshComment{
    
    return;
    _isCanScroll = NO;
    if (_topicModel.commentList.count > 0) {
        _startcommentid = ((CommentModel *)[_topicModel.commentList firstObject]).commentid;
        if (_startcommentid.length == 0) {
            return;
        }
    }else{
        _startcommentid = @"";
    }
    _direction = @"up";
    [[RequestTools getInstance]get:[NSString stringWithFormat:@"%@?topicid=%@&startcommentid=%@&len=%ld&direction=%@",API_TOPIC_COMMENT_LIST,_topicModel.topicid,_startcommentid,(long)_length,_direction] isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *array = [CommentModel getCommentModelList:dict[@"data"][@"commentlist"]];
            if (array.count > 0) {
                NSMutableArray *marr = [@[]mutableCopy];
                [marr addObjectsFromArray:array];
                [marr addObjectsFromArray:_topicModel.commentList];
                _currentCommetnIndex = _currentCommetnIndex + array.count;
                _topicModel.commentList = marr;
                _topicModel.commentnum = CheckNilValue(dict[@"data"][@"total"]);
                [_commentCollectionView reloadData];
                [self setCommentDefaultView];
//                if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicUpdateModel:index:)]) {
//                    [_topicDelegate topicUpdateModel:_topicModel index:_cellIndex];
//                }
                [self bk_performBlock:^(id obj) {
                    [self scrollAvatarToIndex:_currentCommetnIndex animation:NO];
                } afterDelay:0.1];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
    } finished:^(ASIHTTPRequest *request) {
        _isCanScroll = YES;
    }];
    
}
//向右加载更多评论
- (void)beginLoadMoreComment{
    
    _direction = @"down";
    CommentModel *commentModel = ((CommentModel *)[_topicModel.commentList lastObject]);
    _startcommentid = commentModel.commentid;
    //当发布新评论后。这条评论是没有commentid,type==2
    if ([commentModel.type integerValue] == 2) {
        return;
    }
    if (_startcommentid.length == 0) {
        return;
    }
    _isCanScroll = NO;
    [[RequestTools getInstance]get:API_HOT_COMMENT_LIST(_topicModel.topicid,_startcommentid, (long)_length, _direction) isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *array = [CommentModel getCommentModelList:dict[@"data"][@"hotcommentlist"]];
            if (array.count > 0) {
                NSMutableArray *mArr = [@[]mutableCopy];
                [mArr addObjectsFromArray:_topicModel.commentList];
                [mArr addObjectsFromArray:array];
                _topicModel.commentList = mArr;
                _topicModel.commentnum = CheckNilValue(dict[@"data"][@"total"]);
                [_commentCollectionView reloadData];
                [self setCommentDefaultView];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
    } finished:^(ASIHTTPRequest *request) {
        _isCanScroll = YES;
    }];
}

//修正评论内容的坐标
- (CGPoint)getCommentViewCenter:(CGPoint)popint{
    CGPoint p = popint;
    if (p.x < 60) {
        p.x = 60;
    }
    if (p.x > ScreenWidth - 60) {
        p.x = ScreenWidth - 60;
    }
    if (p.y < 60) {
        p.y = 60;
    }
    if (p.y > ScreenWidth - 60) {
        p.y = ScreenWidth - 60;
    }
    
    return p;
    
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    [view.collectionViewLayout invalidateLayout];
    if (_topicModel.commentList.count ==1) {
        return 2;
    }
    return _topicModel.commentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCollectionCell *cell = (CommentCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:commentCollectionCell forIndexPath:indexPath];
    [cell.avatarView setHidden:NO];
    [cell.selectedView setHidden:NO];
    if (_topicModel.commentList.count == 1) {
        if (indexPath.row == 0) {
            [cell loadCellWithModel:_topicModel.commentList[indexPath.row]];
            return cell;
        }else{
            [cell.selectedView setHidden:YES];
            [cell.avatarView setHidden:YES];
            return cell;
        }
    }else{
       [cell loadCellWithModel:_topicModel.commentList[indexPath.row]];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    [NOTIFICATION_CENTER postNotificationName:Comment_Scroll_BeginDragging object:nil];
    
    if (_topicModel.commentList.count == 1 && indexPath.row ==1) {
        return;
    }
    if (_currentCommetnIndex - 1 != indexPath.row) {
        
        [self scrollAvatarToIndex:indexPath.row animation:YES];
        [self scrollCommentToIndex:indexPath.row animation:YES];
        _currentCommetnIndex = indexPath.row + 1;
        
        NSArray *items = [_commentCollectionView visibleCells];
        for (CommentCollectionCell *cell in items) {
            [cell hidenSelectedView];
        }
        CommentCollectionCell *cell = (CommentCollectionCell *)[_commentCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentCommetnIndex - 1 inSection:0]];
        [cell showSelectedView];
        
    }else{
        CommentModel *model = _topicModel.commentList[indexPath.row];
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentAvatarClick:)]) {
            [_topicDelegate topicCommentAvatarClick:model];
        }
    }
}
#pragma mark 再次上传主题
/**
 *  当上传失败后继续上传主题
 *
 *  @param sender
 */
- (void)resetUploadTopicStatus{
    _reUploadBtn.userInteractionEnabled=YES;
    _topicModel.isUploadFailed = YES;
    [_reUploadLabel setHidden:NO];
    [_reUploadBtn setHidden:NO];
    
    NSString *string0 = TTLocalString(@"TT_network_not_ok");
    NSString *string1 = TTLocalString(@"TT_click_retry");
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:FormatString(@"%@%@", string0,string1)];
    
    [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, string0.length)];
    [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x9B9A9B) range:NSMakeRange(0, string0.length )];
    [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(string0.length,string1.length)];
    [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x719FEB) range:NSMakeRange(string0.length,string1.length)];
    _reUploadLabel.attributedText = mStr;
}
-(void)reUploadTopic:(id)sender{
    //点击一次之后，让_reloadButton不可点。
    [_reUploadBtn setHidden:NO];
    [_reUploadLabel setHidden:NO];
    _topicModel.isUploadFailed = NO;
    _reUploadBtn.userInteractionEnabled=NO;
    [_reUploadLabel setTextColor:UIColorFromRGB(0x9B9A9B)];
    [_reUploadLabel setFont:[UIFont systemFontOfSize:15]];
    [_reUploadLabel setText:WebCopy_Post_Topic_Start];
    ASINetworkQueue *asi=[ASINetworkQueue queue];
    if (_topicModel.type == 5) {
        ASIFormDataRequest *request = [[SendLocalTools getInstance]sendVideoTopic:_topicModel];
        if (request) {
            [asi addOperation:request];
        }
    }else{
        ASIFormDataRequest *request = [[SendLocalTools getInstance]sendTopic:_topicModel];
        if (request) {
            [asi addOperation:request];
        }
    }
    [asi go];
}
/**
 *  向topicModel中插入评论
 *
 *  @param topicModel 插入评论后的model;
 */
- (void)insertCommentWithTopicModel:(TopicModel *)topicModel{
    _topicModel = topicModel;
    _isCanScroll = NO;
    [self setCommentDefaultView];
    
    [_commentCollectionView reloadData];
    
    //让评论滑动到最后一个。
    [self bk_performBlock:^(id obj) {
        _currentCommetnIndex = _topicModel.commentList.count - 1;
        [self scrollAvatarToIndex:_currentCommetnIndex animation:NO];
        [self scrollCommentToIndex:_currentCommetnIndex animation:NO];
        _isCanScroll = YES;
        [self setCommentDefaultView];
    } afterDelay:0.1];
}
/**
 *  播放器每次播放完成，就把视频的评论数 + 1 ；
 *
 *  @param notifi
 */
- (void)addPlayCount:(NSNotification *)notifi{
    
    [NOTIFICATION_CENTER postNotificationName:Notification_Video_Play object:_topicModel];
    
    if ([_topicModel isHasTopicid]) {
        _watchCount.text = FormatString(@"%d",(_topicModel.views  + 1));
        _topicModel.views = [_watchCount.text intValue];

    }
}
// 开始播放
- (void)playVideo{
    [NOTIFICATION_CENTER postNotificationName:Notification_Video_Play object:_topicModel];
    if (_topicModel.type == 5) {
        [NOTIFICATION_CENTER addObserver:self selector:@selector(addPlayCount:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        _isVedioSuccess = [TTplayView isDownloadFinish:_topicModel.videourl];
        if (_isVedioSuccess && _isAutoPlay) {
            if (_isTargetCell) {
                [self.topicPicView addSubview:[AWEasyVideoPlayer sharePlayer]];
                [AWEasyVideoPlayer sharePlayer].endAction = AWEasyVideoPlayerEndActionLoop;
                NSURL *videoUrl = nil;
                if ([_topicModel.videourl hasPrefix:@"http://"] || [_topicModel.videourl hasPrefix:@"https://"]) {
                    NSString *fileName = [[NSURL URLWithString:_topicModel.videourl] lastPathComponent];
                    videoUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",getVideoPath(),fileName]];
                }else{
                    videoUrl = [NSURL fileURLWithPath:_topicModel.videourl];
                }
                [[AWEasyVideoPlayer sharePlayer] setURL:videoUrl];
                [[AWEasyVideoPlayer sharePlayer] play];
            }
        }else{
            if (ApplicationDelegate.isReachableWiFi) {
                if (_isAutoPlay) {
                   [self startDownVedio];
                }
            }
        }
    }else{
        _topicModel.views = _topicModel.views + 1;
        _watchCount.text = IntToString(_topicModel.views);
        
    }
}
// 停止播放
- (void)stopVideo{
    [NOTIFICATION_CENTER removeObserver:self];
    [[AWEasyVideoPlayer sharePlayer]stop];
    [[AWEasyVideoPlayer sharePlayer]removeFromSuperview];
}
- (void)startDownVedio{
    if (!([_topicModel.videourl hasPrefix:@"http://"] || [_topicModel.videourl hasPrefix:@"https://"])) {
        return;
    }
    [[TCBlobDownloadManager sharedInstance]setMaxConcurrentDownloads:2];
    [[TCBlobDownloadManager sharedInstance]startDownloadWithURL:StrToUrl(_topicModel.videourl) identification:_topicModel.videourl customPath:getVideoPath() firstResponse:^(NSURLResponse *response) {
    } progress:^(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress,NSString *identification) {
        if ([identification isEqualToString:_topicModel.videourl]) {
            if (progress > 0.002) {
                [_videoProgress setProgress:progress animated:YES];
            }
        }
    } error:^(NSError *error) {
        
    } complete:^(BOOL downloadFinished, NSString *pathToFile) {
        if (downloadFinished) {
            NSError *error;
            NSArray *components = [pathToFile componentsSeparatedByString:@"."];
            NSString *release = [NSString stringWithFormat:@"%@.mp4",[components firstObject]];
            BOOL isRename=[[NSFileManager defaultManager] moveItemAtPath:pathToFile toPath:release error:&error];
            if (isRename) {
               [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS object:_topicModel.videourl];
                _isVedioSuccess = YES;
                _isAutoPlay = YES;
                [_videoProgress setHidden:YES];
            }
        }else{
            
        }
    }];
    
}

#pragma mark - 评论 ，赞 ，转发， 弹出分享视图 点击

- (void)footerButtonClick:(UIButton *)sender{
    //当点击 评论，咱，分享，更多时，如何主题还没有发表成功，就不让操作。
    if (![_topicModel isHasTopicid]) {
        return;
    }
    if (sender.tag == 3) {//弹出分享页面
        ShareActonSheet *sheet = [ShareActonSheet instancedSheetWith:_topicModel type:ActionSheetButtonTypeAll];
        sheet.delegate = self;
        [sheet showInWindow];
    }else if (sender.tag == 0){//去详情页面
        if (!_isDetail) {
            if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicDetailClick:)]) {
                [_topicDelegate topicDetailClick:_topicModel];
            }
            if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicDetailClick:index:)]) {
                [_topicDelegate topicDetailClick:_topicModel index:_cellIndex];
            }
        }
    }else if (sender.tag == 2){//转发按钮点击
        if ([[LoginManager getInstance]isLogin]) {
            
            if (_topicModel.userisrepost == 0) {//转发主题
                if ([_topicModel.uid isEqualToString:[[LoginManager getInstance] getUid]]) {
                    [SVProgressHUD showErrorWithStatus:TTLocalString(@"topic_can_not_repost")];
                }else{
                    [[RequestTools getInstance]get:API_Repost_Topic(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                        if ([dict[@"code"]intValue] == 10000) {
                            _topicModel.repostnum = _topicModel.repostnum + 1;
                            _reportLabel.text = FormatString(@"%d", _topicModel.repostnum);
                            _topicModel.userisrepost = 1;
                            [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_repost_success")];
                            [_reportBtn setImage:[UIImage imageNamed:@"topic_zhuanfa_hl"] forState:UIControlStateNormal];
                            if (_isDetail) {
                                [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                            }
                        }
                    } failure:^(ASIHTTPRequest *request, NSString *message) {
                        
                    } finished:^(ASIHTTPRequest *request) {
                        
                    }];
                }
                
            }else{//取消转发
                [[RequestTools getInstance]get:API_DEL_Repost_Topic(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                    if ([dict[@"code"]intValue] == 10000) {
                        _topicModel.repostnum = _topicModel.repostnum - 1;
                        _topicModel.userisrepost = 0;
                        _reportLabel.text = FormatString(@"%d", _topicModel.repostnum);
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_repost_cancel_success")];
                        if (_topicModel.repostnum == 0) {
                            _reportLabel.text = TTLocalString(@"topic_repost");
                        }
                        [_reportBtn setImage:[UIImage imageNamed:@"topic_zhuanfa"] forState:UIControlStateNormal];
                        if (_isDetail) {
                            [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                        }
                        
                    }
                    
                } failure:^(ASIHTTPRequest *request, NSString *message) {
                    
                } finished:^(ASIHTTPRequest *request) {
                    
                }];
            }
            
 
        }else{
            [[LoginManager getInstance]showLoginView:nil];
        }
    }else{//点赞
        
        //从本地取数字，如果 < 3, 提示双击点赞

        NSInteger count = [UserDefaults integerForKey:UserDefaults_Topic_Zan_Count];
        count ++;
        [UserDefaults setInteger:count forKey:UserDefaults_Topic_Zan_Count];
        if (count < 3) {
            [self bk_performBlock:^(id obj) {
               [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_double_click_zan") duration:1.2];
            } afterDelay:1.5];
            
        }
        [self likeButtonClick];
    }

}
#pragma mark  LXActionSheetDelegate 
- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if (tag == 1000) {
        if (buttonIndex == 0) {
            //屏蔽莫人的主题，只在登录后才有权限
            if (self.currentUserInfo.uid.length > 0) {
                [[RequestTools getInstance]get:API_BLOCK_USER_FEED(_topicModel.uid) isCache:NO completion:^(NSDictionary *dict) {
                    UserInfo *userinfo = [[UserInfo alloc]init];
                    userinfo.uid = _topicModel.uid;
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_TOPIC object:userinfo];
                } failure:^(ASIHTTPRequest *request, NSString *message) {
                } finished:^(ASIHTTPRequest *request) {
                }];
            }else{
                [self showLoginView];
            }
        }else if (buttonIndex == 1){
            //举报莫条主题
        }else if (buttonIndex == 2){
            //收藏主题，只在登录后才有权限
            if (self.currentUserInfo.uid.length > 0) {
                //当已经收藏，需要取消收藏
                if (_topicModel.favorite == YES) {
                    [[RequestTools getInstance]get:API_TOPIC_FAVORITE_DELETE(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                        if ([dict[@"code"]intValue] == 10000) {
                            _topicModel.favorite = NO;
                            if (_isDetail) {
                                [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                            }
                        }
 
                    } failure:^(ASIHTTPRequest *request, NSString *message) {
                        
                    } finished:^(ASIHTTPRequest *request) {
                        
                    }];
                }else{
                    [[RequestTools getInstance]get:API_TOPIC_FAVORITE_ADD(_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                        if ([dict[@"code"]intValue] == 10000) {
                            _topicModel.favorite = YES;
                            [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_collection_success") duration:1.0];
                            
                            if (_isDetail) {
                                [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                            }
                        }

                    } failure:^(ASIHTTPRequest *request, NSString *message) {
                        
                    } finished:^(ASIHTTPRequest *request) {
                        
                    }];
                }
            }else{
                [self showLoginView];
            }
        }
    }else if (tag == 9999){
        if (buttonIndex == 0) {
            if (_currentCommetnIndex - 1 < _topicModel.commentList.count) {

                CommentModel *commentModel = _topicModel.commentList[_currentCommetnIndex - 1];
                [[RequestTools getInstance]get:API_COMMENT_DELETE(commentModel.commentid,commentModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                    for (CommentModel *model in _topicModel.commentList) {
                        if ([model.commentid isEqualToString:commentModel.commentid]) {
                            [_topicModel.commentList removeObject:model];
                        }
                    }
                    [_commentCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentCommetnIndex - 1 inSection:0]]];
                    if (_currentCommetnIndex == _topicModel.commentList.count && _currentCommetnIndex != 0) {
                        _currentCommetnIndex --;
                    }
                    if (_currentCommetnIndex >= 0) {
                        [self scrollCommentToIndex:_currentCommetnIndex animation:YES];
                    }
                    
                    NSInteger totalCount = [_topicModel.commentnum integerValue] - 1;
                    _topicModel.commentnum = [NSString stringWithFormat:@"%ld",(long)totalCount];
                    
                    [self setCommentDefaultView];
                    
                    
                    [self bk_performBlock:^(id obj) {
                        _isCanScroll = YES;
                    } afterDelay:.5f];
                } failure:^(ASIHTTPRequest *request, NSString *message) {
                    _isCanScroll = YES;
                } finished:^(ASIHTTPRequest *request) {
                    
                }];
            }

        }else{
            _isCanScroll = YES;
        }
    }else if (tag == 10000){
        if (buttonIndex == 0) {
            
        }else{
            LoginViewController * login = [[LoginViewController alloc] init];
            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:login];
            nav.navigationBarHidden=YES;
            [ApplicationDelegate.window setRootViewController:nav];
        }
    }else if(tag == 7777){ //是否去下载视频
        if (buttonIndex == 0) {
            [_playButton setHidden:YES];
            [self startDownVedio];
        }else{
        
        }
    }
}

/**
 *  弹出登录提示
 */
- (void)showLoginView{
    [[LoginManager getInstance]showLoginView:self];
}
- (void)likeButtonClick{
    
    if (self.currentUserInfo.uid.length > 0) {
        __block int likeCount = [_topicModel.zan intValue];
        _likeCountBtn.userInteractionEnabled = NO;
        if (_topicModel.isLike == YES) {
            likeCount --;
            if (likeCount > 0) {
                _likeCountLabel.text = FormatString(@"%d",likeCount);
            }else{
                _likeCountLabel.text = TTLocalString(@"topic_zan");
            }
            [self bk_performBlock:^(id obj) {
                [_likeCountBtn setImage:[UIImage imageNamed:@"topic_zan"] forState:UIControlStateNormal];
            } afterDelay:1.45f];
            [self addAnimationToView:_cancelZanView];
            [[RequestTools getInstance]get:[NSString stringWithFormat:@"%@?topicid=%@",API_TOPIC_UNLIKE,_topicModel.topicid] isCache:NO completion:^(NSDictionary *dict) {
                _topicModel.isLike = NO;
                _topicModel.zan = [NSString stringWithFormat:@"%ld",(long)likeCount];
                //赞成功后更新数据

                if (_isDetail) {
                    [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                }

                if ([_topicModel.zan integerValue] > 0) {
                    _likeCountLabel.text = _topicModel.zan;
                }else{
                    _likeCountLabel.text = TTLocalString(@"topic_zan");
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                likeCount ++;
                _topicModel.zan = [NSString stringWithFormat:@"%ld",(long)likeCount];
                _topicModel.isLike = YES;
                _likeCountLabel.text = FormatString(@"%d",likeCount);
                [_likeCountBtn setImage:[UIImage imageNamed:@"topic_zan_hl"] forState:UIControlStateNormal];
            } finished:^(ASIHTTPRequest *request) {
                [_likeCountBtn setUserInteractionEnabled:YES];
            }];
        }else{
            likeCount ++;
            _likeCountLabel.text = FormatString(@"%d",likeCount);
            [self bk_performBlock:^(id obj) {
                [_likeCountBtn setImage:[UIImage imageNamed:@"topic_zan_hl"] forState:UIControlStateNormal];
            } afterDelay:1.45f];
            [self addAnimationToView:_addZanView];
            [[RequestTools getInstance]get:[NSString stringWithFormat:@"%@?topicid=%@",API_TOPIC_LIKE,_topicModel.topicid] isCache:NO completion:^(NSDictionary *dict) {
                _topicModel.isLike = YES;
                _topicModel.zan = [NSString stringWithFormat:@"%ld",(long)likeCount];

                if (_isDetail) {
                    [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                }

                if ([_topicModel.zan integerValue] > 0) {
                    _likeCountLabel.text = _topicModel.zan;
                }else{
                    _likeCountLabel.text = TTLocalString(@"topic_zan");
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                likeCount--;
                _topicModel.zan = [NSString stringWithFormat:@"%ld",(long)likeCount];
                _topicModel.isLike = NO;
                _likeCountLabel.text = FormatString(@"%d",likeCount);
                [_likeCountBtn setImage:[UIImage imageNamed:@"topic_zan"] forState:UIControlStateNormal];
            } finished:^(ASIHTTPRequest *request) {
                [_likeCountBtn setUserInteractionEnabled:YES];
            }];
        }
    }else{
        [[LoginManager getInstance]showLoginView:self];
    }
    
}
- (UserInfo *)currentUserInfo{
    return _currentUserInfo?_currentUserInfo :[[LoginManager getInstance]getLoginInfo];
}
//刷新commentDefaultLabel的格式
- (void)setCommentDefaultView{
    if ([_topicModel.commentList count] == 0) {
        [_commentDefaultView setHidden:NO];
        _commentDefaultLabel.text = _topicModel.emptyCommentText;
        _commentDefaultLabel.numberOfLines = 1;
        CGSize size = [_commentDefaultLabel getLineLabelSize];
        if (size.width > ScreenWidth - _commentDefaultIcon.mj_width - 20) {
            size.width = ScreenWidth - _commentDefaultIcon.mj_width - 20;
        }
        CGFloat x = (ScreenWidth - size.width - _commentDefaultIcon.mj_width - 9) / 2.0f;
        _commentDefaultIcon.frame = CGRectMake(x, _commentDefaultIcon.mj_y, _commentDefaultIcon.mj_width, _commentDefaultIcon.mj_height);
        _commentDefaultLabel.frame = CGRectMake(_commentDefaultIcon.max_x + 9, _commentDefaultLabel.mj_y, size.width, _commentDefaultLabel.mj_height);
        [_collectionViewbg setHidden:YES];
        _commentCountLabel.text = @"评论";
    }else{
        _commentCountLabel.text = _topicModel.commentnum;
        [_collectionViewbg setHidden:NO];
        [_commentDefaultView setHidden:YES];
    }

}
//评论点击
- (void)commentTap:(UITapGestureRecognizer *)tap{

    if (![_topicModel isHasTopicid]) {
        return;
    }

    if (_topicModel.commentList.count > _currentCommetnIndex - 1) {
        if (self.currentUserInfo.uid.length > 0) {
            
            UIImage *image = nil;
            CGFloat duration = 0;
            if (_topicModel.type == 5) {
                if (!_isVedioSuccess) {
                    return;
                }
                if (_isTargetCell) {
                    image = [[AWEasyVideoPlayer sharePlayer] getCurImage];
                    duration = [[AWEasyVideoPlayer sharePlayer] getCurDuration];
                }else{
                    duration = 0.0f;
                    image = _topicPicView.image;
                }
            }else if(_topicModel.type == 1){
                if (!_isPicSuccess) {
                    return;
                }
                image = _topicPicView.image;
                duration = 0.f;
            }
            if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentContentClick:topicModel:image:duration:type:point:)]) {
                [_topicDelegate topicCommentContentClick:_topicModel.commentList[_currentCommetnIndex - 1] topicModel:_topicModel image:image duration:duration type:2 point:CGPointZero];
            }
            [self stopVideo];
        }else{
            [self showLoginView];
        }
    }
}
//点击弹出删除按钮
- (void)longGesture:(UILongPressGestureRecognizer *)longGesture{
    //当长按删除时，如何主题还没有发表成功，就不让操作。
    if (![_topicModel isHasTopicid]) {
        return;
    }
    if (UIGestureRecognizerStateBegan ==longGesture.state) {
        if (_currentCommetnIndex - 1 < _topicModel.commentList.count) {
            CommentModel *model = _topicModel.commentList[_currentCommetnIndex - 1];
            if ([model.uid isEqualToString:self.currentUserInfo.uid]) {
                _overButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _overButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                [[UIApplication sharedApplication].keyWindow addSubview:_overButton];
                [_overButton addTarget:self action:@selector(dismissDeleteAlert:) forControlEvents:UIControlEventTouchUpInside];
                _isCanScroll = NO;
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [deleteBtn setBackgroundImage:[UIImage imageNamed:@"menu_delete"] forState:UIControlStateNormal];
                deleteBtn.frame = CGRectMake(100, 100, 62, 45);
                [deleteBtn addTarget:self action:@selector(showDeleteAlert:) forControlEvents:UIControlEventTouchUpInside];
                deleteBtn.contentEdgeInsets = UIEdgeInsetsMake(12, 0, 18, 0);
                deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                CGPoint point = [_commentBgView convertPoint:CGPointMake(70,0) toView:_overButton];
                deleteBtn.center = CGPointMake(point.x, point.y + 2);
                [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [deleteBtn setTitle:TTLocalString(@"TT_delete") forState:UIControlStateNormal];
                [_overButton addSubview:deleteBtn];
            }
        }

    }
}
- (void)dismissDeleteAlert:(id)sender{
    _isCanScroll = YES;
    [_overButton removeFromSuperview];
}
- (void)showDeleteAlert:(id)sender{
    [_overButton removeFromSuperview];
    LXActionSheet * actionSheet = [[LXActionSheet alloc]initWithTitle:TTLocalString(@"TT_make_sure_delete_comment") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
    actionSheet.tag = 9999;
    [actionSheet showInView:nil];
    
}
//单击主题去评论
- (void)handleSingleTap:(UITapGestureRecognizer *)tap{
    if (![_topicModel isHasTopicid]) {
        return;
    }
    //评论需要先登录
    if (self.currentUserInfo.uid.length > 0) {
        
        UIImage *image = nil;
        CGFloat duration = 0;

        if (_topicModel.type == 5) {
            if (!_isVedioSuccess) {
                return;
            }
            if (_isTargetCell) {
                image = [[AWEasyVideoPlayer sharePlayer] getCurImage];
                duration = [[AWEasyVideoPlayer sharePlayer] getSumDurtion];
            }else{
                image = _topicPicView.image;
                duration = 0.0f;
            }
        }else if (_topicModel.type ==1){
            if (!_isPicSuccess) {
                return;
            }
            image = _topicPicView.image;
            duration = 0.0;
        }else{
            
        }
        
        //获取点击的坐标
        CGPoint point = [tap locationInView:tap.view];
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentContentClick:topicModel:image:duration:type:point:)]) {
            [_topicDelegate topicCommentContentClick:nil topicModel:_topicModel image:image duration:duration type:2 point:point];
        }
    }else{
        [self showLoginView];
    }
}
//双击点赞
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap{
    //当点击 评论，咱，分享，更多时，如何主题还没有发表成功，就不让操作。
    if (![_topicModel isHasTopicid]) {
        return;
    }
    //当前用户被封号后，不可以点赞
    if (self.currentUserInfo.status == 2) {
        return;
    }
    if (_likeCountBtn.userInteractionEnabled == YES) {
        [self likeButtonClick];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
