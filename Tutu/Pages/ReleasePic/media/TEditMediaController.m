//
//  TEditMediaController.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TEditMediaController.h"
#import "UIView+Border.h"
#import "TutuPlayerView.h"
#import "SelectMusicView.h"
#import "SelectPhotoView.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceManager.h"
#import "recordingProgressView.h"
#import "RCCaptureSessionManager.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
//#import "FFmpegSaveImage.h"
#import "FFmpegSynthAudio.h"
#import "TTplayView.h"
#import "PhotoAlbumController.h"
#import "ImagesToVideo.h"
#import "releaseCommentViewController.h"

//选择系统声音
#import "MusicSelectController.h"

#define VoiceViewHeight 190
#define HEIGHTSPACE 60

#define VOICE_DELETEBTN_TAG 19
#define VOICE_BTN_TAG 20
#define VOICE_OKBTN_TAG 21

#define LINE_WIDTH 1

#define WIDTH   [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
@interface TEditMediaController()<clickDelegate,AVAudioPlayerDelegate,LXActionSheetDelegate,MusicSelectDelegate>
{
    int w;
    int h;
    int selectedPhotoNum;
    CGFloat videoDurtion;   //视频时长
    SelectPhotoView *sliderPhotoView;

    SelectMusicView *sliderMusicView;
//    TutuPlayerView *mediaView;
    TTplayView *ttMediaView;
    
    recordingProgressView *progressView;
    
    RCCaptureSessionManager *manager;
    
    
    
    UIImageView *showImage;   //图片展示
    
    NSMutableArray *fitArrayUrl;    //当录音时长大于视频时长，增加数组里图片
    NSMutableArray *audioPlayArray;   //本地音乐资源
    NSArray *audioPhotoArray;        //本地音乐封面资源
    NSString *selectedAudioPath;    //选中的音乐路径
    
    UIButton *faceButton;     //封面
    UIButton *voiceButton;   //配乐
    NSString *tempPath;
    NSMutableArray *imagesArr;
    UIImageView *lastCheckView;
    
    bool isMusicSelect;  //显示配乐视图  默认为YES
    
    
    
    //录音
    VoiceManager *TEVoiceManager;
    UIView *voiceView;
    UILabel *voiceTimeLabel;
    CGFloat sumTime;   //录音的总时间
    
    NSTimer *voiceTimer;
    BOOL prepareRecording;   //默认为NO
    BOOL isRecording;       //录音状态  默认为NO
    BOOL isRecordPause;
    BOOL hideBoard;          //默认YES
    
}

@end

@implementation TEditMediaController

- (instancetype)init
{
    self=[super init];
    if (self) {
        _arrayImage=[[NSMutableArray alloc]init];
        imagesArr=[[NSMutableArray alloc]init];
        fitArrayUrl=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initMusicSource];
    isMusicSelect=YES;
    prepareRecording=NO;
    isRecording=NO;
    isRecordPause=NO;
    hideBoard=YES;
    if (_arrayImage.count<=10) {
        selectedPhotoNum=3;
    }else if (_arrayImage.count>10&&_arrayImage.count<=20)
    {
        selectedPhotoNum=2;
    }
    else
    {
        selectedPhotoNum=1;
    }
    
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    
    [self.view setBackgroundColor:UIColorFromRGB(BackgroundRecordColor)];
    
    [self createView];
    
    [self initVideo];
    
    [self voiceRecord];

    [[VoiceManager getInstance]setBlockWith:^(CGFloat duration) {
        
        voiceTimeLabel.text=[NSString stringWithFormat:@"%.0f″",videoDurtion-duration];
        sumTime=duration;
        NSLog(@"----------%f",sumTime);
        [progressView changeProgressViewFrame:duration/videoDurtion];
        
        if (duration>videoDurtion) {
            [SVProgressHUD showWithStatus:Video_Message maskType:SVProgressHUDMaskTypeNone];

            [TEVoiceManager stopRecordVoice];
            
            [self hideBoardWithType];
        }
        
    } pause:^(NSURL *fileURL, NSError *error) {
        //暂停
        selectedAudioPath=fileURL.path;
    } stop:^(NSURL *fileURL, NSError *error) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([SVProgressHUD isVisible]) {
                [SVProgressHUD dismiss];
            }
        });
        
        if (sumTime<0.1) {
            selectedAudioPath=nil;
            }
        else
        {
            
            selectedAudioPath=fileURL.path;
            //如果是图片合成的视频而且录音时长大于视频时长的时候,改变数组里的长度
            if (self.isPhotoToVideo&&sumTime>_arrayImage.count*selectedPhotoNum) {

              fitArrayUrl=[self fitArrayCount:fitMusicDurtion];
                [self audioPlay:selectedAudioPath];

            }
            else
            {
            [FFmpegSynthAudio synthAudio:selectedAudioPath withVideo:_filePath withBlock:^(NSString *exportPath) {
                WSLog(@"%@",exportPath);
                self.filePath=exportPath;
            dispatch_async(dispatch_get_main_queue(), ^{
            [ttMediaView playVedio:exportPath];

            });
            }];
            }
        }
        
    }];
}


