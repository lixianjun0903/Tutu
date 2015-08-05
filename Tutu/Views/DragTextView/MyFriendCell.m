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
    [_flagView.layer setCornerRadius:2];
    _flagView.layer.masksToBounds = YES;
    _lineView.backgroundColor = UIColorFromRGB(ListLineColor);
    _lineView.alpha = 0.75;
   
    _butomLine.backgroundColor = UIColorFromRGB(ListLineColor);
    _butomLine.alpha = 0.75;
    
    [_nickNameBtn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateNormal];
    _nickNameBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
    _nickNameBtn.titleLabel.font = ListTitleFont;
    _nickNameBtn.userInteractionEnabled = NO;
    [_nickNameBtn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateHighlighted];
    
    _descLab.textColor = HEXCOLOR(TextGrayColor);
    _descLab.adjustsFontSizeToFitWidth = NO;
    _descLab.font = ListDetailFont;
    _ageLab.textColor = [UIColor whiteColor];
   
    [_flagView.layer setCornerRadius:2];
    _flagView.layer.masksToBounds = YES;
    
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
    
//    if (_cellType == CellTypeBlockMessage || _cellType == CellTypeBlockTopic || _cellType == CellTypeShareMyFriend || _cellType == CellTypeMyFriend) {
//        [_friendStatusBtn setHidden:YES];
//        [_lineView setHidden:YES];
//        [_friendBlockImage setHidden:YES];
//    }
    _userModel = model;
  
    _isShowRigthBtn = NO;
//    if (_cellType == CellTypeMyFriend) {
//        if (_isLogin == YES) {
//            [_lineView setHidden:NO];
//            [_friendStatusBtn setHidden:NO];
//        }else{
//            [_lineView setHidden:YES];
//            [_lineView setHidden:YES];
//        }
//    }
    [_friendStatusBtn setHidden:YES];
    [_lineView setHidden:YES];
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
    
    _flagView.frame = CGRectMake(_nickNameBtn.mj_x + size.width + 10, _flagView.frame.origin.y, _flagView.mj_width, _flagView.mj_height);
    
    //设置性别图片和背景色
    if ([_userModel.gender isEqualToString:@"1"]) {
        _sexImageV.image = [UIImage imageNamed:@"boy"];
        _flagView.backgroundColor = UIColorFromRGB(GenderBoyColorBg);
    }else if ([_userModel.gender isEqualToString:@"2"]){
        _sexImageV.image = [UIImage imageNamed:@"girl"];
        _flagView.backgroundColor = UIColorFromRGB(GenderGirlColorBg);
    }else{
    }
    
    if(model.userhonorlevel==0){
        self.levelImageView.hidden=YES;
    }else{
        [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
    }
    
    //是否显示屏蔽图标
    if (_cellType == CellTypeMyFriend) {
        if (_userModel.isBlock == YES) {
            [_friendBlockImage setHidden:NO];
        }else{
            [_friendBlockImage setHidden:YES];
        }
          // [_lineView setHidden:NO];
        if ([_userModel.relation integerValue] == 3) {
            [_friendStatusBtn setImage:[UIImage imageNamed:@"friend_2"] forState:UIControlStateNormal];
        }else if ([_userModel.relation integerValue] == 2){
            [_friendStatusBtn setImage:[UIImage imageNamed:@"friend_1"] forState:UIControlStateNormal];
        }else if ([_userModel.relation integerValue] == 4){
           // [_lineView setHidden:YES];
            [_friendStatusBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }
        else{
            [_friendStatusBtn setImage:[UIImage imageNamed:@"friend_3"] forState:UIControlStateNormal];
        }
    }

    [_avatar sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:_userModel.uid time:_userModel.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}
//当是本人的时候，不能从右边划开
- (IBAction)friendStatusBtnClick:(id)sender {
    if ([self.userModel.relation integerValue] == 4) {
        return;
    }
    
    [self showRightUtilityButtonsAnimated:YES];
    
}
//创建屏蔽按钮

- (UIButton *)createBlockButton{
    
    UIButton *btn = [[UIButton alloc]init];
    btn.frame = CGRectMake(0, 0.5, 100, 65);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.backgroundColor = HEXCOLOR(0xc8c7cc);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_userModel.isBlock == YES) {
        [btn setTitle:@"取消屏蔽" forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"屏蔽私信" forState:UIControlStateNormal];
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
        [btn setTitle:@"删除好友" forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"加为好友" forState:UIControlStateNormal];
    }
    return btn;

}
- (NSArray *)setRightButtons{
    if (_cellType == CellTypeBlockMessage || _cellType == CellTypeBlockTopic) {
        UIButton *btn = [[UIButton alloc]init];
        btn.frame = CGRectMake(0, 0.5, 70, 65);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:@"删除" forState:UIControlStateNormal];
        btn.backgroundColor = HEXCOLOR(0xFD322F);
        NSArray *array = @[btn];
        return array;
        
    }else{
        UIButton *blockBtn = [self createBlockButton];
        
        UIButton *deleBtn = [self createDeleButton];
        
        return [[NSArray alloc]initWithObjects:blockBtn,deleBtn, nil];
 
    }
}

////取消屏蔽
//- (void)messageUnBlokcClick:(id)sender{
//
//}
////屏蔽私信
//- (void)messageBlockClick:(id)sender{
//
//}
//- (void)deleteButtonClick:(id)sender{
//
//}
- (IBAction)avatarButtonClick:(id)sender {
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(avatarClick:)]) {
        [_cellDelegate avatarClick:_userModel];
    }
}
- (IBAction)nickNameClick:(id)sender {
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(nickNameClick:)]) {
        [_cellDelegate nickNameClick:_userModel];
    }
}
@end
