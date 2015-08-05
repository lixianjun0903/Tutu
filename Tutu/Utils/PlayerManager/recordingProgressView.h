//
//  recordingProgressView.h
//  recordProgress
//
//  Created by gexing on 15/1/26.
//  Copyright (c) 2015年 gexing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recordingProgressView : UIView

@property(nonatomic,strong)NSTimer *slightTimer;

// 背景图像
@property (strong, nonatomic) UIImageView *trackView;
// 填充图像
@property (strong, nonatomic) UIImageView *progressView;

@property(nonatomic,assign,readonly)BOOL lightState;

@property (nonatomic) CGFloat targetProgress; //进度
@property (nonatomic) CGFloat currentProgress; //当前进度

- (void)changeProgressViewFrame:(CGFloat)progress;
- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor movingProgressColor:(UIColor *)movingColor;

-(void)stopSlight;
-(void)startSlight;

@end
