//
//  VideoCutController.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "VideoCutController.h"
#import "TEditMediaController.h"
#import "RCCaptureSessionManager.h"
#import "TutuPlayerView.h"
#import "EasyTableView.h"
//#import "FFmpegSaveImage.h"
#import "FFmpegClipVideo.h"

#define SLIDER_BORDER_WIDTH  30

#define LEFT_TAG 100
#define RIGHT_TAG 101
#define SLIDER_TAG 103



@interface VideoCutController ()<EasyTableViewDelegate>{
    MPMoviePlayerController *_player;
    NSTimer *playerStop;
    float playTime;
    UIButton *btnPlay;
    
    CGFloat w;
    CGFloat h;
    CGFloat topMenuHeight;
    CGFloat scrollViewHeight;
    
    CGPoint touchStart;
    CGRect startRect;
    //是否开始拖动
    CameraMoveDirection direction;
    
    CGFloat startTime;   //视频开始切割时间
    CGFloat cutDurtion;   //视频切割总时长
    CGFloat videoDurtion;      //视频总时长
    
    NSURL *localURL;
    
    UIButton *sliderBorderRight;
    UIButton *sliderBorderLeft;
    RCCaptureSessionManager *manager;
//    UIScrollView *imagesScrollView;
    EasyTableView *testView;
    UIView *bgView;
    UIView *overlayView;
    
    UILabel *labelNumber1;
    UILabel *labelNumber2;
    UILabel *labelNumber3;
    UILabel *labelNumber4;
    
    int pageNumber;
    CGFloat imageWidth;
    CGFloat maxWidth;
    CGFloat secondWidth;
    NSMutableArray *faceArr;
    CGPoint contentOfSetPoint;
}


@property(nonatomic,strong)NSString *mergededVideoPath;
@property(nonatomic,strong)UIImageView *showImageView;
@property(nonatomic,strong)UIView *backView;
@property(nonatomic,strong)UIImageView *sliderView;
@property (strong, nonatomic) AVAssetExportSession *exportSession;

@end

@implementation VideoCutController

- (void)viewDidLoad {
    [super viewDidLoad];
    faceArr=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(CoverRecordColor)];
    
    w=self.view.frame.size.width-20;
    h=self.view.frame.size.height;
    topMenuHeight=45;
    scrollViewHeight=90;
    
    UIButton *menuTitleButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [menuTitleButton setFrame:CGRectMake(44,0, self.view.frame.size.width-88, 44)];
    [menuTitleButton setBackgroundColor:[UIColor clearColor]];
    [menuTitleButton.titleLabel setFont:TitleFont];
    [menuTitleButton setTitle:@"裁剪视频" forState:UIControlStateNormal];
    [menuTitleButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateNormal];
    [self.view addSubview:menuTitleButton];
 
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    backBtn.tag=BACK_BUTTON;
    [backBtn setFrame:CGRectMake(0,0, 44, topMenuHeight)];
    backBtn.backgroundColor=[UIColor clearColor];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 16, 13, 16)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"backc_light"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
    UIButton *commitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setBackgroundColor:[UIColor clearColor]];
    commitBtn.tag=RIGHT_BUTTON;
    [commitBtn setFrame:CGRectMake(SCREEN_WIDTH-60, 0, 55,45)];
//    [commitBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 11.5, 13, 11.5)];
//    [commitBtn setImage:[UIImage imageNamed:@"changeNickDefautl"] forState:UIControlStateNormal];
//    [commitBtn setImage:[UIImage imageNamed:@"changeNickHelight"] forState:UIControlStateHighlighted];
    [commitBtn setTitle:TTLocalString(@"TT_The next step") forState:UIControlStateNormal];
