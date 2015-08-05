//
//  ThemeCell.h
//  Tutu
//
//  Created by gexing on 4/8/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "TopicDelegate.h"
//话题cell
@interface ThemeCell : UITableViewCell <TopicDelegate>
@property(nonatomic,strong)UIView *headView;
@property(nonatomic,strong)UIView *middleView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *moreButton;
@property(nonatomic,strong)NSMutableArray *imageArray;
@property(nonatomic,strong)NSMutableArray *labelArray;
@property(nonatomic,strong)TopicModel *topicModel;
@property(nonatomic,weak)id <TopicDelegate>topicDelegate;
- (void)stopVideo;
- (void)playVideo;
- (void)reloadCellWithModel:(TopicModel *)topicModel;
+ (CGFloat)getCellHeight;
@end
