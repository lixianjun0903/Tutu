//
//  SettingViewController.m
//  Tutu
//
//  Created by gaoyong on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SettingViewController.h"
#import "ChangePassWordViewController.h"
#import "UMFeedback.h"
#import "UMFeedbackViewController.h"
#import "SVWebViewController.h"
#import "SettingHeaderFile.h"
#import "UIView+Border.h"
#import "BlockListVController.h"
#import "NotificationSetController.h"
#import "UILabel+Additions.h"
#import "SDImageCache.h"
#import "InvisibleModeVController.h"
#import "UILabel+Additions.h"
#import "TCBlobDownloadManager.h"

#import "PrivacyController.h"

#define SOUNDSwitch 1000
#define NOTSwitch 2000

@interface SettingViewController () {
    
    NSString *_cacheSize;
}
@end
static NSString *settingCell = @"SettingCell";
@implementation SettingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        
    }
    return self;
}
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
   // [self setNavigationBarStyle];
    [self createTitleMenu];
    [self.menuRightButton setHidden:YES];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_setting") forState:UIControlStateNormal];
    self.mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.mainTable.separatorColor = HEXCOLOR(ListLineColor);
    [_mainTable registerNib:[UINib nibWithNibName:settingCell bundle:nil] forCellReuseIdentifier:settingCell];
    _cacheSize = @"0KB";
    _mainTable.sectionHeaderHeight = 20;
    _mainTable.rowHeight = 46;
    self.view.backgroundColor = HEXCOLOR(SystemGrayColor);
    _mainTable.backgroundColor = [UIColor clearColor];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    footView.backgroundColor = HEXCOLOR(SystemGrayColor);
    [self.mainTable setTableFooterView:footView];
    _dataArray = [[NSMutableArray alloc]init];

    _mainTable.frame = CGRectMake(0, NavBarHeight, ScreenWidth, SelfViewHeight - NavBarHeight);
    [self.view addSubview:_mainTable];
    
    NSArray *array1 = @[TTLocalString(@"TT_account_manager")];
    NSArray *array2 = @[TTLocalString(@"TT_sound"),TTLocalString(@"TT_new_message_notification"),TTLocalString(@"TT_is_accept_stranger_message"),TTLocalString(@"TT_is_wifi_auto_play")];
    NSArray *array3 = @[TTLocalString(@"TT_privacy")];
    NSArray *array4 = @[TTLocalString(@"TT_give_me_score"),TTLocalString(@"TT_user_agreement"),TTLocalString(@"TT_function_introduced"),TTLocalString(@"TT_help_feedback"),TTLocalString(@"TT_remove_storage_space")];
    [_dataArray addObjectsFromArray:@[array1,array2,array3,array4]];
    
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark table view data source methods;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    headerView.backgroundColor = HEXCOLOR(SystemGrayColor);
    return headerView;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ((NSArray *)_dataArray[section]).count;
}

-(UITableViewCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:settingCell forIndexPath:indexPath];
    cell.delegate = self;
    [cell loadCellWithTitle:_dataArray[indexPath.section][indexPath.row] info:@"" indexPaht:indexPath];
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}
#pragma SettingCellDelegate  

-  (void)switchValueChanged:(id)sender index:(NSIndexPath *)indexPath{
    
     UISwitch *switchBtn = sender;
    switch (indexPath.row) {
        case 0://声音开关
            if (switchBtn.isOn) {
                [switchBtn setOn:YES animated:YES];
                [SysTools setSoundEffectClose:NO];
            }
            else
            {
                [switchBtn setOn:NO animated:YES];
                [SysTools setSoundEffectClose:YES];
            }
            break;
        case 2://接受陌生用户信息提醒开关
            if (switchBtn.isOn) {
                [SysTools syncNSUserDeafaultsByKey:AllowStrangerMessage_KEY withValue:@"1"];
            }
            else
            {
                [SysTools syncNSUserDeafaultsByKey:AllowStrangerMessage_KEY withValue:@"0"];
            }
            break;
        case 3://3G下继续播放视频开关
            if (!switchBtn.isOn) {
                [UserDefaults setBool:YES forKey:UserDefaults_is_Close_AutoPlay_Under_Wifi];
                ApplicationDelegate.isAutoPlay = NO;
            }else{
                [UserDefaults setBool:NO forKey:UserDefaults_is_Close_AutoPlay_Under_Wifi];
                ApplicationDelegate.isAutoPlay = YES;
            }
            break;
            
        default:
            break;
    }
   

 
}


