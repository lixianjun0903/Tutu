//
//  FocusListController.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FocusListController.h"
#import "ListTopicsController.h"

#import "UserDetailController.h"
#import "ChineseFirstLetter.h"
#import "UserInfoDB.h"


#define cellIdentifier @"UserFansCell"


@interface FocusListController (){
    UITableView *listTable;
    NSMutableArray *listArray;
    
    // 排序方式，默认A-Z,0,默认，1时间
    int sortType;
    NSMutableArray *_sectionHeadsKeys;
    NSMutableArray *sortedArrForArrays;
    
    NSMutableDictionary *dictData;
    
    UserInfo *doFocusModel;
    
    CGFloat w;
    
    UIButton *topicNumButton;
    UIButton *poiNumButton;
    
    UIView *noticeView;
    BOOL isMyself;
}

@end

@implementation FocusListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self createTitleMenu];
    self.menuRightButton.hidden=NO;
    [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_nor"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_sel"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(10, 9, 10, 9)];
    
    
    w=self.view.frame.size.width;
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:[UIColor whiteColor]];
    [listTable setSeparatorColor:UIColorFromRGB(ListLineColor)];
    listTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    listTable.sectionIndexColor = HEXCOLOR(SystemColor);
    [listTable setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    if([SysTools getSystemVerson] >= 7){
        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    }
    
    if(_info && ![_info.uid isEqual:[[LoginManager getInstance] getUid]]){
        [self.menuTitleButton setTitle:[NSString stringWithFormat:@"%@%@",_info.nickname,TTLocalString(@"TT_de_follow")] forState:UIControlStateNormal];
        isMyself=NO;
    }else{
        [self.menuTitleButton setTitle:[NSString stringWithFormat:TTLocalString(@"TT_mine_follow")] forState:UIControlStateNormal];
        
        [self createTableHeader];
        
        isMyself=YES;
    }
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    sortType=1;
    listArray=[[NSMutableArray alloc] init];
    _sectionHeadsKeys=[[NSMutableArray alloc] init];
    dictData=[[NSMutableDictionary alloc] init];
    
    if(!isMyself){
        self.menuRightButton.hidden=YES;
        [listTable addHeaderWithTarget:self action:@selector(refreshData)];
        [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
        
        
        [listTable headerBeginRefreshing];
    }else{
        self.menuRightButton.hidden=NO;
        if(sortType==1){
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_nor"] forState:UIControlStateNormal];
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_sel"] forState:UIControlStateHighlighted];
        }
        
        
        NSString * httotal=[NSString stringWithFormat:@"%d",[[RequestTools getInstance] getNewfollowhtcount]];
        NSString * poitotal=[NSString stringWithFormat:@"%d",[[RequestTools getInstance] getNewfollowpoicount]];
        
//        [self createChangeNoticeView:olduser];
        
        if(![@"" isEqual:CheckNilValue(httotal)] && ![@"0" isEqual:CheckNilValue(httotal)]){
            [topicNumButton setHidden:NO];
            [topicNumButton setTitle:httotal forState:UIControlStateNormal];
            
            CGFloat xw=[SysTools getWidthContain:httotal font:ListDetailFont Height:20]+10;
            if(xw<20){
                xw=20;
            }
            [topicNumButton setFrame:CGRectMake(w-40-xw, 20, xw, 20)];
        }else{
            [topicNumButton setHidden:YES];
        }
        
        if(![@"" isEqual:CheckNilValue(poitotal)] && ![@"0" isEqual:CheckNilValue(poitotal)]){
            CGFloat xw=[SysTools getWidthContain:poitotal font:ListDetailFont Height:20]+10;
            if(xw<20){
                xw=20;
            }
            [poiNumButton setFrame:CGRectMake(w-40-xw, 20, xw, 20)];
            [poiNumButton setHidden:NO];
            [poiNumButton setTitle:poitotal forState:UIControlStateNormal];
        }else{
            [poiNumButton setHidden:YES];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadSelfData];
        });
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:NOTICE_DELADDFRIEND object:nil];
}

