//
//  BaseController+ScrollNavbar.m
//  fun_beta
//
//  Created by feng on 14-10-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#import "BaseController+ScrollNavbar.h"
#import <objc/runtime.h>
@implementation BaseController (ScrollNavbar)
- (void)setPanGesture:(UIPanGestureRecognizer*)panGesture {	objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN); }
- (UIPanGestureRecognizer*)panGesture {	return objc_getAssociatedObject(self, @selector(panGesture)); }

- (void)setScrollableView:(UIView*)scrollableView {	objc_setAssociatedObject(self, @selector(scrollableView), scrollableView, OBJC_ASSOCIATION_RETAIN); }
- (UIView*)scrollableView {	return objc_getAssociatedObject(self, @selector(scrollableView)); }

- (void)setOverlay:(UIView*)overlay { objc_setAssociatedObject(self, @selector(overlay), overlay, OBJC_ASSOCIATION_RETAIN); }
- (UIView*)overlay { return objc_getAssociatedObject(self, @selector(overlay)); }

- (void)setCollapsed:(BOOL)collapsed { objc_setAssociatedObject(self, @selector(collapsed), [NSNumber numberWithBool:collapsed], OBJC_ASSOCIATION_RETAIN); }
- (BOOL)collapsed {	return [objc_getAssociatedObject(self, @selector(collapsed)) boolValue]; }

- (void)setExpanded:(BOOL)expanded { objc_setAssociatedObject(self, @selector(expanded), [NSNumber numberWithBool:expanded], OBJC_ASSOCIATION_RETAIN); }
- (BOOL)expanded {	return [objc_getAssociatedObject(self, @selector(expanded)) boolValue]; }

- (void)setLastContentOffset:(float)lastContentOffset { objc_setAssociatedObject(self, @selector(lastContentOffset), [NSNumber numberWithFloat:lastContentOffset], OBJC_ASSOCIATION_RETAIN); }
- (float)lastContentOffset { return [objc_getAssociatedObject(self, @selector(lastContentOffset)) floatValue]; }

- (void)setMaxDelay:(float)maxDelay { objc_setAssociatedObject(self, @selector(maxDelay), [NSNumber numberWithFloat:maxDelay], OBJC_ASSOCIATION_RETAIN); }
- (float)maxDelay { return [objc_getAssociatedObject(self, @selector(maxDelay)) floatValue]; }

- (void)setDelayDistance:(float)delayDistance { objc_setAssociatedObject(self, @selector(delayDistance), [NSNumber numberWithFloat:delayDistance], OBJC_ASSOCIATION_RETAIN); }
- (float)delayDistance { return [objc_getAssociatedObject(self, @selector(delayDistance)) floatValue]; }

- (void)setShouldScrollWhenContentFits:(BOOL)shouldScrollWhenContentFits { objc_setAssociatedObject(self, @selector(shouldScrollWhenContentFits), [NSNumber numberWithBool:shouldScrollWhenContentFits], OBJC_ASSOCIATION_RETAIN); }
- (BOOL)shouldScrollWhenContentFits {	return [objc_getAssociatedObject(self, @selector(shouldScrollWhenContentFits)) boolValue]; }


- (void)followScrollView:(UIView*)scrollableView
{
    [self followScrollView:scrollableView withDelay:0];
}

- (void)followScrollView:(UIView*)scrollableView withDelay:(float)delay
{
    self.scrollableView = scrollableView;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.panGesture setMaximumNumberOfTouches:1];
    
    [self.panGesture setDelegate:self];
    [self.scrollableView addGestureRecognizer:self.panGesture];
    
    /* The navbar fadeout is achieved using an overlay view with the same barTintColor.
     this might be improved by adjusting the alpha component of every navbar child */
    CGRect frame = self.navBar.frame;
    frame.origin = CGPointZero;
   // self.overlay = [[UIView alloc] initWithFrame:frame];
    
    // Use tintColor instead of barTintColor on iOS < 7
//    if (IOS7_OR_LATER) {
//        if (self.navBar.backgroundColor) {
//            [self.overlay setBackgroundColor:self.navBar.backgroundColor];
//        } else if ([UINavigationBar appearance].barTintColor) {
//            [self.overlay setBackgroundColor:self.navBar.backgroundColor];
//        } else {
//            NSLog(@"[%s]: %@", __PRETTY_FUNCTION__, @"[AMScrollingNavbarViewController] Warning: no bar tint color set");
//        }
//    } else {
//        [self.overlay setBackgroundColor:self.navBar.backgroundColor];
//    }
    
