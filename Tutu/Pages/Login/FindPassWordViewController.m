//
//  FindPassWordViewController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "FindPassWordViewController.h"
#import "SetPassWordViewController.h"
#import "ResetPassWordViewController.h"
#import "UIView+Border.h"
@interface FindPassWordViewController ()
{
    NSString * titlename;
    NSString * phoneNumber;
    NSTimer * reciprocal;
    int count;
}
@end

@implementation FindPassWordViewController
-(id)initWithPhoneNum:(NSString*)newPhoneNum title:(NSString*)titleString
{
    self = [super init];
    if (self) {
        
        phoneNumber = [[NSString alloc]init];
        phoneNumber = newPhoneNum;
        titlename = titleString;
    }
    return self;
}
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {

    [super viewDidLoad];
    [self createTitleMenu];
    //[self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    [self.menuTitleButton setTitle:titlename forState:UIControlStateNormal];
    [self.menuRightButton setHidden:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector    (textFieldDidStartChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.textBackView addTopBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    [self.textBackView addBottomBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    _phoneTextLabel .text = [NSString stringWithFormat:@"你的手机号+86 %@,你会收到一条带有验证码的短信",phoneNumber];
    [_resendCountButton setBackgroundColor:UIColorFromRGB(MenuTitleColor)];
    [_resendCountButton addLeftBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    
    
    [_resendCountButton setTitleColor:UIColorFromRGB(TextGreenColor) forState:UIControlStateNormal];
    [_resendCountButton setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateSelected];

    [self resetTimer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [_nextButton setUserInteractionEnabled:YES];
//    [reciprocal invalidate];
}

-(void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    count=0;
    [reciprocal invalidate];
    [_resendCountButton setEnabled:YES];
    [_resendCountButton setBackgroundColor:UIColorFromRGB(MenuTitleColor)];

}

-(void)textFieldDidStartChange
{
    if (_checkNum.text.length>0) {
        [_nextButton setEnabled:YES];
    }
    else
    {
        [_nextButton setEnabled:NO];
    }
}

- (IBAction)resendSelector:(id)sender {
    [self resetTimer];
    
    if (_type ==FindPasswordTypeRegist ) {
        //调用重新获取验证码
        [[RequestTools getInstance] get:API_REGIST_GET_REGVERIFY_CODE(phoneNumber) isCache:NO completion:^(NSDictionary *dict) {
            
            //TUDO:do something
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            //TUDO:do something

        }];
    }else if(_type==FindPasswordTypeFind){
        [[RequestTools getInstance] get:APP_CHECKNUM_LOGIN(phoneNumber) isCache:NO completion:^(NSDictionary *dict) {
           
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }else if(_type==BindPhoneNumber){
        [[RequestTools getInstance] get:API_RE_SendCode(phoneNumber) isCache:NO completion:^(NSDictionary *dict) {
            
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }
    
}

-(void)resetTimer{
    [_resendCountButton setEnabled:NO];
    [_resendCountButton setBackgroundColor:UIColorFromRGB(MenuTitleColor)];
    [_resendCountButton setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
    [_resendCountButton setTitleColor:UIColorFromRGB(TextGreenColor) forState:UIControlStateSelected];
    count = 60;
    reciprocal = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
}

-(void)timerDiscount
{
    [_resendCountButton setTitle:[NSString stringWithFormat:@"重新发送(%d)",count] forState:UIControlStateDisabled];
    count--;
    if (count == 0) {
        [reciprocal invalidate];
        [_resendCountButton setEnabled:YES];
        [_resendCountButton setBackgroundColor:UIColorFromRGB(MenuTitleColor)];
    }
}

-(BOOL)checkCode {

    if (_checkNum.text.length >= 4) {
        
        return YES;
    }else {
    
        return NO;
    }
}


- (IBAction)goResetPassWord:(id)sender {    
    
    [_nextButton setUserInteractionEnabled:NO];
    if (_type ==FindPasswordTypeRegist ) {
        
        if ([self checkCode]) {
            WSLog(@"%@",API_REGIST_CHECK_REGVERIFY_CODE(phoneNumber,_checkNum.text));
            [[RequestTools getInstance] get:API_REGIST_CHECK_REGVERIFY_CODE(phoneNumber,_checkNum.text) isCache:NO completion:^(NSDictionary *dict) {
                NSLog(@"%@",API_REGIST_CHECK_REGVERIFY_CODE(phoneNumber,_checkNum.text));
                if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                    SetPassWordViewController * setPass = [[SetPassWordViewController alloc]init];
                    [setPass setPhoneNum:phoneNumber vcode:_checkNum.text title:TTLocalString(@"TT_set_nickname")];
                    [self.navigationController pushViewController:setPass animated:YES];
                
                }else{
                    [self showNoticeWithMessage:TTLocalString(@"TT_verification_code_erro") message:nil bgColor:TopNotice_Red_Color];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                
            } finished:^(ASIHTTPRequest *request) {
//                WSLog(@"%@",API_REGIST_CHECK_REGVERIFY_CODE(phoneNumber,_checkNum.text));
                    [_nextButton setUserInteractionEnabled:YES];
            }];
        }else {
        
            //TUDO:样式需要调整
            [_checkNum shake];
            [_checkNum becomeFirstResponder];
        }

    }
    if (_type == FindPasswordTypeFind) {
        if ([self checkCode]) {
            WSLog(@"%@",APP_RESETPASSWORD_LOGIN(phoneNumber,_checkNum.text));
            [[RequestTools getInstance] get:APP_RESETPASSWORD_LOGIN(phoneNumber,_checkNum.text) isCache:NO completion:^(NSDictionary *dict) {
                WSLog(@"%@",dict);
                if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                    ResetPassWordViewController * setPass = [[ResetPassWordViewController alloc]init];
                    [setPass setPhoneNum:phoneNumber title:@"重置密码"];
                    [self.navigationController pushViewController:setPass animated:YES];
                    
                }else{
                    [self showNoticeWithMessage:@"验证码输入错误!" message:nil bgColor:TopNotice_Red_Color];
                    [_checkNum becomeFirstResponder];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                [_checkNum becomeFirstResponder];
            } finished:^(ASIHTTPRequest *request) {
                [_nextButton setUserInteractionEnabled:YES];
            }];
        }else {
            //TUDO:样式需要调整
            [_checkNum shake];
            [_checkNum becomeFirstResponder];
        }
    }
    
    if(_type==BindPhoneNumber){
        if ([self checkCode]) {
            WSLog(@"%@",API_Check_Code(phoneNumber,_checkNum.text));
            [[RequestTools getInstance] get:API_Check_Code(phoneNumber,_checkNum.text) isCache:NO completion:^(NSDictionary *dict) {
                ResetPassWordViewController * setPass = [[ResetPassWordViewController alloc]init];
                setPass.type=_type;
                [setPass setPhoneNum:phoneNumber title:@"设置密码"];
                [self.navigationController pushViewController:setPass animated:YES];
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
                [_checkNum becomeFirstResponder];
            } finished:^(ASIHTTPRequest *request) {
                [_nextButton setUserInteractionEnabled:YES];
            }];
        }else {
            //TUDO:样式需要调整
            [_checkNum shake];
            [_checkNum becomeFirstResponder];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
