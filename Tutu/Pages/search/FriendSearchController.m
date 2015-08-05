//
//  FriendSearchController.m
//  Tutu
//
//  Created by feng on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "FriendSearchController.h"
#import "AddFriendCell.h"
#import "UserDetailController.h"
#import "SameCityController.h"
#import "UMSocial.h"
#import "StartBindController.h"
#import "SendPhoneNumViewController.h"
#import "AddressListViewController.h"
#import "SendLocalTools.h"
#import "ContactsViewController.h"
#import <AddressBook/AddressBook.h>

#import "UIView+Border.h"

#import "LoginManager.h"
#define cellIdentifier @"RecommentCell"

#import <TencentOpenAPI/TencentOAuth.h>

#import "SameCityCell.h"

#define cellSearchIdentifier @"UserFansCell"

@interface FriendSearchController (){
    int w;
    
    UITableViewCell *itemsView;
    
    UITableView *listTable;
    NSMutableArray *dataArray;
    
    //快速遍历,更新用户关系
    NSMutableDictionary *dictData;
    
    NSMutableArray *searchArray;
    
    UserInfo *doFocusModel;
}


@end

@implementation FriendSearchController

@synthesize searchBar=_searchBar;
@synthesize strongSearchDisplayController=_strongSearchDisplayController;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self createTitleMenu];
//    self.menuRightButton.hidden=YES;
//    [self.menuTitleButton setTitle:@"好友" forState:UIControlStateNormal];
    self.title=TTLocalString(@"TT_add_buddy");
    [self createLeftBarItemSelect:@selector(buttonClick:) imageName:nil heightImageName:nil];
    
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    w=self.view.mj_width;
    dataArray=[[NSMutableArray alloc] init];
    searchArray=[[NSMutableArray alloc] init];
    dictData=[[NSMutableDictionary alloc] init];

    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, -1, w, self.view.mj_height)];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable setBackgroundColor:[UIColor clearColor]];
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    listTable.showsVerticalScrollIndicator = YES;
    [listTable setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:listTable];
    
    [listTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    //创建搜索条
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = FormatString(@"%@/%@", TTLocalString(@"TT_tutu_number"),TTLocalString(@"TT_nickname"));
    _searchBar.delegate = self;
    _searchBar.barStyle=UISearchBarStyleDefault;
    [_searchBar sizeToFit];
    _searchBar.backgroundColor=[UIColor clearColor];
    [listTable setTableHeaderView:_searchBar];
    
    [self createHeaderView];
    
    [self createSearchView];
    
    [self refreshData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkContactsUpload) name:NOTICE_BINDPHONE_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:NOTICE_DELADDFRIEND object:nil];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNavigationBarStyle];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}



-(UITableViewCell *)createHeaderView{
    if(itemsView!=nil){
        [itemsView removeFromSuperview];
    }
    itemsView=[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, w, 190)];
    [itemsView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [itemsView addBottomBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:0.75];
    [itemsView addTopBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:0.75];
    
    [self addItemsView:0 view:itemsView type:2];
    [self addItemsView:44 view:itemsView type:3];
    [self addItemsView:88 view:itemsView type:4];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(15, 162, w-30, 24)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[NSString stringWithFormat:TTLocalString(@"TT_maybe_interest_people")]];
    [label setTextColor:UIColorFromRGB(TextBlackColor)];
    [label setFont:ListDetailFont];
    [itemsView addSubview:label];
    [itemsView setSelectionStyle:UITableViewCellSelectionStyleNone];
    return itemsView;
}


