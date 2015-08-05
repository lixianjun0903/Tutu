//
//  MyFriendCell.m
//  Tutu
//
//  Created by feng on 14-10-27.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "MyFriendCell.h"
#import "UIImageView+WebCache.h"
@implementation MyFriendCell

- (void)awakeFromNib {
    // Initialization code
    [_flagView.layer setCornerRadius:0];
    _flagView.layer.masksToBounds = YES;
    
    [_nickNameBtn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateNormal];
    _nickNameBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
    _nickNameBtn.titleLabel.font = ListTitleFont;
    _nickNameBtn.userInteractionEnabled = NO;
    [_nickNameBtn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateHighlighted];
    
    _descLab.textColor = HEXCOLOR(TextGrayColor);
    _descLab.adjustsFontSizeToFitWidth = NO;
    _descLab.font = ListDetailFont;
    _ageLab.textColor = [UIColor whiteColor];
   
    _avatar.image = [UIImage imageNamed:@"avatar_default"];
    [_avatar.layer setCornerRadius:_avatar.mj_width/2.0];
    _avatar.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)cellReloadWithModel:(UserInfo *)model{
    _userModel = model;
    _isShowRigthBtn = NO;
    [_friendBlockImage setHidden:YES];

    //设置名称
    [_nickNameBtn setTitle:_userModel.nickname forState:UIControlStateNormal];
    _descLab.text = _userModel.sign;
    
    //设置年龄
    _ageLab.text = _userModel.age;
    
    //设置性别标识的位置
    
    CGSize size = [_userModel.nickname sizeWithFont:_nickNameBtn.titleLabel.font];
    
    if (size.width > _nickNameBtn.mj_width - 10) {
        size.width = _nickNameBtn.mj_width - 10;
    }
    
//    _flagView.frame = CGRectMake(_nickNameBtn.mj_x + size.width + 10, _flagView.frame.origin.y, _flagView.mj_width, _flagView.mj_height);
    
    //设置性别图片和背景色
    if ([_userModel.gender isEqualToString:@"1"]) {
        _sexImageV.image = [UIImage imageNamed:@"boy"];
        [self.flagView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderBoyColorBg)]];
//        _flagView.backgroundColor = UIColorFromRGB(GenderBoyColorBg);
    }else if ([_userModel.gender isEqualToString:@"2"]){
        _sexImageV.image = [UIImage imageNamed:@"girl"];
        [self.flagView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderGirlColorBg)]];
//        _flagView.backgroundColor = UIColorFromRGB(GenderGirlColorBg);
    }else{
    }
    
    
    // 昵称实际的最大宽度
    CGFloat nw=self.rightXTagView.frame.origin.x-70;
    self.rightXTagView.hidden=YES;
    
    // 昵称的实际宽度
    CGFloat nameW=[SysTools getWidthContain:model.nickname font:ListTitleFont Height:20]+2;
    CGRect nickf=self.nickNameBtn.frame;
    
    //认证和等级的标识的宽度
    CGFloat sw=0;
    if(model.userhonorlevel>0){
        sw=sw+25;
    }
    if(model.isauth){
        sw=sw+20;
    }
    
    if((nameW+sw) < nw){
        nickf.size.width=nameW;
        [self.nickNameBtn setFrame:nickf];
    }else{
        nickf.size.width=nw-sw;
        [self.nickNameBtn setFrame:nickf];
    }
    
    self.certificationImageView.hidden=YES;
    if(model.isauth){
        self.certificationImageView.hidden=NO;
        
        CGRect certificationF=self.certificationImageView.frame;
        certificationF.origin.x=nickf.size.width+nickf.origin.x+5;
        [self.certificationImageView setFrame:certificationF];
    }
    
    if(model.userhonorlevel==0){
        self.levelImageView.hidden=YES;
    }else{
        self.levelImageView.hidden=NO;
        [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
        CGRect leveF=self.levelImageView.frame;
        if(model.isauth){
            leveF.origin.x=self.certificationImageView.frame.size.width+self.certificationImageView.frame.origin.x+5;
        }else{
            leveF.origin.x=nickf.size.width+nickf.origin.x+5;
        }
        WSLog(@"%@",NSStringFromCGRect(leveF));
        [self.levelImageView setFrame:leveF];
    }
    
    
    //是否显示屏蔽图标
    if (_cellType == CellTypeMyFriend) {
        if (_userModel.isBlock == YES) {
            [_friendBlockImage setHidden:NO];
        }else{
            [_friendBlockImage setHidden:YES];
        }

    }

    [_avatar sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:_userModel.uid time:_userModel.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}

//创建屏蔽按钮

- (UIButton *)createBlockButton{
    
    UIButton *btn = [[UIButton alloc]init];
    btn.frame = CGRectMake(0, 0.5, 100, 65);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.backgroundColor = HEXCOLOR(0xc8c7cc);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_userModel.isBlock == YES) {
        [btn setTitle:TTLocalString(@"TT_cancel_block") forState:UIControlStateNormal];
    }else{
        [btn setTitle:TTLocalString(@"TT_block_message") forState:UIControlStateNormal];
    }
    return btn;

}
//创建删去好友按钮
- (UIButton *)createDeleButton{
    UIButton *btn = [[UIButton alloc]init];
    btn.frame = CGRectMake(0, 0.5, 70, 65);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.backgroundColor = HEXCOLOR(0xFD322F);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if ([_userModel.relation integerValue] == 3 || [_userModel.relation integerValue] == 2) {
        [btn setTitle:TTLocalString(@"TT_delete_friend") forState:UIControlStateNormal];
    }else{
        [btn setTitle:TTLocalString(@"TT_add_friend") forState:UIControlStateNormal];
    }
    return btn;

}
- (NSArray *)setRightButtons{
    if (_cellType == CellTypeBlockMessage || _cellType == CellTypeBlockTopic) {
        UIButton *btn = [[UIButton alloc]init];
        btn.frame = CGRectMake(0, 0.5, 70, 65);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:TTLocalString(@"TT_delete") forState:UIControlStateNormal];
        btn.backgroundColor = HEXCOLOR(0xFD322F);
        NSArray *array = @[btn];
        return array;
        
    }else{
        UIButton *btn = [[UIButton alloc]init];
        btn.frame = CGRectMake(0, 0.5, 70, 65);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:TTLocalString(@"TT_modify_remark") forState:UIControlStateNormal];
        btn.backgroundColor = HEXCOLOR(0xc8c7cc);
        NSArray *array = @[btn];
        return array;
    }
}


@end
