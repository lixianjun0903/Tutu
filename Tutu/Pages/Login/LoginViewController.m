//
//  LoginViewController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "LoginViewController.h"
#import "PhoneLoginController.h"
#import "SendPhoneNumViewController.h"
#import "SendPhoneNumViewController.h"
#import "SetNickName.h"
#import "UIView+Border.h"
#import "MobClick.h"

#define RedirectURL @"http://www.sina.com"


#define LOGIN 1001
#define QQLOGIN 1002
#define REGIST 1003
#define VISITOR 1004
#define SINALOGIN 1005

//#define DEVICESCREENHEIGHT [[UIScreen mainScreen] applicationFrame].size.height

@interface LoginViewController (){
    TencentOAuth *_tencentOAuth;
    float buttonRadios;
    float height ;
    
    long count;
    
    BOOL isQQInstall;
    BOOL isSinaInstall;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    [self createTitleMenu];
    self.menuRightButton.hidden=YES;
    [self.menuLeftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.menuLeftButton setImage:nil forState:UIControlStateNormal];
    [self.menuLeftButton setFrame:CGRectMake(0, StatusBarHeight, 74, 44)];
    [self.menuLeftButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.menuLeftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    
    // 多语言支持
    [self.menuTitleButton setTitle:TTLocalString(@"TTlogin_title") forState:UIControlStateNormal];
    [self.menuLeftButton setTitle:TTLocalString(@"TTlogin_back") forState:UIControlStateNormal];
    [self.loginButton setTitle:TTLocalString(@"TTlogin_button_login") forState:UIControlStateNormal];
    [self.forgetButton setTitle:TTLocalString(@"TTlogin_forgot_password") forState:UIControlStateNormal];
    [self.phoneNum setPlaceholder:TTLocalString(@"TTlogin_placeholder_name")];
    [self.passWord setPlaceholder:TTLocalString(@"TTlogin_placeholder_password")];
    [self.orlabel setText:TTLocalString(@"TTlogin_other_acount")];
    [self.registButton setTitle:TTLocalString(@"TTlogin_button_register") forState:UIControlStateNormal];
    
    
    height = self.view.mj_height;
    
    //注册键盘监听
    [_phoneNum addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [_phoneNum setTextColor:UIColorFromRGB(TextBlackColor)];
    [_passWord setTextColor:UIColorFromRGB(TextBlackColor)];
    
    [_phoneNum setValue:UIColorFromRGB(TextCCCCCCColor) forKeyPath:@"_placeholderLabel.textColor"];
    [_passWord setValue:UIColorFromRGB(TextCCCCCCColor) forKeyPath:@"_placeholderLabel.textColor"];
    
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginButton.layer.cornerRadius=_loginButton.frame.size.height/2;
    _loginButton.layer.masksToBounds=YES;
    [_loginButton setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(LoginButtonBg)] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(LoginButtonBgHD)] forState:UIControlStateHighlighted];
    
    [_forgetButton setTitleColor:UIColorFromRGB(TextSixColor) forState:UIControlStateNormal];
    [_forgetButton setTitleColor:UIColorFromRGB(TextSixAColor) forState:UIControlStateHighlighted];
    