-(void)initMusicSource
{
    audioPhotoArray=[[NSArray alloc]initWithObjects: @"record_getVoice",@"record_localAudio",@"photo01",@"photo02",@"photo03",@"photo04",@"photo05",@"photo06",@"photo07",@"photo08",@"photo09",@"photo10", @"photo11",nil];
    
    audioPlayArray=[[NSMutableArray alloc]init];
    for (int i=0; i<audioPhotoArray.count-2; i++) {
        NSString *tPath=[NSString stringWithFormat:@"bg_audio%.2d",i+1];
        NSString *path=[[NSBundle mainBundle]pathForResource:tPath ofType:@"m4a"];
        [audioPlayArray addObject:path];
    }

    
}
#pragma mark- 封面  配乐

-(void)musicOrPhoto
{
    if (isMusicSelect) {
//        [mediaView setHidden:NO];
        [ttMediaView setHidden:NO];
        [sliderMusicView setHidden:NO];
        [sliderPhotoView setHidden:YES];
        [showImage setHidden:YES];
        
//        [mediaView startPlayer];
        [ttMediaView playVedio:self.filePath];

    }
    else
    {
        [sliderMusicView setHidden:YES];
//        [mediaView setHidden:YES];
        [ttMediaView setHidden:YES];
        [sliderPhotoView setHidden:NO];
        [showImage setHidden:NO];
        
//        [mediaView stopPlayer];
        [ttMediaView stopVideo];
    }
}

//合成视音频
-(void)mixVideoAndAudio
{
//    self.demuxer=[[FfmpegMuxer alloc]init];
    if([self checkBeKill]){
        return;
    }
    //要存储的合成视频的路径
    NSString *outPath =  [self getVideoTempPath];
    
    NSLog(@"录制后的视频路径%@",_filePath);
    NSLog(@"合成的视频路径%@",outPath);
    
    
    //视频，音频 合成
    NSString *imgPath=[NSString stringWithFormat:@"%@.jpg",dateTransformStringAsYMDByFormate([NSDate new],@"yyyyMMddhhmmss")];
    //保存图片
    NSString *filePath=[SysTools writeImageToDocument:showImage.image fileName:imgPath];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        WSLog(@"图片写入成功 %@",filePath);
    }
    
    //如果有配乐
    if (selectedAudioPath) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
       tempPath =[documentsDirectory stringByAppendingPathComponent:@"tempfit.mp4"];
    
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:NULL];

        
        if (self.isPhotoToVideo&&sumTime>_arrayImage.count*selectedPhotoNum) {
            NSLog(@"测-------------------------------------试");
        
            
            //图片合成视频
          [ImagesToVideo videoFromImageURL:fitArrayUrl toPath:tempPath withCallbackBlock:^(BOOL success) {
              if (success) {
                  //视音频合成
                  [FFmpegSynthAudio synthAudio:selectedAudioPath withVideo:tempPath withBlock:^(NSString *exportPath) {
                     
                                           //如果视频合成成功了再进行发布
                      if ([[NSFileManager defaultManager]fileExistsAtPath:exportPath]) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              self.filePath=exportPath;
                              [self pushToCommentControllerVideoPath:exportPath andPhoto:filePath andDurtion:sumTime];
                              
                          });
                          
                      }
        
                  }];
                  
              }else
              {
                  NSLog(@"合成失败");
              }
          }];
        }else
        {
            
            [FFmpegSynthAudio synthAudio:selectedAudioPath withVideo:_filePath withBlock:^(NSString *exportPath) {
                WSLog(@"%@",exportPath);
                self.filePath=exportPath;
                [self pushToCommentControllerVideoPath:exportPath andPhoto:filePath andDurtion:sumTime];
            }];

        }
        
         }else   //直接上传原视频
    {

        [self pushToCommentControllerVideoPath:self.filePath andPhoto:filePath andDurtion:videoDurtion];

    }
    

}

