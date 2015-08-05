//
//  UserFocusCell.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserFocusModel.h"
#import "EasyTableView.h"

@protocol UserFocusTopicDelegate <NSObject>

-(void)itemFocusClick:(UserFocusModel *) focusModel;

-(void)itemTopicOnClick:(UserFocusTopicModel *)model focus:(UserFocusModel *) focusModel;

@end

@interface UserFocusCell : UITableViewCell<EasyTableViewDelegate>

@property (weak, nonatomic) id<UserFocusTopicDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *topBg;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnFocus;


@property (weak, nonatomic) IBOutlet UILabel *lblNum;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;



-(void)dataToView:(UserFocusModel*) model width:(CGFloat) w;

@end