// 个人的时候，关注的人，关注的位置
-(void)createTableHeader{
    UIView *headerView=[[UIView alloc] init];
    [headerView setFrame:CGRectMake(0, 0, w, 120)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    
    [headerView addSubview:[self createItemView:1]];
    
    [headerView addSubview:[self createItemView:2]];
    
    [listTable setTableHeaderView:headerView];
    
}


-(UIView *)createItemView:(int) line{
    int itemHeight=60;
    UIView *itemView=[[UIView alloc] initWithFrame:CGRectMake(0, itemHeight*(line-1), w, itemHeight)];
    itemView.tag=line;
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doChangePage:)];
    [itemView addGestureRecognizer:tap];
    
    
    
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    [iv setImage:[UIImage imageNamed:@"user_focus_topic.png"]];
    [iv setBackgroundColor:[UIColor clearColor]];
    [itemView addSubview:iv];
    
    UILabel *textLabel=[[UILabel alloc] init];
    [textLabel setFrame:CGRectMake(60, 0, w-120, 60)];
    [textLabel setFont:ListTitleFont];
    [textLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [textLabel setNumberOfLines:1];
    [textLabel setTextAlignment:NSTextAlignmentLeft];
    [itemView addSubview:textLabel];
    
    
    UIImageView *iv1=[[UIImageView alloc] initWithFrame:CGRectMake(w-40, 15, 30, 30)];
    [iv1 setImage:[UIImage imageNamed:@"p_right.png"]];
    [iv1 setBackgroundColor:[UIColor clearColor]];
    [itemView addSubview:iv1];
    
    if(line==1){
        [textLabel setText:TTLocalString(@"TT_the_topic_of_concern")];
        
        topicNumButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [topicNumButton setBackgroundColor:[UIColor redColor]];
        [topicNumButton setFrame:CGRectMake(w-40, 20, 0, 20)];
        [topicNumButton.titleLabel setFont:ListDetailFont];
        topicNumButton.layer.cornerRadius=10;
        topicNumButton.layer.masksToBounds=YES;
        [itemView addSubview:topicNumButton];
        [topicNumButton setHidden:YES];
        
        UIImageView *iv2=[[UIImageView alloc] initWithFrame:CGRectMake(60, 60, w-60, 0.75)];
        [iv2 setBackgroundColor:UIColorFromRGB(ListLineColor)];
        [itemView addSubview:iv2];
    }
    if(line==2){
        [textLabel setText:TTLocalString(@"TT_the_location_of_concern")];
        [iv setImage:[UIImage imageNamed:@"user_focus_poi.png"]];
        
        poiNumButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [poiNumButton setBackgroundColor:[UIColor redColor]];
        [poiNumButton setFrame:CGRectMake(w-40, 20, 0, 20)];
        [poiNumButton.titleLabel setFont:ListDetailFont];
        poiNumButton.layer.cornerRadius=10;
        poiNumButton.layer.masksToBounds=YES;
        [itemView addSubview:poiNumButton];
        [poiNumButton setHidden:YES];
    }
    
    return itemView;
}

#pragma mark 获取个人的关注列表
-(void)loadSelfData{
    UserInfoDB *db=[[UserInfoDB alloc] init];
    listArray = [db findMyFriends];
    if(listArray!=nil && listArray.count>0){
        sortedArrForArrays=[self getChineseStringArr:listArray];
        
        [listTable reloadData];
    }
    
    [[SendLocalTools getInstance] synchronousFriendList];
}


