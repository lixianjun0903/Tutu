//
//  ManagerCell.h
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagerUserModel.h"
#import "TCCopyableLabel.h"
@protocol ManagerCellDelegate <NSObject>
@optional;
- (void)label:(TCCopyableLabel *)copyableLabel didCopyText:(NSString *)copiedText;
@end
@interface ManagerCell : UITableViewCell<TCCopyableLabelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titlenameLabel;
@property (weak, nonatomic) IBOutlet TCCopyableLabel *detailInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailArrowImage;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (assign,nonatomic)ManagerCellType type;


@property(nonatomic,weak) id <ManagerCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *lineView;


@property (weak,nonatomic)NSString *imagePath;

-(void)setWithModel:(ManagerUserModel*)model;
-(void)setLineHidden;
@end