-(void)pushToCommentControllerVideoPath:(NSString *)videoPath andPhoto:(NSString *)filePath andDurtion:(CGFloat)videoTime
{
   
    if (imagesArr.count==0) {
        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_In dealing with the cover...") duration:0.5];
        return;
    }

    releaseCommentViewController  *rc=[[releaseCommentViewController alloc]init];
    UIImage *tempImage=[[UIImage alloc]initWithContentsOfFile:filePath];
    rc.passUserImage=tempImage;
    rc.pageType=videoType;
    rc.videoPath=videoPath;
    rc.filePath=filePath;
    rc.videoDurtion=[NSString stringWithFormat:@"%f",videoTime];
    [self.navigationController pushViewController:rc animated:YES];
    
    if(selectedAudioPath!=nil){
        deleteFileByPath(selectedAudioPath);
    }
}

#pragma mark-上传视频

- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if (buttonIndex==0) {
        //删除截取的音频
        if(selectedAudioPath!=nil){
            deleteFileByPath(selectedAudioPath);
        }
        
        //删除临时视频
        if(_filePath!=nil){
            deleteFileByPath(_filePath);
        }
        if(_finishedFilePath!=nil){
            deleteFileByPath(_finishedFilePath);
        }
        
        
        NSArray *viewControllers=self.navigationController.viewControllers;
        for (id viewController in viewControllers) {
            if ([viewController isMemberOfClass:[PhotoAlbumController class]]) {
                PhotoAlbumController *photoAlbum=viewController;
                [photoAlbum.arrayEditModel removeAllObjects];
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
        
    }
}

-(IBAction)buttonClick:(UIButton *)sender{

    if(sender.tag==BACK_BUTTON)
    {
        if (self.isPhotoToVideo==1) {
            LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:@"是否放弃本视频?" delegate:self otherButton:@[@"确定"] cancelButton:@"取消"];
            [sheet showInView:nil];
        }
        else{
            [self goBack:sender];
        }
    }
    
    
#pragma mark-混音
    // 完成
    if(sender.tag==RIGHT_BUTTON){
        
        //如果正在录音状态
        if (prepareRecording) {
            [self hideBoardWithType];
            NSLog(@"%@",selectedAudioPath);
            [TEVoiceManager stopRecordVoice];

        }
        //合成视音频
        if (![SVProgressHUD isVisible]) {
            [SVProgressHUD showWithStatus:Video_Message maskType:SVProgressHUDMaskTypeNone];
        }
        NSLog(@"%f",videoDurtion);
        [self mixVideoAndAudio];
      
        if (imagesArr.count) {
            sender.userInteractionEnabled=NO;
        }
    }
    
    
    
    //封面
    if(sender.tag==DOWN_BTNTAG1){
        
        if (imagesArr.count==0) {
            [SVProgressHUD showSuccessWithStatus:@"封面处理中..." duration:0.5];
            return;
        }
        [self hideBoardWithType];
        [self stopAudio];
        
        isMusicSelect=NO;
        [self musicOrPhoto];
        [faceButton setImage:[UIImage imageNamed:@"medit_face_nor"] forState:UIControlStateNormal];
        [voiceButton setImage:[UIImage imageNamed:@"medit_changevoice_sel"] forState:UIControlStateNormal];
        
        [faceButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [voiceButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateNormal];
        
    }
    
    //配乐
    if(sender.tag==DOWN_BTNTAG2){
        NSLog(@"%@",selectedAudioPath);
        if (selectedAudioPath) {
            [self audioPlay:selectedAudioPath];
        }
        isMusicSelect=YES;
        [self musicOrPhoto];
        [voiceButton setImage:[UIImage imageNamed:@"medit_changevoice_nor"] forState:UIControlStateNormal];
        [faceButton setImage:[UIImage imageNamed:@"medit_face_sel"] forState:UIControlStateNormal];

        
        [faceButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateNormal];
        [voiceButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
//        [mediaView startPlayer];
    }

    
}


#pragma mark-根据url获取图片
- (NSMutableArray *)getImageByURL:(NSMutableArray *)arrayImageURL
{
    NSMutableArray *arrayImage =[[NSMutableArray alloc]init];
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc] init];
    for (NSURL *url in arrayImageURL) {
        NSLog(@"%@",url);
        [library assetForURL:url
                 resultBlock:^(ALAsset *asset){
                     UIImage *image=[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                     UIImage *scaleImage=[UIImage clipImageToSquare:image byWidth:300];
                     [arrayImage addObject:scaleImage];
//                     if (arrayImage.count==arrayImageURL.count) {
//                         [self pushEditMedia:arrayImage];
//                     }
                 }
                failureBlock:^(NSError *error){
                    NSLog(@"operation was not successfull!");
                }
         ];
    }
    return arrayImage;
}
//控制封面的图片为10张，当录音时间超过视频时长的时候控制数组个数合成的视频和音频长度一样
-(NSMutableArray *)fitArrayCount:(fitType)fitType
{
    NSMutableArray *fitArray=[[NSMutableArray alloc]init];
    NSInteger sumCount=_arrayImage.count;

    if (fitType==fitPhotoCount) {
        if (sumCount<10) {
            //当url小于10张时，循环添加到10张
            for (int i=0; i<10; i++) {
                NSURL *fitUrl=[_arrayImage objectAtIndex:i%sumCount];
                [fitArray addObject:fitUrl];
            }
        }else
        {
            //当url大于10张时，间隔取到10张
            
            for (int i=0; i<10; i++) {
                NSURL *fitUrl=[_arrayImage objectAtIndex:(i*sumCount)/10];
                [fitArray addObject:fitUrl];
            }
        }

    }
    else if (fitType==fitMusicDurtion)
    {
        
        // sumtime是录音时间，num为选择的图片个数，
        int count=sumTime/selectedPhotoNum;   //
        
      //混音的原理是10张图片以内三秒播一张，10到20张是俩秒播一张，20张以后一秒播一张
        if (count<=10&&sumTime<=40) {
            count=sumTime/3;
        }else if ((count>10&&count<=20)&&sumTime<=40)
        {
            count=sumTime/2;
        }
        else
        {
              //只要录音时间超过40秒，或者count大于20，即每秒塞一张图片进去
            count=sumTime;
        }
        for (int i=0; i<count; i++) {
            NSInteger index=i%sumCount;
             NSURL *url =[_arrayImage objectAtIndex:index];
            [fitArray addObject:url];
        }
        
    }
    return fitArray;
}


-(void)initVideo{
    
    TEVoiceManager=[VoiceManager getInstance];
    manager = [[RCCaptureSessionManager alloc] init];

    
//
        if (!showImage) {
            showImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,45, WIDTH, WIDTH)];
            [showImage setContentMode:UIViewContentModeScaleAspectFill];
            [showImage.layer setMasksToBounds:YES];
            [self.view addSubview:showImage];
        }
        
        CGPoint point=CGPointMake(WIDTH/2, CGRectGetMaxY(faceButton.frame)+(HEIGHT-CGRectGetMaxY(faceButton.frame))/2);
        CGRect rect=CGRectMake(0, 0, WIDTH-30, 85);
    

        //创建封面选取视图
    //根据url获取图片，本身是异步执行，所以不放在异步函数里
    if (self.isPhotoToVideo) {
        //图片合成的视频
        imagesArr=[self getImageByURL:[self fitArrayCount:fitPhotoCount]];
        //因为获取图片是一个异步操作，所以得延迟0.2秒确保数组里面有图片
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sliderPhotoView=[[SelectPhotoView alloc]initWithFrame:rect ImageArray:imagesArr originalImage:^(UIImage *orImage) {
                
                if (HEIGHT/WIDTH>1.5) {
                    
                    sliderPhotoView .center=point;
                }
                
                showImage.image=orImage;
                
            } selectImageBlock:^(UIImage *image) {
                showImage.image=image;
            }];
            sliderPhotoView.center= [self centerPoint];
            [self.view addSubview:sliderPhotoView];
            [sliderPhotoView setHidden:YES];

        });
        
    }else  //如果是录制的视频，耗时较长，放在异步线程中
    
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if(self.filePath)
            {
                if (!self.isPhotoToVideo) {
                    imagesArr=[manager getImagesFromVideo:[NSURL fileURLWithPath:self.filePath] times:10 width:640];
                    //                    imagesArr=[FFmpegSaveImage getImages:10 withVideo:self.filePath];
                    if(imagesArr==nil && imagesArr.count<=0){
                        NSLog(@"--------------数组空的");
                        return;
                    }
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sliderPhotoView=[[SelectPhotoView alloc]initWithFrame:rect ImageArray:imagesArr originalImage:^(UIImage *orImage) {
                    
                    if (HEIGHT/WIDTH>1.5) {
                        
                        sliderPhotoView .center=point;
                    }
                    
                    showImage.image=orImage;
                    
                } selectImageBlock:^(UIImage *image) {
                    showImage.image=image;
                }];
                sliderPhotoView.center= [self centerPoint];
                [self.view addSubview:sliderPhotoView];
                [sliderPhotoView setHidden:YES];
                
            });
            
        });

    }
    
    

       //配乐选择视图
    CGFloat suitHeight;
    if (HEIGHT/WIDTH==1.5) {
        suitHeight=HEIGHT-CGRectGetMaxY(faceButton.frame)-20;

//
    }else{
        
        suitHeight=95+20;
 }