-(void) addItemsView:(int) y view:(UIView *)pview type:(int)itemtype{
    UIButton *itemView=[UIButton buttonWithType:UIButtonTypeCustom];
    [itemView setFrame:CGRectMake(0, y, w, 44)];
    [itemView setBackgroundColor:[UIColor whiteColor]];
    [itemView setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(ListLineColor)] forState:UIControlStateHighlighted];
    [itemView setBackgroundImage:[SysTools createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    itemView.tag=itemtype;
    [pview addSubview:itemView];
    
    UIImageView *itemImage=[[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 27, 27)];
    [itemImage setImage:[UIImage imageNamed:@"search_type1"]];
    [itemView addSubview:itemImage];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(57, 0, w-57, 44)];
    [label setFont:ListTitleFont];
    [label setTextColor:UIColorFromRGB(TextBlackColor)];
    [label setBackgroundColor:[UIColor clearColor]];
    [itemView addSubview:label];
    if(itemtype==1){
        [label setText:TTLocalString(@"TT_add_samecity_friend")];
        [itemImage setImage:[UIImage imageNamed:@"search_type1"]];
    }else if(itemtype==2){
        [label setText:TTLocalString(@"TT_add_contacts_friend")];
        [itemImage setImage:[UIImage imageNamed:@"search_type2"]];
    }else if(itemtype==3){
        [label setText:TTLocalString(@"TT_add_QQ_friend")];
        [itemImage setImage:[UIImage imageNamed:@"search_type3"]];
    }else if(itemtype==4){
        [label setText:TTLocalString(@"TT_add_weixin_friend")];
        [itemImage setImage:[UIImage imageNamed:@"search_type4"]];
    }
    
    UIImageView *rightBtn=[[UIImageView alloc] initWithFrame:CGRectMake(w-40, 6, 30, 30)];
    [rightBtn setImage:[UIImage imageNamed:@"p_right"]];
    [itemView addSubview:rightBtn];
    
    if(itemtype<4){
        UIImageView *lineImage=[[UIImageView alloc] initWithFrame:CGRectMake(57, 43+y, w-70, 1)];
        [lineImage setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [pview addSubview:lineImage];
    }else{
        [itemView addBottomBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:0.75];
    }
    
    [itemView addTarget:self action:@selector(doTapClick:) forControlEvents:UIControlEventTouchUpInside];
    itemView.userInteractionEnabled=YES;
}

-(void)createSearchView{
    //去掉搜索框背景
    _strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _strongSearchDisplayController.searchResultsDataSource = self;
    _strongSearchDisplayController.searchResultsDelegate = self;
    [_strongSearchDisplayController.searchResultsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.searchDisplayController.searchResultsTableView setSeparatorColor:UIColorFromRGB(ItemLineColor)];
    
    if (iOS7) {
        _strongSearchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
        [_searchBar setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        
        _searchBar.layer.borderWidth = 1;
        _searchBar.layer.borderColor = [UIColorFromRGB(ItemLineColor) CGColor];
        [_searchBar setBarTintColor:UIColorFromRGB(ItemLineColor)];
        _searchBar.opaque = YES;
        
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(SystemColor),UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        
    }
    [_strongSearchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
    
    [_strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:cellSearchIdentifier bundle:nil] forCellReuseIdentifier:cellSearchIdentifier];
    _strongSearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [_strongSearchDisplayController.searchResultsTableView addFooterWithTarget:self action:@selector(loadMoreSearchData)];
}



#pragma mark table代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView==listTable){
        return dataArray.count+1;
    }else{
        return searchArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==listTable){
        if(indexPath.row==0){
            return [self createHeaderView];
        }else{
            RecommentCell *cell = (RecommentCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[RecommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            cell.delegate=self;
            
            UserInfo *info=[dataArray objectAtIndex:indexPath.row-1];
            
            [cell dataToView:info with:w];

            return cell;
        }
    }else{
        UserFansCell *cell = (UserFansCell*)[tableView dequeueReusableCellWithIdentifier:cellSearchIdentifier];
        if (cell == nil) {
            cell = [[UserFansCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSearchIdentifier];
        }
        cell.delegate=self;
        UserInfo *model=[searchArray objectAtIndex:indexPath.row];
        if(model){
            [cell dataToView:model];
//            [cell initDataToView:model width:w reference:ReferenceSearchUserPage];
        }
        
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.row==0 && listTable==tableView){
        return 190;
    }
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView==listTable){
        if(indexPath.row==0){
            return;
        }
        UserInfo *user=[dataArray objectAtIndex:indexPath.row-1];
        UserDetailController *uinfo=[[UserDetailController alloc] init];
        uinfo.uid=user.uid;
        uinfo.user=user;
        
        [self openNav:uinfo sound:nil];
    }else{
        UserInfo *user=[searchArray objectAtIndex:indexPath.row];
        UserDetailController *uinfo=[[UserDetailController alloc] init];
        uinfo.uid=user.uid;
        uinfo.user=user;
        
//        [self.searchDisplayController setActive:YES animated:YES];
        
        self.navigationController.navigationBar.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
        for (UIView *v in self.navigationController.navigationBar.subviews) {
            if(v.tag==10001){
                [v removeFromSuperview];
            }
        }
        [self.navigationController setNavigationBarHidden:YES];
        [self openNav:uinfo sound:nil];
        
    }
}

#pragma mark table cell 点击回调
-(void)itemClick:(UserInfo *)info tag:(RecommentItemTag)tag{
    if(info){
        if(tag==RecommentItemFocus){
            [self doFocus:info del:NO];
        }
        else{
            TopicModel *model=nil;
            NSInteger indexPath;
            if(tag==RecommentItemImageView1 && info.topicList.count>0){
                model=[info.topicList objectAtIndex:0];
                indexPath=0;
            }else if(tag==RecommentItemImageView2 && info.topicList.count>1){
                model=[info.topicList objectAtIndex:1];
                indexPath=1;
            }else if(tag==RecommentItemImageView3 && info.topicList.count>2){
                model=[info.topicList objectAtIndex:2];
                indexPath=2;
            }
            if(model!=nil){
                TopicDetailListController *rvc = [[TopicDetailListController alloc] init];
                
                rvc.currentIndex = indexPath;
                rvc.topicType=TopicTypeList;
                rvc.dataArray = info.topicList;
                
                
                rvc.uid = info.uid;
                
//                rvc.delegate = self;
                
//                [self.navigationController pushViewController:rvc animated:YES];
//                TopicDetailController *detail=[[TopicDetailController alloc] init];
//                detail.topicModel=model;
                [self openNav:rvc sound:nil];
            }
        }
    }
}


#pragma mark search 代理
-(void)searchBarSearchButtonClicked:(UISearchBar *)ssearchBar{
    WSLog(@"%@",ssearchBar.text);
    [searchArray removeAllObjects];
    [_strongSearchDisplayController.searchResultsTableView reloadData];
    
//    SearchController *sc=[[SearchController alloc] init];
//    [self openNav:sc sound:nil];
    
    [self doSearch:ssearchBar.text];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    [searchArray removeAllObjects];
//    [_strongSearchDisplayController.searchResultsTableView reloadData];
//
//    [self doSearch:searchText];
}

-(void)doSearch:(NSString *)searchText{
    if (searchText!=nil && searchText.length>0) {
        [[RequestTools getInstance] get:API_SEARCH_USER(searchText,@"",@"20", Load_UP) isCache:NO completion:^(NSDictionary *dict) {
            NSInteger code = [dict[@"code"]integerValue];
            if (code == 10000) {
                NSArray *datas = dict[@"data"][@"list"];
                for (NSDictionary *dic in datas) {
                    UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
                    [searchArray addObject:model];
                }
                if(datas.count>0){
                    [_strongSearchDisplayController.searchResultsTableView reloadData];
                    
                    [_strongSearchDisplayController.searchResultsTableView setContentSize:CGSizeMake(w, 66*searchArray.count)];
                    if(datas.count==1){
                        UserInfo *user=[searchArray objectAtIndex:0];
                        UserDetailController *uinfo=[[UserDetailController alloc] init];
                        uinfo.uid=user.uid;
                        [self openNav:uinfo sound:nil];
                        [self.searchDisplayController setActive:NO animated:YES];
                    }
                }
            }
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
        }];
    }
}

-(void)loadMoreSearchData{
    NSString *searchText=_searchBar.text;
    NSString *startid=@"";
    if(searchArray!=nil && searchArray.count>0){
        UserInfo *model = [searchArray lastObject];
        startid=model.uid;
    }
    
    if (searchText!=nil && searchText.length>0) {
        WSLog(@"%@",API_SEARCH_USER(searchText,startid,@"20", Load_MORE));
        [[RequestTools getInstance] get:API_SEARCH_USER(searchText,startid,@"20", Load_MORE) isCache:NO completion:^(NSDictionary *dict) {
            WSLog(@"%@",dict);
            NSInteger code = [dict[@"code"]integerValue];
            if (code == 10000) {
                NSArray *datas = dict[@"data"][@"list"];
                NSArray *arr=[[datas reverseObjectEnumerator] allObjects];
                for (NSDictionary *dic in arr) {
                    UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
                    [searchArray addObject:model];
                }
                if(datas.count>0){
                    [_strongSearchDisplayController.searchResultsTableView reloadData];
                    [_strongSearchDisplayController.searchResultsTableView setContentSize:CGSizeMake(w, 66*searchArray.count)];
                    if(datas.count==1){
                        UserInfo *user=[searchArray objectAtIndex:0];
                        UserDetailController *uinfo=[[UserDetailController alloc] init];
                        uinfo.uid=user.uid;
                        [self.navigationController pushViewController:uinfo animated:YES];
                        [self.searchDisplayController setActive:NO animated:YES];
                    }
                }
            }
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            WSLog(@"%@",request.responseString);
            if([_strongSearchDisplayController.searchResultsTableView isFooterRefreshing]){
                [_strongSearchDisplayController.searchResultsTableView footerEndRefreshing];
            }
        }];
    }
}



#pragma mark 数据请求
-(void)refreshData{
    NSString *startid=@"";
    [[RequestTools getInstance] get:API_Get_RecommendMore(Load_UP, 20, startid) isCache:NO completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"list"];
        if(arr!=nil && arr.count>0){
//            NSArray *rearr=[[arr reverseObjectEnumerator] allObjects];
            for (NSDictionary *item in arr) {
                UserInfo *info=[[UserInfo alloc] initWithMyDict:item];
                info.topicList=[TopicModel getTopicModelsWithArray:[item objectForKey:@"topiclist"]];
//                [dataArray insertObject:info atIndex:0];
                [dataArray addObject:info];
                
                [dictData setObject:info forKey:info.uid];
            }
            
            [listTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
        if([listTable isHeaderRefreshing]){
            [listTable headerEndRefreshing];
            [listTable removeHeader];
        }
    }];
}

-(void)loadMoreData{
    NSString *startid=@"";
    if(dataArray!=nil && dataArray.count>0){
        UserInfo *info=[dataArray objectAtIndex:dataArray.count-1];
        startid=info.uid;
    }
    [[RequestTools getInstance] get:API_Get_RecommendMore(Load_MORE, 20, startid) isCache:NO completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"list"];
        if(arr!=nil && arr.count>0){
            for (NSDictionary *item in arr) {
                UserInfo *info=[[UserInfo alloc] initWithMyDict:item];
                info.topicList=[TopicModel getTopicModelsWithArray:[item objectForKey:@"topiclist"]];
                [dataArray addObject:info];
                
                [dictData setObject:info forKey:info.uid];
            }
            
            [listTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([listTable isFooterRefreshing]){
            [listTable footerEndRefreshing];
        }
    }];
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
            }
        }
    }
}


