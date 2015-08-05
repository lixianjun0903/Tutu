//
//  WebViewController.m
//  fun_beta
//
//  Created by 刘大治 on 14-10-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
{
    float navHeight;
    NSString* titleName;
    NSString * loadUrl ;
    float width;
    float height;
}
@end

@implementation WebViewController

-(void)settitleName:(NSString*)newName andURL:(NSString*)url
{
    if (titleName!=newName) {
        titleName = newName;
    }
    if (loadUrl !=url ) {
        loadUrl = url;
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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    UIScreen * screen =[UIScreen mainScreen];
    width = screen.applicationFrame.size.width;
    height = screen.applicationFrame.size.height;

    [super viewDidLoad];
    
    if ([SysTools getSystemVerson]>=7) {
        navHeight =64;
    }
    else
    {
        navHeight =44;
    }
    
    NSLog(@"%d",[SysTools getSystemVerson]);
    [self createTitleMenu];
    [self.menuLeftButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuTitleButton setTitle:titleName forState:UIControlStateNormal];
    [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    [self.menuRightButton setHidden:YES];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,navHeight, width, height-navHeight+20)];
    _webView.scrollView.bounces = NO;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:loadUrl]]];
    [self.view addSubview:_webView];

    
}

-(IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
