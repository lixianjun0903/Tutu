//
//  RecommendUserCell.h
//  Tutu
//
//  Created by gexing on 5/21/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BaseController.h"
@protocol RecommendUserCellDelegate <NSObject>
- (void)userAvatarClick:(RecommendUserModel *)model index:(NSInteger)index;
@end
@interface RecommendUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (nonatomic,strong) RecommendUserModel *userModel;
@property (weak, nonatomic) IBOutlet UIImageView *FlagView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic)  id <RecommendUserCellDelegate>delegate;
@property (nonatomic )NSInteger cellIndex;

- (IBAction)statusButtonClick:(id)sender;

- (void)loadCellWithModel:(RecommendUserModel *)model;
@end

