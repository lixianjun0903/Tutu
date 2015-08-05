//
//  HuaTiLocationCell.h
//  Tutu
//
//  Created by gexing on 5/20/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#define HuaTiCell_Height   (44 + ScreenWidth + 10)
#define PIC_ITEM_WIDTH     (82 * ScreenScale)

#import <UIKit/UIKit.h>
#import "TopicDelegate.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeHuaTi,
    CellTypeLocation,
};
@interface HuaTiLocationCell : UITableViewCell <TopicDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UIView *headView;
@property(nonatomic,strong)UIView *middleView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UIImageView *locationIcon;
@property(nonatomic,strong)UILabel *descLabel;

@property(nonatomic,strong)TopicModel *topicModel;
@property(nonatomic,weak)id <TopicDelegate>topicDelegate;
@property(nonatomic)CellType cellType;
- (void)reloadCellWithModel:(TopicModel *)topicModel;

+ (CGFloat)getCellHeight;
@end