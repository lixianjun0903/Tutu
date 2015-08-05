//
//  UserCenterViewController.h
//  Tutu
//
//  Created by gaoyong on 14-10-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ImageGridCell.h"

static UIEdgeInsets ContentInsets = { .top = 0, .left = 0, .right = 0, .bottom = 0 };
@implementation ImageGridCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *background = [[UIView alloc] init];
        background.backgroundColor = [UIColor blackColor];
        self.selectedBackgroundView = background;
        self.backgroundView = background;
        _image = [[UIImageView alloc] init];
        _image.contentMode = UIViewContentModeScaleAspectFit;
        _image.layer.borderWidth=0.75f;
        _image.layer.borderColor=UIColorFromRGB(ListLineColor).CGColor;
        [self.contentView addSubview:_image];
    }
    return self;
}

- (void)layoutSubviews {

    CGFloat imageHeight = CGRectGetHeight(self.bounds) - ContentInsets.top - ContentInsets.bottom;
    CGFloat imageWidth = CGRectGetWidth(self.bounds) - ContentInsets.left - ContentInsets.right;
    _image.frame = CGRectMake(ContentInsets.left, ContentInsets.top, imageWidth, imageHeight);
}

@end
