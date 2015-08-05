//
//  RCCaptureSessionManager.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-5.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "RCCaptureSessionManager.h"
#import <MediaPlayer/MediaPlayer.h>

#import <ImageIO/ImageIO.h>
#import "UIImage+Resize.h"

#define RUN_TIMER 0.1
#define FAILED_URL 1

@interface RCCaptureSessionManager()


@end

@implementation RCCaptureSessionManager{
    StartRecordBlock startblock;
    FinishRecordBlock endblock;
    RecordProgressBlock progressBlock;
    
    NSTimer *countDurTimer;
    CGFloat currentVideoDur;
    CGFloat totalVideoDur;

    int urlCount;
    
    NSTimer *timer;
//    CGFloat count;
    
    BOOL isTorchOn;
    
    NSMutableArray *tempArray;
    
    //是否处理多个视频 ，并跳页
    BOOL isFinish;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.isrecording=NO;
        tempArray=[[NSMutableArray alloc] init];
    }
    return self;
}


- (void)configureWithParentLayer:(UIView*)parent{
    //1、session
    [self addSession];
    
    //2、previewLayer
    [self addVideoPreviewLayerWithRect:parent];
    
    
}

-(void)startRunning{
    [self.session startRunning];
}
-(void)stopRunning{
    [self.session stopRunning];
    self.isrecording=NO;
}


-(void)takePicture:(DidCapturePhotoBlock)block{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        //        [SCCommon saveImageToPhotoAlbum:image];
        
        CGFloat squareLength = ScreenWidth;
        
        CGFloat headHeight = 0;//_preview.bounds.size.height - squareLength;//_previewLayer的frame是(0, 44, 320, 320 + 44)
        
        CGSize size = CGSizeMake(squareLength * 2, squareLength * 2);
        
        UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
        WSLog(@"scaledImage:%@", [NSValue valueWithCGSize:scaledImage.size]);
        
        CGRect cropFrame = CGRectMake((scaledImage.size.width - size.width) / 2, (scaledImage.size.height - size.height) / 2 + headHeight, size.width, size.height);
        WSLog(@"cropFrame:%@", [NSValue valueWithCGRect:cropFrame]);
        UIImage *croppedImage = [scaledImage croppedImage:cropFrame];
        WSLog(@"croppedImage:%@", [NSValue valueWithCGSize:croppedImage.size]);
        
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation != UIDeviceOrientationPortrait) {
            
            CGFloat degree = 0;
            if (orientation == UIDeviceOrientationPortraitUpsideDown) {
                degree = 180;// M_PI;
            } else if (orientation == UIDeviceOrientationLandscapeLeft) {
                degree = -90;// -M_PI_2;
            } else if (orientation == UIDeviceOrientationLandscapeRight) {
                degree = 90;// M_PI_2;
            }
            croppedImage = [croppedImage rotatedByDegrees:degree];
        }
        
        if(block){
            block(croppedImage);
        }
        NSLog(@"image size = %@",NSStringFromCGSize(image.size));
    }];

}

-(void)changePicture:(BOOL)isPicture{
//    if(isPicture){
//        [self.session beginConfiguration];
//        if([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]){
//            self.session.sessionPreset =AVCaptureSessionPresetPhoto;
//        }
//        [self.session commitConfiguration];
//    }else{
//        if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
//            self.session.sessionPreset =AVCaptureSessionPreset640x480;  //设置成1280*720时  无法切换到前置摄像头
//        }else{
//            self.session.sessionPreset=AVCaptureSessionPresetMedium;
//        }
//    }
}

-(void)setStartRecord:(StartRecordBlock)start endRecordBlock:(FinishRecordBlock)stop{
    startblock=start;
    endblock=stop;
}

-(void)startRecord{
    if(!self.session.isRunning){
        [self startRunning];
    }
    
    self.isrecording=YES;
    isFinish=NO;
    
    NSString *tempPath=[self getVideoTempPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error] == NO) {
            NSLog(@"removeitematpath %@ error :%@", tempPath, error);
        }
    }
    NSURL *recordUrl=[NSURL fileURLWithPath:tempPath];
    
    @try {
        
        [self.aMovieFileOutput startRecordingToOutputFileURL:recordUrl recordingDelegate:self];
        
    }
    @catch (NSException *exception) {
        WSLog(@"%@",exception);
    }
    @finally {
        
    }
    
    
    [self startCountDurTimer];

}

