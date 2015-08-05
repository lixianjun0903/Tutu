//
//  SignChangeViewController.h
//  Tutu
//
//  Created by 刘大治 on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface SignChangeViewController : BaseController<UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *textBackView;
@property (weak, nonatomic) IBOutlet UITextView *signTextfield
;


@end
