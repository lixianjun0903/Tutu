//
//  selectMusicView.m
//  tttttest
//
//  Created by gexing on 15/1/13.
//  Copyright (c) 2015年 gexing. All rights reserved.
//

#import "selectMusicView.h"
//#define BUTTON_WIDTH 60

#define SPACING 10
#define LABEL_HEIGHT 35

#define IPHONE4_LABEL_HEIGHT 20
@implementation SelectMusicView
{
    NSArray *array;
    UIScrollView *sliderView;
    int arrayCount;
    double imageviewAngle;
}


-(id)initWithFrame:(CGRect)rect musicArray:(NSArray *)photoArray delegate:(id<clickDelegate>)delegata
{
    if (self=[super initWithFrame:rect]) {
        
        array=[photoArray mutableCopy];
        self.clickDelegata=delegata;
        arrayCount=(int)array.count;
        [self initView];
    }
    return  self;
}

-(void)initView
{

    int W=self.frame.size.width;
    int H=self.frame.size.height;
    CGFloat buttonWidth;
    if ([UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width==1.5) {
        
    buttonWidth=H-IPHONE4_LABEL_HEIGHT;
        
    }
    else
    {
        buttonWidth=H-LABEL_HEIGHT-15;
    }
    sliderView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,W,H)];
    if (iPhone5) {
        sliderView.contentSize=CGSizeMake((buttonWidth+SPACING)*arrayCount+10,H);
        

    }else
    {
        sliderView.contentSize=CGSizeMake((buttonWidth+SPACING-3)*arrayCount+10,H);

    }
    sliderView.showsHorizontalScrollIndicator=NO;
    sliderView.bounces=NO;
    [self addSubview:sliderView];

    
    
     NSArray *audioNameArray=[[NSArray alloc]initWithObjects:@"Hey girl",@"喜欢你", @"Byebye",@"My love",@"Dance",@"结局",@"Boom",@"咆哮",@"口哨",@"辣舞曲",@"在午后",nil];
    for (int i=0;i<arrayCount; i++) {
        UIButton *btn;
//        UIImageView *selectedView;
        if (iPhone5) {
           btn =[[UIButton alloc]initWithFrame:CGRectMake(i*(buttonWidth+SPACING)+10,0,buttonWidth,buttonWidth)];
//            selectedView=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame)-18, CGRectGetMinY(btn.frame), 18, 18)];
        }else
        {
            btn =[[UIButton alloc]initWithFrame:CGRectMake(i*(buttonWidth+SPACING-3)+10,0,buttonWidth,buttonWidth)];
//            selectedView=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame)-15, CGRectGetMinY(btn.frame), 15, 15)];
        }
//        selectedView.image=[UIImage imageNamed:@"record_music_s"];
//        selectedView.tag=10000+i;
//        [selectedView setHidden:YES];
        WSLog(@"%@",[array objectAtIndex:i]);
        [btn setBackgroundImage:[UIImage imageNamed:[array objectAtIndex:i]] forState:UIControlStateNormal];
//        if(i<=1){
//            [btn setBackgroundImage:[UIImage imageNamed:[array objectAtIndex:i]] forState:UIControlStateNormal];
//            [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_nor",[array objectAtIndex:i]]] forState:UIControlStateHighlighted];
//        }
        btn.tag=i;
        btn.userInteractionEnabled=YES;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [sliderView addSubview:btn];
        
        //设置边框
        CALayer *layer=[btn layer];
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:1];
        [layer setCornerRadius:buttonWidth/2];
          [btn.layer setBorderColor:[UIColor clearColor].CGColor];
//        if (btn.tag==0) {
//            [btn.layer setBorderColor:UIColorFromRGB(SystemColor).CGColor];
//            [selectedView setHidden:NO];
//        }

        //设置蒙层
        if (i>1) {
            UIImageView *rideView=[[UIImageView alloc]initWithFrame:btn.frame];
            rideView.alpha=0.3;
            
            rideView.backgroundColor=UIColorFromRGB(coverViewColor);
            rideView.tag=100+i;
            rideView.userInteractionEnabled=NO;
            [sliderView addSubview:rideView];
            
            CALayer *layer=[rideView layer];
            [layer setMasksToBounds:YES];
            [layer setBorderWidth:1];
            [layer setCornerRadius:buttonWidth/2];
            [btn.layer setBorderColor:[UIColor clearColor].CGColor];
        }
//        [sliderView addSubview:selectedView];

        UILabel *label;
        if (!iPhone5) {
            
            label=[[UILabel alloc]initWithFrame:CGRectMake(i*(buttonWidth+SPACING-3)+10, btn.frame.origin.y+buttonWidth, buttonWidth, IPHONE4_LABEL_HEIGHT)];
            label.font=[UIFont systemFontOfSize:9];

        }else
            
        {
            label=[[UILabel alloc]initWithFrame:CGRectMake(i*(buttonWidth+SPACING)+10, btn.frame.origin.y+buttonWidth, buttonWidth, LABEL_HEIGHT)];
            label.font=[UIFont systemFontOfSize:16];

        }
        
        label.textAlignment=NSTextAlignmentCenter;
        
        
        if (i==0) {
            label.text=@"录音";
        }else if(i==1){
            label.text=@"本地音乐";
        }else{
            label.text=[audioNameArray objectAtIndex:i-2];
        }
        label.textColor=UIColorFromRGB(MenuTitleColor);
        [sliderView addSubview:label];
    }
    
}
- (void)startAnimation:(UIView *)imageView
{

    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 16;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1000;
    [imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
-(void)btnClick:(id)sender
{
    
   
    //设置选中边框
    UIButton *btn=(UIButton *)sender;
    
    for (UIView *view in sliderView.subviews) {
        
        if (view.frame.size.width<=3) {
            [view removeFromSuperview];
        }
        
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.tag) {
                [view.layer removeAllAnimations];
            }
            [view.layer setBorderColor:[UIColor clearColor].CGColor];
            UIButton *b=(UIButton *)view;
            if (b.tag!=btn.tag) {
                b.selected=NO;
            }
        }
        
        if ([view isKindOfClass:[UIImageView class]]) {
            
//            NSLog(@"%ld",(long)view.tag);
//            if (view.tag>=10000) {
//                view.hidden=YES;
//            }else
//            {
            view.alpha=0.3;
//            }
        }
        
    }

    
    
    //设置蒙层
    if (btn.selected) {
        if (btn.tag) {
            [btn.layer removeAllAnimations];
        }
            //取消选中事件
        if ([self.clickDelegata respondsToSelector:@selector(clickButton:andState:)]) {
            [self.clickDelegata clickButton:(int)btn.tag andState:1];
        }
        
    }else
    {
        if (btn.tag>1) {
            [self startAnimation:btn];
        }
        [btn.layer setBorderColor:UIColorFromRGB(SystemColor).CGColor];

        UIImageView *overV=(UIImageView *)[sliderView viewWithTag:100+btn.tag];
        overV.alpha=0;
        
        UIImageView *selected=(UIImageView *)[sliderView viewWithTag:10000+btn.tag];
        [selected setHidden:NO];
        //选中
        if ([self.clickDelegata respondsToSelector:@selector(clickButton:andState:)]) {
            [self.clickDelegata clickButton:(int)btn.tag andState:0];
        }
    }
    btn.selected=!btn.selected;
}

-(void)loclMusicChecked:(int)tag{
    UIView *btn=[sliderView viewWithTag:tag];
    [self startAnimation:btn];
}
@end