//    commitBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [commitBtn.titleLabel setFont:TitleFont];
    [commitBtn setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
    
    
    manager=[[RCCaptureSessionManager alloc]init];
    
    
    _showImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, topMenuHeight, SCREEN_WIDTH, SCREEN_WIDTH)];
    _showImageView.backgroundColor=[UIColor clearColor];
    _showImageView.contentMode=UIViewContentModeScaleAspectFill;
    _showImageView.layer.masksToBounds=YES;
    [_showImageView setImage:[UIImage imageNamed:@"topic_default"]];
    [self.view addSubview:_showImageView];
    
    _player=[[MPMoviePlayerController alloc] init];
    _player.view.frame= CGRectMake(0, topMenuHeight, SCREEN_WIDTH, SCREEN_WIDTH);
    _player.controlStyle = MPMovieControlStyleNone;
    [_player setScalingMode:MPMovieScalingModeAspectFill];
    _player.repeatMode=MPMovieRepeatModeOne;
    [_player setFullscreen:YES animated:YES];
    _player.view.userInteractionEnabled=NO;
    
    for (UIView *view in [_player.view subviews]) {
        [view setBackgroundColor:[UIColor clearColor]];
    }
    
    [_player.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_player.view];
    
    
    btnPlay=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnPlay setImage:[UIImage imageNamed:@"topic_paly_btn"] forState:UIControlStateNormal];
    [btnPlay addTarget:self action:@selector(doStartPlay:) forControlEvents:UIControlEventTouchUpInside];
    [btnPlay setFrame:CGRectMake(0, 0, 75, 75)];
    [btnPlay setCenter:_player.view.center];
    [self.view addSubview:btnPlay];
    [btnPlay setHidden:YES];
    
    

    if(self.videoArr!=nil && self.videoArr.count>0){
        NSDictionary *dict=[self.videoArr objectAtIndex:0];
        
        localURL=[dict objectForKey:@"videoURL"];
        videoDurtion=[[dict objectForKey:@"duration"] floatValue];
        
        if (videoDurtion>=600) {
            [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_The following video oh can only select 10 minutes") duration:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            return;
        }
        
        [_player setContentURL:localURL];
        
        
        startTime=0;
        imageWidth=w/8;
        
        // 每一秒的宽
        secondWidth=w/15;
        
        //所有时长能取多少张图片
        pageNumber=8*videoDurtion/15;
        
        if(videoDurtion<MaxCMtime){
//            maxWidth=videoDurtion*w/15;
            maxWidth=pageNumber*imageWidth;
            cutDurtion=videoDurtion;
        }else{
            maxWidth=w;
            cutDurtion=16;
        }
        
        [_showImageView setImage:[manager thumbnailImageForVideo:localURL atTime:startTime]];
        [self initCutView];
        
        [self overlayClipping];
        
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [manager getImagesFromLocalURL:localURL times:pageNumber maxwidth:60 progress:^(NSData *imgData, int index) {
//                [faceArr addObject:imgData];
//                
//                if (faceArr.count<9) {
//                    [testView reloadData];
//                }else
//                {
//                    if (faceArr.count%3) {
//                        return ;
//                    }else
//                    {
//                        [testView reloadData];
//                    }
//                }
//            }];
            
//            [manager videoToTempFile:localURL finish:^(NSString *filePath) {
//                
//                [FFmpegSaveImage getImages:pageNumber withVideo:filePath withBlock:^(NSData *imgData, int index) {
//                    [faceArr addObject:imgData];
//                    if (faceArr.count<9) {
//                        [testView reloadData];
//                    }
//                    else{
//                        if (faceArr.count%3){
//                            return;
//                        }
//                        else{
//                            [testView reloadData];
//                        }
//                    }
//                    
//                }];
//            } fail:^(NSString *filePath, NSError *error) {
//                return;
//            }];
//    
//        });
        
        dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   dispatch_async(queue, ^{
       [manager getImagesFromVideo:localURL times:pageNumber width:60 progress:^(NSData *imgData, int index) {
           
                           [faceArr addObject:imgData];
           
//           dispatch_async(dispatch_get_main_queue(), ^{
               if (faceArr.count<9) {
                   
                   [testView reloadData];
                   
               }else
                   
               {
                   
                   if (faceArr.count%3) {
                       
                       return ;
                       
                   }else
                       
                   {
                       
                       [testView reloadData];
                    
                   }
               }

                       }];

   });

    }
}



//初始化切图按钮
-(void)initCutView
{
    int xh=h-topMenuHeight-w;
    int backHeight=146;
    if(xh<146){
        backHeight=xh;
        scrollViewHeight=backHeight-53;
    }
    //背景图，裁切视图的的父视图
    _backView=[[UIView alloc]initWithFrame:CGRectMake(0,h-backHeight,ScreenWidth,backHeight)];
    [_backView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_backView];
    float bgWidth;
    float originalY;
    if (iPhone5) {
        originalY=CGRectGetHeight(_backView.frame)-40-30-imageWidth-10;
        bgWidth=20;
    }else
    {
         originalY=CGRectGetHeight(_backView.frame)-40-imageWidth-10-10;
        bgWidth=10;
    }
    
    bgView=[[UIView alloc]initWithFrame:CGRectMake(10,originalY, w, imageWidth+bgWidth)];
    bgView.backgroundColor=UIColorFromRGB(SliderBgColor);
    [bgView setExclusiveTouch:YES];
//    bgView.center=CGPointMake( SCREEN_WIDTH/2,(CGRectGetHeight(_backView.frame)-40)/2);
    [bgView setExclusiveTouch:YES];
    [_backView addSubview:bgView];
//    imagesScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 2, w, scrollViewHeight)];
//    imagesScrollView.alwaysBounceHorizontal=NO;
//    imagesScrollView.alwaysBounceVertical=NO;
//    [imagesScrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    imagesScrollView.showsHorizontalScrollIndicator=NO;
//    imagesScrollView.delegate=self;
//    [imagesScrollView setBackgroundColor:[UIColor clearColor]];
//    [_backView addSubview:imagesScrollView];
//    [imagesScrollView setContentSize:CGSizeMake(pageNumber*imageWidth, scrollViewHeight)];
    testView	= [[EasyTableView alloc] initWithFrame:CGRectMake(0.5, bgWidth/2,w,imageWidth-1) numberOfColumns:faceArr.count  ofWidth:imageWidth];
    testView.delegate	= self;
    testView.autoresizingMask	= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [bgView addSubview:testView];
    
    
    overlayView=[[UIView alloc] initWithFrame:CGRectMake(0,bgWidth/2, w, imageWidth)];
    [overlayView setBackgroundColor:UIColorFromRGBAlpha(OverlayViewColor, 0.5)];
//    overlayView.backgroundColor=[UIColor greenColor];
    [overlayView setExclusiveTouch:YES];
    //不设置会阻挡UIScrollView的滚动
    [overlayView setUserInteractionEnabled:NO];
    [bgView addSubview:overlayView];
    
    
    //滑块视图
    _sliderView=[[UIImageView alloc]initWithFrame:CGRectMake(0, bgWidth/2, maxWidth, imageWidth)];
    [_sliderView setBackgroundColor:[UIColor clearColor]];
    _sliderView.layer.borderColor=UIColorFromRGB(SystemColor).CGColor;
    _sliderView.layer.borderWidth=2.0f;
    _sliderView.layer.cornerRadius=5.0f;
    _sliderView.layer.masksToBounds=YES;
    _sliderView.userInteractionEnabled=NO;
    _sliderView.tag=SLIDER_TAG;
    [bgView addSubview:_sliderView];
    
    
    //给滑块添加手势
    UIPanGestureRecognizer *panRecognizerRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    [panRecognizerRight setMinimumNumberOfTouches:1];
    [panRecognizerRight setMaximumNumberOfTouches:1];
    
    
    UIPanGestureRecognizer *panRecognizerLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    [panRecognizerLeft setMinimumNumberOfTouches:1];
    [panRecognizerLeft setMaximumNumberOfTouches:1];
    sliderBorderLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    [sliderBorderLeft setFrame:CGRectMake(0,bgWidth/2, SLIDER_BORDER_WIDTH,imageWidth)];
    [sliderBorderLeft setImage:[UIImage imageNamed:@"record_cut_slider_left"] forState:UIControlStateNormal];
    [sliderBorderLeft setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 18)];
    sliderBorderLeft.userInteractionEnabled=YES;
    [sliderBorderLeft setExclusiveTouch:YES];
    sliderBorderLeft.tag=LEFT_TAG;
    [sliderBorderLeft setContentMode:UIViewContentModeLeft];
    [sliderBorderLeft.layer setMasksToBounds:YES];
    [bgView addSubview:sliderBorderLeft];
    
    if(videoDurtion>2){
        [sliderBorderLeft addGestureRecognizer:panRecognizerLeft];
    }
    
    //滑块的边界
    sliderBorderRight=[UIButton buttonWithType:UIButtonTypeCustom];
    [sliderBorderRight setFrame:CGRectMake(maxWidth-SLIDER_BORDER_WIDTH,bgWidth/2, SLIDER_BORDER_WIDTH,imageWidth)];
    [sliderBorderRight setImage:[UIImage imageNamed:@"record_cut_slider_left"] forState:UIControlStateNormal];
    [sliderBorderRight setImageEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 0)];
    sliderBorderRight.userInteractionEnabled=YES;
    sliderBorderRight.tag=RIGHT_TAG;
    [sliderBorderRight setContentMode:UIViewContentModeTopRight];
    [sliderBorderRight setExclusiveTouch:YES];
    [sliderBorderRight addGestureRecognizer:panRecognizerRight];
    [sliderBorderRight.layer setMasksToBounds:YES];
    [bgView addSubview:sliderBorderRight];
    
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, backHeight-40, w, 40)];
    [bottomView setBackgroundColor:[UIColor clearColor]];
    [_backView addSubview:bottomView];
    
    labelNumber1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 28)];
    [labelNumber1 setBackgroundColor:[UIColor clearColor]];
    [labelNumber1 setTextColor:UIColorFromRGB(TextSixColor)];
    [labelNumber1 setTextAlignment:NSTextAlignmentCenter];
    [labelNumber1 setFont:ListDetailFont];
    [labelNumber1 setText:@":00"];
    [bottomView addSubview:labelNumber1];
    
    labelNumber2=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 28)];
    [labelNumber2 setBackgroundColor:[UIColor clearColor]];
    [labelNumber2 setTextColor:UIColorFromRGB(TextSixColor)];
    [labelNumber2 setTextAlignment:NSTextAlignmentCenter];
    [labelNumber2 setFont:ListDetailFont];
    [labelNumber2 setText:@":05"];
    [bottomView addSubview:labelNumber2];
    
    
    labelNumber3=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 28)];
    [labelNumber3 setBackgroundColor:[UIColor clearColor]];
    [labelNumber3 setTextColor:UIColorFromRGB(TextSixColor)];
    [labelNumber3 setTextAlignment:NSTextAlignmentCenter];
    [labelNumber3 setFont:ListDetailFont];
    [labelNumber3 setText:@":10"];
    [bottomView addSubview:labelNumber3];
    
    
    labelNumber4=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 28)];
    [labelNumber4 setBackgroundColor:[UIColor clearColor]];
    [labelNumber4 setTextColor:UIColorFromRGB(TextSixColor)];
    [labelNumber4 setTextAlignment:NSTextAlignmentCenter];
    [labelNumber4 setFont:ListDetailFont];
    [labelNumber4 setText:@":15"];
    [bottomView addSubview:labelNumber4];
    
    
    int startX=25;
    int itemW=(w-startX*2)/3;
    [labelNumber1 setCenter:CGPointMake(startX, 14)];
    [labelNumber2 setCenter:CGPointMake(startX+itemW, 14)];
    [labelNumber3 setCenter:CGPointMake(startX+itemW*2, 14)];
    [labelNumber4 setCenter:CGPointMake(startX+itemW*3, 14)];
    
