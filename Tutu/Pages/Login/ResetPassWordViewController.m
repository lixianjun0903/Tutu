//
//  ResetPassWordViewController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ResetPassWordViewController.h"
#import "CompleteInfoController.h"
#import "UIView+Border.h"
#import "StopBindController.h"

@interface ResetPassWordViewController ()
{
    NSString * phone;
    NSString * mytitle;
}
@end

@implementation ResetPassWordViewController

-(id)init
{
    self = [super init];
    if (self) {
        phone = [[NSString alloc]init];

    }
    return self;
}
- (IBAction)buttonClick:(id)sender{
    if (((UIButton *)sender).tag == BACK_BUTTON) {
        [self goBack:sender];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
  //  [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];

    [self.menuRightButton setHidden:YES];

    [self.menuTitleButton setTitle:mytitle forState:UIControlStateNormal];
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];

    // Do any additional setup after loading the view from its nib.

    [_mybackView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [_mybackView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [_lineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downKeyBoard)];
    [self.view addGestureRecognizer:tap];

}

-(void)downKeyBoard
{
    [_secondPassword resignFirstResponder];
    [_firstPassword resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _backScroll.contentOffset = CGPointMake(0, -StatusBarHeight);
    }];
    
}

-(void)keyBoardShow:(NSNotification*)notification
{
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    float stateHeigth = iOS7?0:20;
    keyboardHeight -= self.view.frame.size.height - _finishButton.frame.origin.y -_finishButton.frame.size.height - stateHeigth;
    if (keyboardHeight<0) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _backScroll.contentOffset = CGPointMake(0, keyboardHeight);
    }];
    
}

-(void)keyBoardHide
{
    [UIView animateWithDuration:0.3 animations:^{
        _backScroll.contentOffset = CGPointMake(0, -StatusBarHeight);
    }];
}


-(void)setPhoneNum:(NSString*)phonenum title:(NSString*)newtitle
{
    phone = phonenum;
    mytitle = newtitle;
}

- (IBAction)resetPassWord:(id)sender {
    NSString *fText=_firstPassword.text;
    NSString *sText=_secondPassword.text;
    
    if(fText==nil || [@"" isEqual:fText]){
        [_firstPassword shake];
        [_firstPassword becomeFirstResponder];
        return;
    }
    if(!validatePassword(fText)){
        [_firstPassword shake];
        [_firstPassword becomeFirstResponder];
        return;
    }
    if(sText==nil || [@"" isEqual:sText]){
        [_secondPassword shake];
        [_secondPassword becomeFirstResponder];
        return;
    }
    if(!validatePassword(sText)){
        [_secondPassword shake];
        [_secondPassword becomeFirstResponder];
        return;
    }
    
    if(![sText isEqual:fText]){
        [self showNoticeWithMessage:@"两次密码不一样!" message:nil bgColor:TopNotice_Red_Color];
        [_secondPassword becomeFirstResponder];
        return;
    }
    
    if(_type==BindPhoneNumber){
        [[RequestTools getInstance] get:API_BIND_PHONE(phone,fText) isCache:NO completion:^(NSDictionary *dict) {
            StopBindController *stop=[[StopBindController alloc] init];
            stop.phoneNumber=phone;
            [self.navigationController pushViewController:stop animated:YES];
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            [_secondPassword becomeFirstResponder];
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }else{
        [[RequestTools getInstance] get:APP_RESTPASSWORD_RESET(phone,fText) isCache:NO completion:^(NSDictionary *dict) {
            [[LoginManager getInstance] doLoginWidthDict:[dict objectForKey:@"data"]];

            WSLog(@"%@",dict);
//            [self showNoticeWithMessage:@"重置密码成功!" message:nil bgColor:TopNotice_Block_Color block:^{
                //进入首页
                UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.navigationController.navigationBar setHidden:NO];
                }];
//            }];
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            [_secondPassword becomeFirstResponder];
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }
}

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
