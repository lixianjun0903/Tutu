//

//  UserDetailController.m

//  Tutu

//

//  Created by zhangxinyao on 15-1-26.

//  Copyright (c) 2015年 zxy. All rights reserved.

//



#import "UserDetailController.h"
#define cellIdentifier @"UserInfoCell"
#define cellHeaderIdentifier @"UserHeaderCell"


#import "CoverListController.h"
#import "UIView+Border.h"
#import "SameCityController.h"
#import "MyFriendViewController.h"
#import "RCLetterListController.h"
#import "RCLetterController.h"
#import "FeedsController.h"
#import "SettingViewController.h"
#import "UserSettingController.h"
#import "UserInfoDB.h"
#import "UIImageView+WebCache.h"
#import "CompleteInfoController.h"
#import "AuthorizationGuideController.h"
#import "SVWebViewController.h"
#import "SynchMarkDB.h"
#import "ApplyFriendsController.h"
#import "locationSearchViewController.h"
#import "ListTopicsController.h"

#import "FocusListController.h"
#import "FansListController.h"

#import "UserFocusModel.h"

#define columnNum 3

@interface UserDetailController (){
    //屏幕的宽度
    CGFloat w;
    
    UITableView *listTable;
    
    // 头部menu切换是否有动画
    BOOL changeAnimate;
    //顶部拉伸图片，封面图片
    UIImageView *headerImageView;
    // table头
    UserHeaderCell *tableHeaderCell;
    
    
    // 显示的arr
    NSMutableArray *columnArr;
    
    //发布帖子的数组
    NSMutableArray *sendArr;
    
    NSMutableArray *focusArr;
    
    //收藏的数据
    NSMutableArray *collectionArr;
    
    //1、我发送的数据，2、我收藏的数据，默认发送, 3、关注，4粉丝
    int dataType;
    
    // 当前页面是否正在显示
    BOOL isShowing;
    
    //是否为第一次启动
    BOOL isFirst;
    
    //正在修改好友关系
    BOOL isLoading;
    
    // 判断当前是在选择背还是选择头像
    BOOL isUploadCover;
    
    // 个人数据同步调用
    NSString *updateTime;
    NSString *startTime;
    NSString *endTime;
    NSString *locallisttype;
    
    BOOL isMySelf;
    UIView *sectionView;
    UIButton *sendButton;
    UIButton *favButton;
    UIButton *focusButton;
    UILabel *sendLabel;
    UILabel *favLabel;
    UILabel *focusLabel;
    
    // 用户不存在
    UILabel *notFoundUserLabel;
}
@end



@implementation UserDetailController

@synthesize uid;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    updateTime=@"0";
    startTime=@"";
    endTime=@"";
    locallisttype=@"";
    isFirst=YES;
    
    if(_fromRoot){
        self.uid=[[LoginManager getInstance] getUid];
    }
    
    //自己
    if([[self getUID] isEqual:self.uid] || [[self getLoginUser].nickname isEqual:CheckNilValue(self.nickName)]){
        self.uid=[self getUID];
        self.user=[self getLoginUser];
        self.nickName=nil;
        isMySelf=YES;
    }else{
        isMySelf=NO;
    }

    
    [self createView];
    
    [self createBottomView];
    
    
    
    if(self.user){
        if(self.user.uid==nil || [@"" isEqual:CheckNilValue(self.user.uid)]){
            self.user.uid=self.uid;
        }
        
        UIImage *image=headerImageView.image;
        if(image==nil){
            image=[UIImage imageNamed:@"user_default_cover"];
        }
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
        [listTable reloadData];
    }else{
        NSDictionary *info=[SysTools getValueFromNSUserDefaultsByKey:UserInfoCacheKey(self.uid)];
        if(info!=nil && [info[@"uid"] isEqual:self.uid]){
            self.user=[[UserInfo alloc] initWithMyDict:info];
            
            UIImage *image=headerImageView.image;
            if(image==nil){
                image=[UIImage imageNamed:@"user_default_cover"];
            }
            [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
        }else{
            self.uid=CheckNilValue(self.uid);
            [SysTools removeNSUserDeafaultsByKey:UserInfoCacheKey(self.uid)];
            UIImage *image=headerImageView.image;
            if(image==nil){
                image=[UIImage imageNamed:@"user_default_cover"];
            }
            [headerImageView setImage:image];
        }
    }
    
    [self refreshData];
}


#pragma mark 系统处理
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    [self.navigationController.navigationBar removeFromSuperview];
    [self.navigationController setNavigationBarHidden:YES];
    
    isShowing=YES;
    
    if(!isFirst){
        if(_fromRoot){
            self.uid=[[LoginManager getInstance] getUid];
            [self refreshHeaderData];
        }
        else{
            [self refreshData];
        }
    }
    isFirst=NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    isShowing=NO;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}


-(void)createView{
    w=self.view.bounds.size.width;
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, w, self.view.mj_height)];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellHeaderIdentifier bundle:nil]  forHeaderFooterViewReuseIdentifier:cellHeaderIdentifier];
    [listTable registerClass:[UserInfoCell class] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:[UIColor clearColor]];
    [listTable setSeparatorColor:[UIColor clearColor]];
    [listTable setScrollEnabled:YES];
    [listTable setShowsVerticalScrollIndicator:YES];
    [listTable setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:listTable];
    
    headerImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 250-w, w, w)];
//    [headerImageView setImage:[UIImage imageNamed:@"user_default_cover"]];
    [headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    [headerImageView.layer setMasksToBounds:YES];
    [listTable insertSubview:headerImageView atIndex:0];
    
    
    [self createTitleMenu];
    
    [self.titleMenu setBackgroundColor:[UIColor clearColor]];
    
    [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(12, 8, 12, 24)];
    
    [self.menuLeftButton setImage:[UIImage imageNamed:@"user_back_nor"] forState:UIControlStateNormal];
    
    [self.menuLeftButton setImage:[UIImage imageNamed:@"user_back_sel"] forState:UIControlStateHighlighted];
    
    [self.menuLeftButton setBackgroundColor:[UIColor clearColor]];
    
    [self.menuRightButton setBackgroundColor:[UIColor clearColor]];
    if(self.fromRoot){
        self.menuLeftButton.hidden=YES;
    }
    
    //设置视图到顶部
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    UIView *view =[ [UIView alloc] initWithFrame:CGRectMake(0, 0, w, 5)];
    
    view.backgroundColor = [UIColor clearColor];
    
    [listTable setTableFooterView:view];
    
    sendArr=[[NSMutableArray alloc] init];
    
    collectionArr=[[NSMutableArray alloc] init];
    
    columnArr=[[NSMutableArray alloc] init];
    
    focusArr =[[NSMutableArray alloc] init];
    
    dataType=1;
    
    _stretchableTableHeaderView = [HFStretchableTableHeaderView new];
    
    [_stretchableTableHeaderView stretchHeaderForTableView:listTable withView:headerImageView];
    
    __block UserDetailController *myself=self;
    
    [_stretchableTableHeaderView setStartBlock:^{
        
        if(myself.activityView.isHidden){
            
            [myself.activityView startAnimating];
            
            myself.activityView.hidden=NO;
            
            [myself refreshData];
            
        }
    }];
    
    
    
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [_activityView setCenter:CGPointMake(w/2, 45)];
    
    _activityView.hidden=YES;
    
    [_activityView stopAnimating];
    
    [self.view addSubview:_activityView];
    
}


