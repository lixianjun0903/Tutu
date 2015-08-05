//
//  PrivacyController.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-18.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "PrivacyController.h"
#import "UILabel+Additions.h"

#import "BlackListController.h"
#import "InvisibleModeVController.h"
#import "SendLocalTools.h"
#import "M13ProgressViewRing.h"

@interface PrivacyController (){
    NSMutableArray *dataArray;
    ASIFormDataRequest *request;
    M13ProgressViewRing *_progressView;
    UILabel *detailLabel;
}

@end

static NSString *cellIdentifier = @"ListCell";

@implementation PrivacyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_privacy") forState:UIControlStateNormal];
    [self.menuRightButton setHidden:YES];
    
    
    dataArray=[[NSMutableArray alloc] initWithObjects:TTLocalString(@"TT_blacklist"),TTLocalString(@"TT_stealth_mode"),TTLocalString(@"TT_chat_history_download"), nil];
    
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
    
    
    if(self.fromPage==1){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self exportData];
        });
    }
    
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
    UITableViewCell *cell = nil;
    if(indexPath.row==2){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }else{
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor whiteColor];
    
    
    [cell.textLabel setFont:ListTitleFont];
    [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    [cell.textLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [cell.detailTextLabel setTextColor:UIColorFromRGB(SystemColor)];
    
    cell.textLabel.text=dataArray[indexPath.row];
    if(indexPath.row==2){
        cell.accessoryType=UITableViewCellAccessoryNone;
        if([[ SendLocalTools getInstance] checkExportIMData]){
            [cell.detailTextLabel setText:TTLocalString(@"TT_download_success")];
        }else if([[SendLocalTools getInstance] checkExportIMPause]){
            [cell.detailTextLabel setText:TTLocalString(@"TT_download_pause")];
        }else{
            [cell.detailTextLabel setText:TTLocalString(@"TT_download_start")];
        }
        detailLabel=cell.detailTextLabel;
    }else{
//        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
//        cell. accessoryView = iv;
        UIImage *image= [ UIImage imageNamed:@"p_right" ];
        CGRect frame = CGRectMake( SelfViewWidth-42 , 7.5 , 42, 30);
        
        UIImageView *iv=[[UIImageView alloc] initWithImage:image];
        [iv setFrame:frame];
        [iv setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:iv];
    }
    _progressView = (M13ProgressViewRing *)[cell viewWithTag:999];
    if(_progressView==nil){
        _progressView=[[M13ProgressViewRing alloc]initWithFrame:CGRectMake(SelfViewWidth-49, 5.5, 34, 34)];
        _progressView.progressRingWidth = 5;
        _progressView.backgroundRingWidth = 5;
        _progressView.showPercentage = YES;
        _progressView.tag=999;
        [_progressView setPrimaryColor:HEXCOLOR(0x52CBAB)];
        [_progressView setSecondaryColor:HEXCOLOR(0xE5F7F2)];
        [cell.contentView addSubview:_progressView];
    }
    _progressView.hidden=YES;
    
    
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
        BlackListController *vc=[[BlackListController alloc] init];
        [self openNavWithSound:vc];
    }
    else if(indexPath.row==1){
        InvisibleModeVController *vc=[[InvisibleModeVController alloc] init];
        [self openNavWithSound:vc];
    }else{
        [self exportData];
    }
}


-(void)exportData{
    if([[ SendLocalTools getInstance] checkExportIMData]){
        detailLabel.text=TTLocalString(@"TT_download_success");
        return;
    }
    
    if(request!=nil){
        detailLabel.text=TTLocalString(@"TT_download_pause");
        _progressView.hidden=YES;
        [request cancel];
        request=nil;
    }else{
        detailLabel.text=@"";
        _progressView.hidden=NO;
        request=[[SendLocalTools getInstance] exportIMDataReceive:^(long long size, long long total) {
            [_progressView setProgress:size / [@(total) doubleValue] animated:YES];
        } finish:^(int isSuccess) {
            if(isSuccess){
                [self.listTable reloadData];
            }
            
            [request cancel];
            request=nil;
        }];
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
