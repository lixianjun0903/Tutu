//
//  HomeController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
#import "HomeController.h"
#import "UtilsMacro.h"
#import "TopicModel.h"
#import "ReleasePicViewController.h"
#import "releaseCommentViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSArray+Addition.h"
#import "UserInfo.h"
#import "UMSocial.h"
#import "UserDetailController.h"
#import "MyFriendViewController.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "LoginViewController.h"
#import "ShareTutuFriendsController.h"
#import "SVWebViewController.h"
#import "VPImageCropperViewController.h"
#import "AuthorizationGuideController.h"
#import "RecordViewController.h"
#import "BaseController+ScrollNavbar.h"
#import "UILabel+Additions.h"
#import "DownLoadManager.h"
#import "M13ProgressViewRing.h"
#import "PinYinForObjc.h"
#import "SameCityController.h"
#import "RCLetterListController.h"
#import "FeedsController.h"
#import "MyFriendViewController.h"
#import "ListTopicsController.h"
#import "SVWebViewController.h"
#import "FriendSearchController.h"

#import "UserViewController.h"
#import "NSDate+Helper.h"
#import "PhoneModelSetVController.h"
#import "RecommendFollowVController.h"
#import "MobClick.h"

#define FootViewHeigth           50.f
@interface HomeController ()
{
    //观看次数数组
    NSMutableDictionary *_viewsDic;
    
    //当前需要滚动的那个cell的索引
   
    NSTimer *animationTimer;
    
    //去进行评论的主题的索引
    //是不是第一次刷新
    BOOL isShow;
    NSInteger _displayDefault;
    

}
//用来缓存，用户发的主题
@property(nonatomic,strong)TopicCell *currentCell;
@property(nonatomic,strong)NSMutableArray *cacheTopicModels;
@property(nonatomic,strong)UIScrollView *mainScroll;
@property(nonatomic,strong)UIView *footView;
@property(nonatomic,strong)UIView *segmentView;
@property(nonatomic,strong)UserInfo *userInfo;
@property(nonatomic,strong)TopicViewController *hotController;
@property(nonatomic,strong)TopicViewController *friendController;
@end


@implementation HomeController
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (animationTimer) {
        animationTimer = nil;
    }
}
- (IBAction)buttonClick:(id)sender{
    NSInteger tag = ((UIButton *)sender).tag;
    if (![LoginManager getInstance].isLogin) {
       [[LoginManager getInstance]showLoginView:self];
    }else{
        if (tag == BACK_BUTTON) {
            [MobClick event:@"click_home_addfriend"];
            FriendSearchController *search=[[FriendSearchController alloc] init];
            [self openNav:search sound:@"open"];

        }else{
            [MobClick event:@"click_home_camera"];
            RecordViewController *vc = [[RecordViewController alloc]init];
            [self openNavWithSound:vc];
        }
    }
}

