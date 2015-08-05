//
//  FeedsCell.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedsModel.h"

@protocol FeedHeaderClickDelegate <NSObject>

-(void)headerClick:(FeedsModel *) item;

@end


@interface FeedsCell : UITableViewCell
@property (weak, nonatomic) id<FeedHeaderClickDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *newsDotImage;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@property (weak, nonatomic) IBOutlet UIImageView *certificationImageView;



-(void)initDataToView:(FeedsModel *)model;

@end
