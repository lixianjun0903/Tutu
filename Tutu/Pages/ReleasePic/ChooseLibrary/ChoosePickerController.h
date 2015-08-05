//
//  ChoosePickerController.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
#import "BaseController.h"
#import "UzysGroupPickerView.h"


@interface ChoosePickerController : BaseController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

// 需要显示，至少为2，否则不能取消选择
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionVideo;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionPhoto;


@property (nonatomic, strong) UzysGroupPickerView *groupPicker;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;


+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end
