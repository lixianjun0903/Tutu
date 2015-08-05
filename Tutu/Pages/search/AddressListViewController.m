//
//  AddressListViewController.m
//  Tutu
//
//  Created by 刘大治 on 14/12/8.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AddressListViewController.h"
#import "UILabel+Additions.h"
#import "AddressDB.h"
#import "RCLetterController.h"
#import "StartBindController.h"
#import "StopBindController.h"
#import "PinYinForObjc.h"
#import "PinYin4Objc.h"
#import "ChineseInclude.h"
#import "UserDetailController.h"

@interface AddressListViewController ()
{
    BOOL isFristTime;
}
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@property(nonatomic,strong) NSMutableArray *addFriendArray;
@property(nonatomic,strong)NSMutableArray *sectionIndexTitleArray;
@property(nonatomic)NSMutableArray *dataArray;//放所以的数据
@property(nonatomic)NSMutableArray *groupArray;//存放分组的数据
@property(nonatomic)NSMutableArray *commonArray;//存放常用联系人
@property(nonatomic)NSMutableArray *headArray;//存放首字母
@property(nonatomic)NSMutableArray *specialArray;//存放特殊字符，名称除了中文和英文之外的字符
@property(nonatomic)NSMutableArray *searchResults;//存放搜索结果

@property(nonatomic)UIActivityIndicatorView *indicatorView;