- (void)createSegmentView{
    NSArray *titles = @[TTLocalString(@"home_page_hot_title"),TTLocalString(@"home_page_follow_title"),];
    
    _displayDefault = 0;
    
    //_displayDefault = [UserDefaults integerForKey:UserDefaults_Home_Default_Display];
    
    _segmentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,120 * ScreenScale, 30)];
    _segmentView.center = CGPointMake(ScreenWidth / 2.f, 40);
    if (iOS7) {
      self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight )];
    [self.view addSubview:_mainScroll];
    [_mainScroll setContentSize:CGSizeMake(ScreenWidth * 2, _mainScroll.mj_height)];
    _mainScroll.showsHorizontalScrollIndicator = NO;
    [_mainScroll setContentOffset:CGPointMake(_displayDefault * ScreenWidth, 0)];
    _mainScroll.showsVerticalScrollIndicator = NO;
    _mainScroll.alwaysBounceHorizontal = NO;
    _mainScroll.alwaysBounceVertical = NO;
    _mainScroll.pagingEnabled = YES;
    _mainScroll.bounces = NO;
    _mainScroll.scrollEnabled = NO;
    _mainScroll.scrollsToTop = NO;

    [self.titleMenu addSubview:_segmentView];
    for (int i = 0; i < 2; i ++) {
        TopicViewController *controller = [[TopicViewController alloc]init];
        if (i == 0) {
            controller.topicType = TopicListTypeHot;
            controller.isVisible = YES;
        }else{
            controller.topicType = TopicListTypeFollow;
            controller.isVisible = NO;
        }
        controller.view.frame = CGRectMake(ScreenWidth * i, 0, ScreenWidth, _mainScroll.mj_height);
        controller.topicDelegate = self;
        

        [_mainScroll addSubview:controller.view];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(_segmentView.mj_width / 2.f * i, 0, _segmentView.mj_width / 2.f , 30);
        [btn setTitleColor:HEXCOLOR(0xFFFFFF) forState:UIControlStateDisabled];
        [btn setTitleColor:HEXCOLOR(0x259d7d) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(segmentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_segmentView addSubview:btn];
        
        if (i == 0) {
            _hotController = controller;
            UIImage *leftImage = [UIImage imageNamed:@"home_segment_L"];
            leftImage = [leftImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
            UIImage *leftImage_hl = [UIImage imageNamed:@"home_segment_L_hl"];
            leftImage_hl = [leftImage_hl resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
            [btn setBackgroundImage:leftImage forState:UIControlStateDisabled];
            [btn setBackgroundImage:leftImage_hl forState:UIControlStateNormal];
            
        }else{
            _friendController = controller;
            UIImage *rightImage = [UIImage imageNamed:@"home_segment_R"];
            rightImage = [rightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
            UIImage *rightImage_hl = [UIImage imageNamed:@"home_segment_R_hl"];
            rightImage_hl = [rightImage_hl resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
            [btn setBackgroundImage:rightImage forState:UIControlStateNormal];
            [btn setBackgroundImage:rightImage_hl forState:UIControlStateDisabled];
            
            _focusDotView=[[UIImageView alloc] initWithFrame:CGRectMake(_segmentView.mj_width/2-18, 5, 6, 6)];
            [_focusDotView setBackgroundColor:[UIColor redColor]];
            _focusDotView.layer.cornerRadius=3;
            _focusDotView.hidden = YES;
            _focusDotView.layer.masksToBounds=YES;
            [btn addSubview:_focusDotView];

        }
        if (_displayDefault == i) {
            [btn setEnabled:NO];
        }
    }
    if (_displayDefault == 0) {
        [_hotController.mainTable headerBeginRefreshing];
        _hotController.mainTable.scrollsToTop = YES;
        _friendController.mainTable.scrollsToTop = NO;
    }else{
        [_friendController.mainTable headerBeginRefreshing];
        _hotController.mainTable.scrollsToTop = NO;
    }
}
- (void)hidenSegmentViewAndFootView{
    [UIView animateWithDuration:0.2f animations:^{
        [_segmentView setAlpha:0];
        _footView.frame = CGRectMake(_footView.mj_x, _footView.mj_y + FootViewHeigth, _footView.mj_width, _footView.mj_height);
        self.menuTitleButton.alpha = 0;
    }];
}
- (void)showSegmentViewAndFootView{
    [UIView animateWithDuration:0.2f animations:^{
        [_segmentView setAlpha:1];
        _footView.frame = CGRectMake(_footView.mj_x, _footView.mj_y - FootViewHeigth, _footView.mj_width, _footView.mj_height);
        self.menuTitleButton.alpha = 1;
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _userInfo = [[LoginManager getInstance]getLoginInfo];
    
    
    
    [self createTitleMenu];
    [self.menuTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuTitleButton setTitle:@"" forState:UIControlStateNormal];
    
    [self.menuLeftButton setImage:[UIImage imageNamed:@"homepage_add_friend"] forState:UIControlStateNormal];
    [self.menuLeftButton setImage:[UIImage imageNamed:@"homepage_add_friend_hl"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImage:[UIImage imageNamed:@"homepage_camera"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"homepage_camera_hl"] forState:UIControlStateHighlighted];
    [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    [self.menuRightButton  setImageEdgeInsets:UIEdgeInsetsMake(10, 7, 9, 8)];

    
    //添加通知Observer
    [self addNotiticationObserver];
    
    //创建顶部按钮，点击后让tabel滚动到顶部。
    
    
    
    //创建segmentButton
    [self createSegmentView];
    
    
    
    
   //创建下面的footView;
   // [self createFootView];
   //让导航栏上滑时隐藏。
   // [self followScrollView:_mainScroll];
    
    //创建一个定时器，让评论头像滚动
   
    
    //用来存储主题播放的次数，然后上传给服务器
    
    _viewsDic = [[NSMutableDictionary alloc]init];
    
   [[SendLocalTools getInstance]synchronousLocalMessage];
    
   //开启拼音转中文字体库缓存
    [self bk_performBlockInBackground:^(id obj) {
        [PinYinForObjc chineseConvertToPinYin:@"开启缓存"];
    } afterDelay:3.f];
}

- (void)segmentButtonClick:(UIButton *)sender{
    
    if (![[LoginManager getInstance]isLogin] && sender.tag == 1) {
        [[LoginManager getInstance]showLoginView:self];
    }else{
        
        [[_segmentView subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *btn = (UIButton *)obj;
            [btn setEnabled:YES];
        }];
        [sender setEnabled:NO];
        _hotController.currentPlayCell = nil;
        _friendController.currentPlayCell = nil;
        
        _displayDefault = sender.tag;
        _hotController.isVisible = NO;
        _friendController.isVisible = NO;
        
        if (_displayDefault == 0) {
            _hotController.isVisible = YES;
            _hotController.mainTable.scrollsToTop = YES;
            _friendController.mainTable.scrollsToTop = NO;
        }else{
            _friendController.isVisible = YES;
            _hotController.mainTable.scrollsToTop = NO;
            _friendController.mainTable.scrollsToTop = YES;
        }
        
        [[AWEasyVideoPlayer sharePlayer]stop];
        [[AWEasyVideoPlayer sharePlayer]removeFromSuperview];
        
        [_mainScroll scrollRectToVisible:CGRectMake(ScreenWidth * _displayDefault,_mainScroll.mj_y, _mainScroll.mj_width, _mainScroll.mj_height) animated:YES];
        
        [self bk_performBlock:^(id obj) {
            if (_displayDefault == 0) {
                if (_hotController.dataArrayM.count == 0) {
                    [_hotController.mainTable headerBeginRefreshing];
                }else{
                    [_hotController getcurrentPlayCell];
                }
            }else{
                if (_friendController.dataArrayM.count == 0) {
                    [_friendController refreshData];
                }else{
                    [_friendController getcurrentPlayCell];
                }
                
                if ([[RequestTools getInstance] getNewfollowtopiccount]>0) {
                    [_friendController refreshData];
                }
            }
        } afterDelay:0.3f];
    }
    
    //[UserDefaults setInteger:_displayDefault forKey:UserDefaults_Home_Default_Display];
}
- (void)addNotiticationObserver{
    
    
    //监测消息数的变化

    [NOTIFICATION_CENTER addObserver:self selector:@selector(pauseTimer) name:Comment_Scroll_BeginDragging object:nil];
   // [NOTIFICATION_CENTER addObserver:self selector:@selector(topicSend:) name:Notification_Topic_Send object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(saveTopicViews:) name:Notification_Video_Play object:nil];
    
}
- (void)appEnterBackground:(NSNotification *)notifi{
    [self uploadVedioViews];
    _hotController.isVisible = NO;
    _friendController.isVisible = NO;
    _hotController.currentPlayCell = nil;
    _friendController.currentPlayCell = nil;
    isShow=NO;
}
- (void)appEnterForeground:(NSNotification *)notifi{
    NSArray *controllers = self.navigationController.viewControllers;
    
    if (controllers.count == 1) {
        if (_displayDefault == 0) {
            _hotController.isVisible = YES;
            [_hotController getcurrentPlayCell];
        }else{
            _friendController.isVisible = YES;
            [_friendController getcurrentPlayCell];
        }
        isShow = YES;
    }
}

//发送主题成功后，滑动到关注列表

- (void)topicScrollIndex:(NSInteger)index{
    if (_displayDefault != 1) {
        _displayDefault = 1;
        [[_segmentView subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *btn = (UIButton *)obj;
            [btn setEnabled:YES];
            if (btn.tag == 1) {
                [btn setEnabled:NO];
            }
        }];
        _friendController.isVisible = YES;
        _hotController.isVisible = NO;
        [_mainScroll scrollRectToVisible:CGRectMake(ScreenWidth * _displayDefault,_mainScroll.mj_y, _mainScroll.mj_width, _mainScroll.mj_height) animated:YES];
    }
}
//变更保存主题的观看次数
- (void)saveTopicViews:(NSNotification *)notification{
    if ([[notification object]isKindOfClass:[TopicModel class]]) {
        TopicModel *model = [notification object];
        int count = [_viewsDic[model.topicid] intValue];
        if (count > 0) {
            count ++;
        }else{
            count = 1;
        }
        [_viewsDic setValue:FormatString(@"%d", count) forKey:model.topicid];
    }
}

//上传视频的观看次数
- (void)uploadVedioViews{
    
    NSString *json = [_viewsDic JSONString];
    
    [[RequestTools getInstance]post:API_UPLOAD_VEDIO_VIEWS filePath:nil fileKey:nil params:[@{@"viewdata":json} mutableCopy]completion:^(NSDictionary *dict) {
    } failure:^(ASIFormDataRequest *request, NSString *message) {
        
    } finished:^(ASIFormDataRequest *request) {
        
    }];
}

#pragma mark Timer Stop ,Fire
//，当，评论条人为滑动时暂停几秒timer
- (void)pauseTimer{
    if (animationTimer) {
        [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL2]];
    }
}
- (void)stopTimer{
    [animationTimer invalidate];
    animationTimer = nil;
}
- (void)fireTimer{
    if (animationTimer && isShow == YES) {
        if (animationTimer) {
            [animationTimer invalidate];
            animationTimer = nil;
        }
    }
    animationTimer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(scrollCommentView) userInfo:nil repeats:YES];
    [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[NSRunLoop currentRunLoop]addTimer:animationTimer forMode:NSDefaultRunLoopMode];
    [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL]];

}

- (void)scrollCommentView{
    if (_displayDefault == 0) {
        if ([_hotController.currentPlayCell isKindOfClass:[TopicCell class]]) {
            [((TopicCell *)_hotController.currentPlayCell) scrollAvatarAndComment];
        }
    }else{
        if ([_friendController.currentPlayCell isKindOfClass:[TopicCell class]]) {
            [((TopicCell *)_friendController.currentPlayCell) scrollAvatarAndComment];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self stopTimer];
    isShow = NO;
    _hotController.isVisible = NO;
    _friendController.isVisible = NO;
    _hotController.currentPlayCell = nil;
    _friendController.currentPlayCell = nil;
    [[AWEasyVideoPlayer sharePlayer]stop];
    [[AWEasyVideoPlayer sharePlayer]removeFromSuperview];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self fireTimer];
    if([[RequestTools getInstance] getNewfollowtopiccount]>0){
        _focusDotView.hidden=NO;
    }else{
        _focusDotView.hidden=YES;
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_displayDefault == 0) {
        _hotController.isVisible = YES;
        [_hotController getcurrentPlayCell];
    }else{
        _friendController.isVisible = YES;
        [_friendController getcurrentPlayCell];
    }
    
    [self showNavBarAnimated:YES];
    isShow = YES;
    
}

#pragma mark LXActionSheetDelegatel

- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    
    if (buttonIndex == 0) {
        if ([SysTools isHasCaptureDeviceAuthorization]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }else{
            AuthorizationGuideController *vc = [[AuthorizationGuideController alloc]init];
            vc.authorizatonType = AuthorizationTypeCaptureDevice;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        }
    }else if(buttonIndex == 1){
        if ([SysTools isHasPhotoLibraryAuthorization]) {
            UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            //        imagePicker.allowsEditing = YES;
            if ([imagePicker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                [imagePicker.navigationBar setBarTintColor:UIColorFromRGB(SystemColor)];
                [imagePicker.navigationBar setTranslucent:YES];
                [imagePicker.navigationBar setTintColor:[UIColor whiteColor]];
                
            }else{
                [imagePicker.navigationBar setBackgroundColor:UIColorFromRGB(SystemColor)];
            }
            [imagePicker.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }else{
            AuthorizationGuideController *vc = [[AuthorizationGuideController alloc]init];
            vc.authorizatonType = AuthorizationTypePhotoLibrary;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        }
    }else if (buttonIndex == 2){
        
       // [_hotController.currentPlayCell stopVideo];
        RecordViewController *vc = [[RecordViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
              [self bk_performBlock:^(id obj) {

        } afterDelay:0.01];

    }
    else{

    }

}


#pragma mark  裁剪界面入口
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //UIImagePickerControllerEditedImage
    
        [picker dismissViewControllerAnimated:YES completion:^{
            
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        VPImageCropperViewController *_imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:image];
            _imgEditorVC.pcontroller=self;
        [self.navigationController pushViewController:_imgEditorVC animated:YES];
        image = nil;

    }];
    
}

#pragma mark
#pragma mark  TopicDelegate
//关注页面的位置，话题点击
- (void)topicLocationAndHuaTiClick:(NSString *)topicid{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicid = topicid;
    [self openNavWithSound:vc];
}
- (void)topicPhoneNameClick:(id)sender{
    PhoneModelSetVController *vc = [[PhoneModelSetVController alloc]init];
    [self openNavWithSound:vc];
//    RecommendFollowVController *vc = [[RecommendFollowVController alloc]init];
//    [self openNavWithSound:vc];
}
- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = topicModel.uid;
    vc.user = topicModel.userinfo;
    [self openNavWithSound:vc];
}
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel{
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.nickName=[name stringByReplacingOccurrencesOfString:@"@" withString:@""];
    [self openNav:detail sound:nil];
}
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=string;
    control.pageType=TopicWithDefault;
    [self openNav:control sound:nil];
}
- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=location;
    control.poiid=topicModel.poiId;
    control.pageType=TopicWithPoiPage;
    [self openNav:control sound:nil];
}
- (void)topicDetailClick:(TopicModel *)topicModel index:(NSInteger)index{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicModel = topicModel;
    vc.indexRow = index;
    vc.topicDelegate = self;
    vc.tableIndex = _displayDefault;
    [self openNavWithSound:vc];
}
//去详情页
- (void)topicCommentCountClick:(TopicModel *)topicModel{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicModel = topicModel;
    [self openNavWithSound:vc];
}

- (void)topicCommentAvatarClick:(CommentModel *)commentModel{
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.uid = commentModel.uid;
    [self openNav:detail sound:nil];
}
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint)commentPoint{
    ReleasePicViewController *vc=[[ReleasePicViewController alloc] init];
    vc.comeFrom = 0;
    vc.topicModel = topicModel;
    vc.pageType = type;
    vc.releaseImage = image;
    vc.commentModel = commentModel;
    vc.commentPoint=commentPoint;
    [self openNavWithSound:vc];
}
//转发的用户名称点击
- (void)topicReportUserNameClick:(NSString *)userID nickName:(NSString *)name{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = userID;
    [self openNavWithSound:vc];
}

//分享类型的按钮点击
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index{
    if (type == ActionSheetTypeTutu) {
        ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
        vc.uid = _userInfo.uid;
        vc.topicModel=topicModel;
        [self openNavWithSound:vc];
    }
    if (type == ActionSheetTypeCopyLink){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *shareUrl = FormatString(@"%@%@", SHARE_TOPIC_HOST,topicModel.topicid);
        [pasteboard setString:shareUrl];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:@"复制成功" duration:1.0];
        } afterDelay:.5];
    }
}

