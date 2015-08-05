//
//  RecordViewController.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-5.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "RecordViewController.h"
#import "TEditMediaController.h"
#import "recordingProgressView.h"
#import "ChoosePickerController.h"
#import "VPImageCropperViewController.h"
#import "ChooseVideoManager.h"
#import "ReleasePicViewController.h"
#import "releaseCommentViewController.h"

#import "MusicSelectController.h"

#define WIDTH   [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
#define deleteBtnTag 9
#define okBtnTag 10
#define RULE_TIME 2

@interface RecordViewController ()

{
    int w;
    int h;

    UIImage *videoPhoto;
    UIImage *firstImage;
    BOOL isRecording;   //是否是录制状态
    BOOL allowLight;    //是否允许闪关灯，默认为YES
    BOOL isPauseRecord;
    CALayer *layer;
    UILabel *lightLabel;
    int slightModeNum;

    UIButton *playButton;
    
    BOOL isPhotoState;  //是否是拍照模式 ，默认为YES
    

    
}

@property(nonatomic,strong) recordingProgressView *progressView;
@property(nonatomic,assign) BOOL beyondRuletTime;   //是否超过录制的最短规定时间，默认为NO
@property(nonatomic,assign) int videoDurtion;  //记录视频时长

@property(nonatomic,assign) BOOL isFinish;


@end

@implementation RecordViewController

- (void)viewDidLoad {
    
    
    
    [super viewDidLoad];
    

    
    // Do any additional setup after loading the view.
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    allowLight=YES;
    isPhotoState=YES;
    if (isPhotoState) {
        isRecording=NO;
    }
    else
    {
        isRecording=YES;
    }
    _beyondRuletTime=NO;
    
    
    //初始化为暂停状态
    isPauseRecord=YES;
    
    self.isFinish=NO;
    
    [self.view setBackgroundColor:UIColorFromRGB(BackgroundRecordColor)];
    
    //初始化按钮
    [self createView];
    
    //录制
    [self recordEvent];
    
    __weak typeof(self) myself=self;
    self.rcManager.failedBlock=^{
        NSLog(@"处理失败拉");

        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:TTLocalString(@"TT_Video processing failure")];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [myself.navigationController popToRootViewControllerAnimated:YES];
        });
    };
    
    
    //如果是照片，需要设置为yes，改为高清图片
    // 必须在初始化_rcManager后面调用
    [_rcManager changePicture:YES];
}

-(void)recordEvent
{
    
    //初始化录制界面
    self.rcManager=[[RCCaptureSessionManager alloc] init];
    [self.rcManager configureWithParentLayer:self.cameraShowView];
    
    __block RecordViewController *myself=self;   //防止 retain cycle
    
    //开始 和结束录制调用
    [self.rcManager setStartRecord:^(NSURL *fileURL, NSError *error) {
        
    } endRecordBlock:^(NSURL *fileURL, NSError *error) {
        
        if([SVProgressHUD isVisible]){
            [SVProgressHUD dismiss];
        }
        
        
        //执行跳转
        myself.isFinish=NO;
        
        WSLog(@"视频路径：%@",fileURL.path);
        TEditMediaController *edit=[[TEditMediaController alloc] init];
        edit.filePath=fileURL.path;

        [myself.navigationController pushViewController:edit animated:YES];
    }];
    
   
    
    //进度条
    [self.rcManager setProgressBlock:^(CGFloat duration, int videoNumber) {
        //如果点击过快，导致视频数组里为空

    
        CGFloat progress=(CGFloat)duration/MaxCMtime;
        [myself.progressView changeProgressViewFrame:progress];
        
        if (duration>=RULE_TIME) {
            
            myself.videoDurtion=duration;
        
            myself.beyondRuletTime=YES;
            
            [myself buttonHidden:NO];

        }
        
        NSLog(@"---------%f",duration);
    }];
    
    
    //时长超过8秒调用
    self.rcManager.valueBlock=^(void){

        myself.isFinish=YES;
        //改变录制按钮状态
        UIButton *btn=(UIButton *)[myself.view viewWithTag:DOWN_BTNTAG2];
        [btn setImage:[UIImage imageNamed:@"record_wait_nor"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"record_wait_sel"] forState:UIControlStateHighlighted];
        
        
        [SVProgressHUD showWithStatus:Video_Message maskType:SVProgressHUDMaskTypeNone];
        
    };
}








