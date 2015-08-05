//
//  ChooseVideoManager.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-30.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class ChoosePickerController;

typedef void (^ReadFinish)(NSMutableArray *arr);
typedef void (^ReadLastImage)(UIImage *img);



#define AssetPropertyDate @"date"
#define AssetPropertyImage @"image"
#define AssetPropertyFileName @"fileName"
#define AssetPropertyURL @"nsurl"
#define AssetPropertyFileSize @"fileSize"
#define AssetPropertyType @"assetType"

typedef NS_ENUM(NSInteger,FilterType){
    //所有内容、图片、视频
    FilterAll = 0,
    
    //仅仅过滤出图片
    FilterPhoto=1,
    
    // 仅仅过滤出视频
    FilterVideo=2,
};


@interface ChooseVideoManager : NSObject

+(id)getInstance;

@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *groups;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assets;


/**
 * 获取所有资源
 */
-(void)getAllVideosAndPhots:(ReadFinish) block;

/**
 * 获取所有视频
 **/
-(void)getVideos:(ReadFinish) block;


/**
 * 获取系统图片
 **/
-(void)getPhotos:(ReadFinish) block;




/**
 * 获取最新的一张封面
 * fileType ,获取封面来源
 * 注：未作排序，默认取第一张，目前看系统默认最新放在前面，未完全确认
 **/
-(void)getLastImage:(ReadLastImage) block filterType:(FilterType) filterType;


@end
