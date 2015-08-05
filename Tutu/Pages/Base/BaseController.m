//
//  BaseController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "UtilsMacro.h"
#import "UILabel+Additions.h"
#import "LoginViewController.h"
#import "UIImage+ImageWithColor.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MobClick.h"
#import "UserInfoDB.h"
#import "SynchMarkDB.h"
#import "LoginManager.h"

@interface BaseController (){
}

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.frame = CGRectMake(0, 0,ScreenWidth, ScreenHeight);

    
    //获取消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doParseRCMessage:) name:NOTICE_RC_RECICEMESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doParseRCConnect:) name:NOTICE_RC_CONNECT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doParseRCConnectError) name:NOTICE_RC_CONNECT_ERROR object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doParseBlockNotice:) name:NOTICE_BLOCKORUN object:nil];
}


- (void)createPlaceholderView:(CGPoint)center message:(NSString *)message withView:(UIView *)superView{
    if (_placeholderView) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
    
    _placeholderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 105)];
    _placeholderView.center = center;
    if(superView!=nil){
        [superView addSubview:_placeholderView];
    }else{
        [self.view insertSubview:_placeholderView atIndex:0];
    }
    
    UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"null_page_pic"]];
    icon.bounds = CGRectMake(0, 0, 40, 51);
    icon.frame = CGRectMake(0, _placeholderView.mj_height - icon.mj_height, icon.mj_width, icon.mj_height);
    [_placeholderView addSubview:icon];
    
    UIImageView *bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"null_page_message"]];
    bgView.bounds = CGRectMake(0, 0, 166, 56);
    bgView.frame = CGRectMake(25, 2, bgView.mj_width, bgView.mj_height);
    [_placeholderView addSubview:bgView];
    
    UILabel *messageLabel = [UILabel labelWithSystemFont:12 textColor:HEXCOLOR(TextGrayColor)];
    messageLabel.text = message;
    messageLabel.frame = CGRectMake(0, 0, 140, 0);
    CGSize labelSize = [messageLabel getLabelSize];
    messageLabel.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
    messageLabel.center = CGPointMake(bgView.mj_width / 2.0f, 45 / 2.0f);
    [bgView addSubview:messageLabel];

    UIImage *image = [UIImage imageNamed:@"null_page_message"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 30, 20)];
    bgView.frame = CGRectMake(25,56 - 50 - labelSize.height, 166, labelSize.height + 40);
    bgView.image = image;
    
    messageLabel.frame = CGRectMake(13, 14, labelSize.width, labelSize.height);
    
    
}

- (void)removePlaceholderView{
    if (_placeholderView) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
}
-(void)createTitleMenu{
    int height=44;
    
    self.titleMenu=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, height+StatusBarHeight)];
    [self.titleMenu setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.view addSubview:self.titleMenu];
    
    
    self.menuTitleButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuTitleButton setFrame:CGRectMake(44, StatusBarHeight, self.view.mj_width-88, 44)];
    [self.menuTitleButton setBackgroundColor:[UIColor clearColor]];
    [self.menuTitleButton.titleLabel setFont:TitleFont];
    [self.menuTitleButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateNormal];
    [self.titleMenu addSubview:self.menuTitleButton];
   
    
    self.menuLeftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuLeftButton setFrame:CGRectMake(0, StatusBarHeight, 44, 44)];
    self.menuLeftButton.tag=BACK_BUTTON;
    [self.menuLeftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(3, 4, 3, 4)];
    [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(12, 8, 13, 24)];
    
    [self.menuLeftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.menuLeftButton setImage:[UIImage imageNamed:@"backc_light"] forState:UIControlStateHighlighted];
    [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(12, 8, 13, 24)];
    [self.titleMenu addSubview:self.menuLeftButton];
    
    self.menuRightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuRightButton setFrame:CGRectMake(self.view.mj_width-44, StatusBarHeight, 44, 44)];
    self.menuRightButton.tag=RIGHT_BUTTON;
    [self.menuRightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(3, 10, 3, 10)];
    [self.menuRightButton setImage:[UIImage imageNamed:@"setting_nor"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"setting_sel"] forState:UIControlStateHighlighted];
    [self.titleMenu addSubview:self.menuRightButton];
    
    self.otherButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.otherButton setFrame:CGRectMake(self.view.mj_width-88, StatusBarHeight, 44, 44)];
    self.otherButton.tag=RIGHT_BUTTON;
    [self.otherButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.otherButton setImageEdgeInsets:UIEdgeInsetsMake(3, 10, 3, 10)];
    [self.otherButton setImage:[UIImage imageNamed:@"setting_nor"] forState:UIControlStateNormal];
    [self.otherButton setImage:[UIImage imageNamed:@"setting_sel"] forState:UIControlStateHighlighted];
    [self.titleMenu addSubview:self.otherButton];
    self.otherButton.hidden=YES;
}



#pragma mark



//*******************************************************************
-(BOOL)isLogin{
    return [[LoginManager getInstance] isLogin];
}

