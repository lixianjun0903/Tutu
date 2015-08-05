//
//  ShareTutuFriendsController.m
//  Tutu
//
//  Created by gexing on 14/12/10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ShareTutuFriendsController.h"
#import "MJRefresh.h"
#import "MyFriendCell.h"
#import "RCRichContentMessage.h"
#import "RCIMClient.h"
#import "SDWebImageManager.h"
#import "PinYin4Objc.h"
#import "UILabel+Additions.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "UserInfoDB.h"
#import "NewFriendViewController.h"
#import "SynchMarkDB.h"
#import "ChineseFirstLetter.h"

@interface ShareTutuFriendsController ()
@property(nonatomic,strong)NSString *startuid;
@property(nonatomic,strong)NSString *direction;
@property(nonatomic)NSInteger len;
@property(nonatomic)NSInteger totalCount;
@property(nonatomic)UISearchBar *searchBar;
@property(nonatomic)UISearchDisplayController *strongSearchDisplayController;

//@property(nonatomic)NSMutableArray *commonArray;//存放常用联系人
//@property(nonatomic)NSMutableArray *headArray;//存放首字母
//@property(nonatomic)NSMutableArray *specialArray;//存放特殊字符，名称除了中文和英文之外的字符
@property(nonatomic)NSMutableArray *searchResults;//存放搜索结果
@property(nonatomic)UIActivityIndicatorView *indicatorView;
@end
static NSString *cellIdentifier = @"MyFriendCell";

@implementation ShareTutuFriendsController{
    NSMutableArray *_sectionHeadsKeys;
    NSMutableArray *sortedArrForArrays;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [_indicatorView startAnimating];
    
    [self bk_performBlock:^(id obj) {
        [self loadDataFromDB];
        [self updateMyFriendList];
        
        [_indicatorView stopAnimating];
    } afterDelay:0.0f];
}
- (void)keyboardWillChange:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    [_shareView.backGroundView setFrame:CGRectMake(_shareView.backGroundView.mj_x, ScreenHeight - keyboardRect.size.height - _shareView.backGroundView.mj_height, _shareView.backGroundView.mj_width, _shareView.backGroundView.mj_height)];
}
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarItemSelect:@selector(buttonClick:) imageName:nil heightImageName:nil];
    self.title = TTLocalString(@"TT_share_to");

    _len = 1000;
    
    _mainTable.separatorStyle = UITableViewCellSelectionStyleNone;
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_mainTable setTableFooterView:view];
    _mainTable.rowHeight = 77;
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_mainTable registerNib:[UINib nibWithNibName:@"MyFriendCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    _mainTable.frame = CGRectMake(0, 0, ScreenWidth, SelfViewHeight);
    [self.view addSubview:_mainTable];
    
    //[_mainTable headerBeginRefreshing];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = TTLocalString(@"TT_search");
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    
    _mainTable.tableHeaderView = self.searchBar;
    
    //self.searchBar.frame = CGRectMake(0, 0, ScreenWidth, 44);
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.strongSearchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (iOS7) {
        self.searchBar.layer.borderWidth = 1;
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
        _mainTable.sectionIndexBackgroundColor = [UIColor clearColor];
        self.searchBar.layer.borderColor = [HEXCOLOR(EmotionListBg) CGColor];
        [self.searchBar setBarTintColor:HEXCOLOR(0XC9C9CE)];
        self.searchBar.opaque = YES;
    }else{
        self.mainTable.frame =CGRectMake(0, 44, ScreenWidth, self.view.mj_height - 44);
    }
    [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.strongSearchDisplayController.searchResultsTableView.rowHeight = 77;
    _strongSearchDisplayController.searchResultsTableView.tableFooterView = [[UITableView alloc]initWithFrame:CGRectZero];
    
    UIView *footView =[ [UIView alloc]init];
    footView.backgroundColor = [UIColor clearColor];
    [_mainTable setTableFooterView:footView];
    
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.center = CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f);
    [_indicatorView setHidesWhenStopped:YES];
    [self.view addSubview:_indicatorView];

}

