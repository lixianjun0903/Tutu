//
//  releaseCommentViewController.h
//  Tutu
//
//  Created by gexing on 15/4/10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
typedef NS_ENUM(NSInteger,buttonTag){
  
    anonymousBtnTag=101,  //匿名按钮
    locationBtnTag=102,  //添加位置按钮
    shareToQQTag=103,
    shareToWeixinTag=104,
    shareToWeiboTag=105,
    topicTag=106,
    userTag=107,
    imageBtnTag=108,
    closeBtnTag=109,
    
};

typedef NS_ENUM(NSInteger, passPageType){
    PhotoType,
    videoType,
};


@interface releaseCommentViewController : BaseController
@property(nonatomic,strong)UIImage *passUserImage;    //用户头像
@property (nonatomic,assign)passPageType pageType;
@property(nonatomic,strong)NSString *videoPath;  //视频路径
@property(nonatomic,strong)NSString *filePath;  //封面路径
@property(nonatomic,strong)NSString *videoDurtion;  //视频时长
@property(nonatomic,strong)NSString *poiid;  //视频时长
@property(nonatomic,strong)NSString *poitext;  //视频时长

@end