-(UILabel *)getLableWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:12];
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        label.frame =CGRectMake(SCREEN_WIDTH - 60 - 28,\
                                15, 60, label.frame.size.height);
    } else {
        label.frame =CGRectMake(SCREEN_WIDTH - 60 - 38,\
                                15, 60, label.frame.size.height);
    }
    [label setTextAlignment:NSTextAlignmentRight];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    return label;
}

-(UIImageView *)getImageWithName:(NSString *)name {
    
    UIImage *uiImage = [UIImage imageNamed:name];
    UIImageView *image = [[UIImageView alloc] initWithImage:uiImage];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        image.frame =CGRectMake(SCREEN_WIDTH - 68,\
                                5, 33, 33);
    } else {
        image.frame =CGRectMake(SCREEN_WIDTH - 78,\
                                5, 33, 33);
    }
    image.layer.cornerRadius = image.frame.size.height / 2.0;
    image.layer.masksToBounds = YES;
    return image;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    //    NSString *rowValue = @"";
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0:
                {
                    //                    账号管理
                    CompleteInfoController * managerAccount = [[CompleteInfoController alloc]init];
                    [self.navigationController pushViewController:managerAccount animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            if (row == 1) {
                NotificationSetController * notificationSet = [[NotificationSetController alloc] init];
                [self.navigationController pushViewController:notificationSet animated:YES];
            }
            break;
        }
        case 2:
        {
            switch (row) {
                case 0:
                {
                    PrivacyController *vc=[[PrivacyController alloc] init];
                    [self openNavWithSound:vc];
//                    InvisibleModeVController *vc = [[InvisibleModeVController alloc]init];
//                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
                    break;
                default:
                    break;
            }
            break;
        }
        case 3:
        {
            if (row==0) {
                NSString *APPID=@"934862300";
                
                NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
                NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%@", APPID]];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ) {
                    NSString *templateReviewURLiOS7 = @"itms-apps://itunes.apple.com/app/idAPP_ID";
                    
                    reviewURL = [templateReviewURLiOS7 stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%@", APPID]];
                }
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
                
            }
            if(row==1){
                
                SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/static/agreement.html",API_HOST]]];
                webView.title = TTLocalString(@"TT_user_agreement");
//                self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
                [self.navigationController pushViewController:webView animated:YES];
            }
            if (row == 2) {
                SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:API_Function_About]];
                webView.title = TTLocalString(@"TT_function_introduced");
//                self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
                [self.navigationController pushViewController:webView animated:YES];
                break;
            }
            if (row==3) {
                //                帮助与反馈
                //                [self playerSoundWith:@"open"];
                UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
                
                feedbackViewController.appkey = @"544f704ffd98c5a651002b48";
                [self.navigationController pushViewController:feedbackViewController animated:YES];
            }
            if (row == 4) {
                SettingCell *cell = (SettingCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:3]];
                if (cell.activityView.isAnimating != YES) {
                    LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@（ %@ ）",TTLocalString(@"TT_remove_storage_space"),cell.infoLab.text] delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
                    [sheet showInView:nil];

                }
                break;
            }
            
            break;
        }
    }
    
}

- (void)didClickOnButtonIndex:(NSInteger )buttonIndex tag:(NSInteger)tag{
    if (buttonIndex == 0) {
        SettingCell *cell = (SettingCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:3]];
        cell.infoLab.text = @"0KB";
        [[TCBlobDownloadManager sharedInstance]cancelAllDownloadsAndRemoveFiles:YES];
        [[SDImageCache sharedImageCache]clearDisk];
        NSError *error;
        [[NSFileManager defaultManager]removeItemAtPath:getVideoPath() error:&error];
    }else{
    
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}


@end