- (void)loadDataFromDB{
    //从数据库中获得数据
    
    _dataArray = [[NSMutableArray alloc]init];
    //储存分组的数据
    _sectionHeadsKeys = [[NSMutableArray alloc]init];
    //储存分组的字母
    sortedArrForArrays = [[NSMutableArray alloc]init];
    
    
    UserInfoDB *db = [[UserInfoDB alloc]init];
    
    
    
    
    NSArray *dbArray = [db findMyFriends];
    [_dataArray addObjectsFromArray:dbArray];
    
    
    NSMutableArray *mArray = [@[]mutableCopy];
    
    NSMutableArray *_commonArray=[[NSMutableArray alloc] init];
    NSInteger topCount = 3;
    //取出来top3
    if (dbArray.count > topCount) {
        [_commonArray addObjectsFromArray:[_dataArray subarrayWithRange:NSMakeRange(0, topCount)]];
        [mArray addObjectsFromArray:[_dataArray subarrayWithRange:NSMakeRange(topCount, _dataArray.count - topCount)]];
        
        sortedArrForArrays=[self getChineseStringArr:mArray];
    }else{
        [_commonArray addObjectsFromArray:dbArray];
    }

    [_sectionHeadsKeys insertObject:TTLocalString(@"TT_common_contacts") atIndex:0];
    [sortedArrForArrays insertObject:_commonArray atIndex:0];
    
    [_mainTable reloadData];

}
- (void)updateMyFriendList{
    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    NSString *localUpdateTime=[db findWidthUID:SynchMarkTypeUserInfo];
    UserInfoDB *userinfoDB = [[UserInfoDB alloc]init];
    NSString *localNewTime = [userinfoDB findNewUserInfo].addtime;
    NSString *localLastTime = [userinfoDB findOldUserInfo].addtime;
    
    [[RequestTools getInstance]get:API_Sync_My_Friend(localNewTime,localLastTime,localUpdateTime) isCache:NO completion:^(NSDictionary *dict) {
        NSDictionary *data = dict[@"data"];
        NSArray *addlist = data[@"addlist"];
        NSArray *dellist = data[@"dellist"];
        NSString *updatetime = [data[@"updatetime"] stringValue];
        
        for (NSDictionary *dic in addlist) {
            UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
            [userinfoDB saveUser:info];
        }
        for (NSDictionary *dic in dellist) {
            UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
            [userinfoDB deleteUserInfoByUID:info.uid];
        }
        [db saveSynchData:SynchMarkTypeUserInfo withTime:updatetime];
        
        [self loadDataFromDB];
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
- (void)refreshData{
    
    if (_dataArray.count == 0) {
        _startuid = @"";
    }else{
        _startuid =  ((UserInfo *)_dataArray[0]).uid;
    }
    _direction = @"up";
    NSString *upApi = [NSString stringWithFormat:@"%@?uid=%@&startuid=%@&len=%ld&direction=%@",API_MY_FRIENDS_GET,_uid,_startuid,(long)_len,_direction];
    [[RequestTools getInstance]get:upApi isCache:NO completion:^(NSDictionary *dict) {
        
        NSInteger code = [dict[@"code"]integerValue];
        if (code == 10000) {
            NSArray *datas = dict[@"data"][@"list"];
            _totalCount = [dict[@"data"][@"total"]  integerValue];
            if (datas.count > 0) {
                NSMutableArray *mArray = [@[]mutableCopy];
                for (NSDictionary *dic in datas) {
                    UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
                    [mArray addObject:model];
                    UserInfoDB *db = [[UserInfoDB alloc]init];
                    [db saveUser:model];
                }
                
                [self loadDataFromDB];
//                NSIndexSet *indexs = [NSIndexSet indexSetWithIndexesInRange:
//                                      NSMakeRange(0,[mArray count])];
//                 [_dataArray insertObjects:mArray atIndexes:indexs];
//              //  [_mainTable reloadData];
//                
//                if (_totalCount > _dataArray.count) {
//                    [[_mainTable getRefreshFooter]setHidden:NO];
//                }else{
//                    [[_mainTable getRefreshFooter]setHidden:YES];
//                }
            }
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [self.mainTable headerEndRefreshing];
    }];
}

- (void)loadMoreData{
    if (_dataArray.count >= _totalCount) {
        [_mainTable footerEndRefreshing];
        [[_mainTable getRefreshFooter]setHidden:YES];
        return;
    }
    _direction = @"down";
    _startuid = ((UserInfo *)[_dataArray lastObject]).uid;
    NSString *downApi = [NSString stringWithFormat:@"%@?uid=%@&startuid=%@&len=%ld&direction=%@",API_MY_FRIENDS_GET,_uid,_startuid,(long)_len,_direction];
    [[RequestTools getInstance]get:downApi isCache:NO completion:^(NSDictionary *dict) {
        
        NSInteger code = [dict[@"code"]integerValue];
        if (code == 10000) {
            NSArray *datas = dict[@"data"][@"list"];
            NSMutableArray *mArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in datas) {
                UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
                [mArray addObject:model];
            }
            [_dataArray addObjectsFromArray:mArray];
            [_mainTable reloadData];
            if (_totalCount > _dataArray.count) {
                [[_mainTable getRefreshFooter]setHidden:NO];
            }else{
                [[_mainTable getRefreshFooter]setHidden:YES];
            }
            
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [self.mainTable footerEndRefreshing];
    }];
    
}
#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _mainTable) {
        return  [[sortedArrForArrays objectAtIndex:section] count];
    }else{
        return _searchResults.count;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(tableView==_mainTable){
        NSMutableArray *indexTitles = [[NSMutableArray alloc] initWithArray:_sectionHeadsKeys];
        if (indexTitles.count > 0) {
            [indexTitles replaceObjectAtIndex:0 withObject:@""];
        }
        return indexTitles;
    }else{
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _mainTable) {
        return [sortedArrForArrays count];
    }else{
        return 1;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        if (section == 0) {
            return 25;
        }else
            return 25;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable ) {
        UIView *headView = [[UIView alloc] init];
        headView.backgroundColor = HEXCOLOR(0xF8F8F8);
        headView.frame = CGRectMake(0, 0, ScreenWidth, 25);
        UILabel *headLabel = [UILabel labelWithSystemFont:12 textColor:HEXCOLOR(0xA0A0A0)];
        headLabel.frame = CGRectMake(10, 6, 200, 13);
        [headView addSubview:headLabel];
        headLabel.text = [_sectionHeadsKeys objectAtIndex:section];
        return headView;
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyFriendCell *cell = (MyFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.cellType = CellTypeShareMyFriend;
    if (_mainTable == tableView) {
        UserInfo *model = sortedArrForArrays[indexPath.section][indexPath.row];
        [cell cellReloadWithModel:model];
    }else{
        UserInfo *model = _searchResults[indexPath.row];
        [cell cellReloadWithModel:model];
    }
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *model = nil;
    if (tableView == _mainTable) {
       model = sortedArrForArrays[indexPath.section][indexPath.row];
    }else{
       model = _searchResults[indexPath.row];
    }
    if(self.rcmsg!=nil){
        if([self.rcmsg.objectName isEqual:RCImageMessageTypeIdentifier]){
            RCImageMessage *msg=(RCImageMessage *)self.rcmsg.content;
            _shareView =[[ShareCustomView alloc] initWithDelegate:self imageURL:msg.imageUrl uid:model];
        }else if([self.rcmsg.objectName isEqual:RCRichContentMessageTypeIdentifier]){
            RCRichContentMessage *msg=(RCRichContentMessage *)self.rcmsg.content;
            if([@"0001" isEqual:self.rcmsg.targetId]){
                _shareView =[[ShareCustomView alloc] initWithDelegate:self imageURL:msg.imageURL uid:model title:msg.title message:msg.digest];
            }else{
                _shareView =[[ShareCustomView alloc] initWithDelegate:self imageURL:msg.imageURL uid:model];
            }
        }
    }else if(_focusModel!=nil){
        _shareView =[[ShareCustomView alloc] initWithDelegate:self imageURL:_focusModel.topicModel.sourcepath uid:model title:_focusModel.idtext message:_focusModel.topicModel.topicDesc];
    }else{
        BOOL hasDesc=![@"" isEqual:_topicModel.topicDesc];
        NSString *messageDesc=hasDesc?_topicModel.topicDesc:WebCopy_ShareTuFriendDesc;
        _shareView =[[ShareCustomView alloc] initWithDelegate:self imageURL:_topicModel.sourcepath uid:model title:_topicModel.nickname message:messageDesc];
//         _shareView =[[ShareCustomView alloc] initWithDelegate:self imageURL:_topicModel.sourcepath uid:model];
    }
    
   
    [_shareView showInView:self.view];
}
#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchResults = [[NSMutableArray alloc]init];
    if (_searchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:_searchBar.text]) {
        for (int i=0; i<_dataArray.count; i++) {
            UserInfo *info = _dataArray[i];
            if ([ChineseInclude isIncludeChineseInString:info.nickname]) {
                NSString *tempPinYinStr = info.pinyin;
                NSRange titleResult=[tempPinYinStr rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:info];
                }
            }
            else {
                NSRange titleResult=[info.nickname rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:info];
                }
            }
            NSRange numerResult = [info.uid rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
            if (numerResult.length > 0 && ![_searchResults containsObject:info]) {
                [_searchResults addObject:info];
            }
        }
    } else if (_searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:_searchBar.text]) {
        for (UserInfo *info in _dataArray) {
            NSString *tempStr = info.nickname;
            NSRange titleResult=[tempStr rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [_searchResults addObject:info];
            }
        }
    }
}

- (void) shareButtonClick:(UIButton *)btn title:(NSString *)title content:(NSString *)content message:(NSString *)message uid:(UserInfo *)userInfo{
   //
    if (ApplicationDelegate.isConnect == YES) {
        if(self.rcmsg!=nil){
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            if(userInfo.topicblock || userInfo.isblockme){
                [dict setObject:@"1" forKey:@"isblock"];
            }
            if([self.rcmsg.objectName isEqual:RCImageMessageTypeIdentifier]){
                RCImageMessage *imageMessage=(RCImageMessage*)self.rcmsg.content;
                WSLog(@"%@",imageMessage.imageUrl);
                
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageMessage.imageUrl] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    RCImageMessage *imageModel=[RCImageMessage messageWithImage:image];
                    imageModel.extra=[dict JSONString];
                    
                    imageMessage.extra=[dict JSONString];
                    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:imageModel delegate:nil object:userInfo.uid];
                    
                    if([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                        RCTextMessage *textmessage=[RCTextMessage messageWithContent:message];
                        [textmessage setExtra:[dict JSONString]];
                        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:textmessage delegate:nil object:userInfo.uid];
                    }
                }];
            }else if([self.rcmsg.objectName isEqual:RCRichContentMessageTypeIdentifier]){
                RCRichContentMessage *content=(RCRichContentMessage *)self.rcmsg.content;
                
                [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:content delegate:nil object:userInfo.uid];
                
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
                if(userInfo.topicblock || userInfo.isblockme){
                    [dict setObject:@"1" forKey:@"isblock"];
                }
                if([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                    RCTextMessage *textmessage=[RCTextMessage messageWithContent:message];
                    [textmessage setExtra:[dict JSONString]];
                    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:textmessage delegate:nil object:userInfo.uid];
                }
            }
        }else if(_topicModel!=nil){
            NSString *url=[NSString stringWithFormat:@"Tutu://topicid=%@",_topicModel.topicid];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setObject:FormatString(@"%@ >>", TTLocalString(@"TT_look_more")) forKey:@"buttonText"];
            [dict setObject:url forKey:@"buttonlink"];
            [dict setObject:url forKey:@"contentLink"];
            [dict setObject:_topicModel.topicid forKey:@"ptId"];
            if(userInfo.topicblock || userInfo.isblockme){
                [dict setObject:@"1" forKey:@"isblock"];
            }
            
            
            RCRichContentMessage *rcmessage=[RCRichContentMessage messageWithTitle:title digest:content imageURL:_topicModel.sourcepath extra:[dict JSONString]];
            [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:rcmessage delegate:nil object:userInfo.uid];
            
            if([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                RCTextMessage *textmessage=[RCTextMessage messageWithContent:message];
                [textmessage setExtra:[dict JSONString]];
                [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:textmessage delegate:nil object:userInfo.uid];
            }
        }else if(self.message!=nil){
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            if(userInfo.topicblock || userInfo.isblockme){
                [dict setObject:@"1" forKey:@"isblock"];
            }
            RCTextMessage *textmessage=[RCTextMessage messageWithContent:self.message];
            [textmessage setExtra:[dict JSONString]];
            [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:textmessage delegate:nil object:userInfo.uid];
            if([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                //追加信息
                RCTextMessage *textmsg=[RCTextMessage messageWithContent:message];
                [textmsg setExtra:[dict JSONString]];
                [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:textmsg delegate:nil object:userInfo.uid];
            }
        }else if(self.focusModel!=nil){
            NSString *url=[NSString stringWithFormat:@"Tutu://topicstring##%@/type##%d/poiid##%@/topicid=%@",self.focusModel.idtext,self.focusType,self.focusModel.ids,self.focusModel.topicModel.topicid];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setObject:FormatString(@"%@ >>", TTLocalString(@"TT_look_more")) forKey:@"buttonText"];
            [dict setObject:url forKey:@"buttonlink"];
            [dict setObject:url forKey:@"contentLink"];
            if([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                [dict setObject:message forKey:@"sendmsg"];
            }
            [dict setObject:self.focusModel.ids forKey:@"ptId"];
            if(userInfo.topicblock || userInfo.isblockme){
                [dict setObject:@"1" forKey:@"isblock"];
            }
            
            
            RCRichContentMessage *rcmessage=[RCRichContentMessage messageWithTitle:self.focusModel.idtext digest:_focusModel.topicModel.topicDesc imageURL:_focusModel.topicModel.sourcepath extra:[dict JSONString]];
            [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:rcmessage delegate:nil object:userInfo.uid];
            
            if([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                RCTextMessage *textmessage=[RCTextMessage messageWithContent:message];
                [dict setObject:@"1" forKey:@"dodelete"];
                [textmessage setExtra:[dict JSONString]];
                [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:userInfo.uid content:textmessage delegate:self object:userInfo.uid];
            }
        }
    }
    [_shareView shareViewDismiss];
    [self bk_performBlock:^(id obj) {
        [_searchBar resignFirstResponder];
        [_strongSearchDisplayController setActive:NO animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    } afterDelay:0.3];
    
}



-(void)responseSendMessageStatus:(RCErrorCode)errorCode messageId:(long)messageId object:(id)object{
    //删除自己发送的无用消息
    NSArray *arr=[NSArray arrayWithObject:[NSNumber numberWithLong:messageId]];
    [[RCIMClient sharedRCIMClient] deleteMessages:arr];
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
