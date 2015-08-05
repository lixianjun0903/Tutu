//
//  FocusListDetailController.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FocusListDetailController.h"
#import "SVWebViewController.h"

#define cellIdentifier @"UserFocusCell"

@interface FocusListDetailController ()
{
    UITableView *listTable;
    NSMutableArray *listArray;
    
    
    UserFocusModel *doFocusModel;
    
    CGFloat w;
}

@end

@implementation FocusListDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    [self createTitleMenu];
    self.menuRightButton.hidden=YES;
    
    w=self.view.frame.size.width;
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:[UIColor clearColor]];
    [listTable setSeparatorColor:[UIColor clearColor]];
    
    if([SysTools getSystemVerson] >= 7){
        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if(_info && ![_info.uid isEqual:[[LoginManager getInstance] getUid]]){
        [self.menuTitleButton setTitle:[NSString stringWithFormat:@"%@%@",_info.nickname,TTLocalString(@"TT_de_follow")] forState:UIControlStateNormal];
    }else{
        if(self.pageType==TopicWithDefault){
            [self.menuTitleButton setTitle:[NSString stringWithFormat:TTLocalString(@"TT_the_topic_of_concern")] forState:UIControlStateNormal];
        }else{
            [self.menuTitleButton setTitle:[NSString stringWithFormat:TTLocalString(@"TT_the_location_of_concern")] forState:UIControlStateNormal];
        }
    }
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    listArray=[[NSMutableArray alloc] init];
    
    [listTable addHeaderWithTarget:self action:@selector(refreshData)];
    [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    [listTable headerBeginRefreshing];
}

// 个人的时候，关注的人，关注的位置
-(void)createTableHeader{
    
}


#pragma mark 刷新数据
-(void)refreshData{
    NSString *startid=@"";
    if(listArray!=nil && listArray.count>0){
        UserFocusModel *tempModel=[listArray objectAtIndex:0];
        startid=tempModel.fid;
    }
    NSString *api=API_GetUserFocus_List(_info.uid,Load_UP,startid,@"20");
    if(self.pageType==TopicWithDefault){
        api=[NSString stringWithFormat:@"%@&restype=1",api];
    }else{
        api=[NSString stringWithFormat:@"%@&restype=2",api];
    }
    
//    WSLog(@"%@",api);
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"followlist"];
        if(arr!=nil && arr.count>0){
            NSArray *focusArr=[[UserFocusModel alloc] getWithArray:arr];
            
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                    NSMakeRange(0,[focusArr count])];
            [listArray insertObjects:focusArr atIndexes:indexSet];
            [listTable reloadData];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(setReadStatus:)]){
                [self.delegate setReadStatus:self.pageType];
            }
            if(listTable.isHeaderRefreshing){
                [listTable headerEndRefreshing];
                [listTable removeHeader];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
//        [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
        WSLog(@"%@",request.responseString);
        
        [self checkDataNull];
        if(listTable.isHeaderRefreshing){
            [listTable headerEndRefreshing];
        }
    }];
}

-(void)loadMoreData{
    NSString *startid=@"";
    if(listArray!=nil && listArray.count>0){
        UserFocusModel *model=[listArray objectAtIndex:listArray.count-1];
        startid=model.fid;
    }
    
    NSString *api=API_GetUserFocus_List(_info.uid,Load_MORE,startid,@"20");
    if(self.pageType==TopicWithDefault){
        api=[NSString stringWithFormat:@"%@&restype=1",api];
    }else{
        api=[NSString stringWithFormat:@"%@&restype=2",api];
    }
    
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"followlist"];
        if(arr!=nil && arr.count>0){
            NSMutableArray *array=[[UserFocusModel alloc] getWithArray:arr];
            [listArray addObjectsFromArray:array];
        }
        
        [listTable reloadData];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
//        [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"%@",request.responseString);
        
        [self checkDataNull];
        if([listTable isFooterRefreshing]){
            [listTable footerEndRefreshing];
        }
    }];
}