//    bgView.center=CGPointMake(SCREEN_WIDTH/2, (ScreenHeight-CGRectGetMaxY(_showImageView.frame)-CGRectGetMinY(labelNumber1.frame))/2);
    
    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, 28, w, 12)];
    [img setImage:[UIImage imageNamed:@"recort_cut_bottom_scale"]];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    [img.layer setMasksToBounds:YES];
    [bottomView addSubview:img];
}


/**
 * 0，滚动scrollview，1、左移动，2右移动
 **/
-(void)reSetScaleWithMove:(int) fromMove{
//    startTime=(CGRectGetMinX(_sliderView.frame)+imagesScrollView.contentOffset.x)/imagesScrollView.contentSize.width*videoDurtion;
    startTime=(CGRectGetMinX(_sliderView.frame)+contentOfSetPoint.x)/(pageNumber*imageWidth)*videoDurtion;
    
    NSLog(@"=========%f",startTime);
    if(fromMove>0){
        if(cutDurtion>MaxCMtime){
            cutDurtion=MaxCMtime;
            if(cutDurtion>videoDurtion){
                cutDurtion=videoDurtion;
            }
        }
        if(cutDurtion<2 && videoDurtion>2){
            cutDurtion=2;
        }
        if (cutDurtion>videoDurtion||CGRectGetMaxX(sliderBorderRight.frame)>CGRectGetMinX(bgView.frame)+imageWidth*pageNumber) {
            cutDurtion=videoDurtion-startTime;
        }
        
        
        CGFloat cutWidth;
        if (videoDurtion>=MaxCMtime-1) {
           cutWidth=secondWidth*cutDurtion;
        }
        else
        {
            //右滑块
            if (fromMove==2) {
                
                if (CGRectGetMaxX(sliderBorderRight.frame)>CGRectGetMinX(bgView.frame)+imageWidth*pageNumber) {
                    cutWidth=pageNumber*imageWidth-CGRectGetMinX(sliderBorderLeft.frame);

                }else
                {
                    cutWidth=CGRectGetMaxX(sliderBorderRight.frame)-CGRectGetMinX(sliderBorderLeft.frame);
                }
            }
            //左滑块
            else if(fromMove==1)
            {
            cutWidth=pageNumber*imageWidth-CGRectGetMinX(sliderBorderLeft.frame);
            }
           
            
            
        }
        


        CGRect f=_sliderView.frame;
        f.size.width=cutWidth;
        _sliderView.frame=f;
        
        CGRect rf=sliderBorderRight.frame;
        rf.origin.x=f.size.width+f.origin.x-rf.size.width;
        sliderBorderRight.frame=rf;
        
        
        //在滑动左滑块时控制——sliderview不滑出边界
        if (CGRectGetMaxX(_sliderView.frame)+20>CGRectGetMaxX(bgView.frame)&&cutDurtion<=2) {
           
            CGPoint  temp=_sliderView.center;
            
            temp.x=CGRectGetMaxX(bgView.frame)-_sliderView.frame.size.width+10;
            _sliderView.center=temp;
            
            CGRect rf1=sliderBorderRight.frame;
            rf1.origin.x=CGRectGetMaxX(_sliderView.frame)-rf1.size.width;
            sliderBorderRight.frame=rf1;
            
            CGRect rf2=sliderBorderLeft.frame;
            rf2.origin.x=CGRectGetMinX(_sliderView.frame);
            sliderBorderLeft.frame=rf2;

        }
        
    }
    
    if(fromMove==0){
        int st = videoDurtion * (contentOfSetPoint.x/(pageNumber*imageWidth));
        
        NSLog(@"--------------st%d",st);
        st = lroundf(st);
        [labelNumber1 setText:[self getTimeStringOfTimeInterval:st]];
        [labelNumber2 setText:[self getTimeStringOfTimeInterval:st+5]];
        [labelNumber3 setText:[self getTimeStringOfTimeInterval:st+10]];
        [labelNumber4 setText:[self getTimeStringOfTimeInterval:st+15]];
    }
    
    [self overlayClipping];
    [_showImageView setImage:[manager thumbnailImageForVideo:localURL atTime:startTime]];
}

//// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    WSLog(@"拖动停止");
//}
//
////减速停止
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    WSLog(@"减速停止");
//    float x=_sliderView.frame.origin.x;
//    startTime= videoDurtion * (imagesScrollView.contentOffset.x+x)/(imagesScrollView.contentSize.width);
//    
//    [self reSetScaleWithMove:0];
//}

// 滑块拖动
-(void)handelPan:(UIPanGestureRecognizer *)sender {
    
    UIImageView *selectedIMageView=(UIImageView *)[sender view];
    CGPoint translatedPoint = [sender translationInView:selectedIMageView];
    
    
    if (sender.state ==UIGestureRecognizerStateBegan)
    {
        direction = kCameraMoveDirectionNone;
        touchStart=selectedIMageView.center;
        touchStart=[self translateUsingTouchLocation:touchStart selectedView:selectedIMageView];
        startRect=selectedIMageView.frame;
    }
    else if (sender.state == UIGestureRecognizerStateChanged && direction == kCameraMoveDirectionNone)
    {
   
        WSLog(@"sx=%f,selectX=%f===%f",startRect.origin.x,selectedIMageView.frame.origin.x,cutDurtion);
        //右移动
        if(startRect.origin.x<selectedIMageView.frame.origin.x){
            WSLog(@"右移动");
            if(selectedIMageView.tag==RIGHT_TAG && cutDurtion>MaxCMtime){
                WSLog(@"右边。。1");
                return;
            }else if(selectedIMageView.tag==LEFT_TAG && cutDurtion<2){
                WSLog(@"右边。。2");
                return;
            }
        }
        
        //左移动
        if(startRect.origin.x>selectedIMageView.frame.origin.x){
            WSLog(@"左移动");
            if(selectedIMageView.tag==RIGHT_TAG && cutDurtion<2){
                return;
            }else if(selectedIMageView.tag==LEFT_TAG && cutDurtion>MaxCMtime){
                return;
            }
        }
        
        
        CGRect rect=_sliderView.frame;
        translatedPoint = CGPointMake(touchStart.x+translatedPoint.x,selectedIMageView.center.y);

        
        
        
        //让view跟随
        [selectedIMageView setCenter:[self translateUsingTouchLocation:translatedPoint selectedView:selectedIMageView]];
        
        
        //右滑块
        if (selectedIMageView.tag==RIGHT_TAG) {
            rect.origin.x=CGRectGetMinX(sliderBorderLeft.frame);
            rect.size.width=CGRectGetMaxX(sliderBorderRight.frame)-CGRectGetMinX(sliderBorderLeft.frame);
            _sliderView.frame=rect;
            
        }
        
        //左滑块
        else if(selectedIMageView.tag==LEFT_TAG)
        {
            

            rect.origin.x=CGRectGetMinX(selectedIMageView.frame);
            rect.size.width=CGRectGetMaxX(sliderBorderRight.frame)-CGRectGetMinX(sliderBorderLeft.frame);
            _sliderView.frame=rect;
            
        }
      
         startTime=(CGRectGetMinX(_sliderView.frame)+contentOfSetPoint.x)/(pageNumber*imageWidth)*videoDurtion;
        cutDurtion=15*_sliderView.frame.size.width/w;
        
        [self overlayClipping];
    }
    
    else if (sender.state ==UIGestureRecognizerStateEnded)
    {
        [self setPlayProgress];
        if(selectedIMageView.tag==RIGHT_TAG){
            
            [self reSetScaleWithMove:2];
            
            [btnPlay setHidden:NO];
        }else{
            [self reSetScaleWithMove:1];
            [btnPlay setHidden:NO];
        }
        
        
    }
}

