//
//  UserHeaderCell.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

typedef NS_ENUM(NSInteger, UserHeaderCellClickTag) {
    UserChangeBgTag = 2,
    UserEditBtnTag = 3,
    UserMyListBtnTag = 4,
    UserMyCollectionBtnTag = 5,
    UserChangeAvatarTag=6,
    UserLikeTag = 7,
    UserMyFocusTag=8,
    UserFansTag=9,
    UserFocusActionTag=10,
    UserChatTag=11,
};


#import <UIKit/UIKit.h>
#import "InsetsLabel.h"

@protocol UserHeaderCellDelegate <NSObject>

@optional

- (void)headerViewClick:(UserHeaderCellClickTag)viewTag clickView:(UIView *) senderView;

@end


@interface UserHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *zanButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;


@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@property (weak, nonatomic) id<UserHeaderCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *changeBgButton;

@property (weak, nonatomic) IBOutlet InsetsLabel *certLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cerificationTagView;


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
@property (weak, nonatomic) IBOutlet UIButton *fansButton;

@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;
@property (weak, nonatomic) IBOutlet UILabel *focusLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;

@property (weak, nonatomic) IBOutlet UIImageView *verticalLine1;
@property (weak, nonatomic) IBOutlet UIImageView *verticalLine2;
@property (weak, nonatomic) IBOutlet UIImageView *verticalLine3;


@property (weak, nonatomic) IBOutlet UIImageView *focusDotImageView;

@property (weak, nonatomic) IBOutlet UIImageView *fansDotsImageView;


@property (weak, nonatomic) IBOutlet UIImageView *beKillView;
@property (weak, nonatomic) IBOutlet UIImageView *bgColorView;




-(void)dataToView:(UserInfo *)userInfo width:(CGFloat )releaseWidth type:(UserHeaderCellClickTag) clicktag animate:(BOOL) isanimate;


//手势切换
-(void)handleSwipeMove:(UISwipeGestureRecognizerDirection) dure;

@end
