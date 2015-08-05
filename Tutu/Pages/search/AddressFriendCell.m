//
//  AddressFriendCell.m
//  Tutu
//
//  Created by gexing on 14/12/11.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AddressFriendCell.h"
#import "UIImage+ImageWithColor.h"

@implementation AddressFriendCell

- (void)awakeFromNib {
    // Initialization code
    _addButton.layer.masksToBounds = YES;
    [_addButton.layer setCornerRadius:_addButton.mj_height / 2.0f];
    _addButton.layer.borderColor = HEXCOLOR(SystemColor).CGColor;
    
    
    [_addButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _nickNameLabel.adjustsFontSizeToFitWidth = NO;
    _nickNameLabel.font = ListTitleFont;//[UIFont boldSystemFontOfSize:16];
    _nickNameLabel.textColor = HEXCOLOR(TextBlackColor);
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, 44, ScreenWidth - 30, 0.6)];
    lineView.backgroundColor = HEXCOLOR(ListLineColor);
    [self.contentView addSubview:lineView];
}
- (void)loadCellWith:(LinkManModel *)model{
    _linkModel = model;
    _nickNameLabel.text = _linkModel.nickName;
    _addButton.tag = 0;
    _addButton.userInteractionEnabled = YES;
    [_addButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_addButton setBackgroundColor:[UIColor clearColor]];
    
    if (model.relation == -1) {
        [_addButton setImage:nil forState:UIControlStateNormal];
        _addButton.layer.borderWidth = 0.6f;
        _addButton.tag = ButtonTypeInvitation;
        [_addButton setTitle:TTLocalString(@"TT_invitation") forState:UIControlStateNormal];
        _addButton.backgroundColor = [UIColor whiteColor];
        [_addButton setTitleColor:HEXCOLOR(SystemColor) forState:UIControlStateNormal];
        [_addButton setTitleColor:HEXCOLOR(0x87dbc4) forState:UIControlStateHighlighted];
    }else if (model.relation == 0 || model.relation==1){
        [_addButton setTitle:nil forState:UIControlStateNormal];
        _addButton.tag = ButtonTypeAddFriend;
        _addButton.layer.borderWidth = 0.6f;
        [_addButton setTitle:TTLocalString(@"TT_add_friends") forState:UIControlStateNormal];
//        _addButton.backgroundColor = HEXCOLOR(SystemColor);
        [_addButton setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        [_addButton setTitleColor:HEXCOLOR(0x87dbc4) forState:UIControlStateHighlighted];
        
        [_addButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor0"] forState:UIControlStateNormal];
        [_addButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel0"] forState:UIControlStateHighlighted];

    }else{
        [_addButton setTitle:nil forState:UIControlStateNormal];
        
        _addButton.tag = ButtonTypeChat;
        _addButton.layer.borderWidth = 0.0f;
        [_addButton setBackgroundColor:[UIColor clearColor]];
//        [_addButton setTitle:@"已添加" forState:UIControlStateNormal];
        [_addButton setTitleColor:HEXCOLOR(TextGrayColor) forState:UIControlStateNormal];
        _addButton.userInteractionEnabled = NO;
        if(model.relation==3){
            [_addButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor2"] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel2"] forState:UIControlStateHighlighted];
        }else{
            [_addButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor1"] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel1"] forState:UIControlStateHighlighted];
        }
    }
}
- (void)buttonClick:(UIButton *)btn{

    if (_delegate && [_delegate respondsToSelector:@selector(addFriendButtonClick:model:index:isSearchTabel:)]) {
        [_delegate addFriendButtonClick:btn.tag model:_linkModel index:_indexPath isSearchTabel:_isSearchTabel];
    }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
