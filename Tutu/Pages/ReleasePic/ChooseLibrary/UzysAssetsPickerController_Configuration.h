//
//  UzysAssetsPickerController_configuration.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 来源于最专业的源码分享网站: Code4App

#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^intBlock)(NSInteger);
typedef void (^voidBlock)(void);

#define kGroupViewCellIdentifier           @"groupViewCellIdentifier"
#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"
#define kThumbnailLength    (([UIScreen mainScreen].bounds.size.width - 5) / 4.0)
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)

#define kTagButtonClose 101
#define kTagButtonCamera 102
#define kTagButtonGroupPicker 103
#define kTagButtonDone 104
#define kTagNoAssetViewImageView 30
#define kTagNoAssetViewTitleLabel 31
#define kTagNoAssetViewMsgLabel 32

#define kGroupPickerViewCellLength 90