// 创建section
-(void)createSectionView{
    sectionView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    [sectionView setBackgroundColor:[UIColor whiteColor]];
    
    if(isMySelf){
        sendButton=[UIButton buttonWithType:UIButtonTypeSystem];
        sendButton.tag=1;
        favButton=[UIButton buttonWithType:UIButtonTypeSystem];
        favButton.tag=2;
        focusButton=[UIButton buttonWithType:UIButtonTypeSystem];
        focusButton.tag=3;
        
        sendLabel=[[UILabel alloc] init];
        favLabel=[[UILabel alloc] init];
        focusLabel=[[UILabel alloc] init];
        
        [sectionView addSubview:sendButton];
        [sectionView addSubview:favButton];
        [sectionView addSubview:focusButton];
        
        [sectionView addSubview:sendLabel];
        [sectionView addSubview:favLabel];
        [sectionView addSubview:focusLabel];
        
        [sendButton addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [focusButton addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [sendButton.titleLabel setFont:ListTitleFont];
        [sendButton setFrame:CGRectMake(0, 0, w/3, 44)];
        [sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        
        
        [favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [favButton.titleLabel setFont:ListTitleFont];
        [sendButton setFrame:CGRectMake(w/3, 0, w/3, 44)];
        [favButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        
        [focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [focusButton.titleLabel setFont:ListTitleFont];
        [sendButton setFrame:CGRectMake(w*2/3, 0, w/3, 44)];
        [focusButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        
        
        [sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [sendLabel setTextAlignment:NSTextAlignmentCenter];
        [sendLabel setFrame:CGRectMake(0, 22, w/3, 20)];
        [sendLabel setFont:ListTimeFont];
        
        [favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [favLabel setTextAlignment:NSTextAlignmentCenter];
        [favLabel setFrame:CGRectMake(w/3, 22, w/3, 20)];
        [favLabel setFont:ListTimeFont];
        
        [focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [focusLabel setTextAlignment:NSTextAlignmentCenter];
        [focusLabel setFrame:CGRectMake(w*2/3, 22, w/3, 20)];
        [focusLabel setFont:ListTimeFont];
    }else{
        sendButton=[UIButton buttonWithType:UIButtonTypeSystem];
        [sectionView addSubview:sendButton];
        
        [sendButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [sendButton setFrame:CGRectMake(10, 0, w-2, 44)];
        [sendButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0 , 10,(w-20)/2-20)];
        [sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    }
}

-(void)changeMenuClick:(UIButton *)sender{
    
}


-(void)createBottomView{
    int statusBarHeight=0;
    if (!iOS7) {
        statusBarHeight=20;
        // support full screen on iOS 6
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    
    //个人去设置
    if([self.uid isEqual:[[LoginManager getInstance] getUid]]){
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_setting_nor"] forState:UIControlStateNormal];
        self.menuRightButton.tag=OTHER_BUTTON;
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_setting_sel"] forState:UIControlStateHighlighted];
        [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-24/2, 22-23/2, 22-24/2, 22-23/2)];
    }else{
        //他人去好友列表
        self.menuRightButton.tag=OTHER_BUTTON;
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_more_nor"] forState:UIControlStateNormal];
        [self.menuRightButton setImage:[UIImage imageNamed:@"user_more_sel"] forState:UIControlStateHighlighted];
        [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-4, 22-25/2, 22-4,22-25/2)];
    }
    
    //添加左右切换手势
    [self addSwipeGesture];
    
    if([self.uid isEqual:[LoginManager getInstance].getUid]){
        //消息增加
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUserInfoData) name:CHANGEUSERINFO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoverNotice:) name:NOTICE_UPDATE_COVER object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserNick:) name:NOTICE_UPDATE_UserInfo object:nil];
    }
    
    //动态增加
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDCOMMENT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDFRIEND object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:NOTICE_DELADDFRIEND object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDZAN object:nil];
}


#pragma mark table 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return columnArr.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //第一个cell
    if(indexPath.row==0){
        tableHeaderCell = (UserHeaderCell*)[tableView dequeueReusableCellWithIdentifier:cellHeaderIdentifier];
        if(!tableHeaderCell){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserHeaderCell" owner:nil options:nil];
            //第一个对象就是CustomCell了
            tableHeaderCell = [nib objectAtIndex:0];
        }
        
        [tableHeaderCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        int type=dataType;
        
        [tableHeaderCell dataToView:self.user width:w type:type animate:changeAnimate];
        
        tableHeaderCell.delegate=self;
        
        return tableHeaderCell;
    }else{
        UserInfoCell *cell = (UserInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell dataToView:[columnArr objectAtIndex:(int)(indexPath.row-1)] column:columnNum row:(int)(indexPath.row-1) width:tableView.frame.size.width];
        
        cell.delegate=self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row>0){
        return (w-(columnNum+1)*5)/columnNum+5;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark datamanage
-(void)refreshData{
    if(self.nickName!=nil && ![@"" isEqual:self.nickName]){
        [self loadOtherInfo];
        return;
    }
    UserInfo *loginUser=[[LoginManager getInstance] getLoginInfo];
    //当时个人页面为本人时，应该先加载本地的数据
    if([loginUser.uid isEqual:self.uid]){
        [self loadSelfInfo];
    }else{
        [self loadOtherInfo];
    }
}

-(void)loadMoreData{
    if(self.user==nil|| self.uid==nil || [@"" isEqual:self.uid]){
        if([listTable isFooterRefreshing]){
            [listTable footerEndRefreshing];
        }
        return;
    }
    
    UserInfo *user=[[LoginManager getInstance]getLoginInfo];
    //当时个人页面为本人时，应该先加载本地的数据
    if([user.uid isEqual:self.uid]){
        [self loadSelfMore];
    }else{
        [self loadOtherMore];
    }
}

#pragma 加载数据
-(void)loadSelfInfo{
    if(self.user==nil || self.user.uid==nil || [@"" isEqual:self.user.uid] || [@"" isEqual:CheckNilValue(self.user.nickname)]){
//        WSLog(@"%@",api);
        self.user=[[LoginManager getInstance] getLoginInfo];
        if(!self.user){
            [headerImageView setImage:[UIImage imageNamed:@"user_default_cover"]];
        }
    }
    
    if(sendArr.count==0 && collectionArr.count==0){
        [self loadSelfLocalData];
        [self parseSelfHeaderData:1];
    }
    
    [self loadMoreData];
    
    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    NSString *time=[db findWidthUID:SynchMarkTypeUserInfo];
    
    NSString *api=[NSString stringWithFormat:@"%@?localupdatetime=%@",API_GET_SELFINFO,time];
    
    
    self.activityView.hidden=NO;
    [self.activityView startAnimating];
    WSLog(@"%@",api);
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
                self.user=dictUser;
                
                [[LoginManager getInstance] saveInfoToDB:dictUser];
                
                //保存更新时间
                NSString *time=[item objectForKey:@"updatetime"];
                [db saveSynchData:SynchMarkTypeUserInfo withTime:time];
                
                
                [self parseSelfHeaderData:0];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
        if(listTable.isHeaderRefreshing){
            [listTable headerEndRefreshing];
        }
        [_stretchableTableHeaderView endLoading];
        
        self.activityView.hidden=YES;
        [self.activityView stopAnimating];
    }];
    
}

-(void)loadOtherInfo{
    NSString *api=[NSString stringWithFormat:@"%@&%@&nickname=%@",API_GET_USERINFO(CheckNilValue(self.uid)),@"gettopiclist=1&len=21&richtopicinfo=1",CheckNilValue(self.nickName)];
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
//        WSLog(@"%@",dict);
        
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            [self parseHeaderData:dict];
        }
        if(notFoundUserLabel!=nil){
            [notFoundUserLabel removeFromSuperview];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        if(notFoundUserLabel==nil && self.user==nil){
            notFoundUserLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 200+(self.view.frame.size.height-200)/2, w, 30)];
            [notFoundUserLabel setText:WebCopy_User_NotFound];
            [notFoundUserLabel setTextAlignment:NSTextAlignmentCenter];
            [notFoundUserLabel setTextColor:UIColorFromRGB(TextBlackColor)];
            [self.view addSubview:notFoundUserLabel];
        }else{
            if(self.user==nil){
                [notFoundUserLabel setHidden:NO];
            }else{
                [notFoundUserLabel removeFromSuperview];
                [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            }
        }
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
        if(listTable.isHeaderRefreshing){
            [listTable headerEndRefreshing];
        }
        
        [_stretchableTableHeaderView endLoading];
        
        self.activityView.hidden=YES;
    }];
}


-(void)loadSelfMore{
    // 当dataType为2的时候，重新赋值
    startTime=@"";
    endTime=@"";
    SynchMarkDB *synchDB=[[SynchMarkDB alloc] init];
    
    if(dataType==2){
        locallisttype=@"favlist";
        updateTime=[synchDB findWidthUID:SynchMarkTypeTopicCollection];
        // 我的收藏
        if(collectionArr!=nil && collectionArr.count>0){
            startTime=((TopicModel *)[collectionArr objectAtIndex:0]).time;
            endTime=((TopicModel *)[collectionArr objectAtIndex:(collectionArr.count-1)]).time;
        }
    }else{
        locallisttype=@"publishlist";
        updateTime=[synchDB findWidthUID:SynchMarkTypeTopicSend];
        // 我的发送
        if(sendArr!=nil && sendArr.count>0){
            startTime=((TopicModel *)[sendArr objectAtIndex:0]).time;
            endTime=((TopicModel *)[sendArr objectAtIndex:(sendArr.count-1)]).time;
        }
    }
    
    if(self.user.favnum==0){
        self.user.favnum=(int)collectionArr.count;
    }
    
    if(self.user.topicnum==0){
        self.user.topicnum=(int)sendArr.count;
    }
    
    if(self.user.follownum==0)
    {
        self.user.follownum=(int)focusArr.count;
    }
    changeAnimate=YES;
    
    [self reloadTableData:0];
    
    WSLog("loadSelfMore第一次加载");
    NSString *api=API_GET_SelfUSER_TOPIC(startTime, endTime, updateTime, locallisttype);
    
    
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
//        WSLog(@"%@",dict);
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            NSArray *adddatas = dict[@"data"][@"addlist"];
            NSArray *delList = dict[@"data"][@"dellist"];
            NSArray *topicModels=nil;
            if(dict[@"data"][@"addlist"] && [dict[@"data"][@"addlist"] isKindOfClass:[NSArray class]]){
                topicModels =[TopicModel getTopicModelsWithArray:adddatas];
            }
            NSArray *delTopicModels=nil;
            if(dict[@"data"][@"dellist"] && [dict[@"data"][@"dellist"] isKindOfClass:[NSArray class]]){
                delTopicModels = [TopicModel getTopicModelsWithArray:delList];
            }
            
            TopicCacheDB *db=[[TopicCacheDB alloc] init];
            SynchMarkDB *synchDB=[[SynchMarkDB alloc] init];
            //保存更新时间
            updateTime=dict[@"data"][@"updatetime"];
            
            if(dataType==1){
                
                [synchDB saveSynchData:SynchMarkTypeTopicSend withTime:updateTime];
                if(topicModels!=nil && topicModels.count>0){
                    for (TopicModel *item in topicModels) {
                        
                        item.topicStatus=@"3";
                        
                        item.topicType=@"0";
                        
                        [db saveTopic:item];
                    }
                }
                if(delTopicModels !=nil && delTopicModels.count>0){
                    
                    for (TopicModel *item in delTopicModels) {
                        
                        [db deleteTopicByTopicID:item.topicid withType:TopicStatusSend];
                        
                    }
                }
                
                NSMutableArray *arr=[db getCacheListWithType:TopicStatusSend];
                if(arr!=nil){
                    [sendArr removeAllObjects];
                    [sendArr addObjectsFromArray:arr];
                    self.user.topicnum=(int)sendArr.count;
                }
            }else{
                [synchDB saveSynchData:SynchMarkTypeTopicCollection withTime:updateTime];
                if(topicModels!=nil && topicModels.count>0){
                    for (TopicModel *item in topicModels) {
                        
                        item.topicStatus=@"4";
                        
                        item.topicType=@"0";
                        
                        [db saveTopic:item];
                        
                    }
                    
                }
                
                if(delTopicModels !=nil && delTopicModels.count>0){
                    
                    for (TopicModel *item in delTopicModels) {
                        
                        [db deleteTopicByTopicID:item.topicid withType:TopicStatusCollection];
                        
                    }
                    
                }
                
                
                NSMutableArray *arr=[db getCacheListWithType:TopicStatusCollection];
                if(arr!=nil){
                    [collectionArr removeAllObjects];
                    [collectionArr addObjectsFromArray:arr];
                    self.user.favnum=(int)collectionArr.count;
                }
            }
            
            changeAnimate=NO;
        }
        [self reloadTableData];
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:@"" bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
        if([listTable isFooterRefreshing]){
            
            [listTable footerEndRefreshing];
            
        }
        
        [self.activityView stopAnimating];
        self.activityView.hidden=YES;
    }];
    
}

