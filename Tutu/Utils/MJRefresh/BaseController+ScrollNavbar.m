//
//  BaseController+ScrollNavbar.m
//  Tutu
//
//  Created by feng on 5/1/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController+ScrollNavbar.h"
#import <objc/runtime.h>
#import "TopicDetailListController.h"
#import "HomeController.h"
#import "TopicDetailController.h"
#import "HomeController.h"
@implementation BaseController (ScrollNavbar)
- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture {
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}
- (UIPanGestureRecognizer*)panGesture {
    return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setIsNavHiden:(BOOL)hiden{
   objc_setAssociatedObject(self, @selector(isNavHiden), [NSNumber numberWithBool:hiden], OBJC_ASSOCIATION_RETAIN);
}
- (BOOL)isNavHiden{
    return [objc_getAssociatedObject(self, @selector(isNavHiden)) boolValue];
}
- (void)setScrollableView:(UIView *)scrollableView {
    objc_setAssociatedObject(self, @selector(scrollableView), scrollableView, OBJC_ASSOCIATION_RETAIN);
}
- (UIView *)scrollableView {
    return objc_getAssociatedObject(self, @selector(scrollableView));
}
- (void)setLastContentOffset:(float)lastContentOffset {
    objc_setAssociatedObject(self, @selector(lastContentOffset), [NSNumber numberWithFloat:lastContentOffset], OBJC_ASSOCIATION_RETAIN);
}
- (float)lastContentOffset {
    return [objc_getAssociatedObject(self, @selector(lastContentOffset)) floatValue];
}
- (void)followScrollView:(UIView *)scrollableView{
    self.scrollableView = scrollableView;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.panGesture setMaximumNumberOfTouches:1];
    
    [self.panGesture setDelegate:self];
    [self.scrollableView addGestureRecognizer:self.panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture{
   
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
            self.lastContentOffset = translation.y;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
        
            CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
            
            CGFloat distance = translation.y - self.lastContentOffset;
            
            if (distance > 10) {
                [self showNavBarAnimated:YES];
               // NSLog(@"向下滑动需要显示");
            }
            if (distance < -10) {
              //  NSLog(@"向上滑动需要隐藏");
               [self hidenNavBarAnimated:YES];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
        
            self.lastContentOffset = 0;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)hidenNavBarAnimated:(BOOL)animated{
    if (self.isNavHiden == YES) {
        return;
    }else{
        self.isNavHiden = YES;
        if ([self isKindOfClass:[TopicDetailController class]]) {
            TopicDetailController *controller = (TopicDetailController *)self;
            [controller hidenCommentButton];
        }else if ([self isKindOfClass:[TopicDetailListController class]]){
            TopicDetailListController *controller = (TopicDetailListController *)self;
            [controller hidenCommentButton];
        }else if ([self isKindOfClass:[HomeController class]]){
            HomeController *controller = (HomeController *)self;
            [controller hidenSegmentViewAndFootView];
        }
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGRect frame = self.titleMenu.frame;
            self.titleMenu.frame = CGRectMake(frame.origin.x, frame.origin.y - 44, frame.size.width, frame.size.height);
            CGRect frame1 = self.scrollableView.frame;
            self.scrollableView.frame = CGRectMake(frame1.origin.x, frame1.origin.y - 44, frame1.size.width, frame1.size.height + 44);
            if ([self isKindOfClass:[TopicDetailListController class]]) {
                    self.scrollableView.frame = CGRectMake(frame1.origin.x, frame1.origin.y - 22, frame1.size.width, frame1.size.height + 44);
            }else{
                self.scrollableView.frame = CGRectMake(frame1.origin.x, frame1.origin.y - 44, frame1.size.width, frame1.size.height + 44);
            }

            self.menuLeftButton.alpha = 0.0f;
            self.menuRightButton.alpha = 0.0f;
            self.menuTitleButton.alpha = 0.0f;
        } completion:nil];
    }

}
- (void)showNavBarAnimated:(BOOL)animated{
    if (self.isNavHiden == NO) {
        return;
    }else{
        self.isNavHiden = NO;
        if ([self isKindOfClass:[TopicDetailController class]]) {
            TopicDetailController *controller = (TopicDetailController *)self;
            [controller showCommentButton];
        }else if ([self isKindOfClass:[TopicDetailListController class]]){
            TopicDetailListController *controller = (TopicDetailListController *)self;
            [controller showCommentButton];
        }else if ([self isKindOfClass:[HomeController class]]){
        
            HomeController *controller = (HomeController *)self;
            [controller showSegmentViewAndFootView];
        }
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGRect frame = self.titleMenu.frame;
            self.titleMenu.frame = CGRectMake(frame.origin.x, frame.origin.y + 44, frame.size.width, frame.size.height);
            CGRect frame1 = self.scrollableView.frame;
            self.scrollableView.frame = CGRectMake(frame1.origin.x, frame1.origin.y + 44, frame1.size.width, frame1.size.height - 44);
            if ([self isKindOfClass:[TopicDetailListController class]]) {
                self.scrollableView.frame = CGRectMake(frame1.origin.x, frame1.origin.y + 22, frame1.size.width, frame1.size.height - 44);
            }else{
                self.scrollableView.frame = CGRectMake(frame1.origin.x, frame1.origin.y + 44, frame1.size.width, frame1.size.height - 44);
            }
            self.menuLeftButton.alpha = 1.0f;
            self.menuRightButton.alpha = 1.0f;
            self.menuTitleButton.alpha = 1.0f;
        } completion:nil];
    }
}
@end
