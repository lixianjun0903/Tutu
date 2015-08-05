//
//  BaseController+ScrollNavbar.h
//  fun_beta
//
//  Created by feng on 14-10-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import <UIKit/UIKit.h>
@interface BaseController (ScrollNavbar)<UIGestureRecognizerDelegate>
/**-----------------------------------------------------------------------------
 * @name UIViewController+ScrollingNavbar
 * -----------------------------------------------------------------------------
 */

/** Scrolling init method
 *
 * Enables the scrolling on a generic UIView.
 * Also sets the value (in points) that needs to scroll through beofre the navbar is moved back into scene
 * Remember to call showNavbar or showNavBarAnimated: in your viewDidDisappear.
 *
 * @param scrollableView The UIView where the scrolling is performed.
 * @param delay The delay of the downward scroll gesture
 */
- (void)followScrollView:(UIView*)scrollableView withDelay:(float)delay;

/** Scrolling init method
 *
 * Enables the scrolling on a generic UIView.
 * Remember to call showNavbar or showNavBarAnimated: in your viewDidDisappear.
 *
 * @param scrollableView The UIView where the scrolling is performed.
 */
- (void)followScrollView:(UIView*)scrollableView;

/** Navbar slide down
 *
 * Manually show the navbar
 */
- (void)showNavbar;

/** Navbar slide down
 *
 * Manually show the navbar
 *
 * @param animated Animates the navbar scrolling
 */
- (void)showNavBarAnimated:(BOOL)animated;

/** Remove the scrollview tracking
 *
 * Use this method to stop following the navbar
 */
- (void)stopFollowingScrollView;

/** Enable or disable the scrolling
 *
 * Set this property to NO to disable the scrolling of the navbar.
 */
- (void)setScrollingEnabled:(BOOL)enabled;

/** Enable or disable the scrolling when the content size is smaller than the bounds
 *
 * Set this property to YES to enable the scrolling of the navbar even when the
 * content size of the scroll view is smaller than its height.
 */
- (void)setShouldScrollWhenContentFits:(BOOL)enabled;


@end
