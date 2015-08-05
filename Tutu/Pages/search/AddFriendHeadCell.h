//
//  AddFriendHeadCell.h
//  Tutu
//
//  Created by gexing on 3/18/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendHeadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UILabel *msgCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightPoint;
@property (weak, nonatomic) IBOutlet UILabel *friendValidationLabel;

- (void)cellReloadWith:(NSString *)count;

@end