#pragma mark 点击事件处理
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
        return;
    }
    [self goBack:nil];
}

-(IBAction)doTapClick:(UIButton *)view{
    
    if(view.tag==1){
        SameCityController *res=[[SameCityController alloc] init];
        [self.navigationController pushViewController:res animated:YES];
    }else if(view.tag==2){
        WSLog(@"to do something");
        UserInfo * model = [[LoginManager getInstance]getLoginInfo];
        if(model.isQQLogin && !model.isbind_phone)
        {
            StartBindController *bind=[[StartBindController alloc] init];
            [self.navigationController pushViewController:bind animated:YES];
        }
        else
        {
            [self checkContactsUpload];
        }
    }
    else{
        NSArray *types=@[UMShareToWechatSession];
        if(view.tag==3){
            types=@[UMShareToQQ];
            
//            if([SysTools getApp].checkUserAge){
                //取消未安装QQ的判断
                if (![TencentOAuth iphoneQQInstalled] && ![TencentOAuth iphoneQQSupportSSOLogin]) {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No QQ" message:@"QQ haven't been install in your device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
//            }
        }
        else if(view.tag==4){
            types=@[UMShareToWechatSession];
        }
        
        NSString *shareText= WebCopy_ShareProfleToFridenDesc([LoginManager getInstance].getUid);

        NSString *shareURL=[NSString stringWithFormat:@"%@%@",SHAREURL,[LoginManager getInstance].getUid];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
        [UMSocialData defaultData].extConfig.qqData.url = shareURL;
        [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
        [UMSocialData defaultData].extConfig.title=@"邀请你加入Tutu";
        
//        UMSocialUrlResource *resourece = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@""];
    
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:types content:shareText image:[UIImage imageNamed:@"Icon-72"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            //            WSLog(@"分享状态：%@，返回数据：%@",response.message,response.data);
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_success") duration:2];
            }else{
                // Todo
                [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_faild") duration:2];
            }
        }];
    }
}


// 当添加通讯录好友时，需要先判断是否上传通讯录
-(void)checkContactsUpload{
    WSLog(@"%@",SYSContactsTime_KEY);
    NSString *time=[SysTools getValueFromNSUserDefaultsByKey:SYSContactsTime_KEY];
    if(time==nil || [@"" isEqual:time]){
        WSLog(@"还未上传通讯录！");
        ABAuthorizationStatus status =   ABAddressBookGetAuthorizationStatus();
        if(status!=kABAuthorizationStatusAuthorized){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:TTLocalString(@"TT_need_contacts_permission") message:TTLocalString(@"TT_set_open_contacts_premission") delegate:self cancelButtonTitle:TTLocalString(@"TT_I_get_it") otherButtonTitles: nil];
            alert.tag=1;
            alert.delegate=self;
            [alert show];
            return;
        }
        [[SendLocalTools getInstance] sendAddresBookSuccessCallback:^{
            // 显示通讯录页面
            AddressListViewController * addressList = [[AddressListViewController alloc]init];
            [self.navigationController pushViewController:addressList animated:YES];
        }startCallBack:^{
            [SVProgressHUD showWithStatus:TTLocalString(@"TT_getting_contacts_friend_relation")];
        } errorCallback:^{
            
        } finishCallback:^{
            if([SVProgressHUD isVisible]){
                [SVProgressHUD dismiss];
            }
        }];
        return;
    }else{
        // 显示通讯录页面
        AddressListViewController * addressList = [[AddressListViewController alloc]init];
        [self.navigationController pushViewController:addressList animated:YES];
    }
}


#pragma mark alert代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1 && alertView.tag==1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
    }
}
//用户关注
-(void)doFocus:(UserInfo *)info del:(BOOL) isDel{
    if(!isDel && info!=nil && ([info.relation intValue]==2 || [info.relation intValue]==3)){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:@"确定取消关注?" delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
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



#pragma mark 其它控件代理监听
-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    // 取消关注
    if(tag==4){
        if(buttonIndex==0){
            [self doFocus:doFocusModel del:YES];
        }
    }
    // 取消关注
    if(tag==5){
        if(buttonIndex==0){
            [self doFocusForSearch:doFocusModel del:YES];
        }
    }
}

#pragma mark TableCell代理
-(void)itemFocusClick:(UserInfo *)info{
    [self doFocusForSearch:info del:NO];
}

//用户关注
-(void)doFocusForSearch:(UserInfo *)info del:(BOOL) isDel{
    if(!isDel && info!=nil && ([info.relation intValue]==2 || [info.relation intValue]==3)){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_maksure_cancel_follow") delegate:self otherButton:@[@"TT_make_sure"] cancelButton:TTLocalString(@"TT_cancel")];
        sheet.tag=5;
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
            [_strongSearchDisplayController.searchResultsTableView reloadData];
            
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
