//
//  SignChangeViewController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SignChangeViewController.h"
#import "UIView+Border.h"
#import "UserInfoDB.h"
@interface SignChangeViewController (){
    int maxSize;
}

@end

@implementation SignChangeViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [self createTitleMenu];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];

    
    
    [self.menuTitleButton setTitle:@"编辑签名" forState:UIControlStateNormal];
    
    
    [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickDefautl.png"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickHelight.png"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(12,8,12,16)];

    NSString *sign=[[[LoginManager getInstance]getLoginInfo] sign];
    self.signTextfield.text = sign;
    _signTextfield.delegate = self;
    
    [self.signTextfield setTextColor:UIColorFromRGB(TextGrayColor)];
    [_textBackView addTopBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    [_textBackView addBottomBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [_signTextfield becomeFirstResponder];
}
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    else if(sender.tag == RIGHT_BUTTON)
    {
        [self commitChange:sender];
    }
    
}


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)commitChange:(id)sender {
    NSString *text=_signTextfield.text;
//    int size=getStringCharCount(text);
//    if(size>60){
//        [self showNoticeWithMessage:@"签名最多只能输入30个汉字哦!" message:@""  bgColor:TopNotice_Red_Color];
//        return;
//    }
    WSLog(@"%@",API_ADD_SETUSERINFO(@"sign",text));
//    提交成功
    [[RequestTools getInstance] get:API_ADD_SETUSERINFO(@"sign",text) isCache:NO completion:^(NSDictionary *dict) {
        WSLog(@"%@",dict);
        UserInfo * model = [[LoginManager getInstance]getLoginInfo];
        model.sign = _signTextfield.text;
        [[LoginManager getInstance] saveInfoToDB:model];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEUSERINFO object:nil];
        [self.navigationController popViewControllerAnimated:YES];

    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:@"" bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}

#pragma mark UITextViewDelegate


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
