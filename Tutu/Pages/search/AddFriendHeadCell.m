//
//  AddFriendHeadCell.m
//  Tutu
//
//  Created by gexing on 3/18/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "AddFriendHeadCell.h"

@implementation AddFriendHeadCell

- (void)awakeFromNib {
    // Initialization code
    _redView.layer.masksToBounds = YES;
    _redView.layer.cornerRadius = _redView.mj_width / 2.0f;
    _friendValidationLabel.text = TTLocalString(@"TT_friends_validation");
}
- (void)cellReloadWith:(NSString *)count{
    _redView.frame = CGRectMake(ScreenWidth - 64, _redView.mj_y, _redView.mj_width, _redView.mj_height);
    _rightPoint.frame = CGRectMake(ScreenWidth - 34, _rightPoint.mj_y, _rightPoint.mj_width, _rightPoint.mj_height);
    _msgCountLabel.text = count;
    if ([count integerValue] > 0) {
        [_redView setHidden:NO];
    }else{
        [_redView setHidden:YES];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