//    CGFloat suitHeight=HEIGHT-CGRectGetMaxY(faceButton.frame);
    sliderMusicView=[[SelectMusicView alloc]initWithFrame:CGRectMake(0,0, WIDTH,suitHeight) musicArray:audioPhotoArray delegate:self];
    
    sliderMusicView.center=[self centerPoint];
    
    [self.view addSubview:sliderMusicView];
    
//    UISlider *sliderView=[[UISlider alloc]initWithFrame:CGRectMake(0, 0, 220, 5)];
//    sliderView.center=CGPointMake(SCREEN_WIDTH/2,CGRectGetMaxY(sliderMusicView.frame));
//    sliderView.minimumTrackTintColor=UIColorFromRGB(SystemColor);
//    sliderView.maximumTrackTintColor=UIColorFromRGB(SliderBgColor);
//    [sliderView setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
//    [self.view addSubview:sliderView];
    
    //视频播放视图
    UIView *playView=[[UIView alloc] initWithFrame:CGRectMake(0, 45, w, w)];
    [playView setBackgroundColor:[UIColor clearColor]];
    NSLog(@"-----------%@",self.filePath);
//    mediaView=[[TutuPlayerView alloc] initWithPath:self.filePath];
    
//    [mediaView setRepeatPlayer:YES];
//    [mediaView.player setScalingMode:MPMovieScalingModeAspectFill];
//    [playView addSubview:mediaView];
//    videoDurtion=[mediaView getDuration];
    [self.view addSubview:playView];