//在详情页面点赞后更新首页的数据
- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex isReload:(BOOL)isReload{
    if (tabelIndex == 0) {
        [_hotController.dataArrayM replaceObjectAtIndex:index withObject:model];
        
    }else{
        [_friendController.dataArrayM replaceObjectAtIndex:index withObject:model];
    }
}
- (void)topicHuaTiMoreClick:(TopicModel *)topicModel{
    SVWebViewController *vc = [[SVWebViewController alloc]initWithURL:StrToUrl(URL_HuaTi_GuangChang)];
    [self openNavWithSound:vc];
}
- (void)topicHuaTiClick:(TopicModel *)topicModel index:(NSInteger)index{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString = [topicModel.huatilist[index] huatitext];
    control.pageType=TopicWithDefault;
    [self openNav:control sound:nil];
}
- (void)topicThemeTitleOrLocationClick:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString = topicModel.idtext;
    control.pageType=TopicWithDefault;
    if (topicModel.poiId.length > 0 ) {
        control.pageType = TopicWithPoiPage;
        control.poiid = topicModel.poiId;
    }
    [self openNav:control sound:nil];
 
}

//- (void)savaTopicModel:(TopicModel *)model index:(NSInteger)index{
//    if (index < _dateArray.count) {
//        [_dateArray replaceObjectAtIndex:index withObject:model];
//    }
//}
//- (void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object{
//  NSInteger totalCount = [[RequestTools getInstance]getAllNewsNum];
//    if (totalCount > 0) {
//        [avatarDot setHidden:NO];
//    }else{
//        [avatarDot setHidden:YES];
//    }
//}