#pragma mark table 代理开始
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserFocusCell *cell = (UserFocusCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UserFocusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate=self;
    
    [cell dataToView:[listArray objectAtIndex:indexPath.row] width:w];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserFocusModel *fm=[listArray objectAtIndex:indexPath.row];
    fm.isread=@"1";
    [listTable reloadData];
    
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=fm.title;
    control.poiid=fm.resid;
    control.pageType=self.pageType;
    [self openNav:control sound:nil];
}


#pragma mark TableCell代理
// 关注
-(void)itemFocusClick:(UserFocusModel *)focusModel{
    [self doFocus:focusModel];
}

//点击主题
-(void)itemTopicOnClick:(UserFocusTopicModel *)model focus:(UserFocusModel *)focusModel{
    if(model!=nil){
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString=focusModel.title;
        if([focusModel.restype intValue]==1){
            control.pageType=TopicWithDefault;
        }else{
            control.pageType=TopicWithPoiPage;
            control.poiid=focusModel.resid;
        }
        control.startid=model.topicid;
        [self openNav:control sound:nil];
    }
}


#pragma mark 本页面事件处理
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}
-(void)doFocus:(UserFocusModel *) focusModel{
    if(focusModel==nil){
        return;
    }
    doFocusModel=focusModel;
    
    NSString *doFocusORDelAPI=@"";
    if([focusModel.restype intValue]==1){
        if(focusModel.isfollow){
            doFocusORDelAPI=API_DEL_TOPIC_FOCUS(focusModel.resid);
        }else{
            doFocusORDelAPI=API_ADD_TOPIC_FOCUS(focusModel.resid);
        }
    }else if ([focusModel.restype intValue]==2){
        if(focusModel.isfollow){
            doFocusORDelAPI=API_DEL_POI_FOCUS(focusModel.resid);
        }else{
            doFocusORDelAPI=API_ADD_POI_FOCUS(focusModel.resid);
        }
    }
    
    if(focusModel.isfollow){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_maksure_cancel_follow") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
        
        sheet.tag=4;
        
        [sheet showInView:self.view];
    }else{
        [[RequestTools getInstance] get:doFocusORDelAPI isCache:NO completion:^(NSDictionary *dict) {
            focusModel.isfollow=!focusModel.isfollow;
            [listTable reloadData];
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
            NSString *doFocusORDelAPI=@"";
            if([doFocusModel.restype intValue]==1){
                if(doFocusModel.isfollow){
                    doFocusORDelAPI=API_DEL_TOPIC_FOCUS(doFocusModel.resid);
                }else{
                    doFocusORDelAPI=API_ADD_TOPIC_FOCUS(doFocusModel.resid);
                }
            }else if ([doFocusModel.restype intValue]==2){
                if(doFocusModel.isfollow){
                    doFocusORDelAPI=API_DEL_POI_FOCUS(doFocusModel.resid);
                }else{
                    doFocusORDelAPI=API_ADD_POI_FOCUS(doFocusModel.resid);
                }
            }
            [[RequestTools getInstance] get:doFocusORDelAPI isCache:NO completion:^(NSDictionary *dict) {
                doFocusModel.isfollow=!doFocusModel.isfollow;
                [self checkDataNull];
                
                //取消关注的时候发送通知
                if (!doFocusModel.isfollow) {
                    [NOTIFICATION_CENTER postNotificationName:Notification_Del_Focus object:doFocusModel];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
        }
    }
}

#pragma mark 空数据UI展示
-(void)checkDataNull{
    if(listArray==nil || listArray.count==0){
        
        [self removePlaceholderView];
        self.placeholderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 100)];
        self.placeholderView.center = CGPointMake(self.view.center.x, self.view.center.y-40);
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
    }else{
        [self removePlaceholderView];
    }
}


-(IBAction)changePageClick:(UIButton *)sender{
    NSURL *url=[NSURL URLWithString:URL_HuaTi_GuangChang];
    SVWebViewController *web=[[SVWebViewController alloc] initWithURL:url];
    [self openNav:web sound:nil];
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