-(void)doLogin{
    LoginViewController * login = [[LoginViewController alloc] init];
//    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:login];
//    nav.navigationBarHidden=YES;
//    [self.view.window setRootViewController:nav];
    [self openNav:login sound:nil];
}

-(NSString *)getUID{
    return [[LoginManager getInstance] getUid];
}

-(IBAction)openNavWithSound:(UIViewController *)controller{
    SystemSoundID soundID;
    NSURL *filePath   = [[NSBundle mainBundle] URLForResource:@"open" withExtension: @"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    
    AudioServicesPlaySystemSound(soundID);

    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)openNav:(UIViewController *)controller sound:(NSString *)soundName{
    if(soundName!=nil && ![@"" isEqual:soundName]){
        SystemSoundID soundID;
        NSURL *filePath   = [[NSBundle mainBundle] URLForResource:@"open" withExtension: @"m4a"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        
        AudioServicesPlaySystemSound(soundID);
    }
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)playerSoundWith:(NSString *)soundName{
    if ([SysTools isCloseSoundEffect]) {
        return;
    }
    SystemSoundID soundID;
    NSURL *filePath   = [[NSBundle mainBundle] URLForResource:soundName withExtension: @"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    
    AudioServicesPlaySystemSound(soundID);
}

-(IBAction)goBack:(id)sender{
    if(self.navigationController!=nil){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)buttonClick:(id)sender{
    
}

-(void)refreshData{

}
-(void)loadMoreData{


}


-(UIView *)showNoticeWithMessage:(NSString *)title message:(NSString *)detail bgColor:(TopNoticeBackColor)colorEnum{
   return  [self showNoticeWithMessage:title message:detail bgColor:colorEnum block:nil];
}

-(UIView *) showNoticeWithMessage:(NSString *)title message:(NSString *)detail bgColor:(TopNoticeBackColor)colorEnum block:(NoticeComplete)finish{
    UIView *showNotice=[[UIView alloc] initWithFrame:CGRectMake(0, -44-StatusBarHeight, self.view.mj_width, 44+StatusBarHeight)];
    if(colorEnum==TopNotice_Block_Color){
        [showNotice setBackgroundColor:UIColorFromRGB(NoticeBlockBgColor)];
    }else if(colorEnum==TopNotice_Red_Color){
        [showNotice setBackgroundColor:UIColorFromRGB(NoticeColor)];
    }
    
    UILabel *label=[[UILabel alloc] init];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:title];
    
    if(detail==nil ||[@"" isEqual:detail]){
        [label setFrame:CGRectMake(0, StatusBarHeight, self.view.mj_width, 44)];
    }else{
        [label setFrame:CGRectMake(0, StatusBarHeight, self.view.mj_width, 20)];
        
        UILabel *msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 20+StatusBarHeight, self.view.mj_width, 20)];
        [msgLabel setBackgroundColor:[UIColor clearColor]];
        [msgLabel setTextColor:[UIColor whiteColor]];
        [msgLabel setFont:[UIFont systemFontOfSize:12]];
        [msgLabel setTextAlignment:NSTextAlignmentCenter];
        [msgLabel setText:detail];
        [showNotice addSubview:msgLabel];
    }
    [showNotice addSubview:label];
    [[[UIApplication sharedApplication]keyWindow]addSubview:showNotice];
    [self animationShowNotice:showNotice block:finish];
    return showNotice;
}


-(void)animationShowNotice:(UIView *) view block:(NoticeComplete) finish{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect cf=view.frame;
        cf.origin.y=0;
        view.frame=cf;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                CGRect cf1=view.frame;
                cf1.origin.y=-44-StatusBarHeight;
                view.frame=cf1;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
                if(finish){
                    finish();
                }
            }];
        });
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:self.description];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)dealloc{
    //移除消息监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [MobClick endLogPageView:self.description];
//    [self.navigationController setNavigationBarHidden:NO];
    
}



