//
//  MyFriendCell.h
//  Tutu
//
//  Created by feng on 14-10-27.
//  Copyright (c) 2014年 zxy. All rights reserved.
//


typedef NS_ENUM(NSInteger, UserCellType) {

    CellTypeMyFriend,//cell类型为我的好友
    CellTypeBlockMessage,//cell类型为屏蔽私信
    CellTypeBlockTopic,//Cell类型为屏蔽主题
    CellTypeShareMyFriend,//cell类型为分享QQ好友的
};

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@protocol MyFriendCellDelegate <NSObject>
@optional
- (void)nickNameClick:(UserInfo *)userModel;
- (void)avatarClick:(UserInfo *)userModel;

@end
@interface MyFriendCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *descLab;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property(nonatomic,strong)UserInfo *userModel;

@property (weak, nonatomic) IBOutlet UIButton *nickNameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *flagView;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageV;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property(nonatomic,weak) id <MyFriendCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet UIImageView *friendBlockImage;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UIImageView *certificationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightXTagView;


@property (nonatomic) BOOL isShowRigthBtn;
@property(nonatomic)BOOL isLogin;
@property(nonatomic)UserCellType cellType;
- (void)cellReloadWithModel:(UserInfo *)model;
- (NSArray *)setRightButtons;
@end