-(void)loadSelfLocalData{
    TopicCacheDB *db=[[TopicCacheDB alloc] init];
    SynchMarkDB *synchDB=[[SynchMarkDB alloc] init];
    NSMutableArray *collectionModels=[db getCacheListWithType:TopicStatusCollection];
    NSMutableArray *sendModels=[db getCacheListWithType:TopicStatusSend];
    
    WSLog(@"当前查询的type:%d",dataType);
    // 当dataType为2的时候，重新赋值
    if(dataType==2){
        locallisttype=@"favlist";
        updateTime=[synchDB findWidthUID:SynchMarkTypeTopicCollection];
    }else{
        locallisttype=@"publishlist";
        updateTime=[synchDB findWidthUID:SynchMarkTypeTopicSend];
    }
    
    if(collectionModels && collectionModels.count>0){
        if(collectionArr.count==0){
            [collectionArr removeAllObjects];
            [collectionArr addObjectsFromArray:collectionModels];
        }
        
        if(self.user.favnum==0){
            self.user.favnum=(int)collectionArr.count;
        }
    }
    
    if(sendModels && sendModels.count>0){
        if(sendArr.count==0){
            [sendArr removeAllObjects];
            [sendArr addObjectsFromArray:sendModels];
        }
        if(self.user.topicnum==0){
            self.user.topicnum=(int)sendArr.count;
        }
    }
}

