//
//  PhotoAlbumCell.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "PhotoAlbumCell.h"

@implementation PhotoAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         [self setUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setUI
{
    _imgView=[[UIImageView alloc]init];
    _imgView.frame=CGRectMake(10, 10, 65, 65);
    _imgView.contentMode=UIViewContentModeScaleAspectFill;
    _imgView.layer.masksToBounds=YES;
    [self addSubview:_imgView];
    
    _labName=[[UILabel alloc]init];
    _labName.frame=CGRectMake(92, 25, 100, 20);
    _labName.font=[UIFont systemFontOfSize:16];
    [self addSubview:_labName];
    
    _labSize=[[UILabel alloc]init];
    _labSize.frame=CGRectMake(92, 45, 100, 20);
    _labSize.font=[UIFont systemFontOfSize:11];
    [self addSubview:_labSize];
}

- (void)setWidth:(int)width
{
    _width=width;
    
    double line_h=0.7;
    UIView *view=[[UIView alloc]init];
    view.frame=CGRectMake(0, kPhotoAlbumCellHeight-line_h, width, line_h);
    view.backgroundColor=UIColorFromRGB(0xCACACA);
    [self addSubview:view];
    
    double ratio=1.0/2,w=14*ratio,h=22*ratio,gap=17;
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(_width-w-gap, (kPhotoAlbumCellHeight-h)/2, w, h);
    imgView.image=[UIImage imageNamed:@"photo_to_right.png"];
    [self addSubview:imgView];
}

@end
