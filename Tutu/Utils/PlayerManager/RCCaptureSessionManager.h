//
//  RCCaptureSessionManager.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-5.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UzysAssetsPickerController_Configuration.h"

typedef NS_ENUM(NSInteger,slightMode){
    //打开闪光灯
    slightOn = 0,
    //关闭闪光灯
    slightOff=1,
    
    // 自动模式
    slightAuto=2,
};

@protocol RCCaptureSessionManager;
typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);
typedef void(^StartRecordBlock)(NSURL *fileURL,NSError *error);
typedef void(^FinishRecordBlock)(NSURL *fileURL,NSError *error);
typedef void(^RecordProgressBlock)(CGFloat duration,int videoNumber);
typedef void(^failedNotice)(void);

typedef void(^myProgressBlock)(void);


typedef void(^VideoMoveFinishBlock) (NSString *filePath);
typedef void(^VideoMoveFailBlock) (NSString *filePath,NSError *error);

//合成声音完成
typedef void (^SyntheticBlock) (NSString *filePath);
typedef void(^CutVideoBlock)(NSURL *fileURL, CGFloat duration,NSError *error);
typedef void(^CutVideoFailBlock)(NSURL *fileURL,NSError *error);



//提取图片过慢
typedef void(^GetImageDataBlock) (NSData *imgData,int index);


@interface RCCaptureSessionManager : NSObject<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, assign) BOOL isrecording;

@property (nonatomic, strong) AVCaptureSession *session;


@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
//视频输出流量
@property (nonatomic, strong) AVCaptureMovieFileOutput *aMovieFileOutput;

@property(nonatomic,copy)failedNotice failedBlock;

@property(nonatomic,copy)myProgressBlock valueBlock; //时间超过八秒时调用

- (void)configureWithParentLayer:(UIView*)parent;

//开始抓屏
-(void)startRunning;
//停止抓屏
-(void)stopRunning;

//拍照
- (void)takePicture:(DidCapturePhotoBlock)block;
//切换到拍照调用，使用高清图片
-(void)changePicture:(BOOL) isPicture;

//切换前后镜头
- (void)toggleCamera;  //测试暂不可用

- (void)swapFrontAndBackCameras;


//开关闪关灯
-(void)openTorch:(slightMode)mode;

//开始拍摄
-(void)startRecord;
//结束拍摄
-(void)endRecord;
//暂停录制
-(void)pauseRecord;
//清理录制内容
-(void)cleanRecord;

//获取当前录制时间
-(void)setProgressBlock:(RecordProgressBlock) block;

//重置拍摄的时间
-(void)resetTheDurtion;

//设置拍摄监听
- (void)setStartRecord:(StartRecordBlock) start endRecordBlock:(FinishRecordBlock) stop;


/***
 * 转换视频为方形的640*640，不缩放，直接剪切
 * 从指定位置，截取长度，如果不截取，后面2个参数，直接传递0
 * fileURL 要裁切的视频
 * seconds 开始时间
 * length 裁切多长
 */
//- (void)mergeAndExportVideosAtFileURLs:(NSURL *)fileURL startSecond:(CGFloat) seconds lengthSeconds:(CGFloat) length;

//裁切
- (void)cutVideosAtFileURLs:(NSURL *)fileURL  startSecond:(CGFloat)seconds lengthSeconds:(CGFloat)length succes:(CutVideoBlock) cutSuccessblock fail:(CutVideoFailBlock) failBlock;

//获取视频时长
-(Float64)getViewDuration:(NSURL *)url;

// 系统视频压缩方法
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler;

//系统视频copy到temp中
-(void)videoToTempFile:(NSURL *)assetURL finish:(VideoMoveFinishBlock) fblock fail:(VideoMoveFailBlock) failBlock;



-(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
// asset当个获取，并且直接返回
-(NSMutableArray *) getImagesFromVideo:(NSURL *)videoURL times:(int)num width:(CGFloat) iWidth;

// asset当个获取
-(void) getImagesFromVideo:(NSURL *)videoURL times:(int)num width:(CGFloat) iWidth progress:(GetImageDataBlock)block;

//asset直接获取数组
-(void)getImagesFromLocalURL:(NSURL *)videoURL times:(int) num maxwidth:(float) maxwidth progress:(GetImageDataBlock)block;


// 系统合成声音和视频
-(void)syntheticAudioToVideo:(NSString *) audioUrl video:(NSString *)videoUrl block:(SyntheticBlock) successBlock;


// 声音切割
-(void)cutAudio:(NSURL *)path export:(NSString *)exportPath start:(NSTimeInterval) startDuration length:(NSTimeInterval) len succes:(CutVideoBlock) cutSuccessblock fail:(CutVideoFailBlock) failBlock;


@end

