//
//  InvisibleModeVController.m
//  Tutu
//
//  Created by gexing on 12/18/14.
//  Copyright (c) 2014 zxy. All rights reserved.
//

#import "InvisibleModeVController.h"
#import "UILabel+Additions.h"
#import "UserInfoDB.h"
@interface InvisibleModeVController ()
{
    NSInteger _selectedIndex;
    NSInteger _lastIndex;
}
@end
static NSString *cellIdentifier = @"Cell";
@implementation InvisibleModeVController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_stealth_mode") forState:UIControlStateNormal];
    [self.menuRightButton setHidden:YES];
    
    // Do any additional setup after loading the view from its nib.
    [_mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    _mainTable.frame = CGRectMake(0, NavBarHeight, ScreenWidth, SelfViewHeight - NavBarHeight);
    [self.view addSubview:_mainTable];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    headerView.backgroundColor = HEXCOLOR(SystemGrayColor);
    [_mainTable setTableHeaderView:headerView];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.mj_width, 44)];
    footView.backgroundColor = HEXCOLOR(SystemGrayColor);
    [_mainTable setTableFooterView:footView];
    _mainTable.rowHeight = 60;
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.view.backgroundColor = HEXCOLOR(SystemGrayColor);
    _mainTable.backgroundColor = [UIColor clearColor];
    //默认对好友可见
    NSString *locationstatus = [[LoginManager getInstance]getLoginInfo].locationstatus;
    if ([locationstatus isEqualToString:@"none"]) {
        _selectedIndex = 2;
    }else if ([locationstatus isEqualToString:@"friend"]){
        _selectedIndex = 1;
    }else{
        _selectedIndex = 0;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor whiteColor];
    
    NSArray *titles = @[TTLocalString(@"TT_visible_to_all"),TTLocalString(@"TT_visible_to_friend"),TTLocalString(@"TT_visible_to_none"),];
    NSArray *desc = @[TTLocalString(@"TT_visible_distance_to_all"),TTLocalString(@"TT_visible_distance_to_friend"),TTLocalString(@"TT_visible_distance_to_none"),];
   
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:777];
    if (titleLabel == nil) {
        titleLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(TextBlackColor)];
        titleLabel.frame = CGRectMake(15, 12, 200, 16);
        [cell.contentView addSubview:titleLabel];
        titleLabel.tag = 777;
        titleLabel.text = titles[indexPath.row];
    }
    UILabel *descLabel = (UILabel *)[cell viewWithTag:888];
    if (descLabel == nil) {
        descLabel = [UILabel labelWithSystemFont:12 textColor:HEXCOLOR(TextGrayColor)];
        descLabel.frame = CGRectMake(titleLabel.mj_x, titleLabel.max_y + 8, 200, 12);
        [cell.contentView addSubview:descLabel];
        descLabel.tag = 888;
        descLabel.text = desc[indexPath.row];
    }
    UIImageView *selectedImageView = (UIImageView *)[cell viewWithTag:999];
    if (selectedImageView == nil) {
        selectedImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"setting_selected"]];
        selectedImageView.bounds = CGRectMake(0, 0, 18, 14);
        selectedImageView.frame = CGRectMake(ScreenWidth - selectedImageView.mj_width - 15,(cell.mj_height - selectedImageView.mj_height) / 2.0f, 18, 14);
        selectedImageView.tag = 999;
        [cell.contentView addSubview:selectedImageView];
        selectedImageView.hidden = YES;
    }
    if (_selectedIndex == indexPath.row) {
        [selectedImageView setHidden:NO];
    }else{
        [selectedImageView setHidden:YES];
    }
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _lastIndex = _selectedIndex;
    _selectedIndex = indexPath.row;
    [_mainTable reloadData];
    NSString *status = @"";
    switch (_selectedIndex) {
        case 0:
           status = @"all";
            break;
        case 1:
           status = @"friend";
            break;
        case 2:
           status = @"none";
            break;
            
        default:
            break;
    }
    [[RequestTools getInstance]get:API_SET_USER_INFO(status) isCache:NO completion:^(NSDictionary *dict) {
        NSString *locationstatus = @"";
        switch (_selectedIndex) {
            case 0:
                locationstatus = @"all";
                break;
            case 1:
                locationstatus = @"friend";
                break;
            case 2:
                locationstatus = @"none";
                break;
                
            default:
                break;
        }
        
        UserInfo *userInfo = [[LoginManager getInstance] getLoginInfo];
        userInfo.locationstatus = locationstatus;
        [[LoginManager getInstance] saveInfoToDB:userInfo];
 
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        //失败之后要还原之前的状态。
        _selectedIndex = _lastIndex;
        [_mainTable reloadData];
    } finished:^(ASIHTTPRequest *request) {
        
    }];
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
