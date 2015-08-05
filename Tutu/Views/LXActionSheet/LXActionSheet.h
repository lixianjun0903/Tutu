//
//  LXActionSheet.h
//  LXActionSheetDemo
//
//  Created by lixiang on 14-3-10.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LXActionSheetDelegate <NSObject>
- (void)didClickOnButtonIndex:(NSInteger )buttonIndex tag:(NSInteger)tag;
@optional
- (void)didClickOnDestructiveButton;
- (void)didClickOnCancelButton;
- (void)didClickOnBackground;
@end

@interface LXActionSheet : UIView

- (void)showInView:(UIView *)view;
- (void)showInCustomView:(UIView *)view;
@property(nonatomic)NSInteger buttonCount;
//如何一个页面弹出多个需要通过tag来区分
@property(nonatomic)NSInteger tag;

- (id)initWithTitle:(NSString *)title delegate:(id<LXActionSheetDelegate>)delegate otherButton:(NSArray *)buttons cancelButton:(NSString *)cancelButton;
@end