#pragma mark-按钮点击事件
-(void)buttonHidden:(BOOL) isHidden
{
    [[self.view viewWithTag:okBtnTag] setHidden:isHidden];
    
    [[self.view viewWithTag:deleteBtnTag] setHidden:isHidden];
    
    
    [[self.view viewWithTag:DOWN_BTNTAG1] setHidden:YES];
    [[self.view viewWithTag:DOWN_BTNTAG3] setHidden:YES];
}


-(IBAction)buttonClick:(UIButton *)sender{
    WSLog(@"点击功能按钮:%ld",(long)sender.tag);
    
    //删除录制的视频
    if (sender.tag==deleteBtnTag) {
        
        [self deleteVideo];
        
        }
    
    //录制完成
    if (sender.tag==okBtnTag) {
        //删除仅测试使用
        [self finishedRecorder];
        
    }
    
    //回到上级界面
    if(sender.tag==BACK_BUTTON){
        [self.rcManager stopRunning];
        [self.rcManager pauseRecord];
        [self.rcManager cleanRecord];
        
        [self goBack:sender];
      
    }
    
    // 闪光灯
    if(sender.tag==RIGHT_BUTTON){
        [self lightState];
    }
    
    //切换前后摄像头
    if(sender.tag==OTHER_BUTTON){
        
        [self changeCameraDirection];
     }
    
    //左侧按钮,选择视频
    if(sender.tag==DOWN_BTNTAG1){
        
        [self photoOrVideo];  //选择照片和视频
    }
    
    
    //录像、拍照
    if(sender.tag==DOWN_BTNTAG2){
        
        if (isRecording) {
            //摄像
             [self recordingVideo:sender];
       
        }else{
            
            [self.rcManager takePicture:^(UIImage *stillImage) {
                NSLog(@"%@",stillImage);

//                ReleasePicViewController *release=[[ReleasePicViewController alloc] init];
//                release.releaseImage=stillImage;
//                release.pageType=1;
//                [self.navigationController pushViewController:release animated:YES];
                releaseCommentViewController *rc=[[releaseCommentViewController alloc]init];
                rc.passUserImage=stillImage;
                rc.pageType=PhotoType;
                [self.navigationController pushViewController:rc  animated:YES];
            }];
            //拍照
            NSLog(@"拍摄照片");
        }
        
       
        
        }
    

    //切换录像、拍照
    if(sender.tag==DOWN_BTNTAG3){
        [self transferPhotoAndVideo:sender];
    }
    
}

#pragma mark -切换  录像拍照
//切换录像，拍照
-(void)transferPhotoAndVideo:(UIButton *)sender
{
    UIButton *transfer=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG3];
    
    UIButton *recordBtn=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG2];
    
    UIButton *videoBtn=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG1];

    sender.selected=!sender.selected;
    if (sender.selected) {
        isPhotoState=YES;
        [_rcManager changePicture:YES];

        //切换到拍照
        [recordBtn setImage:[UIImage imageNamed:@"record_photo_nor"] forState:UIControlStateNormal];
        [recordBtn setImage:[UIImage imageNamed:@"record_photo"] forState:UIControlStateHighlighted];
        
        [videoBtn setImage:[UIImage imageNamed:@"record_go_photo_nor"] forState:UIControlStateNormal];
        [videoBtn setImage:[UIImage imageNamed:@"record_go_photo"] forState:UIControlStateHighlighted];
//        layer.cornerRadius=0;
        
        
        
        transfer.frame=CGRectMake(0, 0, 44, 27);
        transfer.center=CGPointMake(WIDTH-60, recordBtn.center.y);
        [transfer setImage:[UIImage imageNamed:@"record_button_nor"] forState:UIControlStateNormal];

        if (firstImage) {
            [videoBtn setImage:firstImage forState:UIControlStateNormal];
            [videoBtn setImage:firstImage forState:UIControlStateHighlighted];
        }
        
        //进度条闪烁
        [_progressView stopSlight];
        
        //隐藏播放视图
        [playButton setHidden:YES];
    }
    else
    {
        //切换到录像
        isPhotoState=NO;
        [_rcManager changePicture:NO];
        
        [recordBtn setImage:[UIImage imageNamed:@"record_wait_nor"] forState:UIControlStateNormal];
        [recordBtn setImage:[UIImage imageNamed:@"record_wait_sel"] forState:UIControlStateHighlighted];
        layer.cornerRadius=8;
//            [[ChooseVideoManager getInstance]getLastImage:^(UIImage *img) {
//
        if (videoPhoto) {
            videoBtn=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG1];
            [videoBtn setImage:videoPhoto forState:UIControlStateNormal];
            [videoBtn setImage:videoPhoto forState:UIControlStateHighlighted];

        }
           //