    [_inputBackGroundView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [_inputBackGroundView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    
    CGRect lineF=_itemLineView.frame;
    lineF.size.height=0.75f;
    [_itemLineView setFrame:lineF];
    [_itemLineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    
    
    //取消未安装QQ的判断
    if (![TencentOAuth iphoneQQInstalled] && ![TencentOAuth iphoneQQSupportSSOLogin]) {
        //       不显示QQ登陆
        [_qqLoginButton setImage:[UIImage imageNamed:@"login_qq_sel"] forState:UIControlStateNormal];
        isQQInstall=NO;
    }else{
        isQQInstall=YES;
    }
    
    if(![SysTools APCheckIfAppInstalled2:@"sinaweibo://"]){
        [_sinaLoginButton setImage:[UIImage imageNamed:@"login_sina_sel"] forState:UIControlStateNormal];
        isSinaInstall=NO;
    }else{
        isSinaInstall=YES;
    }
    
    if([SysTools getApp].checkUserAge){
        if(!isQQInstall && !isSinaInstall){
            [self.lineOrView setHidden:YES];
            [self.qqLoginButton setHidden:YES];
            [self.sinaLoginButton setHidden:YES];
        }
    }
    
    [_orLineImage setBackgroundColor:UIColorFromRGB(TextBlackColor)];
    [_orlabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [_orlabel setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    [_registButton.titleLabel setFont:ListTitleFont];
    [_registButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [_registButton setTitleColor:UIColorFromRGB(SystemColorHigh) forState:UIControlStateHighlighted];
    _registButton.layer.borderWidth=1.0f;
    _registButton.layer.borderColor=UIColorFromRGB(SystemColor).CGColor;
    _registButton.layer.cornerRadius=15;
    _registButton.layer.masksToBounds=YES;
    
    _backgroundScrollView.bounces = NO;
    
    
    if (ScreenHeight<548) {
//        屏幕<= iPhone4s
        CGRect qqFrame = _qqLoginButton.frame;
        qqFrame.origin.y=qqFrame.origin.y-10;
        [_qqLoginButton setFrame:qqFrame];
        
        
        CGRect sinaFrame = _sinaLoginButton.frame;
        sinaFrame.origin.y=sinaFrame.origin.y-10;
        [_sinaLoginButton setFrame:sinaFrame];
        
        CGRect frame = _lineOrView.frame;
        frame.origin.y=_forgetButton.frame.origin.y+32;
        [_lineOrView setFrame:frame];
        
        CGRect topFrame=_registButton.frame;
        topFrame.origin.y=topFrame.origin.y+10;
        _registButton.frame=topFrame;
    }
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downKeyBoard:)];
    [self.view addGestureRecognizer:tap];
    
}


-(void)keyboardShow:(NSNotification*)notification
{
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    WSLog(@"%d",iOS7?0:20);
    float stateHeigth = iOS7?0:20;
    keyboardHeight -=height - _loginButton.frame.origin.y- _loginButton.frame.size.height - stateHeigth;
    if (keyboardHeight<0) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundScrollView.contentOffset=CGPointMake(0, keyboardHeight);
        
    }];
    
}

-(void)keyboardHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundScrollView.contentOffset=CGPointMake(0,-StatusBarHeight);
        
    }];

}


-(void)downKeyBoard:(id)sender
{
    [_passWord resignFirstResponder];
    [_phoneNum resignFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];

    [self.navigationController.navigationBar setHidden:YES];
    [_loginButton setUserInteractionEnabled:YES];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    
    
}

- (void)textFieldChanged:(UITextField *)textField{
    if (count > textField.text.length) {
        //删除
        if (count == 5 || count == 10) {
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",textField.text];
            textField.text = [str substringToIndex:count -2];
        }
    }
    else if (count < textField.text.length){
        //增加
        if (count == 3 || count == 8) {
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",textField.text];
            [str insertString:@" " atIndex:count];
            textField.text = str;
        }
    }
    
    //通过count的值和当前的textField内容的长度比较，如果count大那么证明是删除，反之增加
    count = textField.text.length;
}


- (IBAction)forgetPassWord:(id)sender {
    SendPhoneNumViewController * forgetPassword = [[SendPhoneNumViewController alloc] init];
    [forgetPassword setTitleWithString:@"忘记密码"];
    forgetPassword.type = FindPasswordTypeFind;
    [self.navigationController pushViewController:forgetPassword animated:YES];
}

