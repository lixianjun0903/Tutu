//
//  UserSettingController.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "UserSettingController.h"
#import "UIView+Border.h"
#import "ToReportController.h"
#import "RCIMClient.h"
#import "UserInfoDB.h"
#import "ApplyLeaveDB.h"

@interface UserSettingController (){
    UITextField *nickField;
    int w;
    int y;
    BOOL isLoading;
}

@end

@implementation UserSettingController
@synthesize userInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"topic_more") forState:UIControlStateNormal];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    self.menuRightButton.hidden=YES;
    
    
    w=self.view.mj_width;
    y=NavBarHeight;
    
    [self createView];
    
    if(userInfo!=nil){
        [nickField setText:userInfo.nickname];
    }
    nickField.returnKeyType=UIReturnKeyDone;
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downKeyBoard:)];
    [self.view addGestureRecognizer:tap];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [nickField becomeFirstResponder];
//    });
}

-(void)downKeyBoard:(id)sender
{
    [nickField resignFirstResponder];
}


-(void)createView{
    
    if([userInfo.relation intValue]>1){
        UILabel *remarkLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, y+10, w-30, 32)];
        [remarkLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [remarkLabel setText:TTLocalString(@"TT_remark")];
        [remarkLabel setFont:ListTitleFont];
        [self.view addSubview:remarkLabel];
        y=y+42;
    
        UIView *textViewBack=[[UIView alloc] init];
        [textViewBack setFrame:CGRectMake(0, y, w, 44)];
        [textViewBack setBackgroundColor:[UIColor whiteColor]];
        [textViewBack addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
        [textViewBack addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
        [textViewBack setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:textViewBack];
        
        nickField=[[UITextField alloc] initWithFrame:CGRectMake(15, 0, w-30, 44)];
        [nickField setBackgroundColor:[UIColor clearColor]];
        [nickField setPlaceholder:TTLocalString(@"TT_Add notes")];
        [nickField setFont:ListTitleFont];
        [nickField setTextColor:UIColorFromRGB(TextBlackColor)];
        nickField.delegate=self;
        [textViewBack addSubview:nickField];
        
        y=y+44;
    }
    y=y+15;
    
    UIView *itemViewBack=[[UIView alloc] init];
    [itemViewBack setFrame:CGRectMake(0, y, w, 90)];
    [itemViewBack setBackgroundColor:[UIColor whiteColor]];
    [itemViewBack addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [itemViewBack addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [itemViewBack setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:itemViewBack];
    
    //
    [self addItemView:0 type:1 view:itemViewBack];
    
    //
    UIImageView *lineView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 44, w-15, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [itemViewBack addSubview:lineView];
    
    //
    [self addItemView:45 type:2 view:itemViewBack];
    
    
    y=y+90+20;
    
    UIView *itemViewBack2=[[UIView alloc] init];
    [itemViewBack2 setFrame:CGRectMake(0, y, w, 45)];
    [itemViewBack2 setBackgroundColor:[UIColor whiteColor]];
    [itemViewBack2 addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [itemViewBack2 addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [itemViewBack2 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:itemViewBack2];
    
    //
    [self addItemView:0 type:3 view:itemViewBack2];
    
    
    
    y=y+45+25;
}


-(void)addItemView:(int) itemy type:(int) itemType view:(UIView *)textViewBack{
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, itemy, w-80, 44)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    if(itemType==1){
        [textLabel setText:TTLocalString(@"TT_block_his(her)_content")];
    }else if(itemType==2){
        [textLabel setText:TTLocalString(@"TT_block_his(her)_message")];
    }else if(itemType==3){
        [textLabel setText:TTLocalString(@"TT_report_this_person")];
    }
    [textViewBack addSubview:textLabel];
    [textLabel setFont:ListTitleFont];
    [textLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    
    if(itemType<3){
        UISwitch *uiswitch=[[UISwitch alloc] initWithFrame:CGRectMake(w-65, itemy+7, 50, 30)];
        uiswitch.tag=itemType;
        [uiswitch addTarget:self action:@selector(uiswitchCahange:) forControlEvents:UIControlEventValueChanged];
        [uiswitch setOn:NO];
        [textViewBack addSubview:uiswitch];
        
        if(userInfo!=nil){
            if(userInfo.isBlock && itemType==2){
                [uiswitch setOn:YES animated:YES];
            }
        }
    }else if(itemType==3){
        UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [textLabel addGestureRecognizer:tap];
        textLabel.userInteractionEnabled=YES;
        
        
        UIImageView *rv=[[UIImageView alloc] initWithFrame:CGRectMake(w-15-30, 7, 30, 30)];
        [rv setImage:[UIImage imageNamed:@"p_right"]];
        [textViewBack addSubview:rv];
    }
}


-(void) tapClick:(UIGestureRecognizer *)tap{
    ToReportController *report=[[ToReportController alloc] init];
    report.uid=self.userInfo.uid;
    [self.navigationController pushViewController:report animated:YES];
}

-(IBAction)uiswitchCahange:(UISwitch *)sender{
    WSLog(@"%d",sender.isOn);
    NSString *api=@"";
    if(sender.tag==1){
        //屏蔽内容
        api=API_UNBLOCK_USER_FEED(userInfo.uid);
        if(sender.isOn){
            api=API_BLOCK_USER_FEED(userInfo.uid);
        }
    }else if(sender.tag==2){
        //屏蔽私信
        api=API_UNBLOCK(userInfo.uid);
        if(sender.isOn){
            api=API_BLOCK(userInfo.uid);
        }
        userInfo.isBlock=sender.isOn;
    }
    WSLog(@"%@",api);
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        if (sender.tag == 1) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_TOPIC object:userInfo];
        }else{
            // 屏蔽私信
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_MESSAGE object:userInfo];
            
//            if(userInfo.isBlock==0){
//                [[RCIMClient sharedRCIMClient] removeFromBlacklist:userInfo.uid completion:^{
//                    
//                } error:^(RCErrorCode status) {
//                    
//                }];
//            }else{
//                [[RCIMClient sharedRCIMClient] addToBlacklist:userInfo.uid completion:^{
//                    
//                } error:^(RCErrorCode status) {
//                    
//                }];
//            }
        }
        
        [[LoginManager getInstance] saveInfoToDB:userInfo];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}

-(void)deleteFriend:(UIButton *)sender{
    LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:TTLocalString(@"TT_Determine remove buddy") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
    [sheet showInView:nil];
}
- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if (buttonIndex == 0) {
        [self sendDeleteFriendRequest];
    }
}
- (void)sendDeleteFriendRequest{
    if(isLoading){
        return;
    }
    isLoading=YES;
    
    [[RequestTools getInstance] get:[NSString stringWithFormat:@"%@?frienduid=%@",API_MY_FRIEND_DELETE,userInfo.uid] isCache:NO completion:^(NSDictionary *dict) {
        WSLog(@"%@",dict);
        NSString *relation=[dict objectForKey:@"data"];
        WSLog(@"%@",relation);
        userInfo.relation= [NSString stringWithFormat:@"%@",relation];
        
        [[LoginManager getInstance] saveInfoToDB:userInfo];
        
        UserInfoDB *db = [[UserInfoDB alloc]init];
        userInfo.nickname=userInfo.realname;
        [db saveUser:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DELADDFRIEND object:userInfo];
        [self.view viewWithTag:101].hidden=YES;
        
        @try {
            [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:userInfo.uid];
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:userInfo.uid];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        
        [self goBack:nil];
        
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        isLoading=NO;
    }];
}
//提交修改备注
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    WSLog(@"点击完成");
    NSString *text=nickField.text;
    int size=getStringCharCount(text);
    if(size>64){
        [self showNoticeWithMessage:TTLocalString(@"TT_Note only input and 32 characters") message:@"" bgColor:TopNotice_Red_Color];
        return YES;
    }
    //    提交成功
    [[RequestTools getInstance] get:API_UPDATE_REMARD_NICK(userInfo.uid,text) isCache:NO completion:^(NSDictionary *dict) {
        userInfo.remarkname=dict[@"data"][@"remark"];
        userInfo.nickname=userInfo.realname;
        UserInfoDB *db = [[UserInfoDB alloc]init];
        [db updateUser:userInfo];
        TopicCacheDB *topicDB=[[TopicCacheDB alloc] init];
        [topicDB updateTopicNickName:userInfo.uid nickName:userInfo.remarkname];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTICE_UPDATE_UserInfo object:userInfo];
        [self.navigationController popViewControllerAnimated:YES];
        
        
        @try {
            ApplyLeaveDB *aldb=[[ApplyLeaveDB alloc] init];
            ApplyFriendModel *afm=[aldb findModelWidthUID:userInfo.uid];
            afm.nickname=userInfo.nickname;
            [aldb saveApplyToDB:afm];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:@"" bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
        
    }];
    return YES;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
