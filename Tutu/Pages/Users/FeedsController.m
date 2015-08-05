//
//  FeedsController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "FeedsController.h"
#define cellIdentifier @"FeedsCell"

#import "TopicDetailController.h"
#import "UserDetailController.h"

@interface FeedsController (){
    UITableView *listTable;
    NSMutableArray *newData;
    NSMutableArray *historyData;
    int total;
}
@end

@implementation FeedsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    [self createTitleMenu];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    //    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-23/2, 22-23/2, 22-23/2, 22-23/2)];
    self.menuRightButton.hidden=YES;
    [self.menuTitleButton setTitle:TTLocalString(@"TT_dynamic") forState:UIControlStateNormal];

    if(self.fromRoot){
        self.menuLeftButton.hidden=YES;
    }
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    
    [listTable setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:[UIColor clearColor]];
    [listTable setSeparatorColor:UIColorFromRGB(ListLineColor)];
    [listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    if([SysTools getSystemVerson] >= 7){
        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    }
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    [listTable addHeaderWithTarget:self action:@selector(refreshData)];
    [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    

    
    UIView *ivbg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, StatusBarHeight)];
    [ivbg setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.view addSubview:ivbg];
    
    newData=[[NSMutableArray alloc] init];
    historyData=[[NSMutableArray alloc] init];
    
    
    
    //push，如果在当前页，时时获取
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDZAN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTICE_ADDCOMMENT object:nil];
}


