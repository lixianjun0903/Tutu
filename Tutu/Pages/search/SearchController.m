//
//  SearchController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-31.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SearchController.h"

#import "AddFriendCell.h"
#import "UserDetailController.h"
#import "UIView+Border.h"

#define cellIdentifier @"AddFriendCell"


@interface SearchController (){
    UITableView *listTable;
    NSMutableArray *mData;
    UIGestureRecognizer *tap;
}
@property (retain,nonatomic)NSArray * listArray;

@end

@implementation SearchController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIView *ivbg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, StatusBarHeight)];
    [ivbg setBackgroundColor:UIColorFromRGB(SystemColor)];
    
    [self.view addSubview:ivbg];
    
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
//    int sh=iOS7?0:20;
    CGRect bf=CGRectMake(0, StatusBarHeight+44, self.view.mj_width, self.view.mj_height-(44+StatusBarHeight));
    listTable=[[UITableView alloc] initWithFrame:bf];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:[UIColor clearColor]];
    [listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [listTable addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [listTable.tableHeaderView setBackgroundColor:[UIColor clearColor]];
    
        if([SysTools getSystemVerson] >= 7){
            [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
        }
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    
    mySearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, StatusBarHeight , self.view.mj_width, 44)];
    mySearchBar.delegate=self;
    mySearchBar.showsCancelButton = YES;
    mySearchBar.placeholder=@"Tutu号/昵称";
    mySearchBar.backgroundColor=[UIColor clearColor];
    mySearchBar.barStyle = UIBarStyleDefault;
    for (UIView *subview in mySearchBar.subviews)
    {
        WSLog(@"%@",subview);
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
            break;
        }
    }
    if(iOS7){
        UIImageView *iv=[[UIImageView alloc] initWithFrame:mySearchBar.bounds];
        [iv setBackgroundColor:[UIColor whiteColor]];
        [mySearchBar insertSubview:iv atIndex:1];
    }
    
    [self.view addSubview:mySearchBar];
    
    UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    [backView setBackgroundColor:[UIColor clearColor]];
    [self.view insertSubview:backView atIndex:0];
    
    tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)];
    tap.delegate = self;
    [backView addGestureRecognizer:tap];
    
    mData=[[NSMutableArray alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mySearchBar becomeFirstResponder];
    });
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mData.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 10;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* myView = [[UIView alloc] init];
//    myView.backgroundColor = UIColorFromRGB(SystemGrayColor);
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, 10)];
//    titleLabel.textColor=[UIColor whiteColor];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    [myView addSubview:titleLabel];
//    return myView;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddFriendCell *cell = (AddFriendCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AddFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    UserInfo *model=[mData objectAtIndex:indexPath.row];
    if(model){
        [cell initDataToView:model];
    }
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WSLog(@"%@",indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *user=[mData objectAtIndex:indexPath.row];
    UserDetailController *uinfo=[[UserDetailController alloc] init];
    uinfo.uid=user.uid;
    [self.navigationController pushViewController:uinfo animated:YES];
}


-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    WSLog(@"搜索");
    //    [self searchBar:searchBar textDidChange:nil];
    [mySearchBar resignFirstResponder];
    NSString *searchText=mySearchBar.text;
    [self doSearch:searchText];
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    WSLog(@"时时变动的字段：%@",searchText);
    if(searchText==nil || [@"" isEqual:searchText]){
        
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}


-(void)doSearch:(NSString *)searchText{
    if (searchText!=nil && searchText.length>0) {
        WSLog(@"%@",API_SEARCH_USER(searchText,@"",@"20", Load_UP));
        [[RequestTools getInstance] get:API_SEARCH_USER(searchText,@"",@"20", Load_UP) isCache:NO completion:^(NSDictionary *dict) {
            WSLog(@"%@",dict);
            [mData removeAllObjects];
            NSInteger code = [dict[@"code"]integerValue];
            if (code == 10000) {
                NSArray *datas = dict[@"data"][@"list"];
                for (NSDictionary *dic in datas) {
                    UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
                    [mData addObject:model];
                }
                if(datas.count>0){
                    [listTable reloadData];
                    if(datas.count==1){
                        UserInfo *user=[mData objectAtIndex:0];
                        UserDetailController *uinfo=[[UserDetailController alloc] init];
                        uinfo.uid=user.uid;
                        [self.navigationController pushViewController:uinfo animated:YES];
                    }
                }
            }
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            WSLog(@"%@",request.responseString);
        }];
    }
}

-(void)loadMoreData{
    NSString *searchText=mySearchBar.text;
    NSString *startid=@"";
    if(mData!=nil && mData.count>0){
        UserInfo *model = [mData lastObject];
        startid=model.uid;
    }
    
    if (searchText!=nil && searchText.length>0) {
        WSLog(@"%@",API_SEARCH_USER(searchText,startid,@"20", Load_MORE));
        [[RequestTools getInstance] get:API_SEARCH_USER(searchText,startid,@"20", Load_MORE) isCache:NO completion:^(NSDictionary *dict) {
            WSLog(@"%@",dict);
            NSInteger code = [dict[@"code"]integerValue];
            if (code == 10000) {
                NSArray *datas = dict[@"data"][@"list"];
                for (NSDictionary *dic in datas) {
                    UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
                    [mData addObject:model];
                }
                if(datas.count>0){
                    [listTable reloadData];
                    if(datas.count==1){
                        UserInfo *user=[mData objectAtIndex:0];
                        UserDetailController *uinfo=[[UserDetailController alloc] init];
                        uinfo.uid=user.uid;
                        [self.navigationController pushViewController:uinfo animated:YES];
                    }
                }
            }
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            WSLog(@"%@",request.responseString);
            if([listTable isFooterRefreshing]){
                [listTable footerEndRefreshing];
            }
        }];
    }
}



-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
