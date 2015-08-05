//
//  StartBindController.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "StartBindController.h"
#import "SendPhoneNumViewController.h"

@interface StartBindController ()

@end

@implementation StartBindController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_phone_number_bindding") forState:UIControlStateNormal];
 //   [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    self.menuRightButton.hidden=YES;
    
    
    self.btnBind.layer.cornerRadius=5;
    self.btnBind.layer.masksToBounds=YES;
    [self.btnBind setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.btnBind setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnBind addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.labelTitle setTextColor:UIColorFromRGB(TextBlackColor)];
    [self.labelTitle setFont:ListTitleFont];
    
    [self.labelDetail setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.labelDetail setFont:ListTimeFont];
    
}


-(IBAction)sendCode:(id)sender{
    SendPhoneNumViewController *send=[[SendPhoneNumViewController alloc] init];
    send.type=BindPhoneNumber;
    send.title=TTLocalString(@"TT_phone_number_validation");
    [self.navigationController pushViewController:send animated:YES];
}

-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:sender];
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