-(void)loadOtherMore{
    NSString *topicid=@"";
    
    if(sendArr!=nil && sendArr.count>0){
        
        topicid=((TopicModel *)[sendArr lastObject]).topicid;
        
    }
    NSString *api=API_GET_USER_TOPIC(self.uid,topicid, @"21");
    
    // 当dataType为2的时候，重新赋值
    
    if(dataType==2){
        
        if(collectionArr!=nil && collectionArr.count>0){
            
            topicid=((TopicModel *)[collectionArr lastObject]).topicid;
            
        }
        
        api=API_TOPIC_FAVORITE_LIST(21,Load_MORE,topicid);
        
    }
    api=[NSString stringWithFormat:@"%@&richtopicinfo=1",api];
    [self reloadTableData:0];
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        
        //        WSLog(@"%@",dict);
        
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            
            NSArray *datas = dict[@"data"][@"list"];
            
            if (datas!=nil && datas.count>0) {
                for (NSDictionary *tItem in datas) {
                    TopicModel *model=[TopicModel initTopicModelWith:tItem];
                    if(model.fromrepost==0){
                        model.userinfo=self.user;
                        model.remarkname=self.user.remarkname;
                    }
                    if(dataType==1){
                        [sendArr addObject:model];
                    }else{
                        [collectionArr addObject:model];
                        
                    }
                }
                
                
            }
            
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
        [self showNoticeWithMessage:message message:@"" bgColor:TopNotice_Red_Color];
        
    } finished:^(ASIHTTPRequest *request) {
        
        if([listTable isFooterRefreshing]){
            
            [listTable footerEndRefreshing];
        }
        
        //                WSLog("loadOtherMore loading第一次加载");
        [self reloadTableData];
    }];
    
}
#pragma mark datamanage end


