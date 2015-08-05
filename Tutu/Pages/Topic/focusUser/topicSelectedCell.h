//
//  topicSelectedCell.h
//  Tutu
//
//  Created by gexing on 15/4/17.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topicHotModel.h"
@interface topicSelectedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
-(void)cellLoadWith:(topicHotModel *)model;

@end