-(void)doStartPlay:(UIButton *) sender{
    [_player play];
    [_player setCurrentPlaybackTime:startTime];
    [btnPlay setHidden:YES];
}

-(void) setPlayProgress{
    CGFloat ctime = (CGFloat)_player.currentPlaybackTime;
    if(ctime>(startTime+cutDurtion)){
        [_player stop];
        [btnPlay setHidden:NO];
        [playerStop invalidate];
    }
}
/*
 @method 当前可以获取到总时长
 */
-(void)MovieDurationCallback:(NSNotification*)notify
{
    NSLog(@"可以获取长度了");
    playerStop=[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(setPlayProgress) userInfo:nil repeats:YES];
}

-(void)movieLoadStateChange:(NSNotification *)notification
{
    if(_player.loadState==3){
        [_player setCurrentPlaybackTime:startTime];
    }
}




- (CGPoint)translateUsingTouchLocation:(CGPoint)touchPoint selectedView:(UIImageView *)imageView {
    CGPoint newCenter = touchPoint;//CGPointMake(contentView.center.x + touchPoint.x - touchStart.x,contentView.center.y + touchPoint.y - touchStart.y);
    
    // Ensure the translation won't cause the view to move offscreen.
//    if (newCenter.x < dragView.bounds.size.width/2) {
//        newCenter.x = dragView.bounds.size.width/2;
//    }
    
    //控制滑块不超出屏幕
    if (newCenter.x > (w-imageView.bounds.size.width/2)) {
        newCenter.x = w-imageView.bounds.size.width/2;
    }
    else if(newCenter.x<imageView.bounds.size.width/2)
    {
        newCenter.x=imageView.bounds.size.width/2;
    }
    return newCenter;
}