//解析个人头部数据
-(void)parseSelfHeaderData:(BOOL) isLocal{
    
    if(self.user!=nil && [self.user.uid isEqual:[LoginManager getInstance].getUid] && !isLocal){
        
        [[RequestTools getInstance] doSetNewtipscount:self.user.newtipscount];
        
        [[NoticeTools getInstance] postClearMessageRead];
    }
    
    UIImage *image=headerImageView.image;
    if(image==nil){
        image=[UIImage imageNamed:@"user_default_cover"];
    }
    [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
    
    [_stretchableTableHeaderView stretchHeaderForTableView:listTable withView:headerImageView];
    
    if(isLocal){
        // 完全不显示
        [self reloadTableData:0];
    }else{
        // 可能显示
        [self reloadTableData:1];
    }
}

-(void)parseHeaderData:(NSDictionary *) dict{
    if(dataType==1){
        NSDictionary *userDict=[dict objectForKey:@"data"];
        self.user=[[UserInfo alloc] initWithMyDict:userDict];
        [SysTools syncNSUserDeafaultsByKey:UserInfoCacheKey(self.uid) withValue:userDict];
        
        if(self.user!=nil && [self.user.uid isEqual:[LoginManager getInstance].getUid]){
            [[RequestTools getInstance] doSetNewtipscount:self.user.newtipscount];
            
            [[NoticeTools getInstance] postClearMessageRead];
        }
        
        
        UIImage *image=headerImageView.image;
        if(image==nil){
            image=[UIImage imageNamed:@"user_default_cover"];
        }
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
        
        [_stretchableTableHeaderView stretchHeaderForTableView:listTable withView:headerImageView];
        
    }
    
    if(dataType==1){
        
        if(!dict[@"data"][@"topiclist"] || ![dict[@"data"][@"topiclist"] isKindOfClass:[NSArray class]]){
            
            return;
        }
    }else{
        
        if(!dict[@"data"][@"favlist"] || ![dict[@"data"][@"favlist"] isKindOfClass:[NSArray class]]){
            
            return;
            
        }
        
    }
    
    NSArray *datas1 = dict[@"data"][@"topiclist"];
    NSArray *datas2 = dict[@"data"][@"favlist"];
    
    int itemsNum=0;
    
    if(datas1!=nil && datas1.count>0){
        
        itemsNum=(int)datas1.count;
    }
    
    if(datas2!=nil && datas2.count>0){
        itemsNum=(int)itemsNum + (int)datas2.count;
    }
    NSMutableArray *topicModels1 = [[NSMutableArray alloc] init];
    for (NSDictionary *tItem in datas1) {
        TopicModel *model=[TopicModel initTopicModelWith:tItem];
        if(model.fromrepost==0){
            model.userinfo=self.user;
            model.remarkname=self.user.remarkname;
        }
        [topicModels1 addObject:model];
    }
    
    
    if(topicModels1 && topicModels1.count>0){
        TopicModel *tem1=nil;
        TopicModel *tem2=topicModels1[0];
        if(sendArr.count>0){
            tem1=[sendArr objectAtIndex:0];
        }
        if(tem1==nil || ![tem2.topicid isEqual:tem1.topicid]){
            [sendArr removeAllObjects];
            
            [sendArr addObjectsFromArray:topicModels1];
        }
    }
    
//    NSArray *topicModels2 = [TopicModel getTopicModelsWithArray:datas2];
    NSMutableArray *topicModels2 = [[NSMutableArray alloc] init];
    for (NSDictionary *tItem in datas2) {
        TopicModel *model=[TopicModel initTopicModelWith:tItem];
        if(model.fromrepost==0){
            model.userinfo=self.user;
            model.remarkname=self.user.remarkname;
        }
        [topicModels2 addObject:model];
    }
    
    if(topicModels2 && topicModels2.count>0){
        TopicModel *tem1=nil;
        TopicModel *tem2=topicModels2[0];
        if(collectionArr.count>0){
            tem1=[collectionArr objectAtIndex:0];
        }
        if(tem1==nil || ![tem2.topicid isEqual:tem1.topicid]){
            [collectionArr removeAllObjects];
            [collectionArr addObjectsFromArray:topicModels2];
        }
    }
    
    
    int count=0;
    
    if(dataType==1){
        
        count=(int)sendArr.count;
        
    }else{
        
        count=(int)collectionArr.count;
        
    }
    [self reloadTableData];
}



-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
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
    if(sender.tag==OTHER_BUTTON){
        
        if ([[LoginManager getInstance] isLogin]) {
            
            if([uid isEqual:[LoginManager getInstance].getUid]){
                
                SettingViewController *setting=[[SettingViewController alloc] init];
                
                [self.navigationController pushViewController:setting animated:YES];
                
            }else{
                
                if([self checkBeKill]){
                    
                    return;
                    
                }
                
                if(self.user!=nil && self.user.uid!=nil && self.user.status!=-2){
                    
                    UserSettingController *userSeting=[[UserSettingController alloc] init];
                    
                    userSeting.userInfo=self.user;
                    
                    [self.navigationController pushViewController:userSeting animated:YES];
                    
                }
                
            }
            
        }else{
            
            [[LoginManager getInstance]showLoginView:self];
            
        }
        
    }
    
}

-(IBAction)changePageClick:(UIButton *)sender{
    if(self.user==nil){
        return;
    }
    
    if(sender.tag==1){
        
        SameCityController *res=[[SameCityController alloc] init];
        
        [self.navigationController pushViewController:res animated:YES];
        
    }else if(sender.tag==2){
        
        MyFriendViewController *fc=[[MyFriendViewController alloc] init];
        
        [fc setTitle:TTLocalString(@"TT_buddy")];
        
        fc.uid=uid;
        
        [self.navigationController pushViewController:fc animated:YES];
        
    }else if(sender.tag==3){
        
        //去私信页面
        RCLetterListController *list=[[RCLetterListController alloc] init];
        [self.navigationController pushViewController:list animated:YES];
  
//        //测试
//        locationSearchViewController *local=[[locationSearchViewController alloc]init];
//        [self.navigationController pushViewController:local animated:YES];
        
    }else if (sender.tag==4){
        
        ListTopicsController *list=[[ListTopicsController alloc] init];
        list.topicString=@"";
        
        
        //去动态页面
//        FeedsController *list=[[FeedsController alloc] init];
        
        [self.navigationController pushViewController:list animated:YES];
        
    }else if(sender.tag==5){
        NSURL *url=[NSURL URLWithString:@"http://www.tutuim.com/hd/hothuatih5.php"];
        SVWebViewController *web=[[SVWebViewController alloc] initWithURL:url];
        [self openNav:web sound:nil];
    }
}


#pragma mark 滑动相关
// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_stretchableTableHeaderView startRefresh];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //Selected index's color changed.
    static float newy = 0;
    newy= scrollView.contentOffset.y ;
    
    if([listTable isHeaderRefreshing] || [listTable isFooterRefreshing]){
        return;
    }
    [_stretchableTableHeaderView scrollViewDidScroll:scrollView];
    //    [_slimeView scrollViewDidScroll];
}



- (void)viewDidLayoutSubviews
{
    [_stretchableTableHeaderView resizeView];
    
}

