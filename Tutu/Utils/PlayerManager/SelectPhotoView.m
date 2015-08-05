//
//  selectPhotoView.m
//  tttttest
//
//  Created by gexing on 15/1/12.
//  Copyright (c) 2015年 gexing. All rights reserved.
//

#import "selectPhotoView.h"
#define WIDTH   [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
#define sliderImageWidth 85
//#define sliderImageHeight 80
//#define bottonImageHeight 20


@implementation SelectPhotoView
{

    UIScrollView *slider;
    UIImageView * sliderView;
    
    float widthOfSet;
    float bottomWidth;

    CGFloat suitheight;
    CGFloat suitWidth;
    NSMutableArray *transferArray;
}



-(id)initWithFrame:(CGRect)rect ImageArray:(NSArray *)imageArray originalImage:(originalImage)originalImageBlock selectImageBlock:(blockImage)imageBlock

{
    
    if (self=[super initWithFrame:rect]) {
        
        transferArray=[[NSMutableArray alloc]init];
        _array=[imageArray mutableCopy];
        _tempBlock=imageBlock;
        _tempOrBlock=originalImageBlock;
        [self createView];
    }
    return self;
}

-(void)createView
{
    CGFloat scale=HEIGHT/WIDTH;
    
    
    
    //底部图片

    
    if (_array.count<10) {
        bottomWidth=self.frame.size.width/10;
    }else
    {
         bottomWidth=self.frame.size.width/_array.count;
    }

//    if (scale>1.5) {
//        //        suitheight=sliderImageWidth*1.2;
//        //        suitWidth=sliderImageWidth;
//        
//        suitheight=bottomWidth+20;
//        suitWidth=bottomWidth+20;
//    }else
//    {
        suitheight=bottomWidth+20;
        suitWidth=bottomWidth+20;
//    }
    
    
    for (int i=0; i<_array.count; i++) {
        
        
        UIImageView *view1;
        if (HEIGHT>480) {
            
            view1=[[UIImageView alloc]initWithFrame:CGRectMake(i*bottomWidth, self.frame.size.height/2-bottomWidth/2, bottomWidth, bottomWidth)];
            CGPoint center;
            center.x=view1.center.x;
            center.y=self.center.y;
            view1.center=center;
        }
        else
        {
            view1=[[UIImageView alloc]initWithFrame:CGRectMake(i*bottomWidth, self.frame.size.height/2-bottomWidth/2, bottomWidth, bottomWidth)];
        }
        
        if ([[_array objectAtIndex:i]isKindOfClass:[NSMutableData class]]||[[_array objectAtIndex:i]isKindOfClass:[NSData class]]) {
            UIImage *image=[UIImage imageWithData:[_array objectAtIndex:i]];
            view1.image=image;
            [transferArray addObject:image];
        }else
        {
            UIImage *image=[_array objectAtIndex:i];
            view1.image=image;
            [transferArray addObject:image];

        }
        
        [view1 setContentMode:UIViewContentModeScaleAspectFill];
        view1.layer.masksToBounds=YES;
        [self addSubview:view1];
    }
    
       //左右俩边空出的width
    CGFloat outWildWidth=(self.frame.size.width-suitWidth)/2;
    widthOfSet=outWildWidth*2;
    
    slider=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.frame.size.width,suitheight)];
    slider.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    slider.delegate=self;
    slider.bounces=NO;
    slider.showsHorizontalScrollIndicator=NO;
    slider.contentSize=CGSizeMake(self.frame.size.width+outWildWidth*2, suitheight);
    slider.contentOffset=CGPointMake(outWildWidth*2,0 );
    slider.decelerationRate=0.1f;
    
    
    UIView *coverView=[[UIView alloc]initWithFrame:slider.frame];
    coverView.backgroundColor=UIColorFromRGB(OverlayViewColor);
    coverView.alpha=0.5;
    [self addSubview:coverView];

    //滑块视图
    sliderView=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,suitWidth, suitheight)];
    sliderView.contentMode=UIViewContentModeScaleAspectFill;
    
    sliderView.center=CGPointMake(slider.contentSize.width/2, suitheight/2);
    
    if (transferArray.count>0) {
        sliderView.image=[transferArray objectAtIndex:0];
        _tempOrBlock([transferArray objectAtIndex:0]);
    }
   
    sliderView.backgroundColor=[UIColor greenColor];
    
 
    
    [slider addSubview: sliderView];
    [self addSubview:slider];
   
    
    //设置边框
    CALayer *layer=[sliderView layer];
       [layer setMasksToBounds:YES];
//    [layer setCornerRadius:5];
        [layer setBorderWidth:2];
        [layer setBorderColor:UIColorFromRGB(SystemColor).CGColor];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float totalOfSet;
//    NSLog(@"%f",scrollView.contentOffset.x);
    if (_array.count<10) {
        float change=widthOfSet-scrollView.contentOffset.x+bottomWidth-2;
        int i=change/bottomWidth;
        if (i>=0&&i<_array.count) {
            sliderView.image=[transferArray objectAtIndex:i ];
            _tempBlock([transferArray objectAtIndex:i]);
            //  NSLog(@"%d",i);
        }

    }else
    {
         totalOfSet=(self.frame.size.width-suitWidth)/_array.count;

        int i= (scrollView.contentOffset.x+totalOfSet)/totalOfSet ;
        
        
        if (i>0&&i<=_array.count) {
            sliderView.image=[transferArray objectAtIndex:_array.count-i ];
            _tempBlock([transferArray objectAtIndex:_array.count-i]);
            //            NSLog(@"%d",i);
        }

    }
    
    
}

@end
