//
//  ChangePassWordViewController.h
//  Tutu
//
//  Created by 刘大治 on 14-10-27.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface ChangePassWordViewController : BaseController
@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;
@property (weak, nonatomic) IBOutlet UILabel *orgLabel;
@property (weak, nonatomic) IBOutlet UILabel *setNewPassword;

@property (weak, nonatomic) IBOutlet UILabel *sureNewLabel;
@property (weak, nonatomic) IBOutlet UITextField *orignalPassword;
@property (weak, nonatomic) IBOutlet UITextField *firstNewPassWord;
@property (weak, nonatomic) IBOutlet UITextField *firstCheckPassWord;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *myTitle;
@property (weak, nonatomic) IBOutlet UIView *myBackView;
@property (weak, nonatomic) IBOutlet UIImageView *lineView1;
@property (weak, nonatomic) IBOutlet UIImageView *lineView2;

@end