-(void)endRecord{

    
    WSLog(@"当前：%d",self.aMovieFileOutput.isRecording);
    
    [self stopCountDurTimer];
    
    [timer invalidate];
    timer=nil;
    isFinish=YES;
    
    _valueBlock();
    
    WSLog(@"当前：%d",self.aMovieFileOutput.isRecording);
    
    if(self.aMovieFileOutput.isRecording){
        WSLog(@"%d",isFinish);
        [self.aMovieFileOutput stopRecording];
    }else{
        
 
        [self finishAndCreateVideo:tempArray];
    }
}

-(void)pauseRecord{
    isFinish=NO;
    [self stopCountDurTimer];
    
    if(timer!=nil){
        [timer setFireDate:[NSDate distantFuture]];
    }
    [self.aMovieFileOutput stopRecording];
}

-(void)cleanRecord{
    for (NSURL *url in tempArray) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            NSError *error;
            if ([[NSFileManager defaultManager] removeItemAtPath:url.path error:&error] == NO) {
                NSLog(@"removeitematpath %@ error :%@", url.path, error);
            }
        }
    }
    [tempArray removeAllObjects];
}

-(void)setProgressBlock:(RecordProgressBlock)block{
    progressBlock=block;
}


-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制：%@",fileURL);
    if(startblock){
        startblock(fileURL,nil);
    }
    
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    self.isrecording=NO;
    NSLog(@"录制结束：%@:rrr:%@",outputFileURL,error);
    [tempArray addObject:outputFileURL];
    if(isFinish){
        [self finishAndCreateVideo:tempArray];
    }
    //get save path
//    NSURL *mergeFileURL = [NSURL fileURLWithPath:[self getVideoMergeFilePathString]];
//    
//    [self convertVideoToLowQuailtyWithInputURL:outputFileURL outputURL:mergeFileURL handler:^(AVAssetExportSession *xx) {
//        if(endblock){
//            endblock(outputFileURL,error);
//        }
//    }];
}

/**
 *  session
 */
- (void)addSession {
    //这个方法的执行我放在init方法里了
    self.session = [[AVCaptureSession alloc] init];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
        self.session.sessionPreset =AVCaptureSessionPresetiFrame1280x720;  //设置成1280*720时  无法切换到前置摄像头
    }else{
        self.session.sessionPreset=AVCaptureSessionPresetMedium;
    }
    
    self.inputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    if ([self.session canAddInput:self.inputDevice]) {
        [self.session addInput:self.inputDevice];
    }
    
    //[self fronCamera]方法会返回一个AVCaptureDevice对象，因为我初始化时是采用前摄像头，所以这么写，具体的实现方法后面会介绍
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    
    self.aMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    //    [self.aMovieFileOutput pauseRecording];
    //    CMTimeMake(a,b)    a当前第几帧, b每秒钟多少帧.当前播放时间a/b
    //    CMTimeMakeWithSeconds(a,b)    a当前时间,b每秒钟多少帧.
    CMTime maxDuration = CMTimeMakeWithSeconds(0,16);
    self.aMovieFileOutput.maxRecordedDuration=maxDuration;
    
    if([self.session canAddOutput:self.aMovieFileOutput]){
        [self.session addOutput:self.aMovieFileOutput];
    }
    
    //延迟加载声音，否则会卡顿
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.session beginConfiguration];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
        if([self.session canAddInput:audioDeviceInput]){
            [self.session addInput:audioDeviceInput];
        }
        [self.session commitConfiguration];
    });
    
}

/**
 *  相机的实时预览页面
 *
 *  @param previewRect 预览页面的frame
 */
- (void)addVideoPreviewLayerWithRect:(UIView *)pv {
    
    _preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = pv.bounds;
    _preview.masksToBounds=YES;
    [pv.layer insertSublayer:_preview below:[[pv.layer sublayers] objectAtIndex:0]];
//    [pv.layer addSublayer:_previewLayer];
}


//切换前后镜头
- (void)toggleCamera {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        NSLog(@"相机");
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_inputDevice device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        else
            return;
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.inputDevice];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                [self setInputDevice:newVideoInput];
            } else {
                [self.session addInput:self.inputDevice];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}