//        } filterType:FilterVideo];
        
        
        transfer.frame=CGRectMake(0, 0, 44, 38);
        transfer.center=CGPointMake(WIDTH-60, recordBtn.center.y);
        
        [transfer setImage:[UIImage imageNamed:@"record_button_nor"] forState:UIControlStateNormal];

        [transfer setImage:[UIImage imageNamed:@"record_takePhoto"] forState:UIControlStateNormal];

        [_progressView startSlight];

        [playButton setHidden:NO];
        
    }
    
    isRecording=!isRecording;  //转到拍照模式

}

//删除视频
-(void)deleteVideo
{
    [self.rcManager pauseRecord];
    if (self.rcManager.isrecording) {
        //  点了暂停走到代理需要一点时间，在将url添加到数组之前已经走完了clean数组的函数，导致有一条url无法清除，所以延迟处理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.rcManager cleanRecord];
                
            });
            
        });

    }
    else
    {
        
    [self.rcManager cleanRecord];
        
    }
    
    
    [self.rcManager resetTheDurtion];
    
    [_progressView changeProgressViewFrame:0];
    _beyondRuletTime=NO;
    
    [self buttonHidden:YES];
    playButton.hidden=NO;
    isPauseRecord=YES;
    if (!_progressView.lightState) {
        
        [_progressView startSlight];
    }
    [[self.view viewWithTag:DOWN_BTNTAG1] setHidden:NO];
    [[self.view viewWithTag:DOWN_BTNTAG3] setHidden:NO];
    
    UIButton *btn=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG2];
    [btn setImage:[UIImage imageNamed:@"record_wait_nor"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"record_wait_sel"] forState:UIControlStateHighlighted];

}

//切换到拍照状态下
-(void)photoOrVideo
{
    if (isRecording){
        //视频
        LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:nil delegate:self otherButton:@[TTLocalString(@"TT_Processing the local photo"),TTLocalString(@"TT_Local video processing")] cancelButton:TTLocalString(@"TT_cancel")];
        [sheet showInView:nil];
    }
    else{
        //照片
        ChoosePickerController *picker = [[ChoosePickerController alloc] init];
        picker.maximumNumberOfSelectionVideo = 0;
        picker.maximumNumberOfSelectionPhoto = 2;
        [self.navigationController pushViewController:picker animated:YES];
    }
}

//录制视频
-(void)recordingVideo:(UIButton *)sender
{
    if(self.rcManager.isrecording && !isPauseRecord){
        

        isPauseRecord=YES;
        
//        [self buttonHidden:NO];
        
        if (!_beyondRuletTime) {
            [[self.view viewWithTag:okBtnTag] setHidden:YES];
        }
        
        //停止录制
        [self.rcManager pauseRecord];
        
        [_progressView startSlight];
        
        [sender setImage:[UIImage imageNamed:@"record_wait_nor"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"record_wait_sel"] forState:UIControlStateHighlighted];
    }else{
        if(!isPauseRecord){
            return;
        }
        
        isPauseRecord=NO;
//        [self buttonHidden:YES];
        [[self.view viewWithTag:DOWN_BTNTAG1] setHidden:YES];
        [[self.view viewWithTag:DOWN_BTNTAG3] setHidden:YES];

        //开始录制
        [self.rcManager startRecord];
        [playButton setHidden:YES];
        [_progressView stopSlight];

        [sender setImage:[UIImage imageNamed:@"record_run_nor"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"record_run_sel"] forState:UIControlStateHighlighted];
    }

}

