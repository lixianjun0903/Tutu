//
//  PhotoAlbumCell.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPhotoAlbumCellHeight 85

@interface PhotoAlbumCell : UITableViewCell

@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,strong) UILabel *labName;
@property(nonatomic,strong) UILabel *labSize;

@property(nonatomic,assign) int width;

@end