- (void)openTorch:(slightMode)mode
{
    
//     isTorchOn = open;
    
    
    AVCaptureTorchMode torchMode;
    
    if (mode==slightOn) {
        torchMode = AVCaptureTorchModeOn;
    }
    else if(mode==slightOff)
    {
        torchMode = AVCaptureTorchModeOff;
    }
    else
    {
        torchMode=AVCaptureTorchModeAuto;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (![device isTorchModeSupported:torchMode]) {
            NSLog(@"设备不支持闪关灯");
            return;
        }
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}


- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


-(void)deallocSession
{
    for(AVCaptureInput *input1 in self.session.inputs) {
        [self.session removeInput:input1];
    }
    
    for(AVCaptureOutput *output1 in self.session.outputs) {
        [self.session removeOutput:output1];
    }
    [self.session stopRunning];
    self.session=nil;
    self.inputDevice=nil;
    
    self.stillImageOutput=nil;
    //视频输出流量
    self.aMovieFileOutput=nil;
    
}


-(void)finishAndCreateVideo:(NSMutableArray *) arr{
    NSMutableArray *urlArray=[[NSMutableArray alloc] init];
    for (NSURL *url in arr) {
        AVAsset *avAsset = [AVAsset assetWithURL:url];
        CMTime assetTime = [avAsset duration];
        Float64 duration = CMTimeGetSeconds(assetTime);
        if(duration>0.5){
            [urlArray addObject:url];
        }
    }
    [self mergeAndExportVideosAtFileURLs:urlArray];
}


//- (void)mergeAndExportVideosAtFileURLs:(NSURL *)fileURL  startSecond:(CGFloat)seconds lengthSeconds:(CGFloat)length {
//    AVAsset *avAsset = [AVAsset assetWithURL:fileURL];
//    CMTime assetTime = [avAsset duration];
//    Float64 duration = CMTimeGetSeconds(assetTime);
//    NSLog(@"视频时长 %f\n",duration);
//    if(length>duration){
//        length=duration;
//        seconds=0;
//    }else if(seconds>duration ||(seconds+length)>duration){
//        seconds=duration-length;
//    }else if(length<=0){
//        length=duration;
//        seconds=0;
//    }
//    
//    AVMutableComposition *avMutableComposition = [AVMutableComposition composition];
//    
//    AVMutableCompositionTrack *avMutableCompositionTrack = [avMutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    AVAssetTrack *avAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    
//    NSError *error = nil;
//    //前面的是开始时间,后面是裁剪多长 (我这裁剪的是从第二秒开始裁剪，裁剪2.55秒时长.)
////    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(2.0f, 30), CMTimeMakeWithSeconds(2.55f, 30))
////                                       ofTrack:avAssetTrack
////                                        atTime:kCMTimeZero
////                                         error:&error];
//    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(seconds, 30), CMTimeMakeWithSeconds(length, 30))
//                                       ofTrack:avAssetTrack
//                                        atTime:kCMTimeZero
//                                         error:&error];
//    
//    
//    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition];
//    // 这个视频大小可以由你自己设置。比如源视频640*480.而你这320*480.最后出来的是320*480这么大的，640多出来的部分就没有了。并非是把图片压缩成那么大了。
//    avMutableVideoComposition.renderSize = CGSizeMake(640.0f, 640.0f);
//    avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
//    // 这句话暂时不用理会，我正在看是否能添加logo而已。
////    [self addDataToVideoByTool:avMutableVideoComposition.animationTool];
//    
//    AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    
//    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [avMutableComposition duration])];
//    
//    AVMutableVideoCompositionLayerInstruction *avInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
//    [avInstruction setTransform:avAssetTrack.preferredTransform atTime:kCMTimeZero];
//    avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObject:avInstruction];
//    
//    
//    avMutableVideoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
//    
//    
//    NSString *v_strSavePath=[self getVideoMergeFilePathString];
//    NSFileManager *fm = [[NSFileManager alloc] init];
//    if ([fm fileExistsAtPath:v_strSavePath]) {
//        NSLog(@"video is have. then delete that");
//        if ([fm removeItemAtPath:v_strSavePath error:&error]) {
//            NSLog(@"delete is ok");
//        }else {
//            NSLog(@"delete is no error = %@",error.description);
//        }
//    }
//    
//    //get save path
//    NSURL *mergeFileURL = [NSURL fileURLWithPath:[self getVideoMergeFilePathString]];
//    
//    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avMutableComposition presetName:AVAssetExportPresetMediumQuality];
//    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
//    [avAssetExportSession setOutputURL:mergeFileURL];
//    [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
//    [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
//    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
//        if(avAssetExportSession.status==AVAssetExportSessionStatusCompleted){
//            // 想做什么事情在这个做
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self stopRunning];
//                if(endblock){
//                    endblock(mergeFileURL,nil);
//                }
//            });
//        }
//    }];
//    if (avAssetExportSession.status != AVAssetExportSessionStatusCompleted){
//        NSLog(@"Retry export");
//    }
//}
//


