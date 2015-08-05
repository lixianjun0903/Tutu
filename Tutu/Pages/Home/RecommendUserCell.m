//
//  RecommendUserCell.m
//  Tutu
//
//  Created by gexing on 5/21/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "RecommendUserCell.h"
#import "UserDetailController.h"
@implementation RecommendUserCell

- (void)awakeFromNib {
    // Initialization code
    _nameLabel.textColor = HEXCOLOR(TextBlackColor);
    _descLabel.textColor = HEXCOLOR(TextGrayColor);
    _avatarView.userInteractionEnabled = YES;
    _nameLabel.userInteractionEnabled = YES;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.mj_width / 2.f;
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_nameLabel addGestureRecognizer:nameTap];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_avatarView addGestureRecognizer:avatarTap];
    _FlagView.layer.masksToBounds = YES;
    _FlagView.layer.cornerRadius = 2.f;
    
}
- (void)tap:(UITapGestureRecognizer *)tap{
    if (_delegate && [_delegate respondsToSelector:@selector(userAvatarClick:index:)]) {
        [_delegate userAvatarClick:_userModel index:_cellIndex];
    }
}
- (void)loadCellWithModel:(RecommendUserModel *)model{
    [_vipImageView setHidden:YES];
    _userModel = model;
    if (model.relation == 4) {
        [_statusBtn setHidden:YES];
    }else{
        [_statusBtn setHidden:NO];
        if (model.relation == 2 ) {
            _statusBtn.userInteractionEnabled = NO;
            [_statusBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_item_focus_nor1"] forState:UIControlStateNormal];
        }else if (model.relation == 3){
            _statusBtn.userInteractionEnabled = NO;
            [_statusBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_item_focus_nor2"] forState:UIControlStateNormal];
        }else{
            _statusBtn.userInteractionEnabled = YES;
            [_statusBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_item_focus_nor0"] forState:UIControlStateNormal];
        }
    }

    [_avatarView sd_setImageWithURL:StrToUrl([SysTools getHeaderImageURL:IntToString(_userModel.uid) time:IntToString(_userModel.avatartime)]) placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    _nameLabel.text = _userModel.nickname;
    _descLabel.text = _userModel.descinfo;
    
    _ageLabel.text = FormatString(@"%d", _userModel.age);
    
    NSString *gender=@"girl.png";
    [_FlagView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderGirlColorBg)]];
    if( _userModel.gender == 1){
        gender=@"boy.png";
        [_FlagView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderBoyColorBg)]];
    }
    _genderView.image = [UIImage imageNamed:gender];
    CGSize nameSize = [_userModel.nickname sizeWithFont:_nameLabel.font];
    if (nameSize.width > ScreenWidth - 170) {
        nameSize.width = ScreenWidth - 170;
    }
    _nameLabel.frame = CGRectMake(_nameLabel.mj_x, _nameLabel.mj_y, nameSize.width, _nameLabel.mj_height);
    _FlagView.frame = CGRectMake(_nameLabel.max_x + 5, _FlagView.mj_y, _FlagView.mj_width, _FlagView.mj_height);
    
    if (_userModel.isauth == 1) {
        [_vipImageView setHidden:NO];
        _vipImageView.frame = CGRectMake(_FlagView.max_x + 5, _vipImageView.mj_y, 16, 16);
    }else{
        _vipImageView.frame = CGRectMake(_FlagView.max_x + 5, _vipImageView.mj_y, 0, 0);
    }
    _levelImageView.frame = CGRectMake(_vipImageView.max_x + 5, _levelImageView.mj_y, _levelImageView.mj_width, _levelImageView.mj_height);
    _levelImageView.image = [UIImage imageNamed:FormatString(@"user_level%d", _userModel.userhonorlevel)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//添加关注
- (IBAction)statusButtonClick:(id)sender {
    [[RequestTools getInstance]get:API_ADD_Follow_User(IntToString(_userModel.uid)) isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]intValue] == 10000) {
            [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_follow_success")];
            _statusBtn.userInteractionEnabled = NO;
            if (_userModel.relation == 0) {
                _userModel.relation = 2;
               [_statusBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_item_focus_nor1"] forState:UIControlStateNormal]; 
            }else if (_userModel.relation == 1){
                _userModel.relation = 3;
                [_statusBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_item_focus_nor2"] forState:UIControlStateNormal];
                
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
@end