-(IBAction)doLogin:(UIButton *)btn{
    if(btn.tag==LOGIN){
        NSString *phoneString=[_phoneNum.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(phoneString==nil || [@"" isEqual:phoneString]){
            [_phoneNum shake];
            [_phoneNum becomeFirstResponder];
            return;
        }
        
        if(!validateMobile(phoneString)){
            [_phoneNum shake];
            [_phoneNum becomeFirstResponder];
            return;
        }
        
        if(!validatePassword(_passWord.text)){
            [_passWord shake];
            [_passWord becomeFirstResponder];
            return;
        }
        
        [_loginButton setUserInteractionEnabled:NO];
        
        //开启心跳动画
//        [self startheartbeatView:self.iconImage duration:100.0f maxSize:1.2f durationPerBeat:1.5f];
        [_loginButton setTitle:@"登录中..." forState:UIControlStateNormal];
        [[RequestTools getInstance] get:API_ADD_LOGIN(phoneString, _passWord.text) isCache:NO completion:^(NSDictionary *dict) {
//            NSLog(@"登陆====%@",dict);
            @try {
                if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                    [[LoginManager getInstance] doLoginWidthDict:[dict objectForKey:@"data"]];
                    if([[LoginManager getInstance] isLogin]){
                        //进入首页
                        [self loginSuccess];
                    }else{
                        [self showNoticeWithMessage:@"登录失败~" message:nil bgColor:TopNotice_Red_Color];
                    }
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            WSLog(@"失败信息%@",request.responseString);
        } finished:^(ASIHTTPRequest *request) {
            
            NSLog(@"返回数据%@",[request.responseString objectFromJSONString]);
            [_loginButton setUserInteractionEnabled:YES];
            [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
            
            [self removeAnimation:self.iconImage];
        }];

    }else if(btn.tag==QQLOGIN){
//        if(!isQQInstall){
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No QQ" message:@"QQ haven't been install in your device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            return;
//        }
        _qqLoginButton.userInteractionEnabled=NO;
        _permissions = [NSMutableArray arrayWithObjects:
                         kOPEN_PERMISSION_GET_USER_INFO,
                         kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                         kOPEN_PERMISSION_ADD_ALBUM,
                         kOPEN_PERMISSION_ADD_IDOL,
                         kOPEN_PERMISSION_ADD_ONE_BLOG,
                         kOPEN_PERMISSION_ADD_PIC_T,
                         kOPEN_PERMISSION_ADD_SHARE,
                         kOPEN_PERMISSION_ADD_TOPIC,
                         kOPEN_PERMISSION_CHECK_PAGE_FANS,
                         kOPEN_PERMISSION_DEL_IDOL,
                         kOPEN_PERMISSION_DEL_T,
                         kOPEN_PERMISSION_GET_FANSLIST,
                         kOPEN_PERMISSION_GET_IDOLLIST,
                         kOPEN_PERMISSION_GET_INFO,
                         kOPEN_PERMISSION_GET_OTHER_INFO,
                         kOPEN_PERMISSION_GET_REPOST_LIST,
                         kOPEN_PERMISSION_LIST_ALBUM,
                         kOPEN_PERMISSION_UPLOAD_PIC,
                         kOPEN_PERMISSION_GET_VIP_INFO,
                         kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                         kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                         kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                         nil];
        //如果不为nil，就重新注册
        if(_tencentOAuth!=nil){
//            重新注册
            [_tencentOAuth reauthorizeWithPermissions:_permissions];
            return;
        }
        
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:TencentOpenAPI andDelegate:self ];
        
        
        //        _tencentOAuth.redirectURI = @"www.qq.com";
        // 必须设置
        if (![TencentOAuth iphoneQQInstalled] && ![TencentOAuth iphoneQQSupportSSOLogin]) {
            [_tencentOAuth logout:self];
        }
        [_tencentOAuth authorize:_permissions inSafari:YES];
    }else if(btn.tag == SINALOGIN){
        //新浪微博登录
//        if(!isSinaInstall){
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Sina" message:@"Sina haven't been install in your device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            return;
//        }
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
        
        [[UMSocialDataService defaultDataService] requestAddFollow:UMShareToSina followedUsid:@[@"5373107821"] completion:^(UMSocialResponseEntity *response) {
//            WSLog(@"res--%d--%@",response.responseCode,response.description);
        }];

        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            //          获取微博用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
                
                NSString *api=API_LOGIN_SinaBack(snsAccount.usid, snsAccount.accessToken, (int)[snsAccount.expirationDate timeIntervalSince1970]);
                [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
                    [[LoginManager getInstance] doLoginWidthDict:[dict objectForKey:@"data"]];
                    
                    if([[LoginManager getInstance] isLogin]){
                        //进入首页
                        [self loginSuccess];
                    }
                } failure:^(ASIHTTPRequest *request, NSString *message) {
                    NSDictionary * faldDict = [request.responseString objectFromJSONString];
                    NSString *code=[faldDict objectForKey:@"code"];
                    if(code!=nil && [code intValue]==105106){
                        
                        SetNickName * setNick = [[SetNickName alloc] initWithTitle:@"完善资料" accessToken:snsAccount.accessToken wbuid:snsAccount.usid date:snsAccount.expirationDate];
                        setNick.nickname=snsAccount.userName;
                        [self.navigationController pushViewController:setNick animated:YES];
                    }else{
                        [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                    }
                } finished:^(ASIHTTPRequest *request) {
                    
                }];
                WSLog(@"%@",snsAccount.description);
            }});
    }
    else if(btn.tag == REGIST){
        SendPhoneNumViewController * sendPhoneNum= [[SendPhoneNumViewController alloc]init];
        [sendPhoneNum setTitleWithString:@"手机号验证"];
        sendPhoneNum.type = FindPasswordTypeRegist;
        [self.navigationController pushViewController:sendPhoneNum animated:YES];
    }
    else{
//        随便逛逛
        [self loginSuccess];
    }
}




