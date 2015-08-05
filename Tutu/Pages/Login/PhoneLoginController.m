//
//  PhoneLoginController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "PhoneLoginController.h"

@interface PhoneLoginController ()

@end

@implementation PhoneLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//登陆
- (IBAction)doLogin:(id)sender {
    [[RequestTools getInstance] get:API_ADD_LOGIN(_number.text, _passWord.text) isCache:NO completion:^(NSDictionary *dict) {
        @try {
            [[LoginManager getInstance] doLoginWidthDict:[dict objectForKey:@"data"]];
            if([LoginManager getInstance].isLogin){
                //进入首页
                UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.navigationController.navigationBar setHidden:NO];
                }];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
//注册
- (IBAction)goToRegist:(id)sender {
    
}

//返回
- (IBAction)goBack:(id)sender {
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
