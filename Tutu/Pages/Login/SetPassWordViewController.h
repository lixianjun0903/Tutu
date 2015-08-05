//
//  SetPassWordViewController.h
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "YHShakeUITextField.h"

@interface SetPassWordViewController : BaseController
@property (weak, nonatomic) IBOutlet UIScrollView *backScroll;

@property (weak, nonatomic) IBOutlet UITextField *nickName;
@property (weak, nonatomic) IBOutlet UITextField *passwordSet;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondLine;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;

@property (weak, nonatomic) IBOutlet UIView *textView;
-(void)setPhoneNum:(NSString*)phonenum vcode:(NSString*)vcode title:(NSString*)newtitle;
@end
