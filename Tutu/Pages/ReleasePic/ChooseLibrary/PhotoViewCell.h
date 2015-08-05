//
//  PhotoCell.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoViewModel : NSObject

@property(nonatomic,strong) ALAsset *asset;
@property(nonatomic,strong) NSURL *imageURL;
@property(nonatomic,assign) BOOL checked;

@end

@interface PhotoViewCell : UICollectionViewCell

@property(nonatomic,strong) PhotoViewModel *model;

-(void)setChecked:(BOOL)checked;

@end