-(void)refreshHeaderData{
    NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
    
    [listTable reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
}


-(void) reloadTableData{
    [self reloadTableData:1];
}


//转换arr
-(void) reloadTableData:(int) isShowNotice{
    [columnArr removeAllObjects];
    
    if(self.user!=nil){
        
        if(dataType==1){
            
            NSMutableArray *values=[[NSMutableArray alloc] init];
            
            for (int i=1; i<=sendArr.count; i++) {
                
                [values addObject:[sendArr objectAtIndex:(i-1)]];
                
                if(i%columnNum==0 && i>0){
                    [columnArr addObject:values];
                    
                    values=[[NSMutableArray alloc] init];
                    
                }
                
            }
            
            if(values.count>0){
                
                [columnArr addObject:values];
                
            }
            
        }else if(dataType==2){
            
            NSMutableArray *values=[[NSMutableArray alloc] init];
            
            for (int i=1; i<=collectionArr.count; i++) {
                
                [values addObject:[collectionArr objectAtIndex:(i-1)]];
                
                if(i%columnNum==0 && i>0){
                    
                    [columnArr addObject:values];
                    
                    values=[[NSMutableArray alloc] init];
                }
                
            }
            if(values.count>0){
                
                [columnArr addObject:values];
                
            }
        }
    }
    
    if(columnArr.count<3 && dataType<3){
        
        if([listTable getRefreshFooter]!=nil){
            
            if(![[LoginManager getInstance].getUid isEqual:self.user.uid]){
                
                [listTable removeFooter];
                
            }
        }
    }else{
        if([listTable getRefreshFooter]==nil){
            [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
        }
    }
    
    [listTable reloadData];
    
    if(isShowNotice==1){
        [self showPlaceholderView];
    }else{
        [self removePlaceholderView];
    }
}

- (void)showPlaceholderView{
    
    CGFloat headerheight=440;
    if(tableHeaderCell!=nil){
        headerheight=tableHeaderCell.frame.size.height;
        headerheight=headerheight+40;
        if(headerheight<440){
            headerheight=440;
        }
    }
    
    CGFloat centerY=(listTable.frame.size.height-headerheight)/2.0f;
    if(centerY<60){
        centerY=60;
    }
    listTable.tableFooterView=nil;
    
    CGPoint point = CGPointMake(ScreenWidth / 2.0f, headerheight+centerY);
    if (dataType == 1) {
        if (sendArr.count == 0) {
            if([self.uid isEqual:[LoginManager getInstance].getUid]){
                [self createPlaceholderView:point message:TTLocalString(@"TT_Master!Don't send photos is no friend to mess you") withView:listTable];
            }else{
                if(self.user!=nil && self.user.status==-2){
                    [self createPlaceholderView:point message:TTLocalString(@"TT_Ta sent bad information, get banned") withView:listTable];
                }else{
                    [self createPlaceholderView:point message:TTLocalString(@"TT_The friend is a little bit lazy, also did not send photos!") withView:listTable];
                }
            }
            UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 150)];
            [footView setBackgroundColor:[UIColor clearColor]];
            listTable.tableFooterView=footView;
        }else{
            [self removePlaceholderView];
        }
    }
    
    if (dataType == 2) {
        if (collectionArr.count == 0) {
            [self createPlaceholderView:point message:TTLocalString(@"TT_Master! What are m here! Go to the collection like the content") withView:listTable];
            UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 150)];
            [footView setBackgroundColor:[UIColor clearColor]];
            listTable.tableFooterView=footView;
        }else{
            [self removePlaceholderView];
        }
    }
    
    if(dataType == 3){
        if(focusArr.count==0){
            
            [self removePlaceholderView];
            point.y=point.y-20;
            self.placeholderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 100)];
            self.placeholderView.center = point;
            [listTable addSubview:self.placeholderView];
            
            UILabel *placeTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 195, 20)];
            [placeTitleLabel setText:TTLocalString(@"TT_what_do_you_pay_attention_to_all_have_no")];
            [placeTitleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
            [placeTitleLabel setTextAlignment:NSTextAlignmentCenter];
            [self.placeholderView addSubview:placeTitleLabel];
            
            UILabel *placeDescLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 195, 30)];
            [placeDescLabel setText:TTLocalString(@"TT_quick_to_find_interested_attention")];
            [placeDescLabel setFont:ListDetailFont];
            [placeDescLabel setTextColor:UIColorFromRGB(TextGrayColor)];
            [placeDescLabel setTextAlignment:NSTextAlignmentCenter];
            [self.placeholderView addSubview:placeDescLabel];
            
            UIButton *placeButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [placeButton setFrame:CGRectMake(195/2-125/2, 50, 125, 36)];
            placeButton.layer.cornerRadius=18;
            placeButton.layer.borderColor=UIColorFromRGB(SystemColor).CGColor;
            placeButton.layer.borderWidth=1.0f;
            [placeButton setTitle:TTLocalString(@"TT_topic_square") forState:UIControlStateNormal];
            [placeButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
            [placeButton setTitleColor:UIColorFromRGB(SystemColorHigh) forState:UIControlStateHighlighted];
            placeButton.tag=5;
            [placeButton.titleLabel setFont:ListDetailFont];
            [placeButton addTarget:self action:@selector(changePageClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.placeholderView addSubview:placeButton];
            
            UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 150)];
            [footView setBackgroundColor:[UIColor clearColor]];
            listTable.tableFooterView=footView;
        }else{
            [self removePlaceholderView];
        }
    }
    
}



#pragma mark 单个item点击

-(void)cellItemClick:(TopicModel *)model index:(int)indexPath{
    
    TopicDetailListController *rvc = [[TopicDetailListController alloc] init];
    
    rvc.currentIndex = indexPath;
    
    if(dataType==1){
        
        rvc.topicType=TopicTypeList;
        
        rvc.dataArray = sendArr;
        
    }else if(dataType==2){
        
        rvc.dataArray = collectionArr;
        
        rvc.topicType=TopicTypeFavoriteList;
    }
    
    rvc.uid = self.uid;
    
    rvc.delegate = self;
    
    [self.navigationController pushViewController:rvc animated:YES];
    
}


#pragma mark TopicDetailListControllerDelegate
- (void)topicModelsChange:(NSArray *)topicModels{
    
    [sendArr removeAllObjects];
    
    [sendArr addObjectsFromArray:topicModels];
    
    [self reloadTableData];
    
}

- (void)favoriteModelsChange:(NSArray *)models{
    
    [collectionArr removeAllObjects];
    
    [collectionArr addObjectsFromArray:models];
    
    [self reloadTableData];
}

- (void)deleteTopicModelAtIndex:(NSInteger)index{
    
    if(sendArr.count>index){
        
        [sendArr removeObjectAtIndex:index];
        
        dataType = 1;
        
        if(self.user!=nil){
            
            self.user.topicnum=self.user.topicnum-1;
            
            if(self.user.topicnum<0){
                
                self.user.topicnum=0;
                
            }
            
        }
        
        [self reloadTableData];
        
    }
    
}

- (void)deleteFavoriteAtIndex:(NSInteger)index{
    if(collectionArr.count>index){
        
        dataType = 2;
        
        [collectionArr removeObjectAtIndex:index];
        
        if(self.user!=nil){
            
            self.user.favnum=self.user.favnum-1;
            
            if(self.user.favnum<0){
                
                self.user.favnum=0;
                
            }
        }
        
        [self reloadTableData];
    }
}

