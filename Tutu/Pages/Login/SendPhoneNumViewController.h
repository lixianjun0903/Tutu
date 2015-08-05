//
//  SendPhoneNumViewController.h
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "YHShakeUITextField.h"


@interface SendPhoneNumViewController : BaseController
typedef enum {
    
    //
    FindPasswordTypeRegist = 0,
    
    //  头像
    FindPasswordTypeFind = 1,
    
    
    //绑定手机
    BindPhoneNumber = 2,
    
} FindPasswordType;
@property (assign,nonatomic)FindPasswordType type;

@property (weak, nonatomic) IBOutlet UITextField *num;
@property (weak, nonatomic) IBOutlet UIView *textBack;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

-(void)setTitleWithString:(NSString*)string;

@end
