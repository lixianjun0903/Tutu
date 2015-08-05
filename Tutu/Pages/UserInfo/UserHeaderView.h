//
//  UserHeaderView.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, UserViewHeaderClickTag) {
    ItemClickTag_ChangeCover=1,
    ItemClickTag_ChangeAvatar=2,
    ItemClickTag_Zan=3,
    ItemClickTag_Edit=4,
    ItemClickTag_Send=5,
    ItemClickTag_Fav=6,
    ItemClickTag_Focus=7,
};


@protocol UserViewHeaderDelegate <NSObject>

-(void)itemClick:(UserViewHeaderClickTag) tag;

@end

@interface UserHeaderView : UIView

@property (nonatomic ,strong) id<UserViewHeaderDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *zanButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *tutuNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *ageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ageImageView;
@property (weak, nonatomic) IBOutlet UILabel *adrAndXZLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;
@property (weak, nonatomic) IBOutlet UILabel *focusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verticalLine1;
@property (weak, nonatomic) IBOutlet UIImageView *verticalLine2;
@property (weak, nonatomic) IBOutlet UIImageView *beKillView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBackBg;


-(CGFloat)dataToView:(UserInfo *) info isSelf:(BOOL) ismy width:(CGFloat) viewWidth;

-(void)changeMenuButtonStype:(UserViewHeaderClickTag) tag isAnimate:(BOOL) animate;
@end