//    if ([self.navigationController.navigationBar isTranslucent]) {
//        NSLog(@"[%s]: %@", __PRETTY_FUNCTION__, @"[AMScrollingNavbarViewController] Warning: the navigation bar should not be translucent");
//    }
    
    [self.overlay setUserInteractionEnabled:NO];
    [self.overlay setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.navBar addSubview:self.overlay];
    [self.overlay setAlpha:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.maxDelay = delay;
    self.delayDistance = delay;
    self.shouldScrollWhenContentFits = NO;
    self.overlay.backgroundColor = [UIColor clearColor];
}

- (void)stopFollowingScrollView
{
    [self showNavBarAnimated:NO];
    [self.scrollableView removeGestureRecognizer:self.panGesture];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    self.scrollableView = nil;
    self.panGesture = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didBecomeActive:(id)sender
{
    // This works fine in iOS8 without the ugly delay. Oh well.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showNavbar];
    });
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = self.overlay.frame;
    frame.size.height = self.navBar.frame.size.height;
    self.overlay.frame = frame;
    
    [self updateSizingWithDelta:0];
}

- (float)deltaLimit
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ([[UIApplication sharedApplication] isStatusBarHidden]) ? 44 : 24;
    } else {
        if ([[UIApplication sharedApplication] isStatusBarHidden]) {
            return (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 44 : 32);
        } else {
            return (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 24 : 12);
        }
    }
}

- (float)statusBar
{
    if (IOS7_OR_LATER) {
        return ([[UIApplication sharedApplication] isStatusBarHidden]) ? 0 : 20;
    } else {
        return ([[UIApplication sharedApplication] isStatusBarHidden]) ? 0 : 20;
    }
}

- (float)navbarHeight
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ([[UIApplication sharedApplication] isStatusBarHidden]) ? 44 : 64;
    } else {
        if ([[UIApplication sharedApplication] isStatusBarHidden]) {
            return (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 44 : 32);
        } else {
            return (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 64 : 52);
        }
    }
}

- (void)showNavBarAnimated:(BOOL)animated
{
    NSTimeInterval interval = animated ? 0.2 : 0;
    if (self.scrollableView != nil) {
        if (self.collapsed) {
            CGRect rect = [self scrollView].frame;
            rect.origin.y = 0;
            [self scrollView].frame = rect;
            [UIView animateWithDuration:interval animations:^{
                self.lastContentOffset = 0;
                self.delayDistance = -self.navbarHeight;
                [self scrollWithDelta:-self.navbarHeight];
            }];
        } else {
           // [self updateNavbarAlpha:self.navbarHeight];
        }
    }
}

