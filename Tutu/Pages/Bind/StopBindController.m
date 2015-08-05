//
//  StopBindController.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "StopBindController.h"
#import "FriendSearchController.h"
#import "AddressListViewController.h"
#import "ContactsViewController.h"

@interface StopBindController ()

@end

@implementation StopBindController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    [self.labelTitle setText:[NSString stringWithFormat:@"%@：+86%@",TTLocalString(@"TT_bindding_phone_number"),_phoneNumber]];
    
    [self.labelDetail setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.labelDetail setFont:ListTimeFont];
    
}


-(IBAction)sendCode:(id)sender{
    //跳转到
    if(self.navigationController.childViewControllers.count>5){
        NSString *time=[SysTools getValueFromNSUserDefaultsByKey:SYSContactsTime_KEY];
        if(time==nil || [@"" isEqual:time]){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_BINDPHONE_SUCCESS object:nil];
            
            [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-6] animated:YES];
        }else{
            // 显示通讯录页面
            ContactsViewController * addressList = [[ContactsViewController alloc]init];
            [self.navigationController pushViewController:addressList animated:YES];

        }
    }
}


-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        if(self.navigationController.childViewControllers.count>5){
            NSString *time=[SysTools getValueFromNSUserDefaultsByKey:SYSContactsTime_KEY];
            if(time==nil || [@"" isEqual:time]){
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_BINDPHONE_SUCCESS object:nil];
            }
            [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-6] animated:YES];
        }
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
