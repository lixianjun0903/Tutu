//
//  AboutViewController.m
//  fun_beta
//
//  Created by 刘大治 on 14-10-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
{
    float width;
    float height;
    float navheight;
    
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    navheight= self.navigationController.navigationBar.frame.size.height;
    UIScreen * screen  = [UIScreen mainScreen];
//    width = screen.applicationFrame.size.width;
//    height = screen.applicationFrame.size.height;
    NSLog(@"%@",NSStringFromCGRect(screen.applicationFrame));
    
    [self createLeftButtonSelect:@selector(goBack:) imageName:@"common_back@2x" heightImageName:@"common_backSelected@2x"];
    self.title = @"关于我们";
    
    UITapGestureRecognizer * tapPoint = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pointMe:)];
    [_pointView addGestureRecognizer:tapPoint];
    
    UITapGestureRecognizer * tapWebo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(officalWebo:)];
    [_officalWebo addGestureRecognizer:tapWebo];
    
}

//给我打分
-(void)pointMe:(id)sender
{
  //  NSLog(@"给我打分");
}

//官方微博
-(void)officalWebo:(id)sender
{
    NSLog(@"官方微博");
}
-(void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    width = self.view.frame.size.width;
    height = self.view.frame.size.height;
    self.backScroll.frame = CGRectMake(0, navheight,width, height - navheight);
    
    NSLog(@"距离底部的边距%f\n",height- navheight-60);
    _companyLabel.frame = CGRectMake(0, height- navheight-130, width, 24);
    _voteLabel.frame = CGRectMake(0, height - navheight-100, width, 24);
    
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
