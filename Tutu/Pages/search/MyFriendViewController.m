//
//  MyFriendViewController.m
//  Tutu
//
//  Created by feng on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "MyFriendViewController.h"
#import "FriendSearchController.h"
#import "UserDetailController.h"
#import "RCLetterController.h"
#import "BaseController+ScrollNavbar.h"
#import "UserSettingController.h"
#import "PinYin4Objc.h"
#import "PinYinForObjc.h"
#import "ChineseInclude.h"
#import "UILabel+Additions.h"
#import "UserInfoDB.h"
#import "SynchMarkDB.h"
#import "NewFriendViewController.h"
@interface MyFriendViewController ()
@property(nonatomic,strong)NSString *startuid;
@property(nonatomic,strong)NSString *direction;
@property(nonatomic)NSInteger len;
@property(nonatomic)NSInteger totalCount;
@property(nonatomic)NSIndexPath *cellIndexPath;
@property(nonatomic)UserInfo *currentUserModel;

@property(nonatomic)UISearchBar *searchBar;
@property(nonatomic)UISearchDisplayController *strongSearchDisplayController;
@property(nonatomic)NSMutableArray *groupArray;//存放分组的数据
@property(nonatomic)NSMutableArray *commonArray;//存放常用联系人
@property(nonatomic)NSMutableArray *headArray;//存放首字母
@property(nonatomic)NSMutableArray *specialArray;//存放特殊字符，名称除了中文和英文之外的字符
@property(nonatomic)NSMutableArray *searchResults;//存放搜索结果
@property(nonatomic)UIActivityIndicatorView *indicatorView;
@property(nonatomic)NSInteger messageCount;
@property(nonatomic)BOOL isMessageCountNeedClear;
@end


