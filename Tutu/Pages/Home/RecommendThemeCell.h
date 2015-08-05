//
//  RecommendThemeCell.h
//  Tutu
//
//  Created by gexing on 5/21/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecommendThemeCellDelegate <NSObject>
- (void)themeClick:(RecommendThemeModel *)model index:(NSInteger)index;
@end
@interface RecommendThemeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (nonatomic,strong) RecommendThemeModel *themeModel;
@property (weak, nonatomic)  id <RecommendThemeCellDelegate>delegate;
@property (nonatomic )NSInteger cellIndex;

- (IBAction)statusButtonClick:(id)sender;

- (void)loadCellWithModel:(RecommendThemeModel *)model;
@end
