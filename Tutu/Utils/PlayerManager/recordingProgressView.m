//
//  recordingProgressView.m
//  recordProgress
//
//  Created by gexing on 15/1/26.
//  Copyright (c) 2015年 gexing. All rights reserved.
//

#import "recordingProgressView.h"

@implementation recordingProgressView
{
    UIImageView* animatedImageView;
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor movingProgressColor:(UIColor *)movingColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // 背景图像
        _trackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _trackView.backgroundColor=backgroundColor;
        _trackView.clipsToBounds = YES;//当前view的主要作用是将出界了的_progressView剪切掉，所以需将clipsToBounds设置为YES
        [self addSubview:_trackView];
        // 填充图像
        _progressView = [[UIImageView alloc] initWithFrame:CGRectMake(0-frame.size.width, 0, frame.size.width, frame.size.height)];
        _progressView.backgroundColor=movingColor;
        [_trackView addSubview:_progressView];
        
        _currentProgress = 0.0;
        
      
    }
    return self;
}

-(UIImage *)getImageFromView:(UIView *)theView
{
    //UIGraphicsBeginImageContext(theView.bounds.size);
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, theView.layer.contentsScale);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(NSMutableArray *)animatedImage
{
    NSMutableArray *imageArray=[[NSMutableArray alloc]init];
    UIImageView *systemColor=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _progressView.frame.size.height, _progressView.frame.size.height)];

    systemColor.backgroundColor=UIColorFromRGB(SystemColor);
    
    UIImageView *whiteColor=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _progressView.frame.size.height, _progressView.frame.size.height)];
    whiteColor.backgroundColor=UIColorFromRGB(ProgressBackColor);
    
    UIImage *imageS=[self getImageFromView:systemColor];
    UIImage *imageW=[self getImageFromView:whiteColor];
 
    [imageArray addObject:imageS];
    [imageArray addObject:imageW];
    
    return imageArray;
}

//修改显示内容
- (void)changeProgressViewFrame:(CGFloat)progress  {
    //只要改变frame的x的坐标就能看到进度一样的效果
    //    _progressView.frame = CGRectMake(self.frame.size.width * (progress/_targetProgress) - self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    
    if (progress>_targetProgress) {
        return;
    }
    else
    {
//        _progressView.frame=CGRectMake(0, 0, self.frame.size.width*(progress/_targetProgress), self.frame.size.height);
        _progressView.frame = CGRectMake(self.frame.size.width * (progress/_targetProgress) - self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);

        CGRect rect=animatedImageView.frame;
        rect.origin.x=CGRectGetMaxX(_progressView.frame);
        animatedImageView.frame=rect;
    }
}

-(void)stopSlight
{
    [animatedImageView removeFromSuperview];
    _lightState=NO;
}

-(void)startSlight
{
    animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_progressView.frame), 0, _trackView.frame.size.height-2, _trackView.frame.size.height)];
    animatedImageView.animationImages = [[self animatedImage]mutableCopy];
    animatedImageView.animationDuration = .8f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
    
    [_trackView addSubview:animatedImageView];
    _lightState=YES;
}

@end
