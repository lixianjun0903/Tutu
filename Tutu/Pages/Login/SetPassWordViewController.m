//
//  SetPassWordViewController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SetPassWordViewController.h"
#import "CompleteInfoController.h"
#import "UIView+Border.h"

@interface SetPassWordViewController ()
{
    NSString * phone;
    NSString * mycode;
    NSString * mytitle;
}
@end

@implementation SetPassWordViewController



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide) name:UIKeyboardDidHideNotification object:nil];

}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

}
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
    [self.menuRightButton setHidden:YES];
    [self.menuTitleButton setTitle:@"设置密码" forState:UIControlStateNormal];
    [_lineImage setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [_secondLine setBackgroundColor:UIColorFromRGB(ListLineColor)];

    [_textView addTopBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.75];
    [_textView addBottomBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    // Do any additional setup after loading the view from its nib.
    [_lineImage setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [_secondLine setBackgroundColor:UIColorFromRGB(ListLineColor)];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_nickName becomeFirstResponder];
    });
    
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    
}


-(void)downKeyBoard
{
    [_nickName resignFirstResponder];
    [_passwordSet resignFirstResponder];
    [_confirmPassword resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _backScroll.contentOffset = CGPointMake(0, -StatusBarHeight);
    }];

}

-(void)keyBoardShow:(NSNotification*)notification
{
    
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    float stateHeigth = iOS7?0:20;
    CGFloat temp=keyboardHeight;

    
    
    keyboardHeight -= self.view.frame.size.height - _finishButton.frame.origin.y -_finishButton.frame.size.height - stateHeigth;
    if (keyboardHeight<0) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        if (temp==252) {
            _backScroll.contentOffset = CGPointMake(0, keyboardHeight-36);
        }
        else
        {
        _backScroll.contentOffset = CGPointMake(0, keyboardHeight);
        }
    }];
    
}

-(void)keyBoardHide
{
    [UIView animateWithDuration:0.3 animations:^{
        _backScroll.contentOffset = CGPointMake(0, -StatusBarHeight);
    }];
}




-(void)setPhoneNum:(NSString*)phonenum vcode:(NSString*)vcode title:(NSString*)newtitle
{
    phone = phonenum;
    mycode = vcode;
    mytitle = newtitle;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)goToCompleteUserInforMation
{
    if(_nickName.text==nil || [@"" isEqual:_nickName.text]){
        [self showNoticeWithMessage:@"起个昵称吧!" message:nil bgColor:TopNotice_Red_Color];
        [_nickName becomeFirstResponder];
        return ;
    }
    if(!validateNickName(_nickName.text)){
        [self showNoticeWithMessage:@"昵称最少2个汉字或4个字符,最多12个汉字哦!" message:nil bgColor:TopNotice_Red_Color];
        [_nickName becomeFirstResponder];
        return;
    }
    if(!validatePassword(_passwordSet.text)){
        [_passwordSet shake];
        [_passwordSet becomeFirstResponder];
        return;
    }
    if(!validatePassword(_confirmPassword.text)){
        [_confirmPassword shake];
        [_confirmPassword becomeFirstResponder];
        return;
    }

    if(![_passwordSet.text isEqual:_confirmPassword.text]){
        [self showNoticeWithMessage:@"两次密码不一样!" message:nil bgColor:TopNotice_Red_Color];
        [_confirmPassword becomeFirstResponder];
        return;
    }

    
    [[RequestTools getInstance] get:API_REGIST_SETINFO(phone,_passwordSet.text,_nickName.text) isCache:NO completion:^(NSDictionary *dict) {
        WSLog(@"%@",dict);
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            UserInfo *info=[[LoginManager getInstance] parseDictData:[dict objectForKey:@"data"]];
            [[LoginManager getInstance] saveInfoToDB:info];
            
            //进入首页
            UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.navigationController.navigationBar setHidden:NO];
            }];
        }else{
            [self showNoticeWithMessage:TTLocalString(@"TT_set_nickname_password_error") message:nil bgColor:TopNotice_Red_Color];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
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
