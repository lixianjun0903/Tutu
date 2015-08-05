//
//  ContactsViewController.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-13.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ContactsViewController.h"

#import "UILabel+Additions.h"
#import "AddressDB.h"
#import "RCLetterController.h"
#import "StartBindController.h"
#import "StopBindController.h"

#import "UserDetailController.h"

@interface ContactsViewController (){
    UITableView *_mainTable;
}
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@end
static NSString *cellIdentifier = @"AddressFriendCell";
static NSString *cellIdentifier2 = @"Cell";
@implementation ContactsViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    if(iOS7){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        if ([self.navigationController.parentViewController isKindOfClass:[StopBindController class]]) {
            if(self.navigationController.childViewControllers.count>6){
                [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-7] animated:YES];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_add_contacts_friend") forState:UIControlStateNormal];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    self.menuRightButton.hidden=YES;
    
    int sh=iOS7?0:20;
    int tableHeight=self.view.mj_height-NavBarHeight-sh;
    _mainTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.frame.size.width, tableHeight)];
    [_mainTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    _mainTable.rowHeight = 60;
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
    if (iOS7) {
        _mainTable.sectionIndexBackgroundColor = [UIColor clearColor];
        
    }
    _mainTable.delegate=self;
    _mainTable.dataSource=self;
    [self.view addSubview:_mainTable];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = TTLocalString(@"TT_search");
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.strongSearchDisplayController.delegate = self;
    
    
    
    //头部色条
    UIView *ivbg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, StatusBarHeight)];
    [ivbg setBackgroundColor:UIColorFromRGB(SystemColor)];
