//
//  NewFriendTableCell.h
//  Tutu
//
//  Created by gexing on 3/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplyFriendModel.h"
@protocol NewFriendTableCellDelegate <NSObject>

- (void)acceptButtonClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath;
- (void)addFriendButtonClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath;
- (void)replyButtonClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath;
- (void)avatarClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath;
@end
@interface NewFriendTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *hasAddedLabel;
@property (weak, nonatomic) IBOutlet UIView *contentBg;
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *replyBgView;
@property (nonatomic)BOOL isEditing;

@property (weak, nonatomic) IBOutlet UIImageView *replyBgImage;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong)ApplyFriendModel *applyModel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *msgLabArray;
@property(nonatomic,weak)id <NewFriendTableCellDelegate>delegate;
- (IBAction)acceptButtonClick:(id)sender;
- (IBAction)replyButtonClick:(id)sender;
- (IBAction)addButtonClick:(id)sender;
- (void)loadCellWith:(ApplyFriendModel *)infoModel;
- (IBAction)avatarButtonClick:(id)sender;
+ (CGFloat)calculateCellHeight:(ApplyFriendModel *)info isEditinag:(BOOL)isEditing;
@end