#pragma mark 刷新数据
-(void)refreshData{
    NSString *startid=@"";
    if(listArray!=nil && listArray.count>0){
        UserInfo *tempModel=[listArray objectAtIndex:0];
        startid=tempModel.uid;
    }
    NSString *api=API_GET_FollowUserList(_info.uid,Load_UP,20,startid);
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"list"];
        NSString * httotal=CheckNilValue(dict[@"data"][@"httotal"]);
        NSString * poitotal=CheckNilValue(dict[@"data"][@"poitotal"]);
        if(isMyself){
            BOOL olduser=[CheckNilValue(dict[@"data"][@"olduser"]) boolValue];
            [self createChangeNoticeView:olduser];
        }
        if(![@"" isEqual:CheckNilValue(httotal)] && ![@"0" isEqual:CheckNilValue(httotal)]){
            [topicNumButton setHidden:NO];
            [topicNumButton setTitle:httotal forState:UIControlStateNormal];
            
            CGFloat xw=[SysTools getWidthContain:httotal font:ListDetailFont Height:20]+10;
            if(xw<20){
                xw=20;
            }
            [topicNumButton setFrame:CGRectMake(w-40-xw, 20, xw, 20)];
        }else{
            [topicNumButton setHidden:YES];
        }
        
        if(![@"" isEqual:CheckNilValue(poitotal)] && ![@"0" isEqual:CheckNilValue(poitotal)]){
            CGFloat xw=[SysTools getWidthContain:poitotal font:ListDetailFont Height:20]+10;
            if(xw<20){
                xw=20;
            }
            [poiNumButton setFrame:CGRectMake(w-40-xw, 20, xw, 20)];
            [poiNumButton setHidden:NO];
            [poiNumButton setTitle:poitotal forState:UIControlStateNormal];
        }else{
            [poiNumButton setHidden:YES];
        }
        
        if(arr!=nil && arr.count>0){
             NSArray* reversedArray = [[arr reverseObjectEnumerator] allObjects];
            for (NSDictionary *item in reversedArray) {
                [listArray insertObject:[[UserInfo alloc] initWithMyDict:item] atIndex:0];
            }
            
            sortedArrForArrays=[self getChineseStringArr:listArray];
            
            [listTable reloadData];
        }
        [self checkDataNull];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
//                WSLog(@"%@",request.responseString);
        if(listTable.isHeaderRefreshing){
            [listTable headerEndRefreshing];
        }
        
        //以后调用无意义
        if(listArray.count>0){
            [listTable removeHeader];
        }
    }];
}

-(void)loadMoreData{
    NSString *startid=@"";
    if(listArray!=nil && listArray.count>0){
        UserInfo *model=[listArray objectAtIndex:listArray.count-1];
        startid=model.uid;
    }
    
    NSString *api=API_GET_FollowUserList(_info.uid,Load_MORE,20,startid);
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"list"];
        NSString * httotal=CheckNilValue(dict[@"data"][@"httotal"]);
        NSString * poitotal=CheckNilValue(dict[@"data"][@"poitotal"]);
        if(![@"" isEqual:CheckNilValue(httotal)]){
            [topicNumButton setHidden:NO];
            [topicNumButton setTitle:httotal forState:UIControlStateNormal];
            
            CGFloat xw=[SysTools getWidthContain:httotal font:ListDetailFont Height:20]+5;
            if(xw<20){
                xw=20;
            }
            [topicNumButton setFrame:CGRectMake(w-40-xw, 20, xw, 20)];
        }else{
            [topicNumButton setHidden:YES];
        }
        
        if(![@"" isEqual:CheckNilValue(poitotal)]){
            CGFloat xw=[SysTools getWidthContain:poitotal font:ListDetailFont Height:20]+5;
            if(xw<20){
                xw=20;
            }
            [poiNumButton setFrame:CGRectMake(w-40-xw, 20, xw, 20)];
            [poiNumButton setHidden:NO];
            [poiNumButton setTitle:poitotal forState:UIControlStateNormal];
        }else{
            [poiNumButton setHidden:YES];
        }
        
        if(arr!=nil && arr.count>0){
            for (NSDictionary *item in arr) {
                [listArray addObject:[[UserInfo alloc] initWithMyDict:item]];
            }
            
            sortedArrForArrays=[self getChineseStringArr:listArray];
            
            [listTable reloadData];
        }
        [self checkDataNull];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"%@",request.responseString);
        if([listTable isFooterRefreshing]){
            [listTable footerEndRefreshing];
        }
    }];
}


