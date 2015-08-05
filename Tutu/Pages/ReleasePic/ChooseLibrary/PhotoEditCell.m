//
//  PhotoEditCell.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "PhotoEditCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define X 7.0
#define Y 5.0
#define W 85.0
#define H 100.0

@implementation PhotoEditModel

- (instancetype)init
{
    self=[super init];
    if (self) {
        _size=0;
    }
    return self;
}

@end

@interface PhotoEditCell ()

@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,strong) UILabel *labSize;

@end

@implementation PhotoEditCell

+ (double)width
{
    return X+W;
}

+ (double)height
{
    return Y+H;
}

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
    _imgView.frame=CGRectMake(X, Y, W, H);
    _imgView.image=nil;
    _imgView.contentMode=UIViewContentModeScaleAspectFill;
    _imgView.layer.masksToBounds=YES;
    _imgView.layer.cornerRadius=3.0;
    [self addSubview:_imgView];
    
    UIImageView *imgFlag=[[UIImageView alloc]init];
    imgFlag.frame=CGRectMake(2, 0, W/4.2, W/4.2);
    imgFlag.image=[UIImage imageNamed:@"photo_remove.png"];
    [self addSubview:imgFlag];
    
    int w=58/2,h=44/2,gap=5;
    _labSize=[[UILabel alloc]init];
    _labSize.frame=CGRectMake(W-w-gap, H-h-gap, w, h);
    _labSize.font=[UIFont systemFontOfSize:15];
    _labSize.text=@"0";
    _labSize.textColor=[UIColor whiteColor];
    _labSize.textAlignment=NSTextAlignmentCenter;
    _labSize.backgroundColor=[UIColor blackColor];
    _labSize.alpha=60.0/100;
    _labSize.layer.masksToBounds=YES;
    _labSize.layer.cornerRadius=3.0;
    [_imgView addSubview:_labSize];
}

- (void)setModel:(PhotoEditModel *)model
{
    _model=model;
    
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc] init];
    [library assetForURL:_model.imageURL
             resultBlock:^(ALAsset *asset){
                 UIImage *image=[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                 _imgView.image=image;
             }
            failureBlock:^(NSError *error){
                NSLog(@"operation was not successfull!");
            }
     ];
    
    _labSize.text=[NSString stringWithFormat:@"%i",model.size];
}

@end