//闪关灯
-(void)lightState
{
    
    slightModeNum+=1;
    int num=slightModeNum%=3;
    NSLog(@"%d",num);
//    UIButton *light=(UIButton *)[self.view viewWithTag:RIGHT_BUTTON];
    
    if (num==0) {
        [self.rcManager openTorch:slightAuto];
            lightLabel.text=TTLocalString(@"TT_auto");
    }
    if (num==1) {
        [self.rcManager openTorch:slightOn];
        lightLabel.text=TTLocalString(@"TT_open");

    }
    if (num==2) {
        [self.rcManager openTorch:slightOff];
        lightLabel.text=TTLocalString(@"TT_close");

    }
}


//录制完成按钮事件
-(void)finishedRecorder
{
    if(!self.isFinish){
        self.isFinish=YES;
        
        [SVProgressHUD showWithStatus:Video_Message maskType:SVProgressHUDMaskTypeNone];
        [self.rcManager endRecord];
        
        if([SVProgressHUD isVisible]){
            return;
        }
        
        
    }

}

//切换前后摄像头
-(void)changeCameraDirection
{
    //前置摄像头则隐藏闪关灯
    UIButton *light=(UIButton *)[self.view viewWithTag:RIGHT_BUTTON];
    
    if (allowLight) {
        [light setHidden:YES];
        [lightLabel setHidden:YES];
    }
    else{
        [light setHidden:NO];
        [lightLabel setHidden:NO];
    }
    [self.rcManager swapFrontAndBackCameras];
    
    allowLight=!allowLight;

}


-(void)createView{

    
    if (HEIGHT==480) {
        self.cameraShowView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, w+45)];

    }else
    {
        self.cameraShowView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, w+90)];

    }
    
    [self.cameraShowView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.cameraShowView];
    
    
    //添加蒙层
    UIView *topCoverView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 45)];
    topCoverView.backgroundColor=UIColorFromRGB(coverViewColor);
    topCoverView.userInteractionEnabled=YES;
    topCoverView.alpha=0.7;
    [self.view addSubview:topCoverView];
    
    
    UIView *bottomCoverView=[[UIView alloc]initWithFrame:CGRectMake(0,45+WIDTH, WIDTH, 45)];
    bottomCoverView.backgroundColor=UIColorFromRGB(coverViewColor);
    bottomCoverView.alpha=0.7;
    [self.view addSubview:bottomCoverView];
    
    if (HEIGHT==480) {
        
        bottomCoverView.hidden=YES;
    }
    
    //设置进度条
    if (HEIGHT==480) {
        _progressView=[[recordingProgressView alloc]initWithFrame:CGRectMake(0, WIDTH+45-6, WIDTH, 6) backgroundColor:UIColorFromRGB(ProgressBackColor) movingProgressColor:UIColorFromRGB(SystemColor)];
    }
    else
    {
        _progressView=[[recordingProgressView alloc]initWithFrame:CGRectMake(0,WIDTH+90-4, WIDTH, 6) backgroundColor:UIColorFromRGB(ProgressBackColor) movingProgressColor:UIColorFromRGB(SystemColor)];
    }
    
    _progressView.targetProgress=1;
    if (!isPhotoState) {
        [_progressView startSlight];
    }
    [self.view addSubview:_progressView];
    
    
   
    
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    backBtn.tag=BACK_BUTTON;
    [backBtn setFrame:CGRectMake(0,0, 45, 45)];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];

    [backBtn setImage:[UIImage imageNamed:@"record_close_nor"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"record_close"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    CGFloat centerY=backBtn.frame.origin.y+CGRectGetHeight(backBtn.frame)/2;
    
    UIButton *changeCameraBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [changeCameraBtn setBackgroundColor:[UIColor clearColor]];
    changeCameraBtn.tag=OTHER_BUTTON;
    [changeCameraBtn setFrame:CGRectMake(0,0, 45,45)];
    [changeCameraBtn setImageEdgeInsets:UIEdgeInsetsMake(11, 2, 12, 15)];
    CGPoint changeCenter=CGPointMake(WIDTH-CGRectGetWidth(changeCameraBtn.frame)/2, centerY);
    //    [changeCameraBtn setImageEdgeInsets:UIEdgeInsetsMake(9.5, 0, 9.5, 15)];
    changeCameraBtn.center=changeCenter;
    [changeCameraBtn setImage:[UIImage imageNamed:@"record_camera_change_nor"] forState:UIControlStateNormal];
    [changeCameraBtn setImage:[UIImage imageNamed:@"record_camera_change"] forState:UIControlStateHighlighted];
    [changeCameraBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeCameraBtn];
    

    lightLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 28, 15)];
    lightLabel.center=CGPointMake(changeCenter.x-30-lightLabel.frame.size.width,centerY);
    lightLabel.textColor=[UIColor whiteColor];
    lightLabel.font=[UIFont systemFontOfSize:13];
    lightLabel.text=TTLocalString(@"TT_auto");
    [self.view addSubview:lightLabel];

    
    
    UIButton *lightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [lightButton setBackgroundColor:[UIColor clearColor]];
    lightButton.tag=RIGHT_BUTTON;
    [lightButton setFrame:CGRectMake(0, 0, 45, 45)];
    [lightButton setImageEdgeInsets:UIEdgeInsetsMake(12, 16, 13, 16)];
    lightButton.center=CGPointMake(CGRectGetMinX(lightLabel.frame)-CGRectGetWidth(lightLabel.frame)/2, centerY);