static NSString *cellIdentifier = @"MyFriendCell";
static NSString *addFriendHeadCell = @"AddFriendHeadCell";
@implementation MyFriendViewController
-(void)backBtnClick:(UIButton *)btn{
    if (_comeForm == 1) {
        //进入首页
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }else{
    
       [self.navigationController popViewControllerAnimated:YES];
    
    }
    
}
- (void)rightButtonClick:(id)sender{
    FriendSearchController *vc = [[FriendSearchController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leftButtonClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isMessageCountNeedClear = NO;
    _startuid = @"";
    _len = 1000;
    _messageCount = 0;
    // 不等于 1 表示是我的好友列表，需要在导航栏右边创建添加好友的按钮。
    if (_comeForm != 1) {
        UIButton *addButton = [self createRightBarItemSelect:@selector(rightButtonClick:) imageName:@"friend_add" heightImageName:@"friend_add_hl"];
        addButton.frame = CGRectMake(0, 0, 23, 24);
        [addButton setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
    }
    [self createLeftBarItemSelect:@selector(leftButtonClick:) imageName:nil heightImageName:nil];
    
    self.title = TTLocalString(@"TT_buddy");
    _mainTable = [[UITableView alloc]init];
    [_mainTable registerNib:[UINib nibWithNibName:@"MyFriendCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [_mainTable registerNib:[UINib nibWithNibName:addFriendHeadCell bundle:nil] forCellReuseIdentifier:addFriendHeadCell];
    
    [_mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _mainTable.frame = CGRectMake(0,0, ScreenWidth, self.view.mj_height);
    
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.rowHeight = 66;
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
    if (iOS7) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
    }
    UIView *footView = [[UIView alloc]initWithFrame:CGRectZero];
    _mainTable.tableFooterView = footView;
    [self.view addSubview:_mainTable];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = TTLocalString(@"TT_search");
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    
    _mainTable.tableHeaderView = self.searchBar;
    
    //self.searchBar.frame = CGRectMake(0, 0, ScreenWidth, 44);
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (iOS7) {
        self.searchBar.layer.borderWidth = 1;
        self.strongSearchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(60, 0, 0, 0);
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
    _strongSearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
  //  [self.mainTable addHeaderWithTarget:self action:@selector(refreshData)];
  //  [self.mainTable addFooterWithTarget:self action:@selector(loadMoreData)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMyFriendList) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteMyFriend:) name:NOTICE_DELADDFRIEND object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNotictInfo:) name:NOTICE_UPDATE_UserInfo object:nil];
    
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.center = CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f);
    [_indicatorView setHidesWhenStopped:YES];
    [self.view addSubview:_indicatorView];
    [_indicatorView startAnimating];
    [self bk_performBlock:^(id obj) {
       [self loadDataFromDB];
        [_indicatorView stopAnimating];
       [self updateMyFriendList];
       [self getFriendApplayMessageCount];
    } afterDelay:0.0F];
    
    //加载本地数据，并进行分组处理。

}
- (void)loadDataFromDB{
    UserInfoDB *db = [[UserInfoDB alloc]init];
    
    _dataArray = [[NSMutableArray alloc]init];
    //储存分组的数据
    _groupArray = [[NSMutableArray alloc]init];
    //储存分组的字母
    _headArray = [[NSMutableArray alloc]init];
    //储存常用的联系人
    _commonArray = [[NSMutableArray alloc]init];
    _specialArray = [[NSMutableArray alloc]init];
    //从数据库中获得数据
    NSArray *dbArray = [db findMyFriends];
    
    [_dataArray addObjectsFromArray:dbArray];
    
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    //先把用户名称分成两组，一组首字母是特殊字符的，统一分到分组的#号里面，其他的按钮首字母分组。
    NSMutableArray *pinyinArray = [@[]mutableCopy];
    for (UserInfo *info in _dataArray) {
        NSString *pinyin = [[PinyinHelper  toHanyuPinyinStringWithNSString:info.nickname withHanyuPinyinOutputFormat:outputFormat withNSString:@""]lowercaseString];
        info.pinyin = pinyin;
        if (pinyin.length > 0) {
            unichar ch = [pinyin characterAtIndex:0];
            if (ch >= 'a' && ch <= 'z') {
                [pinyinArray addObject:info];
            }else{
                [_specialArray addObject:info];
            }
        }else{
            [_specialArray addObject:info];
        }
    }
    
    NSArray *sortArray = [pinyinArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UserInfo *info1 = (UserInfo *)obj1;
        UserInfo *info2 = (UserInfo *)obj2;
        return [info1.pinyin  compare:info2.pinyin];
    }];
    
    NSMutableArray *items = nil;
    for (int i = 0;i < sortArray.count;i ++) {
        
        UserInfo *model = (UserInfo *)sortArray[i];
        NSString *firstLetter = [[model.pinyin substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        if (![_headArray containsObject:firstLetter]) {
            [_headArray addObject:firstLetter];
            if (items.count > 0) {
                [_groupArray addObject:items];
            }
            items = [@[]mutableCopy];
        }
        [items addObject:model];
        if (i == sortArray.count - 1) {
            [_groupArray addObject:items];
        }
    }
    
    if (_specialArray.count > 0){
        [_headArray addObject:@"#"];
        [_groupArray addObject:_specialArray];
    }
    
    //为保证第一个section 0 Ok,填充了一些假数据
    [_headArray insertObject:@"" atIndex:0];
    [_groupArray insertObject:@[ FormatString(@"%ld",(long)_messageCount) ] atIndex:0];
    [_mainTable reloadData];
}

- (void)deleteMyFriend:(NSNotification *)notifi{
    [self loadDataFromDB];
}
//从本地加载好友列表

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)updateNotictInfo:(NSNotification *)not{
    UserInfo *info=not.object;
    if(info){
        for (int i=0;i<_dataArray.count;i++) {
            UserInfo *item=[_dataArray objectAtIndex:i];
            if([item.uid isEqual:info.uid]){
                item.nickname=info.remarkname;
            }
        }
        [_mainTable reloadData];
    }
}
//获得好友申请的消息数
- (void)getFriendApplayMessageCount{
    [[RequestTools getInstance]get:API_friend_getnewapplycount isCache:NO completion:^(NSDictionary *dict) {
        NSInteger msgCount = [dict[@"data"] integerValue];
        _messageCount = msgCount;
        if (!_isMessageCountNeedClear) {
            if (_messageCount > 0) {
                [_groupArray replaceObjectAtIndex:0 withObject:@[FormatString(@"%ld", (long)_messageCount)]];
            }
            [_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
/**
 *  从服务器更新好友列表
 */
- (void)updateMyFriendList{

    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    NSString *localUpdateTime=[db findWidthUID:SynchMarkTypeUserInfo];
    UserInfoDB *userinfoDB = [[UserInfoDB alloc]init];
    NSString *localNewTime = [userinfoDB findNewUserInfo].addtime;
    NSString *localLastTime = [userinfoDB findOldUserInfo].addtime;
    
    [[RequestTools getInstance]get:API_Sync_My_Friend(localNewTime, localLastTime, localUpdateTime) isCache:NO completion:^(NSDictionary *dict) {
        NSDictionary *data = dict[@"data"];
        NSArray *addlist = data[@"addlist"];
        NSArray *dellist = data[@"dellist"];
        NSString *updatetime = [data[@"updatetime"] stringValue];
        
        for (NSDictionary *dic in addlist) {
            
            UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
            if(![[[LoginManager getInstance] getUid] isEqual:info.uid]){
                [userinfoDB saveUser:info];
            }
        }
        for (NSDictionary *dic in dellist) {
            UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
            [userinfoDB deleteUserInfoByUID:info.uid];
        }
        [db updateSynchMark:SynchMarkTypeUserInfo withTime:updatetime];
        
        [self loadDataFromDB];
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
    } finished:^(ASIHTTPRequest *request) {
        
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        return [_groupArray[section] count];
    }else{
        return _searchResults.count;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _mainTable) {
       return _headArray.count;
    }else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _mainTable) {
        if (indexPath.section == 0 ) {
            AddFriendHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:addFriendHeadCell forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell cellReloadWith:_groupArray[0][0]];
            
            [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
            [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
            return cell;
        }else{
            MyFriendCell *cell = (MyFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.cellDelegate = self;
            cell.delegate = self;
            UserInfo *model = _groupArray[indexPath.section][indexPath.row];
            if ([[LoginManager getInstance]isLogin]) {
                cell.isLogin = YES;
            }else{
                cell.isLogin = NO;
            }
            [cell cellReloadWithModel:model];
            [cell setRightUtilityButtons:[cell setRightButtons]];
            
            [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
            [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
            return cell;
        }
    }else{
        MyFriendCell *cell = (MyFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.cellDelegate = self;
        cell.delegate = self;
        UserInfo *model = _searchResults[indexPath.row];
        if ([[LoginManager getInstance]isLogin]) {
            cell.isLogin = YES;
        }else{
            cell.isLogin = NO;
        }
        [cell cellReloadWithModel:model];
        [cell setRightUtilityButtons:[cell setRightButtons]];
        
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        return cell;
    
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && tableView == _mainTable) {
        return 71;
    }else
        return 77;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable ) {
        UIView *headView = [[UIView alloc] init];
        headView.backgroundColor = HEXCOLOR(0xF8F8F8);
        headView.frame = CGRectMake(0, 0, ScreenWidth, 25);
        UILabel *headLabel = [UILabel labelWithSystemFont:12 textColor:HEXCOLOR(0xA0A0A0)];
        headLabel.frame = CGRectMake(10, 6, 200, 13);
        [headView addSubview:headLabel];
        headLabel.text = _headArray[section];
        return headView;
    }else
        return nil;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        if (section == 0) {
            return 0;
        }else
            return 25;
    }
    return 0;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _mainTable) {
        
        return self.headArray;
    }
    return nil;
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
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *model = nil;
    if (tableView == _mainTable) {
        if (indexPath.section == 0) {
            
        }else{
            model = _groupArray[indexPath.section][indexPath.row];
        }
        
    }else{
        model = _searchResults[indexPath.row];
    }
    if (model) {
      //  [_searchBar resignFirstResponder];
        [_strongSearchDisplayController setActive:NO animated:NO];
        UserDetailController *vc = [[UserDetailController alloc]init];
        vc.uid = model.uid;
        [self openNavWithSound:vc];
    }else{
        _isMessageCountNeedClear = YES;
        _messageCount = 0;
        [_groupArray removeObjectAtIndex:0];
        [_groupArray insertObject:@[@"0"] atIndex:0];
        [_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        NewFriendViewController *vc = [[NewFriendViewController alloc]init];
        [vc setUpdateBlock:^(id objc ,NSInteger type){
            //type == 1,需要刷新好友申请的数目
            //type == 2,需要刷新好友列表
            if (type == 1) {

            }else if (type == 2){
                [self updateMyFriendList];
            }
        }];
        [self openNavWithSound:vc];
    }
}
#pragma mark UISearchControllerDelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    
}
#pragma mark SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
}

// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    MyFriendCell *mycell = (MyFriendCell *)cell;
    NSIndexPath *cellIndexpath = [_mainTable indexPathForCell:mycell];
    _cellIndexPath = cellIndexpath;

    UserInfo *model = mycell.userModel;
    _currentUserModel = model;
    if (index == 0) {
       [_mainTable reloadRowsAtIndexPaths:@[cellIndexpath] withRowAnimation:UITableViewRowAnimationNone];
        UserSettingController *vc = [[UserSettingController alloc]init];
        vc.userInfo = model;
        [self openNavWithSound:vc];
    }
}
- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    UserInfo *model = _currentUserModel;
    NSIndexPath *cellIndexpath = _cellIndexPath;
    if (buttonIndex == 0) {
        [[RequestTools getInstance]get:[NSString stringWithFormat:@"%@?frienduid=%@",API_MY_FRIEND_DELETE,model.uid] isCache:NO completion:^(NSDictionary *dict) {
            if ([model.relation integerValue] == 3) {
                model.relation = @"1";
            }else{
                model.relation = @"0";
            }
            if ([dict[@"code"] integerValue] == 10000 ) {
                [_dataArray removeObjectAtIndex:cellIndexpath.row];
                [_dataArray insertObject:model atIndex:cellIndexpath.row];
                [_mainTable reloadRowsAtIndexPaths:@[cellIndexpath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
            
            @try {
                [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:model.uid];
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:model.uid];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];

    }
}

// utility button open/close event
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{

}

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

// prevent cell(s) from displaying left/right utility buttons
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    MyFriendCell *cell2 = (MyFriendCell *)cell;
    UserInfo *model = cell2.userModel;
    if (state == kCellStateRight) {
        //当是本人的时候，不能从右边划开
        if ([[LoginManager getInstance]isLogin] && [model.relation integerValue] != 4) {
            return YES;
        }else
        return NO;
    }else
        return NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [_strongSearchDisplayController.navigationItem setHidesBackButton:NO];
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{

    if (scrollView == _mainTable) {
        [self showNavBarAnimated:YES];
        return YES;
    }else
        return NO;
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
