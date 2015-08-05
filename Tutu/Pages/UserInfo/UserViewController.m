//
//  UserViewController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserViewController.h"
#import "DropsOfWaterView.h"
#import "SynchMarkDB.h"
#import "UIView+Border.h"

#define staticUserHeaderView @"UserHeaderView"


@interface UserViewController (){
    CGFloat w;
    CGFloat h;
    CGPoint beginLocation;
    CGPoint listPoint;
    
    BOOL isSelf;
    
    CGFloat headerHeight;
    UserHeaderView *headerView;
    
    UIView *footerMenuView;
    
    
    UIImageView *dropWaterView;
    DropsOfWaterView *dView;
    UIScrollView *_mainScroll;
    
    
    InfoTopicListController *sendController;
    InfoTopicListController *favController;
    UserFocusController *focusController;
    
    CGFloat FooterMuenuHeight;
    
    
    int dataType;
    
    
}

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    dataType=1;
    
    
    //自己
    if([[self getUID] isEqual:self.uid] || [[self getLoginUser].nickname isEqual:self.nickname]){
        isSelf=YES;
        [_mainScroll setContentSize:CGSizeMake(w*3, h)];
    }else{
        isSelf=NO;
        [_mainScroll setContentSize:CGSizeMake(w*2, h)];
    }
    
    _mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [_mainScroll setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_mainScroll];

    
    
    dropWaterView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_default_cover"]];
    [dropWaterView setFrame:CGRectMake(0, 250-w,w,w)];
    [dropWaterView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:dropWaterView];
    dView=[DropsOfWaterView new];
    [dView stretchHeaderForTableView:w withView:dropWaterView];
    
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:staticUserHeaderView owner:headerView options:nil];
    headerView=[nibView objectAtIndex:0];
    headerView.delegate=self;
    [headerView setBackgroundColor:[UIColor clearColor]];
    [headerView setFrame:CGRectMake(0, 0, w, headerHeight)];
    [self.view addSubview:headerView];
    
    _mainScroll.showsHorizontalScrollIndicator = NO;
    _mainScroll.showsVerticalScrollIndicator = NO;
    _mainScroll.alwaysBounceHorizontal = NO;
    _mainScroll.alwaysBounceVertical = NO;
    _mainScroll.pagingEnabled = YES;
    _mainScroll.bounces = NO;
    _mainScroll.scrollEnabled = NO;
    
    
    sendController=[[InfoTopicListController alloc] init];
    [sendController.view setBackgroundColor:[UIColor clearColor]];
    focusController =[[UserFocusController alloc] init];
    [focusController.view setBackgroundColor:[UIColor clearColor]];
    
    sendController.view.frame=CGRectMake(0, 0, w, h);
    sendController.delegate=self;
    sendController.uid=self.uid;
    sendController.nickname=self.nickname;
    sendController.user=self.user;
    [_mainScroll addSubview:sendController.view];
    if(isSelf){
        favController=[[InfoTopicListController alloc] init];
        [favController.view setBackgroundColor:[UIColor clearColor]];
        favController.delegate=self;
        favController.uid=self.uid;
        favController.nickname=self.nickname;
        favController.user=self.user;
        favController.view.frame=CGRectMake(w, 0, w, h);
        focusController.view.frame=CGRectMake(w*2, 0, w, h);
        focusController.delegate=self;
        focusController.uid=self.uid;
        [_mainScroll addSubview:favController.view];
        [_mainScroll addSubview:focusController.view];
    }else{
        focusController.view.frame=CGRectMake(w, 0, w, h);
        [_mainScroll addSubview:focusController.view];
    }
    
    [self createMenuButtonView];
    
    if(isSelf)
    {
        [self synchUserInfoData];
    }
    
    
    
    if(self.user){
        headerHeight=[headerView dataToView:self.user isSelf:isSelf width:w];
    }
    
}


