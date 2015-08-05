//
//  AddressFriendCell.h
//  Tutu
//
//  Created by gexing on 14/12/11.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkManModel.h"
typedef NS_ENUM(NSInteger, AddressButtonType) {

    ButtonTypeAddFriend = 100,//加tutu好友
    ButtonTypeChat,//进入私聊
    ButtonTypeInvitation,//发短信邀请
};

@protocol AddressFriendCellDelegate <NSObject>

- (void)addFriendButtonClick:(AddressButtonType)buttonType model:(LinkManModel *)model index:(NSIndexPath*)indexPath isSearchTabel:(BOOL)search;

@end
@interface AddressFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property(nonatomic,weak)id <AddressFriendCellDelegate> delegate;
@property(nonatomic,strong)LinkManModel *linkModel;
@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic)BOOL isSearchTabel;
- (void)loadCellWith:(LinkManModel *)model;
@end