//    [lightButton setImageEdgeInsets:UIEdgeInsetsMake(9, 18, 9, 0)];
    [lightButton setImage:[UIImage imageNamed:@"record_light_nor"] forState:UIControlStateNormal];
    [lightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightButton];
    
    
 
    
    CGFloat recordCenterY=CGRectGetMaxY(_progressView.frame)+(HEIGHT-CGRectGetMaxY(_progressView.frame))/2;

    
    UIButton *goPhotoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [goPhotoBtn setBackgroundColor:[UIColor clearColor]];
    goPhotoBtn.tag=DOWN_BTNTAG1;
    [goPhotoBtn setFrame:CGRectMake(0, 0, 44, 44)];
    goPhotoBtn.center=CGPointMake(60, recordCenterY);

        [goPhotoBtn setImage:[UIImage imageNamed:@"record_go_photo_nor"] forState:UIControlStateNormal];
        [goPhotoBtn setImage:[UIImage imageNamed:@"record_go_photo"] forState:UIControlStateHighlighted];

    
    
    layer=[goPhotoBtn layer];
    [layer setMasksToBounds:YES];
    layer.cornerRadius=8;
    layer.borderWidth=1;
    layer.borderColor=[UIColor clearColor].CGColor;
//    [goPhotoBtn setImage:[UIImage imageNamed:@"record_go_photo"] forState:UIControlStateHighlighted];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[ChooseVideoManager getInstance]getLastImage:^(UIImage *img) {
            WSLog(@"走完一个：。。。。%@",img);
            dispatch_async(dispatch_get_main_queue(), ^{
                firstImage=img;
                if(isPhotoState){
                    [goPhotoBtn setImage:firstImage forState:UIControlStateNormal];
                    [goPhotoBtn setImage:firstImage forState:UIControlStateHighlighted];
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //获取相册最新的视频封面，获取时间较长  1s-2s，后台处理
                    [[ChooseVideoManager getInstance] getLastImage:^(UIImage *img) {
                        WSLog(@"走完第二个：。。。。%@",img);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            videoPhoto=img;
                            if(!isPhotoState){
                                [goPhotoBtn setImage:videoPhoto forState:UIControlStateNormal];
                                [goPhotoBtn setImage:videoPhoto forState:UIControlStateHighlighted];
                            }
                            
                        });
                        
                    } filterType:FilterVideo];
                });
            });
        } filterType:FilterPhoto];
    });

    
    [goPhotoBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goPhotoBtn];
    
    //添加播放视图
    playButton=[[UIButton alloc]initWithFrame:goPhotoBtn.frame];
    [playButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [playButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    playButton.tag=DOWN_BTNTAG1;
    [playButton setImage: [UIImage imageNamed:@"record_play_nor"]forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateHighlighted];
    [self.view addSubview:playButton];
    
    UIButton *recordBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setBackgroundColor:[UIColor clearColor]];
    recordBtn.tag=DOWN_BTNTAG2;
    [recordBtn setFrame:CGRectMake(0, 0, 81, 81)];
    recordBtn.center=CGPointMake(WIDTH/2, recordCenterY);
    if (isPhotoState) {
        [recordBtn setImage:[UIImage imageNamed:@"record_photo_nor"] forState:UIControlStateNormal];
        [recordBtn setImage:[UIImage imageNamed:@"record_photo"] forState:UIControlStateHighlighted];
    }
    else
    {
    [recordBtn setImage:[UIImage imageNamed:@"record_wait_nor"] forState:UIControlStateNormal];
    [recordBtn setImage:[UIImage imageNamed:@"record_wait_sel"] forState:UIControlStateHighlighted];
    }
    [recordBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
    
    
    UIButton *changeMediaBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [changeMediaBtn setBackgroundColor:[UIColor clearColor]];
    changeMediaBtn.tag=DOWN_BTNTAG3;
    [changeMediaBtn setFrame:CGRectMake(0, 0, 44, 38)];
    changeMediaBtn.center=CGPointMake(WIDTH-60, goPhotoBtn.center.y);
    if (isPhotoState) {
    [changeMediaBtn setImage:[UIImage imageNamed:@"record_button_nor"] forState:UIControlStateNormal];
    changeMediaBtn.frame=CGRectMake(0, 0, 44, 27);
    changeMediaBtn.center=CGPointMake(WIDTH-60, recordBtn.center.y);
    changeMediaBtn.selected=YES;

    }
    else
    {
    [changeMediaBtn setFrame:CGRectMake(0, 0, 44, 38)];
    changeMediaBtn.center=CGPointMake(WIDTH-60, goPhotoBtn.center.y);
    [changeMediaBtn setImage:[UIImage imageNamed:@"record_takePhoto"] forState:UIControlStateNormal];
    }
//    [changeMediaBtn setImage:[UIImage imageNamed:@"record_button_nor"] forState:UIControlStateSelected];
    [changeMediaBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeMediaBtn];
    
    
    //-----------删除 完成按钮
    UIButton *deleteBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundColor:[UIColor clearColor]];
    deleteBtn.tag=deleteBtnTag;
    [deleteBtn setFrame:CGRectMake(0,0,44,44)];
    deleteBtn.center=CGPointMake(60, recordBtn.center.y);
    [deleteBtn setImage:[UIImage imageNamed:@"record_delete"] forState:UIControlStateNormal];
//    [deleteBtn setImage:[UIImage imageNamed:@"record_delete"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.hidden=YES;
    [self.view addSubview:deleteBtn];
    
    UIButton *okBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setBackgroundColor:[UIColor clearColor]];
    okBtn.tag=okBtnTag;
    okBtn.hidden=YES;
    [okBtn setFrame:CGRectMake(0, 0,44, 44)];
    okBtn.center=CGPointMake(WIDTH-60, recordBtn.center.y);
    [okBtn setImage:[UIImage imageNamed:@"record_finish_nor"] forState:UIControlStateNormal];
    [okBtn setImage:[UIImage imageNamed:@"record_finish"] forState:UIControlStateHighlighted];
    [okBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
}