//    [mediaView startPlayer];
    
    ttMediaView=[[TTplayView alloc]init];
    ttMediaView.playUrl=[NSURL fileURLWithPath:self.filePath];
    if (self.isPhotoToVideo) {
        videoDurtion=120;
    }else
    {
        videoDurtion=[ttMediaView getSumDurtion];

    }
    [playView addSubview:ttMediaView];
    
}


-(CGPoint)centerPoint
{
        CGFloat originalPhotoY=CGRectGetHeight(faceButton.frame)+faceButton.frame.origin.y;
        CGFloat blankSpace=HEIGHT-originalPhotoY;
    CGPoint photoPoint;
    if (SCREEN_HEIGHT/SCREEN_WIDTH==1.5) {
         photoPoint=CGPointMake(WIDTH/2,  blankSpace/2+originalPhotoY);

    }else
    {
         photoPoint=CGPointMake(WIDTH/2,  blankSpace/2+originalPhotoY);

    }
        return photoPoint;
}

-(CGPoint)centerPointMusic
{
    CGFloat originalPhotoY=CGRectGetHeight(faceButton.frame)+faceButton.frame.origin.y;
    CGFloat blankSpace=HEIGHT-originalPhotoY;
    CGPoint photoPoint;
    if (SCREEN_HEIGHT/SCREEN_WIDTH==1.5) {
        photoPoint=CGPointMake(WIDTH/2,  blankSpace/2+originalPhotoY-14);
        
    }else
    {
        photoPoint=CGPointMake(WIDTH/2,  blankSpace/2+originalPhotoY);
        
    }
    return photoPoint;
}

//创建视图
    
-(void)createView{
    
    
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    backBtn.tag=BACK_BUTTON;
    [backBtn setFrame:CGRectMake(0, 0, 45, 45)];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 16, 13, 16)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"backc_light"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *commitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setBackgroundColor:[UIColor clearColor]];
    commitBtn.tag=RIGHT_BUTTON;
    [commitBtn setFrame:CGRectMake(SCREEN_WIDTH-60, 0, 55,45)];
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [commitBtn setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [commitBtn.titleLabel setFont:TitleFont];
    [self.view addSubview:commitBtn];

    
   
    
    CGFloat buttonHeight;
    if (HEIGHT==480) {
        
        buttonHeight=36;
    }
    else
    {
        buttonHeight=65;
    }
    //封面
    faceButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [faceButton setBackgroundColor:[UIColor clearColor]];
    faceButton.tag=DOWN_BTNTAG1;

    [faceButton setFrame:CGRectMake(w/2+LINE_WIDTH, 45+w, w/2-LINE_WIDTH/2, buttonHeight)];

    [faceButton setTitle:@"封面" forState:UIControlStateNormal];
    [faceButton setImage:[UIImage imageNamed:@"medit_face_sel"] forState:UIControlStateNormal];
    [faceButton setImage:[UIImage imageNamed:@"medit_face_sel"] forState:UIControlStateHighlighted];
    if (iPhone5) {
        [faceButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight-16)/2, w/4-20, (buttonHeight-16)/2,  w/4+6)];
        [faceButton.titleLabel setFont:ListTitleFont];

    }else
    {
        [faceButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight-14)/2, w/4-16, (buttonHeight-14)/2,  w/4+2)];
        [faceButton.titleLabel setFont:ListTimeFont];

    }
    [faceButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateNormal];
    [faceButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateHighlighted];
    [faceButton addRightBorderWithColor:UIColorFromRGB(MenuTitleColor) andWidth:1];
    [faceButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:faceButton];
    
    //配乐
    voiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [voiceButton setBackgroundColor:[UIColor clearColor]];
    voiceButton.tag=DOWN_BTNTAG2;
