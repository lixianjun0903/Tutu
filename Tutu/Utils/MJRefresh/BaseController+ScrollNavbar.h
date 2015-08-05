//
//  BaseController+ScrollNavbar.h
//  Tutu
//
//  Created by feng on 5/1/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface BaseController (ScrollNavbar) <UIGestureRecognizerDelegate>


- (void)followScrollView:(UIView *)scrollableView;

/** Navbar slide down
 *
 * Manually show the navbar
 */

- (void)showNavBarAnimated:(BOOL)animated;


- (void)hidenNavBarAnimated:(BOOL)animated;
@end
