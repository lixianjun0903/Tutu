//
//  ListTopicsController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-13.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ListTopicsController.h"
#import "FocusUserController.h"
#import "ShareTutuFriendsController.h"
#import "UMSocial.h"
#import "SDWebImageManager.h"
#import "UIImage+Category.h"
#import "UserDetailController.h"

#import "TopicCell.h"
#define headerCell @"FocusHeaderCell"
#define cellIdentifier @"TopicCell"


@interface ListTopicsController (){
    CGFloat w;
    CGFloat h;
    
    //1最热 2最新
    int showType;
    
    UIButton *hotBtn;
    UIButton *newsBtn;
    UIImageView *viewMenuLine;
    UIView *menuHeaderView;
    
    //上次偏移量
    CGPoint *hotPoint;
    CGPoint *newsPoint;
    CGRect focusRect;
    
    FocusTopicModel *focusModel;
    
    FocusHeaderCell *focusCell;
    
    UIScrollView *_mainScroll;
    TopicsGeneralController *hotController;
    TopicsGeneralController *newController;
    
    TopicModel *shareModel;
    
    BOOL isChangeFocus;
    BOOL isGoBack;
}

@end

@implementation ListTopicsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.topicString && [self.topicString hasSuffix:@" "]){
        self.topicString=[self.topicString substringToIndex:self.topicString.length-1];
    }
    
    if(self.pageType==TopicWithDefault){
        self.topicString=[self.topicString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStateChanged:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationStateChanged:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self initMainView];
    
    // 在代理里面解析头部数据
    if(self.startid!=nil){
        [self initDefaultData:2];
    }else{
        [self initDefaultData:1];
    }
    
    isGoBack=NO;
}

