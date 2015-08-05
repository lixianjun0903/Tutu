//
//  UserSearchController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-19.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserSearchController.h"

#import "SameCityCell.h"
#import "UserInfoDB.h"

#define cellIdentifier @"SameCityCell"

@interface UserSearchController (){
    NSMutableArray *groupArray;
    NSMutableArray *searchArray;
    NSString *searchTitle;
}
@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISearchDisplayController *strongSearchDisplayController;

@end

@implementation UserSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    groupArray=[[NSMutableArray alloc] init];
    searchArray=[[NSMutableArray alloc] init];
   
    [self createLeftBarItemSelect:@selector(leftButtonClick:) imageName:nil heightImageName:nil];
    self.title = TTLocalString(@"TT_search_user");
    
    [self creatView];
    
    [self loadDataFromDB];
}

-(void)creatView
{
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    _mainTable.frame = CGRectMake(0,0, ScreenWidth, self.view.mj_height);
    [_mainTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectZero];
    _mainTable.tableFooterView = footView;
    [self.view addSubview:_mainTable];
    
    
    //创建搜索条
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = TTLocalString(@"TT_search_user");
    self.searchBar.delegate = self;
    
    self.searchBar.barStyle=UISearchBarStyleDefault;
    [self.searchBar sizeToFit];
    
    self.searchBar.backgroundColor=[UIColor clearColor];
    //去掉搜索框背景
    
    _mainTable.tableHeaderView = self.searchBar;
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (iOS7) {
        self.searchBar.layer.borderWidth = 1;
        self.searchDisplayController.searchResultsTableView.tag=1;
        self.strongSearchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(60, 0, 0, 0);
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTable.sectionIndexBackgroundColor = [UIColor clearColor];
        self.searchBar.layer.borderColor = [HEXCOLOR(EmotionListBg) CGColor];
        [self.searchBar setBarTintColor:HEXCOLOR(0XC9C9CE)];
        self.searchBar.opaque = YES;
        
    }else{
        self.mainTable.frame =CGRectMake(0, 44, ScreenWidth, self.view.mj_height - 44);
    }
    
    [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.strongSearchDisplayController.searchResultsTableView.rowHeight = 55;
    _strongSearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    __block UserSearchController *weakSelf=self;
    [self.strongSearchDisplayController.searchResultsTableView addFooterWithCallback:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.strongSearchDisplayController.searchResultsTableView footerEndRefreshing];
        });
    }];
}



#pragma mark-tableview的代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SameCityCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UserInfo *info=nil;
    if (tableView==_mainTable) {
        info=[groupArray objectAtIndex:indexPath.row];
    }else
    {
        info=[searchArray objectAtIndex:indexPath.row];
    }
    [cell initDataToView:info width:tableView.frame.size.width reference:ReferenceSearchUserPage];
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_mainTable) {
        return groupArray.count;
    }else{
        return searchArray.count;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *info;
    if (tableView==_mainTable) {
        info=[groupArray objectAtIndex:indexPath.row];
    }else
    {
        info=[searchArray objectAtIndex:indexPath.row];
    }
    
    [_searchBar endEditing:YES];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableItemClick:)]){
        [self.delegate tableItemClick:info];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

#pragma mark 搜索
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    NSLog(@"%@",searchText);
    [searchArray removeAllObjects];
    [self doSearchText:searchText];
}


#pragma mark 查询数据
- (void)loadDataFromDB{
    UserInfoDB *db = [[UserInfoDB alloc]init];
    
    //储存分组的数据
    groupArray = [db findMyFriends];
    if(groupArray==nil)
    {
        groupArray=[[NSMutableArray alloc] init];
    }
    [_mainTable reloadData];
}


-(void)doSearchText:(NSString *)text{
    [[RequestTools getInstance] get:API_Publish_SearchUserList(text) isCache:NO completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"list"];
        for (NSDictionary *item in arr) {
            [searchArray addObject:[[UserInfo alloc] initWithMyDict:item]];
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}


- (void)leftButtonClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.strongSearchDisplayController=nil;
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