-(void)loginSuccess{
    if([[SysTools getApp] getCurrentRootViewController]!=nil){
        UIViewController *controller=[[SysTools getApp] getCurrentRootViewController].childViewControllers[0];
        if(![controller isKindOfClass:[LoginViewController class]] && !_isRootPage)
        {
            [self goBack:nil];
            return;
        }
    }
    //进入首页
    UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController.navigationBar setHidden:NO];
    }];
}



#pragma QQ回调函数
/**
 * 登录成功后的回调
 */
-(void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        // 记录登录用户的OpenID、Token以及过期时间
        
        if ([_tencentOAuth.openId length] > 0) {
            WSLog(@"%@QQURL %@",_tencentOAuth.accessToken, _tencentOAuth.openId);
            [[RequestTools getInstance] get:API_QQLOGIN(_tencentOAuth.accessToken, _tencentOAuth.openId) isCache:NO completion:^(NSDictionary *dict) {
                [[LoginManager getInstance] doLoginWidthDict:[dict objectForKey:@"data"]];
                if([[LoginManager getInstance] isLogin]){
                    //进入首页
                    [self loginSuccess];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                NSDictionary * faldDict = [request.responseString objectFromJSONString];
                NSString *code=[faldDict objectForKey:@"code"];
                if(code!=nil && [code intValue]==100817){
                    //获取腾讯用户信息
                    [_tencentOAuth getUserInfo];
                    
                }else{
                    [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                }
 
                
            } finished:^(ASIHTTPRequest *request) {
                [self removeAnimation:self.iconImage];
            }];
        }
    }
    else
    {
        [self removeAnimation:self.iconImage];
        WSLog(@"登录不成功 没有获取accesstoken");
    }
}



/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    [self removeAnimation:self.iconImage];
    WSLog(@"没有登录");
}

/**
 * 登录时网络有问题的回调
 */
-(void)tencentDidNotNetWork
{
    [self removeAnimation:self.iconImage];
//    WSLog(@"登录失败");
}


-(void)tencentDidUpdate:(TencentOAuth *)tencentOAuth{
    WSLog(@"")
}

-(void)getUserInfoResponse:(APIResponse *)response{
    
//    WSLog(@"%@",response);
    if(response && response.jsonResponse){
        SetNickName * setNick = [[SetNickName alloc]initWithTitle:TTLocalString(@"TT_perfect_information") accessToken:_tencentOAuth.accessToken openID:_tencentOAuth.openId];
        setNick.nickname=[response.jsonResponse objectForKey:@"nickname"];
        [self.navigationController pushViewController:setNick animated:YES];
        
    }
}


#pragma mark 页面点击
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self loginSuccess];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 * 开始心跳动画
 **/
- (void)startheartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat
{
    if (view && (fDurationPerBeat > 0.1f))
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.8, 0.8, 1);
        CATransform3D scale2 = CATransform3DMakeScale(fMaxSize, fMaxSize, 1);
        CATransform3D scale3 = CATransform3DMakeScale(fMaxSize - 0.3f, fMaxSize - 0.3f, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];
        
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
//                               [NSNumber numberWithFloat:0.05],
//                               [NSNumber numberWithFloat:0.2],
//                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        animation.duration = fDurationPerBeat;
        animation.repeatCount = fDuration/fDurationPerBeat;
        
        [view.layer addAnimation:animation forKey:@"heartbeatView"];
    }
}


/**
 * 移除心跳动画
 **/
-(void)removeAnimation:(UIView *)view{
    [_qqLoginButton setImage:[UIImage imageNamed:@"login_qq_nor"] forState:UIControlStateNormal];
    
    _qqLoginButton.userInteractionEnabled=YES;
//    [view.layer removeAnimationForKey:@"heartbeatView"];
}


@end