@end
static NSString *cellIdentifier = @"AddressFriendCell";
static NSString *cellIdentifier2 = @"Cell";
@implementation AddressListViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)goBack:(id)sender{
    if ([self.navigationController.parentViewController isKindOfClass:[StopBindController class]]) {
        if(self.navigationController.childViewControllers.count>6){
            [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-7] animated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarStyle];
    self.title = @"添加通讯录好友";
    [self createLeftBarItemSelect:@selector(goBack:) imageName:nil heightImageName:nil];
    [_mainTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    _mainTable.rowHeight = 44;
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
    isFristTime = YES;
 
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = @"搜索";
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
        _mainTable.sectionIndexBackgroundColor = [UIColor clearColor];
        self.searchBar.layer.borderWidth = 1;
        self.searchBar.layer.borderColor = [HEXCOLOR(EmotionListBg) CGColor];
        [self.searchBar setBarTintColor:HEXCOLOR(0XC9C9CE)];
        self.searchBar.opaque = YES;
    }else{
        self.mainTable.frame =CGRectMake(0, 44, ScreenWidth, self.view.mj_height - 44);
    }
    [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.strongSearchDisplayController.searchResultsTableView.rowHeight = 44;
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_mainTable setTableFooterView:view];
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.center = CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f);
    [_indicatorView setHidesWhenStopped:YES];
    [self.view addSubview:_indicatorView];
    
    
    [_indicatorView startAnimating];
    
    [self bk_performBlock:^(id obj) {
        [self filterAddressFriend];
    } afterDelay:0.0f];
}
//过滤通讯录好友。按字母排序
- (void)filterAddressFriend{
    
    _dataArray = [[NSMutableArray alloc]init];
    _addFriendArray = [[NSMutableArray alloc]init];
    _groupArray = [[NSMutableArray alloc]init];
    _headArray = [[NSMutableArray alloc]init];
    _sectionIndexTitleArray = [[NSMutableArray alloc]init];
    _specialArray = [[NSMutableArray alloc]init];
    
    AddressDB *db=[[AddressDB alloc] init];
    _dataArray =  [db findAllContacts];
    
    //先过滤一下，把已经注册tutu号的，但不是好友的提出来放到_addFriendArray,其他的放好 otherArray,
    //已特殊字符开头的放在_specialArray;
    
    _addFriendArray = [[NSMutableArray alloc]init];
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    //先把用户名称分成两组，一组首字母是特殊字符的，统一分到分组的#号里面，其他的按钮首字母分组。
    
    
    //把当前用户过滤掉
    NSMutableIndexSet *setM = [[NSMutableIndexSet alloc] init];
    NSString *uid = [[LoginManager getInstance]getUid];
    for (int i = 0; i < _dataArray.count; i ++) {
        LinkManModel *model = _dataArray[i];
        if ([model.tutuid isEqualToString:uid]) {
            [setM addIndex:i];
        }
    }
    [_dataArray removeObjectsAtIndexes:setM];
    
    NSMutableArray *pinyinArray = [@[]mutableCopy];
    for (LinkManModel *info in _dataArray) {
       
//用于测试加好友逻辑
//        if ([info.nickName isEqualToString:@"张新耀"]) {
//            info.relation = 0;
        
//            AddressDB *db=[[AddressDB alloc] init];
//            [db updateContanst:info];
//        }
        @try {
            
        if (info !=nil && info.relation == 0) {
            [_addFriendArray addObject:info];
        }else{
//            if (info.nickName.length == 0) {
//                info.nickName = @"#";
//            }
            NSString *pinyin = [[PinyinHelper  toHanyuPinyinStringWithNSString:info.nickName withHanyuPinyinOutputFormat:outputFormat withNSString:@""]lowercaseString];
            pinyin = [pinyin stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            info.pinyin = pinyin;
            if (pinyin.length > 0) {
                unichar ch = [pinyin characterAtIndex:0];
                if (ch >= 'a' && ch <= 'z' ) {
                    [pinyinArray addObject:info];
                }else{
                    [_specialArray addObject:info];
                }
            }else{
                [_specialArray addObject:info];
            }
        }
            
        }
        @catch (NSException *exception) {
            WSLog(@"%@",exception);
        }
        @finally {
            
        }
    }
    
    NSArray *sortArray = [pinyinArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        LinkManModel *info1 = (LinkManModel *)obj1;
        LinkManModel *info2 = (LinkManModel *)obj2;
        return [info1.pinyin  compare:info2.pinyin];
    }];
    
    NSMutableArray *items = nil;
    for (int i = 0;i < sortArray.count;i ++) {
        
        LinkManModel *model = (LinkManModel *)sortArray[i];
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
    [_sectionIndexTitleArray addObjectsFromArray:_headArray];
    [_sectionIndexTitleArray addObject:@"#" ];
    [_headArray addObject:@"#"];
    [_groupArray addObject:_specialArray];
    if (_addFriendArray.count > 0) {
        [_headArray insertObject:TTLocalString(@"TT_friend_relation") atIndex:0];
        [_sectionIndexTitleArray insertObject:@"+" atIndex:0];
        [_groupArray insertObject:_addFriendArray atIndex:0];
    }
    [_mainTable reloadData];
    
    [_indicatorView stopAnimating];
    

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable) {
       return 25;
    }else
        return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 25)];
        bgView.backgroundColor = HEXCOLOR(EmotionListBg);
        UILabel *titleLabel = [UILabel labelWithBlodFont:12 textColor:HEXCOLOR(TextGrayColor)];
        titleLabel.frame = CGRectMake(8, 6,80, 12);
        [bgView addSubview:titleLabel];
        titleLabel.text = _headArray[section];
        return bgView;

    }
        return nil;
}
#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        return  [(NSArray *)_groupArray[section] count];
    }
    return  _searchResults.count;
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if (scrollView == _mainTable) {
        return YES;
    }
    return NO;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _mainTable) {
       return _headArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddressFriendCell*cell = (AddressFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (tableView == _mainTable) {
        LinkManModel *model = _groupArray[indexPath.section][indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        [cell loadCellWith:model];
        cell.isSearchTabel = NO;
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        return cell;
    }else{
        cell.indexPath = indexPath;
        LinkManModel *model = _searchResults[indexPath.row];
        cell.delegate = self;
        cell.isSearchTabel = YES;
        [cell loadCellWith:model];
        
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        return cell;
    }
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _mainTable) {
      return self.sectionIndexTitleArray;
    }
    return nil;
}
- (void)addFriendButtonClick:(AddressButtonType)buttonType model:(LinkManModel *)model index:(NSIndexPath *)indexPath isSearchTabel:(BOOL)search{
    if (buttonType == ButtonTypeAddFriend) {
#pragma warning  跳转到ApplyFriendController页面
        [[RequestTools getInstance]get:API_Apply_Friend(model.tutuid,@"",@"") isCache:NO completion:^(NSDictionary *dict) {
            model.relation = 2;
            AddressDB *db=[[AddressDB alloc] init];
            [db updateContanst:model];
            if (search == YES) {
                [_searchResults replaceObjectAtIndex:indexPath.row withObject:model];
                [self.strongSearchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                NSInteger a = 0;
                for (int i = 0 ; i < _specialArray.count ; i ++) {
                    LinkManModel *model1 = _specialArray[i];
                    if ([model1.tutuid isEqualToString:model.tutuid]) {
                        model1.relation = 2;
                        a = i;
                        break;
                    }
                }
                [_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:a inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                NSMutableArray *mArray = _groupArray[indexPath.section];
                [mArray replaceObjectAtIndex:indexPath.row withObject:model];
                [_groupArray replaceObjectAtIndex:indexPath.section withObject:mArray];
                [_mainTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
     //添加好友成功后，刷新数据源和cell
    }else if (buttonType == ButtonTypeChat){
        if (search == YES) {
          [self.strongSearchDisplayController setActive:NO];
        }
        RCLetterController *chat = [[RCLetterController alloc] init];
        chat.userid = model.tutuid;
        chat.lastTime=model.createtime;
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        if (model.phonenumber.length > 0 ) {
            [self showMessageView:model.phonenumber isSearch:search];
        }
    }

}
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    if (!iOS7) {
      self.mainTable.frame = CGRectMake(0, 0, ScreenWidth, self.view.mj_height);
        [self.strongSearchDisplayController setActive:YES animated:NO];
        [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        self.strongSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSelectionStyleNone ;
        self.strongSearchDisplayController.searchResultsTableView.rowHeight = 60;
    }
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    if (!iOS7) {
      self.mainTable.frame = CGRectMake(0, 44, ScreenWidth, self.view.mj_height - 44);
        [self.strongSearchDisplayController setActive:NO animated:YES];
    }
}
#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchResults = [[NSMutableArray alloc]init];
    if (_searchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:_searchBar.text]) {
        for (int i=0; i<_dataArray.count; i++) {
            LinkManModel *info = _dataArray[i];
            if ([ChineseInclude isIncludeChineseInString:info.nickName]) {
                NSString *tempPinYinStr = info.pinyin;
                NSRange titleResult=[tempPinYinStr rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:info];
                }

            }
            else {
                NSRange titleResult=[info.nickName rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:info];
                }
            }
            


        }
    } else if (_searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:_searchBar.text]) {
        for (LinkManModel *info in _dataArray) {
            NSString *tempStr = info.nickName;
            NSRange titleResult=[tempStr rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [_searchResults addObject:info];
            }
        }
    }
}
#pragma mark  searchBarDelegate

- (void)showMessageView:(NSString *)numer isSearch:(BOOL)search
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];

        controller.recipients = [NSArray arrayWithObject:numer];

        controller.body = [NSString stringWithFormat:@"%@%@%@",WebCopy_ShareProfleToFridenDesc([LoginManager getInstance].getUid),SHAREURL,[LoginManager getInstance].getUid];
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:^{
            if (search == YES) {
                [self.searchBar resignFirstResponder];
                [self.strongSearchDisplayController setActive:NO animated:NO];
            }

        }];
        
    }else{
        
        [self alertWithTitle:TTLocalString(@"TT_alert_message") msg:@"TT_equipment_is_not_message_function"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView==_mainTable){
        LinkManModel *model = _groupArray[indexPath.section][indexPath.row];
        if (model.relation != -1) {
            UserDetailController *vc = [[UserDetailController alloc]init];
            vc.uid = model.tutuid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        [self.strongSearchDisplayController setActive:NO animated:NO];
        LinkManModel *model = _searchResults[indexPath.row];
        if (model.relation != -1) {
            UserDetailController *vc = [[UserDetailController alloc]init];
            vc.uid = model.tutuid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

// MFMessageComposeViewControllerDelegate
#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:^{
        
    }];//关键的一句   不能为YES
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
           // [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
           // [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        case MessageComposeResultSent:
           // [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        default:
            break;
    }
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:TTLocalString(@"TT_make_sure"), nil];
    
    [alert show];  
    
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