- (void)cutVideosAtFileURLs:(NSURL *)fileURL  startSecond:(CGFloat)seconds lengthSeconds:(CGFloat)length succes:(CutVideoBlock) cutSuccessblock fail:(CutVideoFailBlock)failBlock{
    AVAsset *avAsset = [AVAsset assetWithURL:fileURL];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
//    NSLog(@"视频时长 %f\n",duration);
    if(length>duration){
        length=duration;
        seconds=0;
    }else if(seconds>duration ||(seconds+length)>duration){
        seconds=duration-length;
    }else if(length<=0){
        length=duration;
        seconds=0;
    }
    WSLog(@"fileULR:%@",fileURL);
    
    AVMutableComposition *avMutableComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *avMutableCompositionTrack = [avMutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    
    //前面的是开始时间,后面是裁剪多长 (我这裁剪的是从第二秒开始裁剪，裁剪2.55秒时长.)
    //    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(2.0f, 30), CMTimeMakeWithSeconds(2.55f, 30))
    //                                       ofTrack:avAssetTrack
    //                                        atTime:kCMTimeZero
    //                                         error:&error];
    
    AVAssetTrack *avAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    
    NSError *error = nil;
    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(seconds, 30), CMTimeMakeWithSeconds(length, 30))
                                       ofTrack:avAssetTrack
                                        atTime:kCMTimeZero
                                         error:&error];
    
    NSArray *arr=[avAsset tracksWithMediaType:AVMediaTypeAudio];
    if(arr!=nil && arr.count>0){
        AVMutableCompositionTrack *avAudioMutableCompositionTrack = [avMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 没有音频会报空指针
        AVAssetTrack *audioTrack = [arr objectAtIndex:0];
        [avAudioMutableCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(seconds, 30), CMTimeMakeWithSeconds(length, 30))
                                                ofTrack:audioTrack
                                                 atTime:kCMTimeZero
                                                  error:&error];
    }
    
    
    
    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition];
    // 这个视频大小可以由你自己设置。比如源视频640*480.而你这320*480.最后出来的是320*480这么大的，640多出来的部分就没有了。并非是把图片压缩成那么大了。
    //如果c是-1，代表旋转，tx代码偏移量，与宽相同
//    WSLog(@"a:%f  b:%f  c:%f  d:%f  tx:%f ty:%f",avAssetTrack.preferredTransform.a,avAssetTrack.preferredTransform.b,avAssetTrack.preferredTransform.c,avAssetTrack.preferredTransform.d,avAssetTrack.preferredTransform.tx,avAssetTrack.preferredTransform.ty);
//    WSLog(@"%@",NSStringFromCGSize(avAssetTrack.naturalSize));
    CGSize renderSize=CGSizeMake(0,0);
    if(avAssetTrack.preferredTransform.c==-1){
//        avMutableVideoComposition.renderSize = CGSizeMake(avAssetTrack.naturalSize.height, avAssetTrack.naturalSize.width);
        renderSize=CGSizeMake(avAssetTrack.naturalSize.height, avAssetTrack.naturalSize.width);
    }else{
//        avMutableVideoComposition.renderSize = avAssetTrack.naturalSize;
        renderSize = avAssetTrack.naturalSize;
    }
    CGFloat renderWidth=0;
    if(renderSize.width<renderSize.height){
        renderWidth=renderSize.width;
    }else{
        renderWidth=renderSize.height;
    }
//    if(renderWidth>640){
//        renderWidth=640;
//    }
    CGFloat rate;
    rate = renderWidth/ MIN(avAssetTrack.naturalSize.width, avAssetTrack.naturalSize.height);
    
    CGAffineTransform layerTransform = CGAffineTransformMake(avAssetTrack.preferredTransform.a, avAssetTrack.preferredTransform.b, avAssetTrack.preferredTransform.c,avAssetTrack.preferredTransform.d, avAssetTrack.preferredTransform.tx * rate, avAssetTrack.preferredTransform.ty * rate);
    
    if (renderSize.width<renderSize.height) {
         layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(avAssetTrack.naturalSize.width - avAssetTrack.naturalSize.height+25.5) / 2.0));//向上移动取中部影响
    }else
    {
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1,-SCREEN_WIDTH/1.5,0));//向右移动取中部影响
    }
   
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
    

    
    avMutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderWidth);
    avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    // 这句话暂时不用理会，我正在看是否能添加logo而已。
    //    [self addDataToVideoByTool:avMutableVideoComposition.animationTool];
    
    AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [avMutableComposition duration])];
    
    AVMutableVideoCompositionLayerInstruction *avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
