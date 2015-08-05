//
//  RecommentCell.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/14.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, RecommentItemTag){
    RecommentItemFocus=1,
    RecommentItemImageView1=2,
    RecommentItemImageView2=3,
    RecommentItemImageView3=4,
};

@protocol RecommentCellDeletage <NSObject>

-(void)itemClick:(UserInfo *)info tag:(RecommentItemTag) tag;

@end

@interface RecommentCell : UITableViewCell

@property (weak, nonatomic) id<RecommentCellDeletage> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderTagImage;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderView;
@property (weak, nonatomic) IBOutlet UIImageView *blockTagView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImage;
@property (weak, nonatomic) IBOutlet UIImageView *topicView1;
@property (weak, nonatomic) IBOutlet UIImageView *topicView2;
@property (weak, nonatomic) IBOutlet UIImageView *topicView3;
@property (weak, nonatomic) IBOutlet UIButton *attentButton;

@property (weak, nonatomic) IBOutlet UIImageView *bottomLineView;

@property (weak, nonatomic) IBOutlet UIImageView *certificationImageView;



-(void)dataToView:(UserInfo *)info with:(CGFloat) w;

@end