#pragma mark 头部cell的代理
-(void)headerViewClick:(UserHeaderCellClickTag)viewTag clickView:(UIView *)senderView{
    if(self.user==nil){
        return;
    }
    
    if(![LoginManager getInstance].isLogin){
        
        [[LoginManager getInstance]showLoginView:self];
        
        return;
    }
    
    
    if(viewTag==UserFocusActionTag){
        [self doFocus:NO];
    }
    
    if(viewTag==UserChatTag){
        RCLetterController *chat=[[RCLetterController alloc] init];
        chat.userid=self.uid;
        if(self.user!=nil){
            chat.lastTime=self.user.avatartime;
        }
        [self openNav:chat sound:nil];
    }
    
    if(viewTag==UserMyFocusTag){
        FocusListController *focusList=[[FocusListController alloc] init];
        focusList.info=self.user;
        [self openNav:focusList sound:nil];
    }
    
    if(viewTag==UserFansTag){
        FansListController *focusList=[[FansListController alloc] init];
        focusList.info=self.user;
        [self openNav:focusList sound:nil];
    }
    
    if(viewTag==UserMyCollectionBtnTag){
        
        dataType=2;
        
        if([[LoginManager getInstance].getUid isEqual:self.user.uid]){
            
            [self loadSelfMore];
            
        }else{
            
            [self reloadTableData];
            
        }
        
    }
    
    
    if(viewTag==UserMyListBtnTag){
        
        dataType=1;
        
        if([[LoginManager getInstance].getUid isEqual:self.user.uid]){
            
            [self loadSelfMore];
            
        }else{
            
            [self reloadTableData];
            
        }
        
    }
    
    if(viewTag==UserEditBtnTag){
        //去编辑页面
        CompleteInfoController *list=[[CompleteInfoController alloc] init];
        [self.navigationController pushViewController:list animated:YES];
        
    }
    
    if(viewTag==UserLikeTag){
        
        [[RequestTools getInstance] get:API_ADD_Liker(self.uid) isCache:NO completion:^(NSDictionary *dict) {
            @try {
                int likeNum=[[[dict objectForKey:@"data"] objectForKey:@"likenum"] intValue];
                
                self.user.likenum=likeNum;
                
                self.user.isliked=YES;
                
                [listTable reloadData];
            }
            
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
        
    }
    
    //更换头像
    if(viewTag==UserChangeAvatarTag){
        isUploadCover=NO;
        UIImageView *showIv=(UIImageView *)senderView;
        
        NSString *avatarURL=[SysTools getBigHeaderImageURL:self.user.uid time:self.user.avatartime];
        
        [showIv sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:showIv.image options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                [showIv setImage:image];
            }
        }];
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        
        [photos addObject:showIv];
        
        XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
        
        imageViewer.delegate = self;
        
        if([self.user.uid isEqual:[LoginManager getInstance].getUid]){
            
            [imageViewer setIsShowMenu:YES];
            
            [imageViewer setMenuType:1];
            
            [imageViewer setParam:self.user.uid];
            
        }else{
            
            imageViewer.delegate = self;
            
            [imageViewer setIsShowMenu:YES];
            
            [imageViewer setMenuType:2];
            
            [imageViewer setParam:self.user.uid];
            
        }
        
        [imageViewer showWithImageViews:photos selectedView:showIv];
        
        return;
        
    }
    
    //更换背景
    if(viewTag==UserChangeBgTag){
        isUploadCover=YES;
        if(![self.user.uid isEqual:[LoginManager getInstance].getUid]){
            //            NSMutableArray *photos = [[NSMutableArray alloc] init];
            //            [photos addObject:headerImageView];
            //            XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
            //            imageViewer.delegate = self;
            //            [imageViewer showWithImageViews:photos selectedView:headerImageView];
            return;
            
        }
        
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_Replace the topic covers?") delegate:self otherButton:@[TTLocalString(@"TT_take_photo"),TTLocalString(@"TT_From the album to choose"),TTLocalString(@"TT_Select the cover page")] cancelButton:TTLocalString(@"TT_cancel")];
        
        sheet.tag=2;
        
        [sheet showInView:self.view];
        
    }
    
}

-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    //头像
    if(tag==1){
        
        if(buttonIndex==0){
            
            LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:@"" delegate:self otherButton:@[TTLocalString(@"TT_take_photo"),TTLocalString(@"TT_From the album to choose")] cancelButton:TTLocalString(@"TT_cancel")];
            
            sheet.tag=3;
            
            [sheet showInView:self.view];
            
        }
        
        if(buttonIndex==1){
            
            SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/static/agreement.html",API_HOST]]];
            
            webView.title = TTLocalString(@"TT_Charm value");
            
            self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            
            [self.navigationController pushViewController:webView animated:YES];
            
        }
        
    }
    
    //修改头像
    if(tag==3){
        
        if (buttonIndex == 0) {
            
            if ([SysTools isHasCaptureDeviceAuthorization]) {
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                
                imagePicker.allowsEditing=YES;
                
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
                
                isUploadCover=NO;
                
                UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];imagePicker.delegate = self;
                
                imagePicker.allowsEditing=YES;
                
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
            
        }
        
    }
    
    //背景
    if(tag==2){
        
        if(buttonIndex==2){
            
            CoverListController *coverList=[[CoverListController alloc] init];
            
            [self.navigationController pushViewController:coverList animated:YES];
            
        }
        
        if (buttonIndex == 0) {
            
            if ([SysTools isHasCaptureDeviceAuthorization]) {
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                
                imagePicker.allowsEditing=YES;
                
                imagePicker.delegate = self;
                
                imagePicker.title=TTLocalString(@"TT_Set the cover");
                
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
                
                isUploadCover=YES;
                
                UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];imagePicker.delegate = self;
                
                imagePicker.allowsEditing=YES;
                
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
                
                imagePicker.title=TTLocalString(@"TT_Set the cover");
                
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
            
        }
        
    }
    
    // 取消关注
    if(tag==4){
        if(buttonIndex==0){
            [self doFocus:YES];
        }
    }
    
}

-(void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView{
    
    for (UIView *v in selectedView.subviews) {
        
        [v removeFromSuperview];
    }
    
    [selectedView removeFromSuperview];
    
    NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:0 inSection:0];
    
    [listTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath_1] withRowAnimation:UITableViewRowAnimationNone];
    
    //    [tableHeaderCell insertSubview:tableHeaderCell.levelImageView aboveSubview:tableHeaderCell.avatarImageView];
    
}


