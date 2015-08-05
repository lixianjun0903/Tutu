//
//  UserFansCell.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FansCellDelegate <NSObject>

-(void)itemFocusClick:(UserInfo *)info;

@end


@interface UserFansCell : UITableViewCell

@property(nonatomic,strong) id<FansCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UILabel *nickLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (weak, nonatomic) IBOutlet UIImageView *genderView;
@property (weak, nonatomic) IBOutlet UIImageView *genderImage;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *isblockImage;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@property (weak, nonatomic) IBOutlet UIButton *doActionButton;

@property (weak, nonatomic) IBOutlet UIImageView *certificationImageView;



-(void)dataToView:(UserInfo *)info;
-(void)dataToView:(UserInfo *)model followTime:(NSString *)time;


@end
