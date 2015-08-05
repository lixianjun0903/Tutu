//
//  NotificationSetController.h
//  Tutu
//
//  Created by 刘大治 on 14/11/24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
@interface NotificationSetController : BaseController
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *notView;
@property (weak, nonatomic) IBOutlet UISwitch *soundButton;
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shakeButton;
@property (weak, nonatomic) IBOutlet UILabel *shakeLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
