//
//  UzysWrapperPickerController.m
//  IdolChat
//
//  Created by Uzysjung on 2014. 1. 28..
//  Copyright (c) 2014년 SKPlanet. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import "UzysWrapperPickerController.h"

@interface UzysWrapperPickerController ()

@end

@implementation UzysWrapperPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  View Controller Setting /Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}
- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)dealloc
{
//    NSLog(@"UzysWrapperPicerController dealloc");
}
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

@end
