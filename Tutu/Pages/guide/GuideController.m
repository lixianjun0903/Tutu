//
//  GuideController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "GuideController.h"
#import "LoginViewController.h"
#define DEVICESCREENHEIGHT [[UIScreen mainScreen] applicationFrame].size.height

@interface GuideController ()

@end

@implementation GuideController


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self imgToTips];
}




- (void)imgToTips
{
    int h = self.view.mj_height;
    int w = self.view.mj_width;
    CGRect scrollView = CGRectMake(0, 0, w,h);
    CGRect pageFrame = scrollView;
    UIImageView* page01 = [[UIImageView alloc] initWithFrame:pageFrame];
    UIImageView* page02 = [[UIImageView alloc] initWithFrame:pageFrame];
    UIImageView* page03 = [[UIImageView alloc] initWithFrame:pageFrame];
    UIImageView* page04 = [[UIImageView alloc] initWithFrame:pageFrame];
    
    page04.userInteractionEnabled = YES;
    int bw=w*2/3;
    int bh=70;
    UIButton *tyBtn=[[UIButton alloc] initWithFrame:CGRectMake(w/2-bw/2, h-80, bw, bh)];
    [tyBtn setTitle:@" " forState:UIControlStateNormal];
    [tyBtn addTarget:self action:@selector(closeGuidePagesView:) forControlEvents:UIControlEventTouchUpInside];
    [tyBtn setBackgroundColor:[UIColor clearColor]];
    [page04 addSubview:tyBtn];
    
    if (DEVICESCREENHEIGHT>=548) {
        [page01 setImage:[UIImage imageNamed:@"guide1"]];
        [page02 setImage:[UIImage imageNamed:@"guide2"]];
        [page03 setImage:[UIImage imageNamed:@"guide3"]];
        [page04 setImage:[UIImage imageNamed:@"guide4"]];
    }
    else
    {
        [page01 setImage:[UIImage imageNamed:@"guide_1"]];
        [page02 setImage:[UIImage imageNamed:@"guide_2"]];
        [page03 setImage:[UIImage imageNamed:@"guide_3"]];
        [page04 setImage:[UIImage imageNamed:@"guide_4"]];
    }
    NSMutableArray* pageArray = [[NSMutableArray alloc]
                                  initWithObjects: page01, page02, page03,page04,nil];
    PageScrollView* pageScrollView = [[PageScrollView alloc] initWithFrame:pageFrame];
    pageScrollView.pages = pageArray;
    //    [pageArray release];
    self.view = pageScrollView;
}


- (void) closeGuidePagesView:(id) sender {
//    UserInfo *userinfo=[UserInfo new];
//    userinfo.avatar=@"avatar1.jpg";
//    userinfo.nickname=@"游客";
//    userinfo.funnum=@"6";
//    userinfo.attentionnum=@"5";
//    userinfo.area=@"火星 东8°";
//    userinfo.sex=@"男";
//    userinfo.token=@"youke";
//    [SysTools checkUserInfo:userinfo];

    if([[LoginManager getInstance]isLogin]){
        //进入首页
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
    }else{
        /**/
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view .window.rootViewController=[stryBoard instantiateInitialViewController];
        
        
//        LoginViewController * login = [[LoginViewController alloc] init];
//        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:login];
//        nav.navigationBarHidden=YES;
//        [self.view.window setRootViewController:nav];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    NSNumber * flag = [NSNumber numberWithInt:1];
    [SysTools syncNSUserDeafaultsByKey:DP_GUIDE_FLAG withValue:flag];
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
