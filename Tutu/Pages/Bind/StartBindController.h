//
//  StartBindController.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface StartBindController : BaseController

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDetail;

@property (weak, nonatomic) IBOutlet UIButton *btnBind;


@end
