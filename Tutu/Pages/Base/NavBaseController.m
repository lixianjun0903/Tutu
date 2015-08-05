//
//  NavBaseController.m
//  Tutu
//
//  Created by zhangxinyao on 15-2-12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NavBaseController.h"

@interface NavBaseController ()

@end

@implementation NavBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarStyle];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
//**************************项目中的导航栏一部分是自定义的View,一部分是系统自带的NavigationBar*********************************
- (void)setNavigationBarStyle{
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                imageView.hidden=YES;
            }
        }
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -20,ScreenWidth, 64)];
        imageView.image=[UIImage imageNamed:@"nav_background"];
        imageView.tag=10001;
        [self.navigationController.navigationBar addSubview:imageView];
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
    
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
}
/**
 *  创建leftBarItem
 *
 *  @param select          按钮点击后调用的方法
 *  @param imageName       Normal下图片的名称
 *  @param heightImageName 点击下图片的名称
 */
- (void)createLeftBarItemSelect:(SEL)select imageName:(NSString *)imageName heightImageName:(NSString *)heightImageName{
    //12 * 19
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:select forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 12,20) ;
    if (imageName) {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }else{
        btn.frame = CGRectMake(0, 0, 12, 20);
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 8)];
        [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    }
    if (heightImageName) {
        [btn setImage:[UIImage imageNamed:heightImageName] forState:UIControlStateHighlighted];
    }else{
        [btn setImage:[UIImage imageNamed:@"bakc_light"] forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = item;
}
- (UIButton *)createRightBarItemSelect:(SEL)select imageName:(NSString *)imageName heightImageName:(NSString *)heightImageName{
    //12 * 1
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:select forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 68, 44);
    if (imageName) {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }else{
        btn.frame = CGRectMake(-8, 0, 68,44) ;
        [btn setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 13,56)];
        [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    }
    if (heightImageName) {
        [btn setImage:[UIImage imageNamed:heightImageName] forState:UIControlStateHighlighted];
    }else{
        [btn setImage:[UIImage imageNamed:@"bakc_light"] forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    return btn;
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
