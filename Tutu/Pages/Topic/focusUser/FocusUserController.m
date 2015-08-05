//
//  FocusUserController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FocusUserController.h"
#import "SameCityCell.h"
#import "UserDetailController.h"

#define ReuseIdentifierCell @"SameCityCell"

@interface FocusUserController (){
    CGFloat w;
    CGFloat h;
    NSMutableArray *listArray;
}


@end

@implementation FocusUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    
    [self createTitleMenu];
    self.menuRightButton.hidden=YES;
    
    listArray=[[NSMutableArray alloc] init];
    
    [self.listTable setFrame:CGRectMake(0, NavBarHeight, w, h-NavBarHeight)];
    [self.listTable registerNib:[UINib nibWithNibName:ReuseIdentifierCell bundle:nil]  forCellReuseIdentifier:ReuseIdentifierCell];
    [self.listTable setSeparatorColor:[UIColor clearColor]];
    [self.listTable setBackgroundColor:[UIColor clearColor]];
    [self.listTable setRowHeight:76];
    [self.listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    [self setTitleText];
    
    //加载数据
    [self refreshData];
}

-(void)refreshData{
    NSString *str_api=[NSString stringWithFormat:@"%@%@&direction=%@",_apiString,@"",Load_UP];
    [[RequestTools getInstance] get:str_api isCache:NO completion:^(NSDictionary *dict) {
        NSArray *datas = dict[@"data"][@"userlist"];
        _usernum=dict[@"data"][@"usercount"];
        [self setTitleText];
        
        if(datas.count==0){
            return ;
        }
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in datas) {
            UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
            [mArray addObject:model];
        }
        
        [listArray addObjectsFromArray:mArray];
        
        [self.listTable reloadData];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([self.listTable isFooterRefreshing]){
            [self.listTable footerEndRefreshing];
        }
    }];
}

-(void)loadMoreData{
    NSString *startid=@"";
    if(listArray.count>0){
        startid=((UserInfo *)[listArray objectAtIndex:listArray.count-1]).uid;
    }
    
    NSString *str_api=[NSString stringWithFormat:@"%@%@&direction=%@",_apiString,startid,Load_MORE];
    [[RequestTools getInstance] get:str_api isCache:NO completion:^(NSDictionary *dict) {
        NSArray *datas = dict[@"data"][@"userlist"];
        _usernum=dict[@"data"][@"usercount"];
        [self setTitleText];
        
        
        if(datas.count==0){
            return ;
        }
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in datas) {
            UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
            [mArray addObject:model];
        }
        
        [listArray addObjectsFromArray:mArray];
        [self.listTable reloadData];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([self.listTable isFooterRefreshing]){
            [self.listTable footerEndRefreshing];
        }
    }];
}

-(void)setTitleText{
    if(_abouttype==AboutFocusType){
        [self.menuTitleButton setTitle:[NSString stringWithFormat:@"%@%@",_usernum,TTLocalString(@"TT_follows")] forState:UIControlStateNormal];
    }
}



#pragma 数据展示
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SameCityCell *cell = (SameCityCell*)[tableView dequeueReusableCellWithIdentifier:ReuseIdentifierCell];
    if (cell == nil) {
        cell = [[SameCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdentifierCell];
    }
    //    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    UserInfo *model=[listArray objectAtIndex:indexPath.row];
    if(model){
        [cell initDataToView:model width:w reference:ReferenceFocusUserPage];
    }
    if(indexPath.row==(listArray.count-1)){
        cell.cellSepetor.hidden=YES;
    }else{
        cell.cellSepetor.hidden=NO;
    }
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WSLog(@"%@",indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *user=[listArray objectAtIndex:indexPath.row];
    UserDetailController *uinfo=[[UserDetailController alloc] init];
    uinfo.uid=user.uid;
    [self.navigationController pushViewController:uinfo animated:YES];
}
#pragma table end


-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
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