//    [voiceButton setFrame:CGRectMake(0, 45+w, w/2, buttonHeight)];
  
        [voiceButton setFrame:CGRectMake(0, 45+w, w/2-LINE_WIDTH/2, buttonHeight)];
        


    
    [voiceButton setTitle:@"配乐" forState:UIControlStateNormal];
    [voiceButton setImage:[UIImage imageNamed:@"medit_changevoice_nor"] forState:UIControlStateNormal];
    [voiceButton setImage:[UIImage imageNamed:@"medit_changevoice_sel"] forState:UIControlStateHighlighted];
    if (iPhone5) {
        [voiceButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight-16)/2, w/4-20, (buttonHeight-16)/2,  w/4+6)];
        [voiceButton.titleLabel setFont:ListTitleFont];
        
    }else
    {
        [voiceButton setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight-14)/2, w/4-16, (buttonHeight-14)/2,  w/4+2)];
        [voiceButton.titleLabel setFont:ListTimeFont];
    }

    [voiceButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [voiceButton setTitleColor:UIColorFromRGB(MenuTitleColor) forState:UIControlStateHighlighted];
    [voiceButton setBackgroundColor:UIColorFromRGB(BackgroundRecordColor)];
    [voiceButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceButton];
    
    
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, LINE_WIDTH,18)];
    lineView.center=CGPointMake(WIDTH/2, voiceButton.center.y);
    lineView.backgroundColor=UIColorFromRGB(MenuTitleColor);
    [self.view addSubview:lineView];
   
    
    
}

#pragma mark 选择系统音乐
-(void)checkedMusic:(NSString *)audioPath{
    selectedAudioPath=audioPath;
    [self audioPlay:selectedAudioPath];
    [sliderMusicView loclMusicChecked:1];
}

#pragma mark-配乐按钮点击事件
-(void)clickButton:(int)buttonTag andState:(int)state
{
    NSLog(@"%d",buttonTag);
    
    //无配音
    if (state) {
        selectedAudioPath=nil;
        [self stopAudio];
    }
    else
    {
        if (buttonTag==0) {
            [self stopAudio];  //停止播放配乐
            //录音
            [self showBoardWithType];
        }else if(buttonTag==1){
            MusicSelectController *selectMusic=[[MusicSelectController alloc] init];
            selectMusic.delegate=self;
            [self openNav:selectMusic sound:nil];
        }
        else
        {
            selectedAudioPath=[self playMusicIndex:buttonTag-2];
        }
    }
    NSLog(@"%@",selectedAudioPath);
}

// 隐藏状态栏 for ios 7
- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [ttMediaView playVedio:self.filePath];
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    UIButton *sender=(UIButton *)[self.view viewWithTag:RIGHT_BUTTON];
    sender.userInteractionEnabled=YES;
    // for ios 6
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    });
       [self stopAudio];
//    selectedAudioPath=nil;
    [TEVoiceManager resetState];
//    [mediaView stopPlayer];
    [ttMediaView stopVideo];
    
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
//    [mediaView destory];
}



//音频播放
-(void)audioPlay:(NSString *)path
{
    //从budle路径下读取音频文件　　轻音乐 - 萨克斯回家 这个文件名是你的歌曲名字,mp3是你的音频格式
    NSURL *url=[NSURL fileURLWithPath:path];
    
    [TEVoiceManager playerVoice:url data:nil startBlock:^{
        
        NSLog(@"开始播放");
    } stopBlock:^(NSURL *fileURL, NSError *error) {
        NSLog(@"停止播放");
    } pause:^(NSURL *fileURL, NSError *error) {
        NSLog(@"暂停播放");
    }];
}

- (void)stopAudio
{
    [TEVoiceManager stopPlayerVoice];
}
//暂停
- (void)pauseAudio
{
    [TEVoiceManager pauseRecordVoice];
}


-(NSString *)playMusicIndex:(int)musicIndex
{

    NSString* selectedPath=[audioPlayArray objectAtIndex:musicIndex];
    [self audioPlay:selectedPath];
    return selectedPath;
    
}