//应用进入后台、从后台进入前台，分享时遇到
-(void)applicationStateChanged:(NSNotification *)noticification{
    if([UIApplicationDidEnterBackgroundNotification isEqual:noticification.name]){
        [self viewDidDisappear:YES];
    }else if([UIApplicationDidBecomeActiveNotification isEqual:noticification.name]){
        [self viewWillAppear:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!hotController.isVisible && !newController.isVisible){
        if(showType==1){
            hotController.isVisible=YES;
        }else{
            newController.isVisible=YES;
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if(!isGoBack){
        hotController.isVisible=NO;
        newController.isVisible=NO;
        
//        [hotController setDataToView:[@[] mutableCopy]];
//        [newController setDataToView:[@[] mutableCopy]];
        
        hotController.currentPlayCell=nil;
        newController.currentPlayCell=nil;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 滚动时显示隐藏menu
-(void)generalScrollDid:(UIScrollView *)scrollView type:(int)type{
    if(type==showType){
        CGPoint p=scrollView.contentOffset;
        CGRect newFocusFrame=focusRect;
        newFocusFrame.origin.y=NavBarHeight-p.y;
        [focusCell setFrame:newFocusFrame];
        
        if(p.y>=100){
            menuHeaderView.hidden=NO;
        }else{
            menuHeaderView.hidden=YES;
        }
    }
}


-(void)loadDataByNet:(FocusTopicModel *)model{
    if(model!=nil && model.ids!=nil){
        focusModel=model;
        
        if(self.pageType==TopicWithPoiPage){
            self.topicString=focusModel.idtext;
            if(self.topicString && [self.topicString hasSuffix:@" "]){
                self.topicString=[self.topicString substringToIndex:self.topicString.length-1];
            }
            if(self.pageType==TopicWithDefault){
                [self.menuTitleButton setTitle:[NSString stringWithFormat:@"#%@",self.topicString] forState:UIControlStateNormal];
            }else{
                [self.menuTitleButton setTitle:self.topicString forState:UIControlStateNormal];
            }
        }
        
        [focusCell dataToView:focusModel tableWidth:w];
    }
}


-(void)openNewController:(UIViewController *)controller{
    [self openNav:controller sound:nil];
}



-(void)doFocus{
    NSString *api=@"";
    if(focusModel==nil){
        return;
    }
    
    if(isChangeFocus){
        return;
    }
    isChangeFocus=YES;
    
    if(self.pageType==TopicWithDefault){
        if(focusModel.isfollow){
            api=API_DEL_TOPIC_FOCUS(focusModel.ids);
        }else{
            api=API_ADD_TOPIC_FOCUS(focusModel.ids);
        }
    }else if (self.pageType==TopicWithPoiPage){
        if(focusModel.isfollow){
            api=API_DEL_POI_FOCUS(focusModel.ids);
        }else{
            api=API_ADD_POI_FOCUS(focusModel.ids);
        }
    }
    
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        if(!focusModel.isfollow){
            NSMutableArray *arr = focusModel.userlist;
            if(arr==nil){
                arr=[[NSMutableArray alloc] init];
            }else{
                if(arr.count>5){
                    [arr removeObjectAtIndex:4];
                }
            }
            
            [arr insertObject:[[LoginManager getInstance] getLoginInfo] atIndex:0];
            focusModel.usercount=focusModel.usercount+1;
            focusModel.userlist=arr;
        }else{
            NSMutableArray *arr = focusModel.userlist;
            UserInfo *removeUser=nil;
            if(arr!=nil && arr.count>0){
                for (UserInfo *item in arr) {
                    if([item.uid isEqual:[[LoginManager getInstance] getUid]]){
                        removeUser=item;
                    }
                }
            }
            if(removeUser!=nil){
                [arr removeObject:removeUser];
                focusModel.userlist=arr;
            }
            focusModel.usercount=focusModel.usercount-1;
        }
        focusModel.isfollow=!focusModel.isfollow;
        [focusCell dataToView:focusModel tableWidth:w];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        isChangeFocus=NO;
    }];
}



#pragma mark header 点击
-(void)itemClick:(FocusTypeTag)tag{
    if(![self isLogin]){
        [[LoginManager getInstance]showLoginView:self];
    }
//    WSLog(@"当前点击了：%d",tag);
    // 关注
    if(tag==FocusClickTag){
        if(focusModel==nil){
            return;
        }
        [self doFocus];
    }
    
    // 查看关注的人
    if(tag==FocusNumClickTag){
        if(focusModel==nil){
            return;
        }
        
        FocusUserController *focusController = [[FocusUserController alloc] init];
        focusController.abouttype=AboutFocusType;
        focusController.usernum=[NSString stringWithFormat:@"%d",focusModel.usercount];
        if(self.pageType==TopicWithDefault){
            focusController.apiString=API_GET_TopicFOCUS_USER_LIST(focusModel.ids,@"20");
        }else{
            focusController.apiString=API_GET_PoiFOCUS_USER_LIST(focusModel.ids, @"20");
        }
        [self openNav:focusController sound:nil];
    }
    
    if(tag==HotTag){
        showType=1;
        [self checkMenuStyle];
    }
    if(tag==NewsTag){
        showType=2;
        [self checkMenuStyle];
    }
}

-(void)itemUserClick:(UserInfo *)model{
    if(model){
        UserDetailController *userController=[[UserDetailController alloc] init];
        userController.uid=model.uid;
        [self openNav:userController sound:nil];
    }
}


#pragma mark 点击事件
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        isGoBack=YES;
        
        hotController.isVisible=NO;
        newController.isVisible=NO;
        
        [hotController setDataToView:[@[] mutableCopy]];
        [newController setDataToView:[@[] mutableCopy]];
        
        
        hotController.currentPlayCell=nil;
        newController.currentPlayCell=nil;
        
        if (_comefrom == 1) {
            //进入首页
            UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }else{
            [self goBack:nil];
        }
    }
    
    //分享
    if(sender.tag==RIGHT_BUTTON){
        shareModel=nil;
        if(showType==1 && hotController.array.count>0){
            shareModel=[hotController.array objectAtIndex:0];
            focusModel.topiclist=hotController.array;
        }
        if(showType==2 && newController.array.count>0){
            shareModel=[newController.array objectAtIndex:0];
            focusModel.topiclist=newController.array;
        }
        ShareActonSheet *sheet = [ShareActonSheet instancedSheetWith:shareModel type:ActionSheetButtonTypeReportAndCopy];
        sheet.delegate = self;
        [sheet showInWindow];
    }
    
    //最热
    if(sender.tag==DOWN_BTNTAG1){
        showType=1;
        [self checkMenuStyle];
    }
    
    //最新
    if(sender.tag==DOWN_BTNTAG2){
        showType=2;
        [self checkMenuStyle];
    }
}

-(void)shareActionSheetButtonClick:(NSInteger)index{
    if(shareModel==nil){
        return;
    }
    
    NSString *shareURL=[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@",SHARE_TOPIC_HOST],shareModel.topicid];
    if(index<=5){
        if (index == ActionSheetTypeTutu) {
            if ([[LoginManager getInstance]isLogin]) {
                ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
                vc.uid = [LoginManager getInstance].getUid;
                focusModel.topicModel=shareModel;
                vc.focusModel=focusModel;
                vc.focusType=self.pageType;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [[LoginManager getInstance]showLoginView:self];
            }
        }else{
            //        NSString *shareTitle=self.topicString;
            NSString *shareText = shareModel.topicDesc;
            NSString *shareTitle = WebCopy_ShareTitle(shareModel.nickname);
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
            [UMSocialData defaultData].extConfig.qqData.url = shareURL;
            [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
            [UMSocialData defaultData].extConfig.sinaData.urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:shareURL];
            BOOL hasDesc=![@"" isEqual:shareModel.topicDesc];
            
            
            NSArray *types=@[UMShareToWechatSession];
            switch (index) {
                case ActionSheetTypeWXFriend:
                    shareText = hasDesc?shareModel.topicDesc : [NSString stringWithFormat:@"%@的主题",shareModel.nickname];
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    types=@[UMShareToWechatSession];
                    break;
                    
                case ActionSheetTypeWXSection:
                    types=@[UMShareToWechatTimeline];
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    shareText =hasDesc?shareModel.topicDesc : WebCopy_ShareWeixinTimelineDesc;
                    break;
                case ActionSheetTypeQQ:
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    shareText =hasDesc?shareModel.topicDesc : WebCopy_ShareQQDesc;
                    types=@[UMShareToQQ];
                    break;
                case ActionSheetTypeQQZone:
                    types=@[UMShareToQzone];
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    shareText =hasDesc?shareModel.topicDesc : WebCopy_ShareZoneDesc;
                    break;
                case ActionSheetTypeSina:
                    types=@[UMShareToSina];
                    //添加视频地址
                    if(shareModel!=nil && shareModel.type==5){
                        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:shareModel.videourl];
                    }else{
                        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:shareModel.sourcepath];
                    }
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    shareText = hasDesc?shareModel.topicDesc : [NSString stringWithFormat:@"%@ %@",WebCopy_ShareSinaDesc,shareURL];
                    break;
                    
                default:
                    break;
            }
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            
            [manager downloadImageWithURL:[NSURL URLWithString:shareModel.sourcepath] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                UMSocialUrlResource *resourece = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:shareModel.sourcepath];
                
                image = [image imageWithWaterMask:[UIImage imageNamed:@"watermark"] inRect:CGRectZero];
                
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:types content:shareText image:image location:nil urlResource:resourece presentedController:self completion:^(UMSocialResponseEntity *response){
                    //            WSLog(@"分享状态：%@，返回数据：%@",response.message,response.data);
                    if (response.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"分享成功！");
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_success") duration:1];
                    }else{
                        // Todo
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_faild") duration:1];
                    }
                    
                }];
                
            }];
        }
    }else{
        if(index==ActionSheetTypeCopyLink){
            [[UIPasteboard generalPasteboard] setString:shareURL];
            [self showNoticeWithMessage:TTLocalString(@"TT_copy_success") message:nil bgColor:TopNotice_Block_Color];
        }
        //举报
        if(index==ActionSheetTypeBlock){
            NSString *reportType=@"ht";
            if(self.pageType==TopicWithPoiPage){
                reportType=@"poi";
            }
            [[RequestTools getInstance] get:API_Report_POIORHT(reportType,focusModel.ids) isCache:NO completion:^(NSDictionary *dict) {
                
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
        }
    }
}



-(void)checkMenuStyle{
    //固定menu样式切换
    [focusCell checkMenuStyle:showType];
    
    CGPoint p=CGPointZero;
    if(showType==1){
        p=[hotController currentContentOffset];
        
        CGRect lineF=viewMenuLine.frame;
        lineF.origin.x=hotBtn.frame.origin.x;
        viewMenuLine.frame=lineF;
        
        [hotBtn setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [newsBtn setTitleColor:UIColorFromRGB(TextSixColor) forState:UIControlStateNormal];
        
        [_mainScroll scrollRectToVisible:CGRectMake(0,_mainScroll.mj_y, _mainScroll.mj_width, _mainScroll.mj_height) animated:YES];
        
        newController.isVisible=NO;
        hotController.isVisible=YES;
        
        
        if(hotController.array==nil || hotController.array.count==0){
            [hotController refreshData];
        }
        
    }else if(showType==2){
        
        p=[newController currentContentOffset];
        
        CGRect lineF=viewMenuLine.frame;
        lineF.origin.x=newsBtn.frame.origin.x;
        viewMenuLine.frame=lineF;
        
        [newsBtn setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [hotBtn setTitleColor:UIColorFromRGB(TextSixColor) forState:UIControlStateNormal];
        
        
        hotController.isVisible=NO;
        newController.isVisible=YES;
        
        [_mainScroll scrollRectToVisible:CGRectMake(w,_mainScroll.mj_y, _mainScroll.mj_width, _mainScroll.mj_height) animated:YES];
        
        if(newController.array==nil || newController.array.count==0){
            [newController refreshData];
        }
        
    }
    
    CGRect newFocusFrame=focusRect;
    newFocusFrame.origin.y=NavBarHeight-p.y;
    [focusCell setFrame:newFocusFrame];
    if(p.y>=100){
        menuHeaderView.hidden=NO;
    }else{
        menuHeaderView.hidden=YES;
    }
}


-(void)initMainView{
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    //设置视图到顶部
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    CGFloat scrollHeight=h-NavBarHeight;
    _mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NavBarHeight, w, scrollHeight)];
    [_mainScroll setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_mainScroll];
    
    [_mainScroll setContentSize:CGSizeMake(ScreenWidth * 2, scrollHeight)];
    _mainScroll.showsHorizontalScrollIndicator = NO;
    _mainScroll.showsVerticalScrollIndicator = NO;
    _mainScroll.alwaysBounceHorizontal = NO;
    _mainScroll.alwaysBounceVertical = NO;
    _mainScroll.pagingEnabled = YES;
    _mainScroll.bounces = NO;
    _mainScroll.scrollEnabled = NO;
    
    hotController=[[TopicsGeneralController alloc] init];
    hotController.view.frame =CGRectMake(0, 0, w, scrollHeight);
    [_mainScroll addSubview:hotController.view];
    
    hotController.delegate=self;
    hotController.pageType=self.pageType;
    hotController.showType=1;
    hotController.topicString=self.topicString;
    if(self.pageType==TopicWithDefault){
        hotController.topicString=[self.topicString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }else{
        hotController.topicString=self.poiid;
    }
    
    newController=[[TopicsGeneralController alloc] init];
    newController.view.frame =CGRectMake(w, 0, w, scrollHeight);
    [_mainScroll addSubview:newController.view];
    
    newController.delegate=self;
    newController.pageType=self.pageType;
    newController.showType=2;
    newController.topicString=self.topicString;
    newController.startid=self.startid;
    if(self.pageType==TopicWithDefault){
        newController.topicString=[self.topicString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }else{
        newController.topicString=self.poiid;
    }
    
    //头部信息
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:headerCell owner:nil options:nil];
    focusCell=[nibView objectAtIndex:0];
    focusCell.delegate=self;
    [focusCell initView:w];
    
    focusRect=CGRectMake(0, NavBarHeight, w, 140);
    [focusCell setFrame:focusRect];
    [self.view addSubview:focusCell];
    
    // 悬浮的menu
    menuHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, NavBarHeight, w, 40)];
    [menuHeaderView setBackgroundColor:[UIColor whiteColor]];
    
    hotBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [hotBtn setFrame:CGRectMake(0, 0, w/2, 40)];
    hotBtn.tag=DOWN_BTNTAG1;
    [hotBtn setTitle:TTLocalString(@"TT_hotest") forState:UIControlStateNormal];
    hotBtn.userInteractionEnabled=YES;
    [hotBtn.titleLabel setFont:ListTitleFont];
    [hotBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuHeaderView addSubview:hotBtn];
    
    viewMenuLine=[[UIImageView alloc] initWithFrame:CGRectMake(0, 38, w/2, 2)];
    [viewMenuLine setBackgroundColor:UIColorFromRGB(SystemColor)];
    [menuHeaderView addSubview:viewMenuLine];
    
    newsBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    newsBtn.tag=DOWN_BTNTAG2;
    [newsBtn setFrame:CGRectMake(w/2, 0, w/2, 40)];
    [newsBtn setTitle:TTLocalString(@"TT_newest") forState:UIControlStateNormal];
    newsBtn.userInteractionEnabled=YES;
    [newsBtn.titleLabel setFont:ListTitleFont];
    [newsBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [menuHeaderView addSubview:newsBtn];
    [self.view addSubview:menuHeaderView];
    [menuHeaderView setHidden:YES];
    
    UIImageView *lineView=[[UIImageView alloc] initWithFrame:CGRectMake(w/2-0.5, 10, 1, 20)];
    [lineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [menuHeaderView addSubview:lineView];
    
    
    //必须放在最后，否则无法覆盖
    [self createTitleMenu];
    [self.menuRightButton setImage:[UIImage imageNamed:@"share_white"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"share_white_sel"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(10.5, 9, 10.5,9)];
}

-(void)initDefaultData:(int) type{
    showType=type;
    if(self.pageType==TopicWithDefault){
        [self.menuTitleButton setTitle:[NSString stringWithFormat:@"#%@",self.topicString] forState:UIControlStateNormal];
    }else{
        [self.menuTitleButton setTitle:self.topicString forState:UIControlStateNormal];
    }
    
    
    [self checkMenuStyle];
}





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
