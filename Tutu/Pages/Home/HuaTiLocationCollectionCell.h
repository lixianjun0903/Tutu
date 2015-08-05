//
//  HuaTiLocationCollectionCell.h
//  Tutu
//
//  Created by gexing on 5/26/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HuaTiLocationCollectionCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)HuaTiModel *huaTiModel;
- (void)reloadCellWithModel:(HuaTiModel *)model;
@end
