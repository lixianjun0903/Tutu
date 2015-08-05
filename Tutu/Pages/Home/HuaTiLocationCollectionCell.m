//
//  HuaTiLocationCollectionCell.m
//  Tutu
//
//  Created by gexing on 5/26/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "HuaTiLocationCollectionCell.h"
#import "HuaTiLocationCell.h"

@implementation HuaTiLocationCollectionCell

- (void)awakeFromNib {
    // Initialization code
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, PIC_ITEM_WIDTH, PIC_ITEM_WIDTH)];
    [self.contentView addSubview:_imageView];
    _imageView.layer.masksToBounds = YES;
    _imageView.backgroundColor = [UIColor whiteColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
}
- (void)reloadCellWithModel:(HuaTiModel *)model{
    _huaTiModel = model;
    [_imageView sd_setImageWithURL:StrToUrl(_huaTiModel.content) placeholderImage:[UIImage imageNamed:@""]];
}
@end