#pragma mark table 代理开始
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(sortType==0){
        return  [[sortedArrForArrays objectAtIndex:section] count];
    }else{
        return listArray.count;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(sortType==0){
        return _sectionHeadsKeys;
    }else{
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(sortType==0){
        return [sortedArrForArrays count];
    }else{
        return 1;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(!isMyself){
        return 0;
    }
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 25)];
    [view setBackgroundColor:UIColorFromRGB(ButtonViewBgColor)];
    
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, w-20, 25)];
    [textLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:ListTitleFont];
    [view addSubview:textLabel];
    if(sortType==0){
        [textLabel setText:[_sectionHeadsKeys objectAtIndex:section]];
    }else{
        [textLabel setText:TTLocalString(@"TT_i_focus_people")];
    }
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserFansCell *cell = (UserFansCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UserFansCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate=self;
    
    UserInfo *info=[listArray objectAtIndex:indexPath.row];
    if(sortType==0){
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        info = [arr objectAtIndex:indexPath.row];
        
        [cell dataToView:info];
    }
    if(isMyself){
        NSString *time=info.followtime;
        if(info.followtime==nil || [@"" isEqual:info.addtime]){
            time=info.addtime;

            NSDate *t=[NSDate dateWithTimeIntervalSince1970:[info.addtime longLongValue]];
            [t dateByAddingTimeInterval:-24*60*60*365];
            
            time=[NSString stringWithFormat:@"%ld",(long)[t timeIntervalSince1970]];
        }
        NSString *followtime=intervalSinceNow(dateTransformString(@"yyyy-MM-dd HH:mm:ss",[NSDate dateWithTimeIntervalSince1970:[time longLongValue]]));
        [cell dataToView:info followTime:followtime];
    }else{
        
        NSString *followtime=intervalSinceNow(info.followtime);
        [cell dataToView:info followTime:followtime];
    }
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserInfo *info=[listArray objectAtIndex:indexPath.row];
    if(sortType==0){
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        info = [arr objectAtIndex:indexPath.row];
    }
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.uid=info.uid;
    [self openNav:detail sound:nil];
}


#pragma mark TableCell代理
-(void)itemFocusClick:(UserInfo *)info{
    [self doFocus:info del:NO];
}


#pragma mark 本页面事件处理
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    
    if(sender.tag==RIGHT_BUTTON){
        if(sortType==0){
            sortType=1;
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_nor"] forState:UIControlStateNormal];
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_sel"] forState:UIControlStateHighlighted];
            [listTable reloadData];
        }else{
            sortType=0;
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_nor"] forState:UIControlStateNormal];
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_sel"] forState:UIControlStateHighlighted];
            [listTable reloadData];
        }
    }
}

