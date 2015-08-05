//
//  UserFocusController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserFocusController.h"
#import "ListTopicsController.h"
#import "UserDetailController.h"

#define staticUserFocusCell @"UserFocusCell"
@interface UserFocusController (){
    CGFloat w;
    CGFloat h;
    
    NSMutableArray *listArr;
}

@end

@implementation UserFocusController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    
    [self.listTable setBackgroundColor:[UIColor clearColor]];
    [self.listTable registerNib:[UINib nibWithNibName:staticUserFocusCell bundle:nil]  forCellReuseIdentifier:staticUserFocusCell];
    
    UIView *header=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, self.tableHeaderHeight)];
    [header setBackgroundColor:[UIColor clearColor]];
    [self.listTable setTableHeaderView:header];
}

//设置table的高度
-(void)setTableHeaderHeight:(CGFloat)tableHeaderHeight{
    UIView *header=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, self.tableHeaderHeight)];
    [header setBackgroundColor:[UIColor clearColor]];
    [self.listTable setTableHeaderView:header];
}


-(void)refreshData{
    NSString *api=API_GetUserFocus_List(self.uid,Load_UP,@"",@"20");
    WSLog(@"%@",api);
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"followlist"];
        if(arr!=nil && arr.count>0){
            listArr=[[UserFocusModel alloc] getWithArray:arr];
            
            [self reloadTableData:YES];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"%@",request.responseString);
        if(self.listTable.isHeaderRefreshing){
            [self.listTable headerEndRefreshing];
        }
    }];
}


-(void)loadMoreData{
    NSString *startid=@"";
    if(listArr!=nil && listArr.count>0){
        UserFocusModel *model=[listArr objectAtIndex:listArr.count-1];
        startid=model.fid;
    }
    [self reloadTableData:0];
    NSString *api=API_GetUserFocus_List(self.uid,Load_MORE,startid,@"20");
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"followlist"];
        if(arr!=nil && arr.count>0){
            NSMutableArray *array=[[UserFocusModel alloc] getWithArray:arr];
            [listArr addObjectsFromArray:array];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([self.listTable isFooterRefreshing]){
            
            [self.listTable footerEndRefreshing];
        }
        [self reloadTableData:YES];
    }];
}

-(void)reloadTableData:(int)showNotice{
    [self.listTable reloadData];
}

#pragma mark table 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //第一个cell
    
        UserFocusCell *cell = (UserFocusCell*)[tableView dequeueReusableCellWithIdentifier:staticUserFocusCell];
        if (cell == nil) {
            cell = [[UserFocusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:staticUserFocusCell];
        }
        
        cell.delegate=self;
        
        [cell dataToView:[listArr objectAtIndex:indexPath.row] width:w];
    
    
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
    UserFocusModel *model=[listArr objectAtIndex:indexPath.row];
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=model.title;
    control.pageType=TopicWithDefault;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openController:)])
    {
        [self.delegate openController:control];
    }
}


#pragma mark 话题主题点击
-(void)extendLabel:(TTExtendLabel *)extendLabel didSelectLink:(NSString *)link withType:(TTExtendLabelLinkType)type{
    if(type==TTExtendLabelLinkTypePoundSign){
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString=link;
        
        control.pageType=TopicWithDefault;
        if(self.delegate && [self.delegate respondsToSelector:@selector(openController:)])
        {
            [self.delegate openController:control];
        }
    }
    if(type==TTExtendLabelLinkTypeAt){
        UserDetailController *detail=[[UserDetailController alloc] init];
        detail.nickName=[link stringByReplacingOccurrencesOfString:@"@" withString:@""];
        if(self.delegate && [self.delegate respondsToSelector:@selector(openController:)])
        {
            [self.delegate openController:detail];
        }
    }
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(focusScrollViewDidView:)]){
        [self.delegate focusScrollViewDidView:scrollView];
    }
}


-(void)itemFocusClick:(UserFocusModel *)focusModel{
    
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
