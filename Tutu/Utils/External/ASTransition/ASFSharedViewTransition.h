//
//  ASFSharedViewTransition.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASFSharedViewTransitionDataSource <NSObject>

- (UIView *)sharedView;

@end

@interface ASFSharedViewTransition : NSObject<UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate>

@property (nonatomic, weak) Class fromVCClass;
@property (nonatomic, weak) Class toVCClass;

+ (void)addTransitionWithFromViewControllerClass:(Class<ASFSharedViewTransitionDataSource>)aFromVCClass
                           ToViewControllerClass:(Class<ASFSharedViewTransitionDataSource>)aToVCClass
                        WithNavigationController:(UINavigationController *)aNav
                                    WithDuration:(NSTimeInterval)aDuration;

@end