#pragma mark 拍照处理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    WSLog(@"%@",picker.title);
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        
        UIImage *image = info[UIImagePickerControllerEditedImage];
        
        //上传封面
        if(isUploadCover){
            
            [headerImageView setImage:image];
            
            [_stretchableTableHeaderView stretchHeaderForTableView:listTable withView:headerImageView];
            
            NSString *filePath=[SysTools writeImageToDocument:image fileName:@"cover.png"];
            
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            
            [dict setObject:@"custom" forKey:@"covertype"];
            
            [[RequestTools getInstance] post:API_POST_COVER filePath:filePath fileKey:@"coverfile" params:dict completion:^(NSDictionary *dict) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    
    //                WSLog(@"%@",dict);
                    
                    //更新封面操作
                    self.user.homecoverurl=[[dict objectForKey:@"data"] objectForKey:@"userhomecoverurl"];
                    [[LoginManager getInstance] saveInfoToDB:self.user];
                    
                    [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
                    
                    [_stretchableTableHeaderView stretchHeaderForTableView:listTable withView:headerImageView];
                
            } failure:^(ASIFormDataRequest *request, NSString *message) {
                
                [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
                
                
                [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                
            } finished:^(ASIFormDataRequest *request) {
                
//                WSLog(@"%@",request.responseString);
                
            }];
            
        }else{
            [tableHeaderCell.avatarImageView setImage:image];
            
            NSString *filePath=[SysTools writeImageToDocument:image fileName:@"avatar.png"];
            
            [[RequestTools getInstance] post:API_ADD_SETUSERAVATAR filePath:filePath fileKey:@"avatarfile" params:nil completion:^(NSDictionary *dict) {
                
                
                //            上传图片成功
                    
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    
                    UserInfo * model = [[LoginManager getInstance]getLoginInfo];
                    
                    [SysTools clearAvatar];
                    
                    model.avatartime = [[dict objectForKey:@"data"] objectForKey:@"avatartime"];
                    
                    //保存图片的时间到本地
                    [[LoginManager getInstance] saveInfoToDB:model];
                    
                    self.user.avatartime=model.avatartime;
                    
                    NSString *avatar=[SysTools getHeaderImageURL:self.user.uid time:model.avatartime];
                    
                    [tableHeaderCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:image];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEUSERINFO object:nil];
                
                
            } failure:^(ASIFormDataRequest *request, NSString *message) {
                //            上传图片失败
                NSString *avatar=[SysTools getHeaderImageURL:self.user.uid time:self.user.avatartime];
                
                [tableHeaderCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:image];
                [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                
            } finished:^(ASIFormDataRequest *request) {
//                WSLog(@"%@",request.responseString);
            }];
            
        }
        
    }];
}

//-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
//
//}

#pragma mark 手势处理
-(void)addSwipeGesture{
    [self.view setUserInteractionEnabled:YES];
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [self.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [self.view addGestureRecognizer:recognizer];
    
    
}


- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(! [self.uid isEqual:[self getUID]]){
        return;
    }
    if(self.user==nil || (sendArr.count==0 && collectionArr.count==0 && focusArr.count==0)){
        
        return;
        
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft && dataType==3){
        
        return;
        
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight && dataType==1){
        
        return;
        
    }
    
    [tableHeaderCell handleSwipeMove:recognizer.direction];
    
    [self showPlaceholderView];
}

//获取到新消息，重新设置消息数
-(void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object{
    [self refreshHeaderData];
}

//修改个人信息
-(void)updateUserNick:(NSNotification *)obj{
    if(self.user!=nil){
        UserInfo *objUser=(UserInfo *)obj.object;
        if(objUser!=nil && [objUser.uid isEqual:self.uid]){
            self.user=objUser;
            
            for (TopicModel *item in sendArr) {
                if(item.uid==self.uid){
                    item.nickname=self.user.nickname;
                }
            }
            
            for (TopicModel *item in collectionArr) {
                if(item.uid==self.uid){
                    item.nickname=self.user.nickname;
                }
            }
            
            [listTable reloadData];
            
            [self showPlaceholderView];
        }
    }
}

-(void)updateUserInfo:(NSNotification *)notic{
    UserInfo *uinfo=(UserInfo *)[notic object];
    
    if(uinfo!=nil && [uinfo.uid isEqual:self.uid]){
        self.user=uinfo;
        
        [listTable reloadData];
    }
}

-(void)updateCoverNotice:(NSNotification *)notic{
    @try {
        NSString  *coverurl=[notic object];
        
        self.user.homecoverurl=coverurl;
        [[LoginManager getInstance] saveInfoToDB:self.user];
        
        
        UIImage *image=headerImageView.image;
        if(image==nil){
            image=[UIImage imageNamed:@"user_default_cover"];
        }
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.homecoverurl] placeholderImage:image];
        
        [_stretchableTableHeaderView stretchHeaderForTableView:listTable withView:headerImageView];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


- (void)reloadUserInfoData{
    
    UserInfo *user=[[LoginManager getInstance]getLoginInfo];
    
    if([user.uid isEqual:self.uid]){
        self.user.nickname = user.nickname;
        self.user.avatartime = user.avatartime;
        self.user.sign = user.sign;
        self.user.age = user.age;
        self.user.gender = user.gender;
        self.user.city = user.city;
        self.user.area = user.area;
        self.user.province = user.province;
        self.user.birthday = user.birthday;
        self.user.uid = user.uid;
        [listTable reloadData];
    }
}


//用户关注
-(void)doFocus:(BOOL) isDel{
    
    if(!isDel && ([self.user.relation intValue]==2 || [self.user.relation intValue]==3)){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_maksure_cancel_follow") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
        sheet.tag=4;
        [sheet showInView:self.view];
    }else{
        NSString *doFocusORDelAPI=API_ADD_Follow_User(self.user.uid);
        if(isDel){
            doFocusORDelAPI=API_DEL_Follow_User(self.user.uid);
        }
        
        [[RequestTools getInstance] get:doFocusORDelAPI isCache:NO completion:^(NSDictionary *dict) {
            if([self.user.relation intValue]==0){
                self.user.relation=@"2";
            }else if([self.user.relation intValue]==1){
                self.user.relation=@"3";
            }else if([self.user.relation intValue]==3){
                self.user.relation=@"1";
            }else if([self.user.relation intValue]==2){
                self.user.relation=@"0";
            }
            
            [self refreshHeaderData];
            
#pragma warning 卡顿
            // 发送通知，修改数据库，有可能引起卡顿
            if(isDel){
                [[NoticeTools getInstance] postdelFocus:self.user];
            }else{
                [[NoticeTools getInstance] postAddFocus:self.user];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
        } finished:^(ASIHTTPRequest *request) {
//            WSLog(@"%@",request.responseString);
        }];
    }
    
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