#pragma mark-录音
-(void)voiceRecord
{
    //添加录音视图
    voiceView=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), WIDTH, VoiceViewHeight)];
    [voiceView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:voiceView];
    
    
    progressView=[[recordingProgressView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 6) backgroundColor:UIColorFromRGB(ProgressVoiceBackColor) movingProgressColor:UIColorFromRGB(SystemColor)];
    progressView.targetProgress=1;
    [voiceView addSubview:progressView];
    
    
    UIButton *btnVoice=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnVoice setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
    [btnVoice setFrame:CGRectMake((WIDTH-195)/2, 22+(VoiceViewHeight-100)/2, 195, 100)];
    [btnVoice setUserInteractionEnabled:NO];
    [btnVoice setBackgroundColor:[UIColor clearColor]];
    btnVoice.tag=VOICE_BTN_TAG;
    [voiceView addSubview:btnVoice];
    
    UIButton *btnDelete=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnDelete setImage:[UIImage imageNamed:@"record_voice_close_nor"] forState:UIControlStateNormal];
    [btnDelete setImage:[UIImage imageNamed:@"record_voice_close"] forState:UIControlStateHighlighted];

    [btnDelete setFrame:CGRectMake(0, 0, 45, 45)];
    [btnDelete setCenter:CGPointMake(28+12, CGRectGetMidY(btnVoice.frame))];
    [btnDelete setImageEdgeInsets:UIEdgeInsetsMake((45-28)/2, (45-28)/2, (45-28)/2, (45-28)/2)];
    [btnDelete setUserInteractionEnabled:NO];
//    [btnDelete addTarget:self action:@selector(voiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnDelete setBackgroundColor:[UIColor clearColor]];
    btnDelete.tag=VOICE_DELETEBTN_TAG;
    [voiceView addSubview:btnDelete];
    
    
    UIButton *btnFinish=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnFinish setImage:[UIImage imageNamed:@"record_voice_finish_nor"] forState:UIControlStateNormal];
    [btnFinish setImage:[UIImage imageNamed:@"record_voice_finish"] forState:UIControlStateHighlighted];

    [btnFinish setFrame:CGRectMake(0, 0, 45, 45)];
    [btnFinish setCenter:CGPointMake(WIDTH-12-28, CGRectGetMidY(btnVoice.frame))];
    [btnFinish setImageEdgeInsets:UIEdgeInsetsMake((45-28)/2, (45-28)/2, (45-28)/2, (45-28)/2)];

    [btnFinish setUserInteractionEnabled:NO];
//    [btnDelete addTarget:self action:@selector(voiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnFinish setBackgroundColor:[UIColor clearColor]];
    btnFinish.tag=VOICE_OKBTN_TAG;
    [voiceView addSubview:btnFinish];


    
    voiceTimeLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 35, WIDTH, 20)];
    [voiceTimeLabel setText:@""];
    [voiceTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [voiceTimeLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [voiceTimeLabel setBackgroundColor:[UIColor clearColor]];
    [voiceView addSubview:voiceTimeLabel];
}


//-(void)startRecordingVoice
//{
//
//    [voiceLabel setText:@"按住说话，松开完成录音"];
//    [voiceLabel setTextColor:UIColorFromRGB(TextRegusterGrayColor)];
//
//    [TEVoiceManager startRecordVoice];
//
//    
//}

//-(void)stopRecordingVoice
//{
//
//
//    [TEVoiceManager stopRecordVoice];
// 
//}

-(void)showBoardWithType{
    selectedAudioPath=nil;
    voiceTimeLabel.text=[NSString stringWithFormat:@"%d″",(int)(videoDurtion)];

    if (!prepareRecording) {
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             CGRect voiceRect = voiceView.frame;
                             voiceRect.origin.y-=VoiceViewHeight;
                             voiceView.frame=voiceRect;
                             
                         }
                         completion:^(BOOL finished) {

                         }
         ];

    }
    prepareRecording=YES;

    }

