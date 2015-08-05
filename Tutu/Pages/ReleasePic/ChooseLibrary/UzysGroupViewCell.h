//
//  UzysGroupViewCell.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 13..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysGroupViewCell : UITableViewCell
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
- (void)applyData:(ALAssetsGroup *)assetsGroup;
@end
