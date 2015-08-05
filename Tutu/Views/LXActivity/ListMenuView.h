//
//  ListMenuView.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-8.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

@protocol ListMenuDelegate <NSObject>
- (void)didClickOnIndex:(NSInteger ) index type:(int) tag;

@end

@interface ListMenuView : UIView


- (id)initWithDelegate:(id<ListMenuDelegate>)delegate items:(NSArray *) array;

- (void)showInView:(UIView *)view;

@end