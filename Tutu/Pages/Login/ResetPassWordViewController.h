//
//  ResetPassWordViewController.h
//  Tutu
//
//  Creaipted by 刘大治 on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "SendPhoneNumViewController.h"
@interface ResetPassWordViewController : BaseController
@property (assign,nonatomic)FindPasswordType type;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIScrollView *backScroll;
@property (weak, nonatomic) IBOutlet UITextField *firstPassword;
@property (weak, nonatomic) IBOutlet UITextField *secondPassword;
@property (weak, nonatomic) IBOutlet UIView *mybackView;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;

-(void)setPhoneNum:(NSString*)phonenum title:(NSString*)newtitle;
@end
