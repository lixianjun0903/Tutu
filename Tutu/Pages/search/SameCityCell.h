//
//  SameCityCell.h
//  Tutu
//  用户信息cell，应用页面：附近、关注用户、@自动提醒
//  改动会同时引起其他页面，注意测试
//  Created by zhangxinyao on 14-11-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(int, ReferencePage) {
    ReferenceFocusUserPage=1,
    ReferenceSameCityPage=2,
    ReferenceSearchUserPage=3,
};

@interface SameCityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nickLabel;


@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (weak, nonatomic) IBOutlet UIImageView *genderView;
@property (weak, nonatomic) IBOutlet UIImageView *genderImage;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellSepetor;

@property (weak, nonatomic) IBOutlet UIImageView *isblockImage;

@property(nonatomic,strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@property (weak, nonatomic) IBOutlet UIView *disanceView;

@property (weak, nonatomic) IBOutlet UIImageView *certificationImageView;


-(void)initDataToView:(UserInfo *) model;
-(void)initDataToView:(UserInfo *) model reference:(ReferencePage) referencePage;
-(void)initDataToView:(UserInfo *) model width:(CGFloat) w reference:(ReferencePage) referencePage;

@end