//    [avMutableVideoCompositionLayerInstruction setTransform:avAssetTrack.preferredTransform atTime:kCMTimeZero];
    [avMutableVideoCompositionLayerInstruction setTransform:layerTransform atTime:kCMTimeZero];
    avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObject:avMutableVideoCompositionLayerInstruction];
    avMutableVideoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
    
    
    
    NSString *v_strSavePath=[self getVideoMergeFilePathString];
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:v_strSavePath]) {
        NSLog(@"video is have. then delete that");
        if ([fm removeItemAtPath:v_strSavePath error:&error]) {
            NSLog(@"delete is ok");
        }else {
            NSLog(@"delete is no error = %@",error.description);
        }
    }
    
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:v_strSavePath];
    WSLog(@"%@",v_strSavePath);
    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avMutableComposition presetName:AVAssetExportPresetMediumQuality];
    if(renderSize.width<640){
        avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avMutableComposition presetName:AVAssetExportPresetPassthrough];
        if(avAssetTrack.preferredTransform.c==-1){
            avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avMutableComposition presetName:AVAssetExportPresetHighestQuality];
        }
    }
    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
    [avAssetExportSession setOutputURL:mergeFileURL];
    [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
    
    [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
        if(avAssetExportSession.status==AVAssetExportSessionStatusCompleted){
            // 想做什么事情在这个做
            dispatch_async(dispatch_get_main_queue(), ^{
                if(cutSuccessblock){
                    cutSuccessblock(mergeFileURL,duration,nil);
                }
            });
        }
    }];
    if (avAssetExportSession.status != AVAssetExportSessionStatusCompleted){
        if(avAssetExportSession.error!=nil && avAssetExportSession.status==4){
            if(failBlock){
                failBlock(mergeFileURL,avAssetExportSession.error);
            }
        }
    }
}


//压缩视频
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    //视频质量设置，目前流畅为清晰切不大范围，13秒1.3M左右
    
    
    CGSize renderSize = CGSizeMake(0, 0);
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
    renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    AVAssetExportSession *exportSession;
    if (renderSize.width<640) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    }else
    {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    }
    
   
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse=YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if(exportSession.status==AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(exportSession);
            });
        }
    }];
}


-(Float64)getViewDuration:(NSURL *)url{
    AVAsset *avAsset = [AVAsset assetWithURL:url];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    return duration;
}




//必须是fileURL
//截取将会是视频的中间部分
//这里假设拍摄出来的视频总是高大于宽的

/*!
 @method mergeAndExportVideosAtFileURLs:
 
 @param fileURLArray
 包含所有视频分段的文件URL数组，必须是[NSURL fileURLWithString:...]得到的
 
 @discussion
 将所有分段视频合成为一段完整视频，并且裁剪为正方形
 */

//必须是fileURL
//截取将会是视频的中间部分
//这里假设拍摄出来的视频总是高大于宽的

/*!
 @method mergeAndExportVideosAtFileURLs:
 
 @param fileURLArray
 包含所有视频分段的文件URL数组，必须是[NSURL fileURLWithString:...]得到的
 
 @discussion
 将所有分段视频合成为一段完整视频，并且裁剪为正方形
 */
- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray
{
    NSError *error = nil;
    
    if (fileURLArray.count==0) {
        [timer invalidate];

        _failedBlock();
        
        return;
    }
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    //先取assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];   //所有的视频信息
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];    //所有的分段视音频信息
    for (NSURL *fileURL in fileURLArray) {
        
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        
        if (!asset) {
            continue;
        }
        
        [assetArray addObject:asset];
        
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        NSArray *arr=[asset tracksWithMediaType:AVMediaTypeAudio];
        if(arr!=nil && arr.count>0){
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:[arr objectAtIndex:0]  //音频源
                             atTime:totalDuration
                              error:nil];
        }
    
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
        
        
        //        http://justsee.iteye.com/blog/1969933
        //        CGAffineTransformMake(a,b,c,d,tx,ty)
        //        ad缩放bc旋转tx,ty位移，基础的2D矩阵
         
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height+25.5) / 2.0));//向上移动取中部影响
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:[self getVideoMergeFilePathString]];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;

    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        int exportStatus=exporter.status; //视频导出状态
        
        switch (exportStatus) {
                
            case AVAssetExportSessionStatusFailed:{
                _failedBlock();
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                break;
            }
                
            case AVAssetExportSessionStatusCompleted:
                
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //To do 处理完后的视频
                    //mergeFileURL
                    
                    if(endblock){
                        endblock(mergeFileURL,error);
                        [self cleanRecord];
                    }
                });

                NSLog (@"AVAssetExportSessionStatusCompleted"); break;
            }
                
            case AVAssetExportSessionStatusUnknown: NSLog (@"AVAssetExportSessionStatusUnknown"); break;
            case AVAssetExportSessionStatusExporting: NSLog (@"AVAssetExportSessionStatusExporting"); break;
            case AVAssetExportSessionStatusCancelled: NSLog (@"AVAssetExportSessionStatusCancelled"); break;
            case AVAssetExportSessionStatusWaiting: NSLog (@"AVAssetExportSessionStatusWaiting"); break;
            default:  NSLog (@"didn't get export status"); break;
        }
        
            }];
}


- (NSString *)getVideoMergeFilePathString
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@",getTempVideoPath(),@"merge.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:fileName error:&error] == NO) {
            NSLog(@"removeitematpath %@ error :%@", fileName, error);
        }
    }

    
    return fileName;
}

-(NSString *)getVideoTempPath{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString stringWithFormat:@"temp%d.mp4",(int)tempArray.count] lastPathComponent]];
}


-(NSString *)getExportVideoTempPath{
//    NSString *videoName=[NSString stringWithFormat:@"megraudio%@.mp4",dateTransformStringAsYMDByFormate([NSDate new],@"yyyyMMddhhmmss")];
//    return [NSTemporaryDirectory() stringByAppendingPathComponent:[videoName lastPathComponent]];
    
    
    NSString *videoName=[NSString stringWithFormat:@"megraudio%@.mp4",dateTransformStringAsYMDByFormate([NSDate new],@"yyyyMMddhhmmss")];
    return [NSString stringWithFormat:@"%@%@",getTempVideoPath(),videoName];
}



-(void)resetTheDurtion
{
//    count=0;
    currentVideoDur=0;
    
}
- (void)dealloc {
    [_session stopRunning];
    self.session = nil;
    self.stillImageOutput = nil;
}


-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)swapFrontAndBackCameras {
    // Assume the session is already running
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.session beginConfiguration];
            if(position==AVCaptureDevicePositionBack){
                if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
                    self.session.sessionPreset =AVCaptureSessionPreset640x480;  //设置成1280*720时  无法切换到前置摄像头
                }else{
                    self.session.sessionPreset=AVCaptureSessionPresetMedium;
                }
            }else{
                if ([self.session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
                    self.session.sessionPreset =AVCaptureSessionPresetiFrame1280x720;  //设置成1280*720时  无法切换到前置摄像头
                }else{
                    self.session.sessionPreset=AVCaptureSessionPresetMedium;
                }
            }
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    } 
}


//时间管理器  设置进度条
- (void)startCountDurTimer
{
    countDurTimer=[NSTimer scheduledTimerWithTimeInterval:RUN_TIMER target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    currentVideoDur += RUN_TIMER;
    
    progressBlock(currentVideoDur,(int)tempArray.count);
    
    if (totalVideoDur + currentVideoDur >=MaxCMtime&&urlCount!=FAILED_URL) {
        [self endRecord];
    }
}

- (void)stopCountDurTimer
{
    [countDurTimer invalidate];
    countDurTimer = nil;
}



-(void)videoToTempFile:(NSURL *)url finish:(VideoMoveFinishBlock)fblock fail:(VideoMoveFailBlock)failBlock{
    NSString *filePath=[self getVideoTempPath];
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString * videoPath = filePath;
                char const *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 1024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(fblock){
                            WSLog(@"%@",filePath);
                            fblock(filePath);
                        }
                    });
                }
            } failureBlock:^(NSError *error) {
                if(failBlock){
                    failBlock(filePath,error);
                }
            }];
        }
    });
}