-(void)createMenuButtonView{
    int statusBarHeight=0;
    if (!iOS7) {
        statusBarHeight=20;
        // support full screen on iOS 6
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    
    [self createTitleMenu];
    [self.titleMenu setBackgroundColor:[UIColor clearColor]];
    [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(12, 8, 12, 24)];
    [self.menuLeftButton setImage:[UIImage imageNamed:@"user_back_nor"] forState:UIControlStateNormal];
    [self.menuLeftButton setImage:[UIImage imageNamed:@"user_back_sel"] forState:UIControlStateHighlighted];
    [self.menuLeftButton setBackgroundColor:[UIColor clearColor]];
    [self.menuRightButton setBackgroundColor:[UIColor clearColor]];

    //设置视图到顶部
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    //个人去设置
    if(isSelf){
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_setting_nor"] forState:UIControlStateNormal];
        self.menuRightButton.tag=OTHER_BUTTON;
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_setting_sel"] forState:UIControlStateHighlighted];
        [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-24/2, 22-23/2, 22-24/2, 22-23/2)];
        FooterMuenuHeight=0;
    }else{
        FooterMuenuHeight=50;
        //他人去好友列表
        self.menuRightButton.tag=OTHER_BUTTON;
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_more_nor"] forState:UIControlStateNormal];
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_more_sel"] forState:UIControlStateHighlighted];
        [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-4, 22-25/2, 22-4,22-25/2)];
        
        
        footerMenuView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.mj_height-statusBarHeight-50, self.view.mj_width, 50)];
        //        [footerMenuView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
        [footerMenuView setBackgroundColor:UIColorFromRGB(SystemColor)];
        footerMenuView.alpha=0.96;
        [self.view addSubview:footerMenuView];
        
        
        UIButton *btnMenu1=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnMenu1 setFrame:CGRectMake(0, 0, w, 50)];
        [btnMenu1 setBackgroundColor:UIColorFromRGB(SystemColor)];
        btnMenu1.tag=1;
//        [btnMenu1 addTarget:self action:@selector(otherPeopleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnMenu1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnMenu1.titleLabel setFont:ListTitleFont];
        [btnMenu1 setBackgroundColor:[UIColor clearColor]];
        [btnMenu1 setImageEdgeInsets:UIEdgeInsetsMake(14, w/2-40, 14, w/2+17)];
        [btnMenu1 addRightBorderWithColor:UIColorFromRGB(UserInfoBottomLineColor) andWidth:0.75];
        [footerMenuView addSubview:btnMenu1];
        
        // 0 没有关系 2我添加对方了
        if(self.user!=nil && ![@"" isEqual:CheckNilValue(self.user.relation)]){
            if([self.user.relation intValue]==0 || [self.user.relation intValue]==2 || [self.user.relation intValue]==6){
                [btnMenu1 setTitle:TTLocalString(@"TT_add_friends") forState:UIControlStateNormal];
                [btnMenu1 setImage:[UIImage imageNamed:@"friend_add"] forState:UIControlStateNormal];
                [btnMenu1 setImage:[UIImage imageNamed:@"friend_add_hl"] forState:UIControlStateHighlighted];
            }else if([self.user.relation intValue]==1){
                //对方添加我了
                [btnMenu1 setTitle:TTLocalString(@"TT_verification_by") forState:UIControlStateNormal];
                [btnMenu1 setImage:[UIImage imageNamed:@"agree_friend"] forState:UIControlStateNormal];
                [btnMenu1 setImage:[UIImage imageNamed:@"agree_friend_sel"] forState:UIControlStateHighlighted];
            }else{
                [btnMenu1 setTitle:TTLocalString(@"TT_send_message") forState:UIControlStateNormal];
                [btnMenu1 setImage:[UIImage imageNamed:@"chat_button"] forState:UIControlStateNormal];
                [btnMenu1 setImage:[UIImage imageNamed:@"chat_button_sel"] forState:UIControlStateHighlighted];
            }
        }
        footerMenuView.hidden=YES;
    }
    
    //添加左右切换手势
//    [self addSwipeGesture];
    
//    if([self.uid isEqual:[LoginManager getInstance].getUid]){
//        //消息增加
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_MESSAGE object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUserInfoData) name:CHANGEUSERINFO object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoverNotice:) name:NOTICE_UPDATE_COVER object:nil];
//    }else{
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserNick:) name:NOTICE_UPDATE_UserInfo object:nil];
//    }
//    
//    //动态增加
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDCOMMENT object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDFRIEND object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:NOTICE_DELADDFRIEND object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDZAN object:nil];
}



