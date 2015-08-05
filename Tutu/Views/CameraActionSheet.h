//
//  CameraActionSheet.h
//  Tutu
//
//  Created by feng on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  CameraActionSheetDelegate <NSObject>

- (void)cameraActionSheetButtonClick:(NSInteger)buttonIndex;

@end
@interface CameraActionSheet : UIView
@property(nonatomic,weak)  id <CameraActionSheetDelegate> cameraDelegate;
@property(nonatomic,strong)UIView *contentView;
- (id)initWithDelegate:(id <CameraActionSheetDelegate>)delegate titles:(NSArray *)titles;
- (void)showInView:(UIView *)view;
@end