-(void)syntheticAudioToVideo:(NSString *) audioUrl video:(NSString *)videoUrl block:(SyntheticBlock)successBlock{
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:audioUrl] options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:videoUrl] options:nil];

    
    
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];

    CMTime duration=videoAsset.duration;
//    Float64 audioduration = CMTimeGetSeconds(audioAsset.duration);
//    Float64 videoduration = CMTimeGetSeconds(videoAsset.duration);
//    
//    if(audioduration<videoduration){
//        duration=videoAsset.duration;
//    }
    
    NSArray *arr=[audioAsset tracksWithMediaType:AVMediaTypeAudio];
    if(arr!=nil && arr.count>0){
        AVMutableCompositionTrack *compositionCommentaryTrack
        = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                      preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                                ofTrack:[arr objectAtIndex:0]
                                     atTime:kCMTimeZero error:nil];
    }
    
    AVMutableCompositionTrack *compositionVideoTrack
        = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                               ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                atTime:kCMTimeZero error:nil];

    AVAssetExportSession* _assetExport
        = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                           presetName:AVAssetExportPresetPassthrough];
    NSString *exportPath =[self getExportVideoTempPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];

    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(successBlock){
                successBlock(exportPath);
            }
        });
    }];
}


/**
 * 音频切割
 * http://blog.sina.com.cn/s/blog_7a162d000101b9w3.html
 */
-(void)cutAudio:(NSURL *)songURL export:(NSString *)exportPath start:(NSTimeInterval) startDuration length:(NSTimeInterval) len succes:(CutVideoBlock) cutSuccessblock fail:(CutVideoFailBlock) failBlock{
    //1. 创建AVURLAsset对象（继承了AVAsset）
//    NSURL *songURL = [NSURL fileURLWithPath:path];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    //2.创建音频文件
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    if(exportPath==nil){
        NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
     exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"cutTempAudio.m4a"];//EXPORT_NAME为导出音频文件名
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    NSError *assetError;
    [AVAssetWriter assetWriterWithURL:exportURL fileType:AVFileTypeCoreAudioFormat
                                                              error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    // 3.创建音频输出会话
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:songAsset
                                                                            presetName:AVAssetExportPresetAppleM4A];
     //4.设置音频截取时间区域 （CMTime在Core Medio框架中，所以要事先导入框架）
    CMTime startTime = CMTimeMake(startDuration, 1);
    CMTime stopTime = CMTimeMake(startDuration+len, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    // 5.设置音频输出会话并执行
    exportSession.outputURL = exportURL; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (AVAssetExportSessionStatusCompleted == exportSession.status) {
                NSLog(@"AVAssetExportSessionStatusCompleted");
                cutSuccessblock(exportURL,len,nil);
                
            } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
                // a failure may happen because of an event out of your control
                // for example, an interruption like a phone call comming in
                // make sure and handle this case appropriately
                NSLog(@"AVAssetExportSessionStatusFailed\n%@",exportSession.error);
                failBlock(exportURL,nil);
            } else {
                NSLog(@"Export Session Status: %d", (int)exportSession.status);
                failBlock(exportURL,nil);
            }
        });
    }];
}


