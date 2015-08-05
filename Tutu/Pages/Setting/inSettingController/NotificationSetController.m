//
//  NotificationSetController.m
//  Tutu
//
//  Created by 刘大治 on 14/11/24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "NotificationSetController.h"
#define SOUNDTAG 100
#define SHAKETAG 200
@interface NotificationSetController ()

@end

@implementation NotificationSetController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
  //  [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_new_alerts") forState:UIControlStateNormal];
    [self.menuRightButton setHidden:YES];
    _shakeButton.tag = SHAKETAG;
    _soundButton.tag = SOUNDTAG;
    if ([SysTools isNotificationSoundOpen]) {
        [_soundButton setOn:YES];
    }
    else
    {
        [_soundButton setOn:NO];
    }
    
    if ([SysTools isNotificationShakeing]) {
        [_shakeButton setOn:YES];
    }
    else
    {
        [_shakeButton setOn:NO];
    }

 
    
    _notView.textColor = UIColorFromRGB(TextGrayColor);
    _soundLabel.textColor = UIColorFromRGB(TextBlackColor);
    _shakeLabel.textColor = UIColorFromRGB(TextBlackColor);
    
    _soundLabel.text = TTLocalString(@"TT_sound");
    _soundLabel.font = ListTitleFont;
    _shakeLabel.text = TTLocalString(@"TT_vibration");
    _shakeLabel.font = ListTitleFont;
    
    _lineView.frame= CGRectMake(20, 44, SCREEN_WIDTH- 20, 0.75);
    [_lineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
}

- (void)buttonClick:(UIButton*)sender
{
    if (sender.tag == BACK_BUTTON) {
        [super goBack:nil];
    }
}


- (IBAction)turnSwitch:(UISwitch*)sender
{
    if (sender.tag == SOUNDTAG) {
        if (sender.isOn) {
//            开声音
            WSLog(@"1");
            [SysTools setNotificationSoundOpen:YES];
        }
        else
        {
//            关声音
            WSLog(@"2");
            [SysTools setNotificationSoundOpen:NO];
        }
    }
    else if(sender.tag == SHAKETAG)
    {
        if (sender.isOn) {
//            开振动
            WSLog(@"3");
//            振动
            [SysTools setNotificationShakeing:YES];
        }
        else
        {
//            关振动
            WSLog(@"4");
            [SysTools setNotificationShakeing:NO];
        }
    }
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
