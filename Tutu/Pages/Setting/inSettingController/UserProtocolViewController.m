//
//  UserProtocolViewController.m
//  fun_beta
//
//  Created by 刘大治 on 14-10-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "UserProtocolViewController.h"

@interface UserProtocolViewController ()
{
    float edgeWidth;
}
@end

@implementation UserProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftButtonSelect:@selector(goBack:) imageName:@"common_back@2x" heightImageName:@"common_backSelected@2x"];
    [self setTitle:@"用户协议"];
    edgeWidth =8 ;
    UIScreen * screen = [UIScreen mainScreen];
    // Do any additional setup after loading the view from its nib.'
    NSString * string = @"";

    NSLog(@"%@",string);
    CGRect labelRect = [SysTools rectWidth:string FontSize:17 size:CGSizeMake(screen.applicationFrame.size.width-edgeWidth*2, CGFLOAT_MAX)];
    NSLog(@"宽%f计算结果%@",screen.applicationFrame.size.width,NSStringFromCGRect(labelRect));

    UILabel * detailContextLabel = [[UILabel alloc]initWithFrame:CGRectMake(edgeWidth,edgeWidth,screen.applicationFrame.size.width-edgeWidth*2, labelRect.size.height)];
    detailContextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    detailContextLabel.font =[UIFont systemFontOfSize:17];
    detailContextLabel.numberOfLines= 0;
    detailContextLabel.text =string;
    
    _backScrollView.contentSize = CGSizeMake(screen.applicationFrame.size.width, detailContextLabel.frame.size.height+edgeWidth*2);
    [_backScrollView addSubview:detailContextLabel];
    
}

-(void)goBack:(id)sender
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
