//
//  RecommendLocationCell.h
//  Tutu
//
//  Created by gexing on 5/21/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecommendLocationCellDelegate <NSObject>
- (void)locationClick:(RecommendLocationModel *)model index:(NSInteger)index;
@end
@interface RecommendLocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (nonatomic,strong) RecommendLocationModel *locationModel;
@property (weak, nonatomic)  id <RecommendLocationCellDelegate>delegate;
@property (nonatomic )NSInteger cellIndex;
- (IBAction)statusButtonClick:(id)sender;

- (void)loadCellWithModel:(RecommendLocationModel *)model;
@end
