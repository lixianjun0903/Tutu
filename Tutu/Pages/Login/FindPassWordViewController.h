//
//  FindPassWordViewController.h
//  Tutu
//
//  Created by 刘大治 on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "SendPhoneNumViewController.h"
#import "InterfaceDefines.h"
@interface FindPassWordViewController : BaseController
@property (assign,nonatomic) FindPasswordType type;

@property (weak, nonatomic) IBOutlet UIView *textBackView;
@property (weak, nonatomic) IBOutlet UILabel *phoneTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *checkNum;
@property (weak, nonatomic) IBOutlet UIButton *resendCountButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

-(id)initWithPhoneNum:(NSString*)newPhoneNum title:(NSString*)titleString;
@end