#pragma 加载数据
-(void)synchUserInfoData{
    if(self.user==nil || self.user.uid==nil || [@"" isEqual:self.user.uid] || [@"" isEqual:CheckNilValue(self.user.nickname)]){
        //        WSLog(@"%@",api);
        self.user=[[LoginManager getInstance] getLoginInfo];
        if(self.user){
            [self loadSelfLocalData];
            [self parseUserInfoData:self.user];
        }else{
            [dropWaterView setImage:[UIImage imageNamed:@"user_default_cover"]];
        }
    }
    
    [self loadMoreData];
    
    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    NSString *time=[db findWidthUID:SynchMarkTypeUserInfo];
    
    NSString *api=[NSString stringWithFormat:@"%@?localupdatetime=%@",API_GET_SELFINFO,time];
    
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        //        WSLog(@"%@",dict);
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            NSDictionary *item=[dict objectForKey:@"data"];
            NSDictionary *userinfoDict = dict[@"data"][@"userinfo"];
            if(userinfoDict==nil || [userinfoDict isKindOfClass:[NSArray class]]){
                return ;
            }
            UserInfo *dictUser=[[LoginManager getInstance] parseDictData:userinfoDict];
            if(dictUser!=nil && dictUser.uid!=nil){
                [[LoginManager getInstance] saveInfoToDB:dictUser];
                
                [self parseUserInfoData:dictUser];
                
                //保存更新时间
                NSString *time=[item objectForKey:@"updatetime"];
                [db saveSynchData:SynchMarkTypeUserInfo withTime:time];
                
                [[RequestTools getInstance] doSetNewtipscount:self.user.newtipscount];
                
                [[NoticeTools getInstance] postClearMessageRead];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
    
}

//读取本地数据
-(void)loadSelfLocalData{
    TopicCacheDB *db=[[TopicCacheDB alloc] init];
    NSMutableArray *favModels=[db getCacheListWithType:TopicStatusCollection];
    NSMutableArray *sendModels=[db getCacheListWithType:TopicStatusSend];
    
    if(favModels && favModels.count>0){
        [favController setLocalData:favModels];
        if(self.user.favnum==0){
            self.user.favnum=(int)favModels.count;
        }
    }
    
    if(sendModels && sendModels.count>0){
        [sendController setLocalData:sendModels];
        if(self.user.topicnum==0){
            self.user.topicnum=(int)sendModels.count;
        }
    }
}

-(void)parseUserInfoData:(UserInfo *) user{
    self.user=user;
    headerHeight = [headerView dataToView:user isSelf:isSelf width:w];
    
    [sendController setTitleHeight:headerHeight];
    [favController setTitleHeight:headerHeight];
    [focusController setTableHeaderHeight:headerHeight];
}


#pragma mark 本页事件
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}


#pragma mark 下拉效果
-(void)focusScrollViewDidView:(UIScrollView *)focusScrollView{
    CGPoint p=focusScrollView.contentOffset;
    
    CGRect newFocusFrame=headerView.frame;
    newFocusFrame.origin.y=-p.y;
    [headerView setFrame:newFocusFrame];
    
    
    [dView scrollViewDidScroll:focusScrollView];
}

-(void)topicScrollDidView:(UIScrollView *)topicScrollView{
    CGPoint p=topicScrollView.contentOffset;
    
    CGRect newFocusFrame=headerView.frame;
    newFocusFrame.origin.y=-p.y;
    [headerView setFrame:newFocusFrame];
    
    [dView scrollViewDidScroll:topicScrollView];
}
-(void)openController:(UIViewController *)controller{
    [self openNav:controller sound:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    beginLocation = [touch locationInView:self.view];
    if(dataType==1){
        listPoint=sendController.listCollectionView.contentOffset;
    }else if(dataType==2){
        listPoint=favController.listCollectionView.contentOffset;
    }else if(dataType==3){
        listPoint=focusController.listTable.contentOffset;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];
    CGFloat y=beginLocation.y-currentPosition.y;
    
    [self resetContentOffSet:CGPointMake(0, listPoint.y + y)];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];
    CGFloat y=beginLocation.y-currentPosition.y;
    if(y<0){
        [self resetContentOffSet:CGPointMake(0, 0)];
        [dView resizeView];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];
    CGFloat y=beginLocation.y-currentPosition.y;
    if(y<0){
        [self resetContentOffSet:CGPointMake(0, 0)];
        [dView resizeView];
    }
}

-(void)resetContentOffSet:(CGPoint )p{
    if(dataType==1){
        [sendController.listCollectionView setContentOffset:p animated:NO];
    }else if(dataType==2){
        [favController.listCollectionView setContentOffset:p animated:NO];
    }else if(dataType==3){
        [focusController.listTable setContentOffset:p animated:NO];
    }
}

// 重置
-(void)viewDidLayoutSubviews{
//    [dView resizeView];
}


#pragma mark header 代理
-(void)itemClick:(UserViewHeaderClickTag)tag{
    WSLog(@"当前点击了：%d",tag);
    
    
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
