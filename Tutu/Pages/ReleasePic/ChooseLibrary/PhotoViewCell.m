//
//  PhotoCell.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "PhotoViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>


#define kShadeColor 0xFFFFFF

@implementation PhotoViewModel

- (instancetype)init
{
    self=[super init];
    if (self) {
        _checked=NO;
    }
    return self;
}

@end

@interface PhotoViewCell()

@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,strong) UIImageView *imgFlag;
@property(nonatomic,strong) UIView *viwShade;

@end

@implementation PhotoViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    _imgView=[[UIImageView alloc]init];
    _imgView.frame=self.bounds;
    _imgView.image=nil;
    _imgView.contentMode=UIViewContentModeScaleAspectFill;
    _imgView.layer.masksToBounds=YES;
    [self addSubview:_imgView];
    
    CGRect gridFrame=self.bounds;
    double w=gridFrame.size.width/4,h=w;
    int gap=5;
    _imgFlag=[[UIImageView alloc]init];
    _imgFlag.frame=CGRectMake(gridFrame.size.width-w-gap, gridFrame.size.height-h-gap, w, h);
    _imgFlag.image=[UIImage imageNamed:@"photo_checked.png"];
    _imgFlag.hidden=YES;
    [self addSubview:_imgFlag];
    
    _viwShade=[[UIView alloc]init];
    _viwShade.frame=self.bounds;
    _viwShade.backgroundColor=UIColorFromRGB(kShadeColor);
    _viwShade.alpha=20.0/100;
    _viwShade.hidden=YES;
    [self addSubview:_viwShade];
}

- (void)setModel:(PhotoViewModel *)model
{
    _model=model;

    _imgView.image=[UIImage imageWithCGImage:model.asset.aspectRatioThumbnail];
    [self setChecked:_model.checked];
}

-(void)setChecked:(BOOL)checked
{
    if (checked) {
        _imgFlag.hidden=NO;
        _viwShade.hidden=NO;
    }
    else{
        _imgFlag.hidden=YES;
        _viwShade.hidden=YES;
    }
}

@end