-(IBAction)buttonClick:(UIButton *)sender{
    
    if(sender.tag==BACK_BUTTON){
        [_player stop];
        
        [self goBack:nil];
    }
    if(sender.tag==RIGHT_BUTTON){
        [SVProgressHUD showWithStatus:Video_Message maskType:SVProgressHUDMaskTypeNone];

        //如果没有压缩完，不能裁切
        if (localURL) {
//            [manager cutVideosAtFileURLs:localURL startSecond:startTime lengthSeconds:cutDurtion succes:^(NSURL *cutfileURL, CGFloat duration, NSError *error) {
//                if([SVProgressHUD isVisible ]){
//                    [SVProgressHUD dismiss];
//                }
//                WSLog(@"buttonClick:剪切后的路径%@",cutfileURL.path);
//                TEditMediaController *edit=[[TEditMediaController alloc] init];
//                edit.filePath= cutfileURL.path ;
//                [self.navigationController pushViewController:edit animated:YES];
//            } fail:^(NSURL *fileURL, NSError *error) {
//                [SVProgressHUD showErrorWithStatus:@"视频格式不识别！" duration:2];
//            }];
        
            [manager videoToTempFile:localURL finish:^(NSString *filePath) {
                NSURL *tempUrl=[NSURL fileURLWithPath:[self getVideoTempPath]];
                [manager convertVideoToLowQuailtyWithInputURL:[NSURL fileURLWithPath:filePath] outputURL:tempUrl handler:^(AVAssetExportSession *hander) {
                    
                    if (hander.status==AVAssetExportSessionStatusCompleted) {
                        [FFmpegClipVideo clipVideoDuration:tempUrl.path begin:startTime duration:cutDurtion block:^(NSString *clipVideoPath, double duration, NSError *error) {
                            if([SVProgressHUD isVisible ]){
                                [SVProgressHUD dismiss];
                            }
                            NSFileManager *fm = [[NSFileManager alloc] init];
                            if (![fm fileExistsAtPath:clipVideoPath]) {
                                [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_Video file does not identify") duration:1];
                                return ;
                            }else{
                                WSLog(@"buttonClick:剪切后的路径%@",clipVideoPath);
                                TEditMediaController *edit=[[TEditMediaController alloc] init];
                                edit.filePath= clipVideoPath;
                                [self.navigationController pushViewController:edit animated:YES];
                            }
                        }];

                    }
                    else
                    {
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_Video processing failure") duration:1];
                    }
                    
                }];
                
                
            } fail:^(NSString *filePath, NSError *error) {
                
            }];

        }else{
            if([SVProgressHUD isVisible ]){
                [SVProgressHUD dismiss];
            }
            [self showNoticeWithMessage:TTLocalString(@"TT_Video file to extract failure") message:@"" bgColor:TopNotice_Red_Color];
        }
    }
}


// 隐藏状态栏 for ios 7
- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    
    //可以获取视频时长了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MovieDurationCallback:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateChange:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:_player];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


-(void)viewWillDisappear:(BOOL)animated{
    if([SVProgressHUD isVisible ]){
        [SVProgressHUD dismiss];
    }
    [_player stop];
    
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    WSLog(@"内存警告:");
}


-(NSString *)getVideoTempPath{
    return [NSString stringWithFormat:@"%@%@",getTempVideoPath(),@"temp.mp4"];
}


- (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    
    NSDateComponents *components = [calendar components:uFlags
                                               fromDate:dateRef
                                                 toDate:dateNow
                                                options:0];
    NSString *retTimeInterval;
    if (components.hour > 0)
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)components.second];
    }
    
    else
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)components.second];
    }
    return retTimeInterval;
}



