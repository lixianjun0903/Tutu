//
//  XHImageViewer.h
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCMessage.h"
#import "LXActionSheet.h"



@class XHImageViewer;
@protocol XHImageViewerDelegate <NSObject>

@optional
- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView;

@end

@interface XHImageViewer : UIView<LXActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) id<XHImageViewerDelegate> delegate;
@property (nonatomic, assign) BOOL isShowMenu;
@property (nonatomic, assign) BOOL isNotInsertView;

@property (nonatomic, assign) int menuType;
@property (nonatomic, strong) NSString * param;
@property (nonatomic, strong) RCMessage * rcmsg;
@property (nonatomic, assign) CGFloat backgroundScale;

- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView;
@end