// 隐藏状态栏 for ios 7
- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)appearState
{
    if (isPhotoState) {
        [playButton setHidden:YES];
    }
    else
    {
        [playButton setHidden:NO];
        
    }
    [_progressView changeProgressViewFrame:0];
    
    _beyondRuletTime=NO;
    
    isPauseRecord=YES;
    
    UIButton *photo=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG1];
    UIButton *media=(UIButton *)[self.view viewWithTag:DOWN_BTNTAG3];
    
    [self buttonHidden:YES];
    
    [photo setHidden:NO];
    [media setHidden:NO];
    
    self.navigationController.navigationBarHidden=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.rcManager startRunning];
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self appearState];
    // for ios 6
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    // 必须放在前面
    [self.rcManager stopRunning];
    
    [super viewWillDisappear:animated];

    
    [self.rcManager resetTheDurtion];
    
    self.navigationController.navigationBarHidden=NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    WSLog(@"内存警告:");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma -mark LXActionSheetDelegate

- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    switch (buttonIndex) {
        case 0:
        {
            //加工本地照片
            PhotoAlbumController *photoAlbum=[[PhotoAlbumController alloc]init];
            [self.navigationController pushViewController:photoAlbum animated:YES];
        }
            break;
        case 1:
        {
            //加工本地视频
            ChoosePickerController *picker = [[ChoosePickerController alloc] init];
            picker.maximumNumberOfSelectionVideo = 2;
            picker.maximumNumberOfSelectionPhoto = 0;
            [self.navigationController pushViewController:picker animated:YES];
        }
            break;
        case 2:
            //取消
            break;
            
        default:
            break;
    }
}

@end
