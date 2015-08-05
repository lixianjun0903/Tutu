//
//  PhotoEditCell.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoEditModel : NSObject

@property(nonatomic,assign) NSInteger targetRow;
@property(nonatomic,strong) ALAsset *asset;
@property(nonatomic,strong) NSURL *imageURL;
@property(nonatomic,assign) int size;

@end

@interface PhotoEditCell : UICollectionViewCell

@property(nonatomic,strong) PhotoEditModel *model;

+ (double)width;
+ (double)height;

@end