-(void)hideBoardWithType
{
    [voiceTimeLabel setText:@""];
    [progressView changeProgressViewFrame:0];

    
    if (prepareRecording) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             CGRect voiceRect = voiceView.frame;
                             voiceRect.origin.y+=VoiceViewHeight;
                             voiceView.frame=voiceRect;
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];

    }
    prepareRecording=NO;
    isRecordPause=NO;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.view removeGestureRecognizer:tapRecognizer];
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    UIButton *vbtn=(UIButton *)[voiceView viewWithTag:VOICE_BTN_TAG];
    CGPoint p=[touch locationInView:vbtn];
    if(p.x>0 && p.y>0 && p.y<vbtn.frame.size.height && p.x<vbtn.frame.size.width){
        if(isRecordPause){
            [TEVoiceManager reStartRecordVoice];
        }else{
            [TEVoiceManager startRecordVoice];
        }

        [vbtn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
        UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [animatedImageView setFrame:vbtn.bounds];
        animatedImageView.tag=10;
        animatedImageView.animationImages = [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"letter_greenvoice2.png"],
                                             [UIImage imageNamed:@"letter_greenvoice3.png"],
                                             [UIImage imageNamed:@"letter_greenvoice1.png"], nil];
        animatedImageView.animationDuration = .8f;
        animatedImageView.animationRepeatCount = 0;
        [animatedImageView startAnimating];
        [vbtn addSubview:animatedImageView];
        
        
        
    }
 
        
        //开始录音
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint p=[touch locationInView:[voiceView viewWithTag:VOICE_BTN_TAG]];
//    WSLog(@"结束事件：%@",NSStringFromCGPoint(p));
    UIButton *btn=(UIButton *)[voiceView viewWithTag:VOICE_BTN_TAG];
    if(btn!=nil){
        UIImageView *iv=(UIImageView *)[btn viewWithTag:10];
        if(iv!=nil){
            [iv removeFromSuperview];
        }
    }
        //暂停录音
    
    [TEVoiceManager pauseRecordVoice];
    isRecordPause=YES;

    
        if(p.y<0 || p.y>btn.frame.size.height || p.x<0 || p.x>btn.frame.size.width){
            [btn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
        }
        else{
            [btn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
        }

    
//    //删除
//    
    UIButton *deleteBtn=(UIButton *)[voiceView viewWithTag:VOICE_DELETEBTN_TAG];
    CGPoint deleteP=[touch locationInView:deleteBtn];
    if (deleteP.x>0&&deleteP.y>0 &&deleteP.x<deleteBtn.frame.size.width&&deleteP.y<deleteBtn.frame.size.width) {

        if (!selectedAudioPath) {
            if (hideBoard) {
                [self hideBoardWithType];
            }
            else
            {
            [deleteBtn setImage:[UIImage imageNamed:@"record_voice_close_nor"] forState:UIControlStateNormal];
            [deleteBtn setImage:[UIImage imageNamed:@"record_voice_close"] forState:UIControlStateHighlighted];
            [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake((45-28)/2, (45-28)/2, (45-28)/2, (45-28)/2)];

            selectedAudioPath=nil;
            [TEVoiceManager resetState];
            isRecordPause=NO;
            [voiceTimeLabel setText:@""];
            [progressView changeProgressViewFrame:0];
            hideBoard=YES;

            }
        }
        else{
            
        [deleteBtn setImage:[UIImage imageNamed:@"record_delete_voice"] forState:UIControlStateNormal];
        [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake((45-28)/2, (45-23)/2, (45-28)/2, (45-23)/2)];

        selectedAudioPath=nil;
        hideBoard=NO;
        }
    }
    
    
//
//    
    //完成
    UIButton *okBtn=(UIButton *)[voiceView viewWithTag:VOICE_OKBTN_TAG];
    CGPoint okP=[touch locationInView:okBtn];
    if (okP.x>0&&okP.y>0&&okP.x<okBtn.frame.size.height&&okP.y<okBtn.frame.size.width) {
        
        if (selectedAudioPath==nil) {
            [self hideBoardWithType];
            return;
        }
        [SVProgressHUD showWithStatus:Video_Message maskType:SVProgressHUDMaskTypeNone];

        [self hideBoardWithType];
        
        NSLog(@"%@",selectedAudioPath);

        
        [TEVoiceManager stopRecordVoice];
        
        

        
    }
    

    //点击除了voiceview之外的区域
    CGPoint pointVoice=[touch locationInView:voiceView];
    if (!(pointVoice.x>0&&pointVoice.y>0&&pointVoice.x<voiceView.frame.size.width&&pointVoice.y<voiceView.frame.size.height)) {
        
//        selectedAudioPath=nil;
        [TEVoiceManager resetState];
        isRecordPause=NO;
        [voiceTimeLabel setText:@""];
        [progressView changeProgressViewFrame:0];
        [self hideBoardWithType];

    }
    
}



-(NSString *)getVideoTempPath{
    NSString *videoName=[NSString stringWithFormat:@"megraudio%@.mp4",dateTransformStringAsYMDByFormate([NSDate new],@"yyyyMMddhhmmss")];
    return [NSString stringWithFormat:@"%@%@",getTempVideoPath(),videoName];
//    return [NSTemporaryDirectory() stringByAppendingPathComponent:[videoName lastPathComponent]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    WSLog(@"内存警告:");
}


@end