//用户关注
-(void)doFocus:(UserInfo *)info del:(BOOL) isDel{
    if(!isDel && info!=nil && ([info.relation intValue]==2 || [info.relation intValue]==3)){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_maksure_cancel_follow") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
        sheet.tag=4;
        [sheet showInView:self.view];
        
        doFocusModel=info;
    }else{
        
        NSString *doFocusORDelAPI=API_ADD_Follow_User(info.uid);
        if(isDel){
            doFocusORDelAPI=API_DEL_Follow_User(info.uid);
        }
        
        [[RequestTools getInstance] get:doFocusORDelAPI isCache:NO completion:^(NSDictionary *dict) {
            if([info.relation intValue]==0){
                info.relation=@"2";
            }else if([info.relation intValue]==1){
                info.relation=@"3";
            }else if([info.relation intValue]==3){
                info.relation=@"1";
            }else if([info.relation intValue]==2){
                info.relation=@"0";
            }

            [listTable reloadData];
            if(isDel){
                [[NoticeTools getInstance] postdelFocus:info];
            }else{
                [[NoticeTools getInstance] postAddFocus:info];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }
    
}

-(void)doChangePage:(UIGestureRecognizer *)tap{
    //关注的话题
    if(tap.view.tag==1){
        FocusListDetailController *listdetail=[[FocusListDetailController alloc] init];
        listdetail.info=self.info;
        listdetail.delegate=self;
        listdetail.pageType=TopicWithDefault;
        [self openNav:listdetail sound:nil];
    }
    
    //关注的位置
    if(tap.view.tag==2){
        FocusListDetailController *listdetail=[[FocusListDetailController alloc] init];
        listdetail.info=self.info;
        listdetail.delegate=self;
        listdetail.pageType=TopicWithPoiPage;
        [self openNav:listdetail sound:nil];
    }
}

#pragma mark 设置消息数
-(void)setReadStatus:(TopicWithTypePage)type{
    if(type==TopicWithDefault){
        [topicNumButton setTitle:@"" forState:UIControlStateNormal];
        [topicNumButton setHidden:YES];
    }
    if(type==TopicWithPoiPage){
        [poiNumButton setTitle:@"" forState:UIControlStateNormal];
        [poiNumButton setHidden:YES];
    }
    if(poiNumButton.hidden){
        [[RequestTools getInstance] doSetNewfollowpoicount:@"0"];
    }
    if(topicNumButton.hidden){
        [[RequestTools getInstance] doSetNewfollowhtcount:@"0"];
    }
    
    
    [[NoticeTools getInstance] postClearMessageRead];
}

#pragma mark 其它控件代理监听
-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    // 取消关注
    if(tag==4){
        if(buttonIndex==0){
            [self doFocus:doFocusModel del:YES];
        }
    }
    
}


#pragma mark 数据处理
// 固定代码 , 每次使用只需要将数据模型替换就好 , 这个方法是获取首字母 , 将填充给 cell 的值按照首字母排序
- ( NSMutableArray *)getChineseStringArr:( NSMutableArray *)arrToSort
{
    [_sectionHeadsKeys removeAllObjects];
    // 创建一个临时的变动数组
    NSMutableArray *chineseStringsArray = [ NSMutableArray array ];
    for ( int i = 0 ; i < [arrToSort count ]; i++)
    {
        // 创建一个临时的数据模型对象
        UserInfo *userInfo=[arrToSort objectAtIndex:i];
        [dictData setObject:userInfo forKey:userInfo.uid];
        
        // 给模型赋值
        if (userInfo.nickname == nil )
        {
            userInfo.nickname = @"" ;
        }
        
        if (![userInfo.nickname isEqual: @"" ])
        {
            //join( 链接 ) the pinYin (letter 字母 )  链接到首字母
            NSString *pinYinResult = [ NSString string ];
            // 按照数据模型中 row 的个数循环
            for ( int j = 0 ;j < userInfo.nickname.length ; j++)
            {
                NSString *singlePinyinLetter = [[ NSString stringWithFormat : @"%c" ,
                                                 pinyinFirstLetter([userInfo.nickname characterAtIndex :j])] uppercaseString ];
                pinYinResult = [pinYinResult stringByAppendingString :singlePinyinLetter];
            }
            userInfo.pinYin = pinYinResult;
        } else {
            userInfo.pinYin = @"#";
        }
        
        if(userInfo.pinYin!=nil && userInfo.pinYin.length>0){
            NSMutableString *strchar= [NSMutableString stringWithString:userInfo.pinYin ];
            NSString *sr= [strchar substringToIndex : 1 ];
            if(!validdatePinYin(sr)){
                userInfo.pinYin=@"#";
            }
        }else{
            userInfo.pinYin=@"#";
        }
        
        [chineseStringsArray addObject :userInfo];
    }
    
    //sort( 排序 ) the ChineseStringArr by pinYin( 首字母 )
    NSArray *sortDescriptors = [ NSArray arrayWithObject :[ NSSortDescriptor sortDescriptorWithKey : @"pinYin" ascending : YES ]];
    
    [chineseStringsArray sortUsingDescriptors :sortDescriptors];
    
    
    NSMutableArray *arrayForArrays = [ NSMutableArray array ];
    
    BOOL checkValueAtIndex= NO ;  //flag to check
    
    NSMutableArray *TempArrForGrouping = nil ;
    
    for ( int index = 0 ; index < [chineseStringsArray count ]; index++)
    {
        UserInfo *chineseStr = [chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString :chineseStr.pinYin ];
        NSString *sr= [strchar substringToIndex : 1 ];
        
        // 检查字符是否已经选择头键
        if (![_sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [ _sectionHeadsKeys addObject :[sr uppercaseString ]];
            TempArrForGrouping = [[ NSMutableArray alloc ] initWithObjects : nil];
            checkValueAtIndex = NO ;
        }
        
        if ([_sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:chineseStr];
            if (checkValueAtIndex == NO )
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES ;
            }
        }
    }
    return arrayForArrays;
}


#pragma mark 老用户，但是第一次使用此版本，显示提示
-(void)createChangeNoticeView:(BOOL) isOldUser{
    if(!isOldUser){
        return;
    }
    NSString *show = [SysTools getValueFromNSUserDefaultsByKey:KeyShowFriendChangeToFollow];
    if(show!=nil && [@"1" isEqual:show]){
        return;
    }
    [SysTools syncNSUserDeafaultsByKey:KeyShowFriendChangeToFollow withValue:@"1"];
    
    if(noticeView!=nil)
    {
        [self tableHeaderTap:nil];
        return;
    }
    noticeView =[[UIView alloc] initWithFrame:CGRectMake(0, NavBarHeight, w, 0)];
    [noticeView setBackgroundColor:UIColorFromRGB(LetterListTopBgColor)];
    noticeView.userInteractionEnabled=YES;
    noticeView.tag=10;
    
    UILabel *lblMsg=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth-70, 55)];
    [lblMsg setBackgroundColor:[UIColor clearColor]];
    [lblMsg setNumberOfLines:0];
    [lblMsg setFont:ListDetailFont];
    [lblMsg setText:WebCopy_FriendToFocus_message];
    [lblMsg setTextColor:UIColorFromRGB(LetterListTopTextColor)];
    lblMsg.userInteractionEnabled=YES;
    lblMsg.tag=1;
    [noticeView addSubview:lblMsg];
    
    UIImageView *ivClose=[[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-40, 55/2-10, 20, 20)];
    [ivClose setImage:[UIImage imageNamed:@"letter_listtop_close"]];
    [ivClose setBackgroundColor:[UIColor clearColor]];
    [ivClose setContentMode:UIViewContentModeScaleAspectFill];
    ivClose.userInteractionEnabled=YES;
    ivClose.tag=2;
    [noticeView addSubview:ivClose];
    
    [self.view addSubview:noticeView];
    
    UIGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableHeaderTap:)];
    [ivClose addGestureRecognizer:tap1];
    
    [UIView animateWithDuration:0.2 animations:^{
        [noticeView setFrame:CGRectMake(0, NavBarHeight, w, 55)];
        [listTable setFrame:CGRectMake(0, NavBarHeight+55, self.view.mj_width, self.view.mj_height-NavBarHeight-55)];
    }];
}