-(void)refreshData{
    NSString *tipid=@"";
    if(newData!=nil && newData.count>0){
        tipid=((FeedsModel *)[newData firstObject]).tipid;
    }else if(historyData!=nil && historyData.count>0){
        tipid=((FeedsModel *)[historyData firstObject]).tipid;
    }
    
//    WSLog(@"%@",API_GET_FEEDS(tipid, @"20", Load_UP));
    [[RequestTools getInstance] get:API_GET_FEEDS(tipid, @"20", Load_UP)
                            isCache:NO completion:^(NSDictionary *dict) {
//        WSLog(@"%@",dict);
        if ([dict[@"code"]integerValue] == 10000) {
            total=[[dict objectForKey:@"total"] intValue];
            if (dict.count > 1) {
                NSArray *newdatas = dict[@"data"][@"newtiplist"];
                NSArray *historydatas = dict[@"data"][@"historytiplist"];
                
                NSArray* newReversedArray = [[newdatas reverseObjectEnumerator] allObjects];
                for (NSDictionary *d in newReversedArray) {
                    [newData insertObject:[[FeedsModel alloc] initWithMyDict:d] atIndex:0];
                }
                
                
                NSArray* historyReversedArray = [[historydatas reverseObjectEnumerator] allObjects];
                for (NSDictionary *d in historyReversedArray) {
                    [historyData insertObject:[[FeedsModel alloc] initWithMyDict:d] atIndex:0];
                }
            }
            [listTable reloadData];
            
            //查看后直接清零
            [[RequestTools getInstance] doSetNewtipscount:@"0"];
            [[NoticeTools getInstance] postClearMessageRead];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
        [listTable headerEndRefreshing];
    }];
}

-(void)loadMoreData{
    
    NSString *tipid=@"";
    if(historyData!=nil && historyData.count>0){
        tipid=((FeedsModel *)[historyData lastObject]).tipid;
    }else if(newData!=nil && newData.count>0){
        tipid=((FeedsModel *)[newData lastObject]).tipid;
    }
//    WSLog(@"%@",API_GET_FEEDS(tipid, @"20", Load_MORE));
    [[RequestTools getInstance] get:API_GET_FEEDS(tipid, @"20", Load_MORE) isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            total=[[dict objectForKey:@"total"] intValue];
            
            if (dict.count > 1) {
                NSArray *newdatas = dict[@"data"][@"newtiplist"];
                NSArray *historydatas = dict[@"data"][@"historytiplist"];
                
                for (NSDictionary *d in newdatas) {
                    [newData addObject:[[FeedsModel alloc] initWithMyDict:d]];
                }
                
                for (NSDictionary *d in historydatas) {
                    [historyData addObject:[[FeedsModel alloc] initWithMyDict:d]];
                }
            }
            
            [listTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [listTable footerEndRefreshing];
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0 && (newData==nil || newData.count==0)){
        return 0;
    }
    
    if(section==1 &&(historyData==nil || historyData.count==0)){
        return 0;
    }
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    [headerView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width-20, 25)];
    [textLabel setFont:ListDetailFont];
    [textLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [headerView addSubview:textLabel];
    if(section==0){
        [textLabel setText:TTLocalString(@"TT_new_dynamic")];
    }else{
        [textLabel setText:TTLocalString(@"TT_history_dynamic")];
    }
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return newData.count;
    }else{
        return historyData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedsCell *cell = (FeedsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FeedsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    FeedsModel *model=nil;
    if(indexPath.section==0){
        model=[newData objectAtIndex:indexPath.row];
    }else{
        model=[historyData objectAtIndex:indexPath.row];
    }
    [cell initDataToView:model];
    
    cell.delegate=self;
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    FeedsModel *sm=nil;
    if(indexPath.section==0 && (newData==nil || newData.count<row)){
        return;
    }
    
    if(indexPath.section==1 && (historyData==nil || historyData.count<row)){
        return;
    }
    if(indexPath.section==1){
        sm=[historyData objectAtIndex:indexPath.row];
    }else{
        sm=[newData objectAtIndex:indexPath.row];
    }
    
    NSString *sid=sm.tipid;
    
    
    [[RequestTools getInstance] get:API_DEL_FEEDS(sid) isCache:NO completion:^(NSDictionary *dict) {
        //删除数据
        if(indexPath.section==0){
            [newData removeObjectAtIndex:row];
        }else{
            [historyData removeObjectAtIndex:row];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationLeft];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TTLocalString(@"TT_delete");
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FeedsModel *model=nil;
    if(indexPath.section==0){
        model=[newData objectAtIndex:indexPath.row];
    }else{
        model=[historyData objectAtIndex:indexPath.row];
    }
    if([model.read intValue]==0){
        model.read=@"1";
        [listTable reloadData];
    }
    
    //评论了你
    if([model.action isEqual:XG_TYPE_COMMENT] || [model.action isEqual:XG_TYPE_ZAN_COMMENT]|| [XG_TYPE_COMMENTATUSER isEqual:model.action] || [model.action isEqual:XG_TYPE_Reposttopic]){
        TopicDetailController *rvc = [[TopicDetailController alloc] init];
        rvc.topicid = model.routeid;
        rvc.startcommentid=model.actionid;
        rvc.comefrom = 2;
        [self.navigationController pushViewController:rvc animated:YES];
    }
    
    //添加你为好友,或赞了你
    if([model.action isEqual:XG_TYPE_ADD_FRIENDS]|| [model.action isEqual:XG_TYPE_ZAN_USER]){
        UserDetailController *userinfo=[[UserDetailController alloc] init];
        userinfo.uid=model.actionuid;
        [self.navigationController pushViewController:userinfo animated:YES];
    }
    
    //赞了你
    if([model.action isEqual:XG_TYPE_ZAN] || [XG_TYPE_ATUSER isEqual:model.action]){
        TopicDetailController *rvc = [[TopicDetailController alloc] init];
        rvc.topicid = model.routeid;
        rvc.comefrom = 2;
        [self.navigationController pushViewController:rvc animated:YES];
    }
}


-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if([[RequestTools getInstance] getTipsNum]>0 || (newData.count==0 && historyData.count==0)){
        [listTable headerBeginRefreshing];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    if(newData!=nil && newData.count>0){
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                NSMakeRange(0,[newData count])];
        [historyData insertObjects:newData atIndexes:indexSet];
        [newData removeAllObjects];
        [listTable reloadData];
    }
    
}
#pragma mark -
#pragma mark NJKScrollFullScreenDelegate

//- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY
//{
//    [self moveNavigtionBar:deltaY animated:YES];
//    [self.leftBarItem setHidden:YES];
//    [self.rightBarItem setHidden:YES];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor clearColor], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
//}
//
//- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY
//{
//    [self moveNavigtionBar:deltaY animated:YES];
//    [self.rightBarItem setHidden:NO];
//    [self.leftBarItem setHidden:NO];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
//}
//
//- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy
//{
//    [self hideNavigationBar:YES];
//}
//
//- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy
//{
//    [self showNavigationBar:YES];
//}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [_scrollProxy reset];
//    [self showNavigationBar:YES];
//}


-(void)headerClick:(FeedsModel *)item{
    if(item){
        UserDetailController *controller=[[UserDetailController alloc] init];
        controller.uid=item.actionuid;
        [self.navigationController pushViewController:controller animated:YES];
    }
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTICE_ADDCOMMENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTICE_ADDZAN object:nil];
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
