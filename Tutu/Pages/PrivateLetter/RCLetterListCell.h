//
//  RCLetterListCell.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSessionModel.h"

@protocol RCListItemClickDelegate <NSObject>

-(void)avatarOnClick:(RCSessionModel *) item;

@end


@interface RCLetterListCell : UITableViewCell

@property (weak, nonatomic) id<RCListItemClickDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;

@property (weak, nonatomic) IBOutlet UILabel *newsNumLabel;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UIImageView *certificationImageView;


-(void)initDataToView:(RCSessionModel *)user width:(CGFloat ) w;

@end