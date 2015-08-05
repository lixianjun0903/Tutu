//
//  ChangePassWordViewController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-27.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ChangePassWordViewController.h"
#import "UIView+Border.h"
#import "YHShakeUITextField.h"
@interface ChangePassWordViewController ()

@end

@implementation ChangePassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [_myTitle setBackgroundColor:UIColorFromRGB(TextBlackColor)];
    _orgLabel.font = ListTitleFont;
    _setNewPassword.font = ListTitleFont;
    _sureNewLabel.font =ListTitleFont;
    
    _orgLabel.textColor = UIColorFromRGB(TextBlackColor);
    _setNewPassword.textColor = UIColorFromRGB(TextBlackColor);
    _sureNewLabel.textColor = UIColorFromRGB(TextBlackColor);
    
    _orignalPassword.font = ListDetailFont;
    _firstNewPassWord.font = ListDetailFont;
    _firstCheckPassWord.font = ListDetailFont;
    
    _orignalPassword.textColor = UIColorFromRGB(TextGrayColor);
    _firstNewPassWord.textColor = UIColorFromRGB(TextGrayColor);
    _firstCheckPassWord.textColor = UIColorFromRGB(TextGrayColor);
    
    [self createTitleMenu];

//    [_myTitle setFont:TitleFont];
//    [_myTitle setTextColor:UIColorFromRGB(TextBlackColor)];
    [self.menuTitleButton setTitle:@"修改密码" forState:UIControlStateNormal];
    [self.menuRightButton setHidden:YES];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    
    
    [_myBackView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [_myBackView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];

    
    [_lineView1 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [_lineView2 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    
//    UIGestureRecognizer * gesture = [[UIGestureRecognizer alloc]initWithTarget:self action:@selector(resignResponder)];
//    [self.view addGestureRecognizer:gesture];
    
    // Do any additional setup after loading the view from its nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];

    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gesture];
    
}

-(void)keyboardShow:(NSNotification*)notification
{
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    keyboardHeight -= self.view.frame.size.height- _sureButton.frame.origin.y-_sureButton.frame.size.height-StatusBarHeight;
    if (keyboardHeight<0) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _backScrollView.contentOffset =CGPointMake(0, keyboardHeight);
    }];
}

-(void)keyboardHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        _backScrollView.contentOffset=CGPointMake(0,-StatusBarHeight);
        
    }];
}


-(void)hideKeyboard
{
    [_orignalPassword resignFirstResponder];
    [_firstNewPassWord resignFirstResponder];
    [_firstCheckPassWord resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _backScrollView.contentOffset=CGPointMake(0,-StatusBarHeight);
        
    }];
}



//- (void)resignResponder
//{
//    [_orignalPassword resignFirstResponder];
//    [_firstCheckPassWord resignFirstResponder];
//    [_firstNewPassWord resignFirstResponder];
//}

-(IBAction)buttonClick:(UIButton*)sender
{    
    if (sender.tag == BACK_BUTTON) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(sender.tag == RIGHT_BUTTON)
    {
        [self sureButton:sender];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)sureButton:(id)sender {
    if ([_firstCheckPassWord.text isEqualToString: _firstNewPassWord.text]) {
        [[RequestTools getInstance] get:API_CHANGEPASSWORD_LOGIN( _orignalPassword.text,_firstNewPassWord.text) isCache:NO completion:^(NSDictionary *dict) {
            
            
            if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"code"]] isEqualToString:@"10000"]) {
                [self showNoticeWithMessage:@"密码修改成功!" message:nil bgColor:TopNotice_Block_Color block:^{
                    [self goBack:nil];
                }];
            }
            else
            {
                NSString *desc = [NSString stringWithFormat:@"%@",[dict objectForKey:@"desc"]];
                [self showNoticeWithMessage:desc message:nil bgColor:TopNotice_Red_Color];
            }
            WSLog(@"%@",dict);
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            WSLog(@"%@",message);
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
        } finished:^(ASIHTTPRequest *request) {
            WSLog(@"%@",[request responseString]);
        }];
        
    }
    else
    {

        [self showNoticeWithMessage:@"新密码设置不一至" message:nil bgColor:TopNotice_Red_Color];
        [_firstCheckPassWord shake];
    }
    
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