-(void)doParseRCMessage:(NSNotification *) noti
{
    //获取参数
    @try {
        NSDictionary *dict=[noti object];
        if(dict!=nil){
            RCMessage *message=[dict objectForKey:@"message"];
            int num= [CheckNilValue([dict objectForKey:@"num"]) intValue];
            id otherObject=[dict objectForKey:@"other"];
            if([SysTools checkItemIsBlock:message]){
                //这条消息，不应该被收到，直接删除
                NSArray *arr=[NSArray arrayWithObject:[NSNumber numberWithLong:message.messageId]];
                [[RCIMClient sharedRCIMClient] deleteMessages:arr];
            }else if([@"998" isEqual:message.targetId]){
                if([message.objectName isEqual:RCTextMessageTypeIdentifier]){
                    RCTextMessage *rcmsg=(RCTextMessage *)message.content;
                    NSDictionary *dict=[[rcmsg.extra JSONString] objectFromJSONString];
                    NSDictionary *newsItem=[dict objectForKey:@"extradata"];
                    [[RequestTools getInstance] setNewsCountWithDict:newsItem];

                }
                
                //这条消息，不应该被收到，直接删除
                NSArray *arr=[NSArray arrayWithObject:[NSNumber numberWithLong:message.messageId]];
                [[RCIMClient sharedRCIMClient] deleteMessages:arr];
                [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId];
            }else if([@"999" isEqual:message.targetId]){
                @try {
                    if([message.objectName isEqual:RCTextMessageTypeIdentifier]){
                        RCTextMessage *rcmsg=(RCTextMessage *)message.content;
                        NSDictionary *dict=[[rcmsg.extra JSONString] objectFromJSONString];
                        WSLog(@"%@",dict);
                        NSString *uid=[dict objectForKey:@"frienduid"];
                        UserInfoDB *db=[[UserInfoDB alloc] init];
                        UserInfo *uinfo=[db findWidthUID:uid];
                        if(uinfo!=nil && uinfo.uid!=nil){
                            uinfo.canchat=[[dict objectForKey:@"canchat"] boolValue];
                            uinfo.relation=[dict objectForKey:@"relation"];
                            uinfo.nickname=uinfo.realname;
                            [db saveUser:uinfo];
                            
                            [self reciveRCMessage:nil num:num object:message.targetId];
                        }
                    }
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                //这条消息，不应该被收到，直接删除
                NSArray *arr=[NSArray arrayWithObject:[NSNumber numberWithLong:message.messageId]];
                [[RCIMClient sharedRCIMClient] deleteMessages:arr];
                [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId];
            }else{
                if([@"10001" isEqual:message.senderUserId]){
                    //同步个人信息
                    SynchMarkDB *db=[[SynchMarkDB alloc] init];
                    NSString *time=[db findWidthUID:SynchMarkTypeUserInfo];
                    
                    NSString *api=[NSString stringWithFormat:@"%@?localupdatetime=%@",API_GET_SELFINFO,time];
                    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
//                        WSLog(@"%@",dict);
                        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                            
                            NSDictionary *item=[dict objectForKey:@"data"];
                            UserInfo *user=[[LoginManager getInstance] parseDictData:[item objectForKey:@"userinfo"]];
                            if(user!=nil && user.uid!=nil){
                                [[LoginManager getInstance] saveInfoToDB:user];
                                
                                //保存更新时间
                                NSString *time=[item objectForKey:@"updatetime"];
                                [db saveSynchData:SynchMarkTypeUserInfo withTime:time];
                                
                                [self reciveRCMessage:nil num:0 object:@"999"];
                            }
                            
                        }
                    } failure:^(ASIHTTPRequest *request, NSString *message) {
                        
                    } finished:^(ASIHTTPRequest *request) {
                        
                    }];
                }
                
                
//                if([message.targetId isEqual:[[LoginManager getInstance] getUid]]){
//                    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId];
//                }
                
                
                UserInfoDB *db=[[UserInfoDB alloc] init];
                UserInfo *info=[db findWidthUID:message.senderUserId];
                //我把对方删了，不显示
                if(info!=nil && [info.relation intValue]==6){
                    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId];
                }
                if(info!=nil && ([info.relation intValue]==0 || [info.relation intValue]==1)){
                    NSString *isAllowStranger=[SysTools getValueFromNSUserDefaultsByKey:AllowStrangerMessage_KEY];
                    // 不接收陌生人消息，直接删除
                    if([@"0" isEqual:isAllowStranger]){
                        NSArray *arr=[NSArray arrayWithObject:[NSNumber numberWithLong:message.messageId]];
                        [[RCIMClient sharedRCIMClient] deleteMessages:arr];
                        
                        [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId];
                    }
                }
                
                if(info!=nil){
                    // 设置常用联系人
//                    [[SendLocalTools getInstance] setFavContacts:self.userid];
                    info.nickname=info.realname;
                    info.changetime=[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
                    [db updateUser:info];
                }
                
                [self reciveRCMessage:message num:num object:otherObject];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void)doParseRCConnect:(NSString *) userId
{
    //获取参数
    if(userId!=nil){
        [self connectRCSuccess:userId];
    }
}

-(void)doParseRCConnectError{
    [self connectRCError:@""];
}


-(void)doParseBlockNotice:(NSNotification *) noti{
    //获取参数
    NSDictionary *dict=[noti object];
    if(dict!=nil){
        [self pushBlockNotice:[dict objectForKey:@"action"] uid:[dict objectForKey:@"actionuid"]];
    }
}




-(void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object{
    // to do
    // 需要接受消息的页面实现此方法即可
}

-(void)connectRCSuccess:(NSString *)userId{
    // to do
    // 需要重新判断链接的实现此方法
}

-(void)connectRCError:(NSString *)errorMsg{
    // to do
    // 需要重新判断链接的状态
}


-(void)pushBlockNotice:(NSString *)action uid:(NSString *)userid{
    // to do
    // 屏蔽或解除屏蔽私信通知回调
}




-(BOOL)checkBeKill{
    if([LoginManager getInstance].getLoginInfo!=nil && [LoginManager getInstance].getLoginInfo.status==-2){
        [SVProgressHUD showErrorWithStatus:WebCopy_BeKill_message];
        return YES;
    }
    return NO;
}

-(UserInfo *)getLoginUser{
    return [[LoginManager getInstance] getLoginInfo];
}



//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
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