//    [self.strongSearchDisplayController.searchContentsController.view addSubview:ivbg];
//    [self.strongSearchDisplayController.searchResultsTableView setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.translucent = NO;
    _mainTable.tableHeaderView = self.searchBar;
    
    if (iOS7) {
        self.searchBar.layer.borderWidth = 1;
        self.searchBar.layer.borderColor = [HEXCOLOR(EmotionListBg) CGColor];
        
        [self.searchBar setBarTintColor:HEXCOLOR(0XC9C9CE)];
        self.searchBar.opaque = YES;
    }
    
    [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.strongSearchDisplayController.searchResultsTableView.rowHeight = 60;
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_mainTable setTableFooterView:view];
    
    [self.strongSearchDisplayController.searchResultsTableView setTableFooterView:view];
    
    // Do any additional setup after loading the view from its nib.
    _friendsArray = [[NSMutableArray alloc]init];
    _letterArray = [[NSMutableArray alloc]init];
    _searchArray = [[NSMutableArray alloc]init];
    _searchDic = [[NSMutableDictionary alloc]init];
    [self bk_performBlock:^(id obj) {
        AddressDB *db=[[AddressDB alloc] init];
        _modelsArray =  [db findAllContacts];
        
        for (LinkManModel *model in _modelsArray) {
            if (model.fristLetter.length <=0) {
                
            }
        }
        
        _modelsArray = [_modelsArray sortedArrayUsingComparator:^NSComparisonResult(LinkManModel *p1, LinkManModel *p2){
            
            return [p1.fristLetter compare:p2.fristLetter];
            
        }];
        
        NSMutableArray *items = nil;
        for (int i = 0;i < _modelsArray.count;i ++) {
            LinkManModel *model = (LinkManModel *)_modelsArray[i];
            if (![_letterArray containsObject:model.fristLetter]) {
                [_letterArray addObject:model.fristLetter];
                if (items.count > 0) {
                    [_friendsArray addObject:items];
                }
                items = [@[]mutableCopy];
            }
            [items addObject:model];
            if (i == _modelsArray.count - 1) {
                [_friendsArray addObject:items];
            }
        }
        [_mainTable reloadData];
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:_modelsArray];
        for (LinkManModel *model in mArray ) {
            [_searchDic setObject:model forKey:model.pinyin];
        }
    } afterDelay:0.1f];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        return 22;
    }else
        return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 22)];
        bgView.backgroundColor = HEXCOLOR(EmotionListBg);
        UILabel *titleLabel = [UILabel labelWithBlodFont:12 textColor:HEXCOLOR(TextGrayColor)];
        titleLabel.frame = CGRectMake(8, 5, 30, 12);
        [bgView addSubview:titleLabel];
        titleLabel.text = _letterArray[section];
        return bgView;
        
    }
    return nil;
}
#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _mainTable) {
        return  ((NSArray *)_friendsArray[section]).count;
        
    }
    return  _searchArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _mainTable) {
        return _letterArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _mainTable) {
        AddressFriendCell*cell = (AddressFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        LinkManModel *model = _friendsArray[indexPath.section][indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        [cell loadCellWith:model];
        cell.isSearchTabel = NO;
        
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        return cell;
        
    }else{
        AddressFriendCell*cell = (AddressFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.indexPath = indexPath;
        LinkManModel *model = _searchArray[indexPath.row];
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
        return self.letterArray;
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
            if (search == NO) {
                NSArray *array = _friendsArray[indexPath.section];
                LinkManModel *linkModel = array[indexPath.row];
                linkModel.relation = 2;
                NSMutableArray *Marray = [NSMutableArray arrayWithArray:array];
                [Marray removeObjectAtIndex:indexPath.row];
                [Marray insertObject:linkModel atIndex:indexPath.row];
                [_friendsArray removeObjectAtIndex:indexPath.section];
                [_friendsArray insertObject:(NSArray *)Marray atIndex:indexPath.section];
                [_mainTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [_searchArray removeObjectAtIndex:indexPath.row];
                [_searchArray insertObject:model atIndex:indexPath.row];
                [self.strongSearchDisplayController.searchResultsTableView reloadData];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
        //添加好友成功后，刷新数据源和cell
    }else if (buttonType == ButtonTypeChat){
//        LetterController *chat = [[LetterController alloc] init];
        RCLetterController *chat = [[RCLetterController alloc] init];
        
        chat.lastTime=model.createtime;
        chat.userid = model.tutuid;
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        if (model.phonenumber.length > 0 ) {
            [self showMessageView:model.phonenumber isSearch:search];
        }
    }
    
}
#pragma mark  searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    CGRect mf=_mainTable.frame;
    mf.origin.y=0;
    mf.size.height=mf.size.height+44+StatusBarHeight;
    _mainTable.frame=mf;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.strongSearchDisplayController setActive:YES animated:NO];
    if (!iOS7) {
    
        [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        self.strongSearchDisplayController.searchResultsTableView.rowHeight = 60;
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchText = CheckNilValue(searchText);
    [self bk_performBlockInBackground:^(id obj) {
        NSArray* possibleItems = [_searchDic allKeys];
        NSMutableArray* predicates = [NSMutableArray new];
        for (__strong NSString* queryPart in [searchText componentsSeparatedByString:@" "]) {
            if (queryPart && (queryPart = [queryPart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length > 0) {
                [predicates addObject:[NSPredicate predicateWithFormat:@"SELF like[cd] %@", [NSString stringWithFormat:@"%@*", queryPart]]];
            }
        }
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSArray* matchedItems = [possibleItems filteredArrayUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchArray removeAllObjects];
            [_searchArray addObjectsFromArray:[_searchDic objectsForKeys:matchedItems notFoundMarker:[NSNull null]]];
            [self.strongSearchDisplayController.searchResultsTableView reloadData];
        });
        
    } afterDelay:0.0f];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    CGRect mf=_mainTable.frame;
    mf.origin.y=NavBarHeight;
    mf.size.height=mf.size.height-StatusBarHeight-44;
    _mainTable.frame=mf;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)showMessageView:(NSString *)numer isSearch:(BOOL)search
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:numer];

        controller.body = [NSString stringWithFormat:@"%@%@%@",WebCopy_ShareProfleToFridenDesc([[LoginManager getInstance]getUid]),SHAREURL,[LoginManager getInstance].getUid];
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:^{
            if (search == YES) {
                [self.searchBar resignFirstResponder];
                [self.strongSearchDisplayController setActive:NO animated:NO];
            }
            
        }];
        
    }else{
        
        [self alertWithTitle:TTLocalString(@"TT_alert_message") msg:TTLocalString(@"TT_equipment_is_not_message_function")];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView==_mainTable){
        LinkManModel *model = _friendsArray[indexPath.section][indexPath.row];
        if (model.relation != -1) {
            UserDetailController *vc = [[UserDetailController alloc]init];
            vc.uid = model.tutuid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        LinkManModel *model = _searchArray[indexPath.row];
        if (model.relation != -1) {
            UserDetailController *vc = [[UserDetailController alloc]init];
            vc.uid = model.tutuid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    if(iOS7){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
