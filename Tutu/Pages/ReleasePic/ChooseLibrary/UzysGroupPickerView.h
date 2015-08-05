//
//  UzysGroupPickerView.h
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
@interface UzysGroupPickerView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic,copy) intBlock blockTouchCell;
@property (nonatomic,assign) BOOL isOpen;
- (id)initWithGroups:(NSMutableArray *)groups;

- (void)show;
- (void)dismiss:(BOOL)animated;
- (void)toggle;
- (void)reloadData;
@end