//遮盖层
- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        _sliderView.frame.origin.x,
                                        scrollViewHeight));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(_sliderView.frame.origin.x + _sliderView.frame.size.width,
                                        0,
                                        overlayView.frame.size.width - _sliderView.frame.origin.x - _sliderView.frame.size.width,
                                        overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        overlayView.frame.size.width,
                                        2));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        _sliderView.frame.origin.y + _sliderView.frame.size.height,
                                        overlayView.frame.size.width,
                                        overlayView.frame.size.height - _sliderView.frame.origin.y + _sliderView.frame.size.height));
    maskLayer.path = path;
    overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}


#pragma mark-easyTableViewDelegate
-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section

{
    
    return faceArr.count;
    
}



-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect

{
    
    UIImageView *test=[[UIImageView alloc]initWithFrame:rect];
    test.contentMode=UIViewContentModeScaleAspectFill;
    
    return test;
    
}



-(void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath

{
    
    UIImageView *v=(UIImageView *)view;
    
    v.image=[UIImage imageWithData:[faceArr objectAtIndex:indexPath.row]];
    
    
    
}

-(void)easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset

{
    
    
    
    contentOfSetPoint=contentOffset;
    
    NSLog(@"-------------------%@",NSStringFromCGPoint(contentOffset));
    
    float x=_sliderView.frame.origin.x;
    
    //
    
    startTime=(contentOffset.x+x)/(pageNumber *imageWidth)*videoDurtion;
    
    NSLog(@"%f",videoDurtion);
    
    NSLog(@"---------------%f",startTime);
    
    [self reSetScaleWithMove:0];
    
}



@end