//#pragma mark  评论开始上传，/上传成功
//- (void)startPostComment:(CommentModel *)model{
//    NSString *topicID= model.topicid;
//    model.pointX = [NSString stringWithFormat:@"%f", [model.pointX floatValue] * SCREEN_WIDTH];
//    model.pointY = [NSString stringWithFormat:@"%f",[model.pointY floatValue] * SCREEN_WIDTH];
//    for (int i = 0; i < _dateArray.count; i ++) {
//       NSString * topic_id = ((TopicModel *)_dateArray[i]).topicid;
//        if ([topic_id isEqualToString:topicID]) {
//           
// //           TopicCell *cell = (TopicCell *)[self.currentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//            TopicModel *topicmodel = _dateArray[i];
//            if (topicmodel.commentList) {
//               [topicmodel.commentList addObject:model];
//            }else{
//                topicmodel.commentList = [NSMutableArray arrayWithObject:model];
//            }
//            
//            topicmodel.commentnum = [NSString stringWithFormat:@"%ld",(long)[topicmodel.commentnum integerValue] + 1];
//            [_dateArray replaceObjectAtIndex:i withObject:topicmodel];
//            [self bk_performBlock:^(id obj) {
//             //   [cell insertCommentWithTopicModel:topicmodel];
//            } afterDelay:0.1f];
//            
//            break;
//        }
//    }
//}
//- (void)successPostComment:(NSDictionary *)dict{
//    
//    NSString *topic_id = nil;
//    if ([dict[@"code"]integerValue] == 10000) {
//        NSArray *arr = dict[@"data"][@"commentlist"];
//        NSString * count = CheckNilValue(dict[@"data"][@"total"]);
//        NSString *topicID= CheckNilValue(dict[@"data"][@"topicid"]);
//        for (int i = 0; i < _dateArray.count; i ++) {
//            topic_id = ((TopicModel *)_dateArray[i]).topicid;
//            if ([topic_id isEqualToString:topicID]) {
//                NSArray *models = [CommentModel getCommentModelList:arr];
//      //          TopicCell *cell = (TopicCell *)[self.currentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//                TopicModel *model = _dateArray[i];
//                
//                CommentModel *lastModel = [model.commentList lastObject];
//                BOOL isSuccess = NO;
//                for (int i = 0; i < models.count; i ++) {
//                    CommentModel *newModel = models[i];
//                    if ([newModel.localid isEqualToString:lastModel.localid]) {
//                        [model.commentList replaceObjectAtIndex:model.commentList.count - 1 withObject:newModel];
//                        isSuccess = YES;
//                        break;
//                    }
//                }
//                if (!isSuccess) {
//                    return;
//                }
//                model.commentnum = count;
//    //            cell.topicModel = model;
//                [_dateArray replaceObjectAtIndex:i withObject:model];
//                break;
//            }
//        }
//        
//    }
// 
//}


//- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
//{
//    // This enables the user to scroll down the navbar by tapping the status bar.
//    [self showNavBarAnimated:YES];
//    if (scrollView == self.currentTable) {
//        return YES;
//    }else
//        return NO;
//}

//// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//}
////滑动停止
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    if (scrollView == _mainScroll) {
//        CGFloat offsetx = scrollView.contentOffset.x;
//        if (offsetx == 0) {
//            _displayDefault = 0;
//        }else{
//            _displayDefault = 1;
//        }
//        
//        [[_segmentView subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            UIButton *btn = (UIButton *)obj;
//            if (btn.tag == _displayDefault) {
//                [btn setEnabled:NO];
//            }else{
//                [btn setEnabled:YES];
//            }
//        }];
//        
//    }
//}
//// 滚动停止时，触发该函数
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView == _hotTable) {
//       [self currentVisibleTableCell];
//    }else if (scrollView == _friendTable){
//        [self currentVisibleTableCell];
//    }else{
//    
//    }
//}
//


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