#pragma mark 头部点击事件
-(void)tableHeaderTap:(UIGestureRecognizer *)tap{
    // 以后不显示了
    [UIView animateWithDuration:0.2 animations:^{
        if(noticeView!=nil){
            noticeView.alpha=0;
            [noticeView setFrame:CGRectMake(0, NavBarHeight, w, 0)];
        }
        [listTable setFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    } completion:^(BOOL finished) {
        if(noticeView!=nil){
            [noticeView removeFromSuperview];
        }
    }];
}



#pragma mark 空数据UI展示
-(void)checkDataNull{
    if(listArray.count==0){
        [self removePlaceholderView];
        CGPoint center = CGPointMake(self.view.center.x, self.view.center.y-4);
        [self createPlaceholderView:center message:TTLocalString(@"TT_high_cold_he_has_yet_to_pay_attention_to_anybody_quick_to_conquer_him") withView:listTable];
    }else{
        [self removePlaceholderView];
    }
}


//更新用户关系
-(void)updateRelation:(NSNotification *) nsInfo{
    if(nsInfo){
        UserInfo *info=nsInfo.object;
        if(info){
            UserInfo *dInfo = [dictData objectForKey:info.uid];
            if(dInfo){
                dInfo.relation=info.relation;
                
                [listTable reloadData];
            }else{
                [self loadSelfData];
            }
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
