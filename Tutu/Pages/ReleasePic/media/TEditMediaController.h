//
//  TEditMediaController.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface TEditMediaController : BaseController
typedef NS_ENUM(NSInteger,fitType){

    fitPhotoCount = 0,

    fitMusicDurtion=1,
    
};

@property(nonatomic,strong) NSString *filePath;   //录制后的视频路径
@property(nonatomic,strong) NSString *finishedFilePath;            //声音，视频合成之后的视频路径
@property(nonatomic,strong) NSMutableArray *arrayImage;
@property(nonatomic,assign) int isPhotoToVideo;
@end
