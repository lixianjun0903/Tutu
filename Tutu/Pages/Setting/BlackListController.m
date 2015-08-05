//
//  BlackListController.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-18.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BlackListController.h"
#import "BlockListVController.h"

@interface BlackListController (){
    NSMutableArray *dataArray;
}

@end

static NSString *cellIdentifier = @"ListCell";

@implementation BlackListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_blacklist") forState:UIControlStateNormal];
    [self.menuRightButton setHidden:YES];
    
    
    dataArray=[[NSMutableArray alloc] initWithObjects:TTLocalString(@"TT_block_his(her)_message"),TTLocalString(@"TT_block_his(her)_content"), nil];
    
    [_listTable registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    _listTable.frame = CGRectMake(0, NavBarHeight, ScreenWidth, SelfViewHeight - NavBarHeight);
    //    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    //    headerView.backgroundColor = HEXCOLOR(SystemGrayColor);
    //    [_listTable setTableHeaderView:headerView];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.mj_width, 44)];
    footView.backgroundColor = HEXCOLOR(SystemGrayColor);
    [_listTable setTableFooterView:footView];
    
    _listTable.separatorColor = HEXCOLOR(ListLineColor);
    _listTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.view.backgroundColor = HEXCOLOR(SystemGrayColor);
    _listTable.backgroundColor = [UIColor clearColor];
    
}

-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    [cell.textLabel setFont:ListTitleFont];
    [cell.detailTextLabel setFont:ListDetailFont];
    
    [cell.textLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [cell.detailTextLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    
    cell.textLabel.text=dataArray[indexPath.row];
//    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    UIImage *image= [ UIImage imageNamed:@"p_right" ];
    CGRect frame = CGRectMake( SelfViewWidth-42 , 7.5 , 42, 30);
    
    UIImageView *iv=[[UIImageView alloc] initWithImage:image];
    [iv setFrame:frame];
    [iv setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:iv];
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==0){
        BlockListVController * personalBlock = [[BlockListVController alloc]init];
        personalBlock.blockType = BlockTypeMessage;
        [self.navigationController pushViewController:personalBlock animated:YES];
    }
    else if(indexPath.row==1){
        BlockListVController * contentBlock = [[BlockListVController alloc]init];
        contentBlock.blockType = BlockTypeTopic;
        [self.navigationController pushViewController:contentBlock animated:YES];
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