- (void)showNavbar
{
    [self showNavBarAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setScrollingEnabled:(BOOL)enabled
{
    self.panGesture.enabled = enabled;
}

- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    if (!self.shouldScrollWhenContentFits) {
        if (self.scrollableView.frame.size.height >= [self contentSize].height) {
            return;
        }
    }
    
    CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
    
    float delta = self.lastContentOffset - translation.y;
    self.lastContentOffset = translation.y;
    
    if ([self checkRubberbanding:delta]) {
        [self scrollWithDelta:delta];
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        // Reset the nav bar if the scroll is partial
        [self checkForPartialScroll];
        self.lastContentOffset = 0;
    }
}

- (BOOL)checkRubberbanding:(CGFloat)delta
{
    // Prevents the navbar from moving during the 'rubberband' scroll
    if (delta < 0) {
        if ([self contentoffset].y + self.scrollableView.frame.size.height > [self contentSize].height) {
            if (self.scrollableView.frame.size.height < [self contentSize].height) { // Only if the content is big enough
                return NO;
            }
        }
    } else {
        if ([self contentoffset].y < 0) {
            return NO;
        }
    }
    return YES;
}

- (void)scrollWithDelta:(CGFloat)delta
{
    CGRect frame = self.navBar.frame;
    
    // Scrolling the view up, hiding the navbar
    if (delta > 0) {
        if (self.collapsed) {
            return;
        }
        
        if (self.expanded) {
            self.expanded = NO;
        }
        
        if (frame.origin.y - delta < -self.deltaLimit) {
            delta = frame.origin.y + self.deltaLimit;
        }
        
        frame.origin.y = MAX(-self.deltaLimit, frame.origin.y - delta);
        self.navBar.frame = frame;
        
        if (frame.origin.y == -self.deltaLimit) {
            self.collapsed = YES;
            self.expanded = NO;
            self.delayDistance = self.maxDelay;
        }
        
        [self updateSizingWithDelta:delta];
        [self restoreContentoffset:delta];
    }
    
    // Scrolling the view down, revealing the navbar
    if (delta < 0) {
        if (self.expanded) {
            return;
        }
        
        if (self.collapsed) {
            self.collapsed = NO;
        }
        
        self.delayDistance += delta;
        if (self.delayDistance > 0) {
            return;
        }
        
        if (frame.origin.y - delta > self.statusBar) {
            delta = frame.origin.y - self.statusBar;
        }
        frame.origin.y = MIN(20, frame.origin.y - delta);
        self.navBar.frame = frame;
        
        if (frame.origin.y == self.statusBar) {
            self.expanded = YES;
            self.collapsed = NO;
        }
        
        [self updateSizingWithDelta:delta];
        [self restoreContentoffset:delta];
    }
}

- (UIScrollView*)scrollView
{
    UIScrollView* scroll;
    if ([self.scrollableView isKindOfClass:[UIWebView class]]) {
        scroll = [(UIWebView*)self.scrollableView scrollView];
    } else if ([self.scrollableView isKindOfClass:[UIScrollView class]]) {
        scroll = (UIScrollView*)self.scrollableView;
    }
    return scroll;
}

- (void)restoreContentoffset:(float)delta
{
    // Hold the scroll steady until the navbar appears/disappears
    CGPoint offset = [[self scrollView] contentOffset];
    
    if ([self scrollView].translatesAutoresizingMaskIntoConstraints) {
        [[self scrollView] setContentOffset:(CGPoint){offset.x, offset.y - delta}];
    } else {
        if (delta > 0) {
            [[self scrollView] setContentOffset:(CGPoint){offset.x, offset.y - delta - 1}];
        } else {
            [[self scrollView] setContentOffset:(CGPoint){offset.x, offset.y - delta + 1}];
        }
    }
}

- (CGPoint)contentoffset
{
    return [[self scrollView] contentOffset];
}

- (CGSize)contentSize
{
    return [[self scrollView] contentSize];
}

- (void)checkForPartialScroll
{
    CGFloat pos = self.navBar.frame.origin.y;
    __block CGRect frame = self.navBar.frame;
    // Get back down
    if (pos >= (self.statusBar - frame.size.height / 2)) {
        CGFloat delta = frame.origin.y - self.statusBar;
        NSTimeInterval duration = ABS((delta / (frame.size.height / 2)) * 0.2);
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            frame.origin.y = self.statusBar;
            self.navBar.frame = frame;
            
            self.expanded = YES;
            self.collapsed = NO;
            
            [self updateSizingWithDelta:delta];
        } completion:nil];
    } else {
        // And back up
        CGFloat delta = frame.origin.y + self.deltaLimit;
        NSTimeInterval duration = ABS((delta / (frame.size.height / 2)) * 0.2);
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            frame.origin.y = -self.deltaLimit;
            self.navBar.frame = frame;
            
            self.expanded = NO;
            self.collapsed = YES;
            self.delayDistance = self.maxDelay;
            
            [self updateSizingWithDelta:delta];
        } completion:nil];
    }
}

- (void)updateSizingWithDelta:(CGFloat)delta
{
  //  [self updateNavbarAlpha:delta];
    
    // At this point the navigation bar is already been placed in the right position, it'll be the reference point for the other views'sizing
    CGRect frameNav = self.navBar.frame;
    
    // Move and expand (or shrink) the superview of the given scrollview
    CGRect frame = self.scrollableView.superview.frame;
    if (IOS7_OR_LATER) {
        frame.origin.y = frameNav.origin.y + frameNav.size.height;
    } else {
        frame.origin.y = frameNav.origin.y - [self statusBar];
    }
    if (IOS7_OR_LATER) {
        frame.size.height = [UIScreen mainScreen].bounds.size.height - frame.origin.y;
    } else {
        frame.size.height = [UIScreen mainScreen].bounds.size.height - [self statusBar];
    }
    self.scrollableView.superview.frame = frame;
    self.scrollableView.frame = self.scrollableView.superview.bounds;
    [self.view setNeedsLayout];
}

- (void)updateNavbarAlpha:(CGFloat)delta
{
    CGRect frame = self.navBar.frame;
    
    if (self.scrollableView != nil) {
        [self.navBar bringSubviewToFront:self.overlay];
    }
    
    // Change the alpha channel of every item on the navbr. The overlay will appear, while the other objects will disappear, and vice versa
    float alpha = (frame.origin.y + self.deltaLimit) / frame.size.height;
    [self.overlay setAlpha:1 - alpha];
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* obj, NSUInteger idx, BOOL *stop) {
        obj.customView.alpha = alpha;
    }];
    self.navigationItem.leftBarButtonItem.customView.alpha = alpha;
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* obj, NSUInteger idx, BOOL *stop) {
        obj.customView.alpha = alpha;
    }];
    self.navigationItem.rightBarButtonItem.customView.alpha = alpha;
    self.navigationItem.titleView.alpha = alpha;
    self.navBar.backgroundColor = [self.navBar.backgroundColor colorWithAlphaComponent:alpha];
}


@end