-(NSMutableArray *)getImagesFromVideo:(NSURL *)videoURL times:(int)num width:(CGFloat)iWidth{
    if(iWidth<=0){
        iWidth=640;
    }
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    
    //    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    WSLog(@"%f",duration);
    for (int i=0; i<num; i++) {
        Float64 curTime=(duration/num) * i;
        
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(curTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
        
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        
        UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
        
        CGSize size=thumbnailImage.size;
        
        UIImage *scaleimage=[self imageWithImage:thumbnailImage scaledToSize:CGSizeMake(640, 640*size.height/size.width)];
        
        size=scaleimage.size;
        WSLog(@"%@",NSStringFromCGSize(size));
        CGImageRef cgimg = CGImageCreateWithImageInRect([scaleimage CGImage], CGRectMake(0, size.height/2-size.width/2, size.width, size.width));
        
        NSData *imageData = UIImageJPEGRepresentation([[UIImage alloc]initWithCGImage:cgimg],0.1);
        if(thumbnailImage!=nil){
            [arr addObject:imageData];
        }
        
        
        CGImageRelease(cgimg);
        CGImageRelease(thumbnailImageRef);
    }
    
    return arr;
}


-(void)getImagesFromVideo:(NSURL *)videoURL times:(int)num width:(CGFloat)iWidth progress:(GetImageDataBlock)block{
    if(iWidth<=0){
        iWidth=640;
    }
    AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    
    //    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    WSLog(@"%f",duration);
    for (int i=0; i<num; i++) {
        Float64 curTime=(duration/num) * i;
 
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(curTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
        
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        
        UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
        
        CGSize size=thumbnailImage.size;
        
        UIImage *scaleimage=[self imageWithImage:thumbnailImage scaledToSize:CGSizeMake(160, 160*size.height/size.width)];
//        UIImage *scaleimage=[self imageWithImage:thumbnailImage scaledToSize:CGSizeMake(160, 160)];

        size=scaleimage.size;
        WSLog(@"%@",NSStringFromCGSize(size));
        CGImageRef cgimg = CGImageCreateWithImageInRect([scaleimage CGImage], CGRectMake(0, size.height/2-size.width/2, size.width, size.width));
        
        NSData *imageData = UIImageJPEGRepresentation([[UIImage alloc]initWithCGImage:cgimg],0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block){
                block(imageData,i);
            }
        });
        
        CGImageRelease(cgimg);
        CGImageRelease(thumbnailImageRef);
    }
    
//    [assetImageGenerator generateCGImagesAsynchronouslyForTimes:[[NSArray alloc] initWithObjects:@"", nil] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
//         NSLog(@"actual got image at time:%f", CMTimeGetSeconds(actualTime));
//        if (image)        {
//            [CATransaction begin];
//            [CATransaction setDisableActions:YES];
////            [layer setContents:(id)image];
////            UIImage *img = [UIImage imageWithCGImage:image];
//            //UIImageWriteToSavedPhotosAlbum(img, self, nil, nil);
//            [CATransaction commit];
//        }
//    }];
}

-(void)getImagesFromLocalURL:(NSURL *)videoURL times:(int) num maxwidth:(float) maxwidth progress:(GetImageDataBlock)block{
    if(maxwidth<=0){
        maxwidth=640;
    }
    AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
    CMTime assetTime = [avAsset duration];
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    //帧数
    CMTimeValue v=assetTime.value;
    //
    CMTimeScale scale=assetTime.timescale;
    
    for (int i=0; i<num; i++) {
        CMTimeValue curTime=v/num * i;
        CMTime thumbTime = CMTimeMake(curTime, scale);
        WSLog(@"%@",[NSValue valueWithCMTime:thumbTime]);
        [arr addObject:[NSValue valueWithCMTime:thumbTime]];
    }
    
    [assetImageGenerator generateCGImagesAsynchronouslyForTimes:arr completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        NSLog(@"===================\nrequest time:%f",CMTimeGetSeconds(requestedTime));
         NSLog(@"actual got image at time:%f", CMTimeGetSeconds(actualTime));
        if (image)        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            
            UIImage *thumbnailImage = [UIImage imageWithCGImage:image];
            
            CGSize size=thumbnailImage.size;
            
            UIImage *scaleimage=[self imageWithImage:thumbnailImage scaledToSize:CGSizeMake(160, 160*size.height/size.width)];
            
            size=scaleimage.size;
            
            CGImageRef cgimg = CGImageCreateWithImageInRect([scaleimage CGImage], CGRectMake(0, size.height/2-size.width/2, size.width, size.width));
            
            NSData *imageData = UIImageJPEGRepresentation([[UIImage alloc]initWithCGImage:cgimg],0.1);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block){
                    block(imageData,0);
                }
            });
            [CATransaction commit];
        }
    }];
}



//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

-(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
    
    
    CGSize size=thumbnailImage.size;
    
    UIImage *scaleimage=[self imageWithImage:thumbnailImage scaledToSize:CGSizeMake(640, 640*size.height/size.width)];
//    UIImage *scaleimage=[self imageWithImage:thumbnailImage scaledToSize:CGSizeMake(640, 640)];

    size=scaleimage.size;
    CGImageRef cgimg = CGImageCreateWithImageInRect([scaleimage CGImage], CGRectMake(0, size.height/2-size.width/2, size.width, size.width));
    
    NSData *imageData = UIImageJPEGRepresentation([[UIImage alloc]initWithCGImage:cgimg],0.1);
    
    CGImageRelease(cgimg);
    CGImageRelease(thumbnailImageRef);
    return [UIImage imageWithData:imageData];
}

@end
