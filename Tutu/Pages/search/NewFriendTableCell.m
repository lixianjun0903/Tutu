//
//  NewFriendTableCell.m
//  Tutu
//
//  Created by gexing on 3/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#define Left_Gap   32.f   //编辑状态下，视图整体向右移动距离

#import "NewFriendTableCell.h"
#import "UIImage+ImageWithColor.h"
#import "UIImageView+WebCache.h"
@implementation NewFriendTableCell

- (void)awakeFromNib {
    // Initialization code
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.cornerRadius = _avatarImageView.mj_height / 2.f;
    
    _acceptButton.layer.masksToBounds = YES;
    _acceptButton.layer.cornerRadius = _acceptButton.mj_height / 2.f;
    _addButton.layer.masksToBounds = YES;
    [_acceptButton  setBackgroundColor:HEXCOLOR(SystemColor)];
    [_acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_acceptButton setTitleColor:HEXCOLOR(0x87dbc4) forState:UIControlStateHighlighted];

    _addButton.layer.cornerRadius = _addButton.mj_height / 2.f;
    _addButton.layer.borderColor = HEXCOLOR(SystemColor).CGColor;
    _addButton.backgroundColor = HEXCOLOR(0xffffff);
    _addButton.layer.borderWidth = 1.F;
    [_addButton setTitleColor:HEXCOLOR(SystemColor) forState:UIControlStateNormal];
    [_addButton setTitleColor:HEXCOLOR(0x87dbc4) forState:UIControlStateHighlighted];
    
    _replyButton.layer.masksToBounds = YES;
    _replyButton.layer.cornerRadius = _replyButton.mj_height / 2.f;
    _replyButton.layer.borderColor = HEXCOLOR(0xE0E0E0).CGColor;
    [_replyButton setTitleColor:HEXCOLOR(0xE0E0E0) forState:UIControlStateNormal];
    _replyButton.layer.borderWidth = 0.6f;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)acceptButtonClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(acceptButtonClick: indexPath:  )]) {
        [_delegate acceptButtonClick:_applyModel indexPath:_indexPath];
    }
}

- (IBAction)replyButtonClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(replyButtonClick:indexPath:)]) {
        [_delegate replyButtonClick:_applyModel indexPath:_indexPath];
    }
}

- (IBAction)addButtonClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(addFriendButtonClick: indexPath:  )]) {
        [_delegate addFriendButtonClick:_applyModel indexPath:_indexPath];
    }
}
- (void)loadCellWith:(ApplyFriendModel *)infoModel{
   
    
    _hasAddedLabel.hidden = YES;
    _waitLabel.hidden = YES;
    _addButton.hidden = YES;
    _acceptButton.hidden = YES;
    _applyModel = infoModel;
   //    0等待验证 1已添加  2添加好友   3接受申请
    _nickName.text = _applyModel.nickname;
    
    if (_applyModel.applystatus == 0) {
        _waitLabel.hidden = NO;
    }else if(_applyModel.applystatus == 1){
        _hasAddedLabel.hidden = NO;
    }else if (_applyModel.applystatus == 2){
        _addButton.hidden = NO;
    }else if (_applyModel.applystatus == 3){
        _acceptButton.hidden = NO;
        
    }
    
    if (_isEditing) {
        _acceptButton.userInteractionEnabled = NO;
        _addButton.userInteractionEnabled = NO;
        _replyButton.userInteractionEnabled = NO;
        _avatarImageView.userInteractionEnabled = YES;
        [_selectView setHidden:NO];
    }else{
        _acceptButton.userInteractionEnabled = YES;
        _addButton.userInteractionEnabled = YES;
        _replyButton.userInteractionEnabled = YES;
        _avatarImageView.userInteractionEnabled = NO;
        [_selectView setHidden:YES];
    }
    
    if (_applyModel.applystatus == 1) {
        if (_applyModel.applymsglist.count > 0) {
            [_infoLabel setHidden:NO];
            ApplyModel *model = [_applyModel.applymsglist lastObject];
            NSString *content = @"";
            if (model.isme == YES) {
                content  = FormatString(@"%@:%@",TTLocalString(@"TT_me"),model.applymsg);
            }else{
                content = FormatString(@"%@:%@",_applyModel.nickname,model.applymsg);
            }
            _infoLabel.text = content;
        }
    }
    
    if (_applyModel.applystatus == 1 || _applyModel.applystatus == 2 || _applyModel.applymsglist.count == 0) {
        [_bgView setHidden:YES];
    }else{
        [_bgView setHidden:NO];
    }
    
    for (UILabel *label in _msgLabArray) {
        [label setHidden:YES];
        label.numberOfLines = 0;
        label.frame = CGRectZero;
    }
    CGFloat totalLabelHeith = 0;
    UIFont *font = [UIFont systemFontOfSize:12];
    
    NSInteger messageCounts = 0;
    if (_applyModel.applymsglist.count > 4) {
        messageCounts = 4;
    }else{
        messageCounts = _applyModel.applymsglist.count;
    }
    for (int i = 0; i < messageCounts; i ++) {
        if (_bgView.hidden == YES) {
            break;
        }
        UILabel *label  = _msgLabArray[i];
        label.numberOfLines = 0;
        [label setHidden:NO];
        
        NSString *name = @"";
        ApplyModel *model = _applyModel.applymsglist[i];
        NSString *content = model.applymsg;
        if (model.isme == 1) {
            name = FormatString(@"%@: ", TTLocalString(@"TT_me"));
        }else{
            name = FormatString(@"%@：", _applyModel.nickname);
        }
        NSString *total = FormatString(@"%@%@", name,content);
        
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:total];
        [mStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, name.length)];
        [mStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(name.length,content.length)];
        [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(TextBlackColor) range:NSMakeRange(0, name.length)];
        [mStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(TextGrayColor) range:NSMakeRange(name.length,content.length)];
        label.attributedText = mStr;
        
        //计算 label 的高度。
        CGFloat labelWidth =  ScreenWidth - (320 - 215 );
        if (_isEditing) {
            labelWidth = labelWidth - 32;
        }
        CGFloat labelHeight = [SysTools getHeightContain:total font:label.font Width:labelWidth];
        labelHeight += 12;
        label.frame = CGRectMake(20, totalLabelHeith + 12,labelWidth, labelHeight - 12);
        
        totalLabelHeith += labelHeight;
        
    }
    //信息框的总高度
    
    CGFloat bgKuangHeight = totalLabelHeith + 51;
    
    //当显示是手机联系人时，留言区域到顶部的距离是60，不显示手机联系人时是 45.
    CGFloat top_gap = 0;
    if (_applyModel.applytype == 1) {
        _infoLabel.text = TTLocalString(@"TT_contacts");
        [_infoLabel setHidden:NO];
        top_gap = 60;
    }else{
        [_infoLabel setHidden:YES];
        top_gap = 45;
    }
    
    CGFloat cellHeight = top_gap +  bgKuangHeight + 15;
    //编辑状态和非编辑状态下视图
    
    if (_isEditing == YES) {
        
        if (_applyModel.isSelected) {
            _selectView.image = [UIImage imageNamed:@"apply_friend_select"];
        }else{
            _selectView.image = [UIImage imageNamed:@"apply_friend_no_select"];
        }
        _bgView.frame = CGRectMake(60,top_gap, ScreenWidth - (320 - 250) - 32, bgKuangHeight);
        
        _contentBg.frame = CGRectMake(32,0, ScreenWidth - 32, cellHeight);
        _replyButton.frame = CGRectMake(20, bgKuangHeight - 15 - 27,ScreenWidth - (320 - 215) - 32, 27);
    }else{
        
        
        _bgView.frame = CGRectMake(60,top_gap,ScreenWidth - (320 - 250), bgKuangHeight);
        _contentBg.frame = CGRectMake(0,0, ScreenWidth, cellHeight);
        _replyButton.frame = CGRectMake(20, bgKuangHeight - 15 - 27,ScreenWidth - (320 - 215), 27);
    }
    
    _replyBgImage.frame = CGRectMake(0, 0, _bgView.mj_width, _bgView.mj_height);
    
    UIImage *messageBg = [UIImage imageNamed:@"apply_friend_kuang"];
    messageBg = [messageBg resizableImageWithCapInsets:UIEdgeInsetsMake(22, 20, 13, 13)];
    _replyBgImage.image = messageBg;

   [_avatarImageView sd_setImageWithURL:StrToUrl([SysTools getHeaderImageURL:_applyModel.frienduid time:_applyModel.avatartime]) placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
}

- (IBAction)avatarButtonClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(avatarClick:indexPath:)]) {
        [_delegate avatarClick:_applyModel indexPath:_indexPath];
    }
}
+ (CGFloat)calculateCellHeight:(ApplyFriendModel *)info isEditinag:(BOOL)isEditing{
    
    if (info.applystatus == 1 || info.applymsglist.count == 0 || info.applystatus == 2) {
        return 68;
    }
    
    //信息框的y坐标
    CGFloat y = 0;
    if (info.applytype == 1) {
        y = 57;
    }else{
        y = 45;
    }
    //计算label的总高度
    CGFloat totalHeight = 0;
    CGFloat labelWidth = 0;
    labelWidth = ScreenWidth - (320 - 215);
    if (isEditing) {
        labelWidth = labelWidth - 32;
    }
    
    NSInteger messageCount = 0;
    if (info.applymsglist.count > 4) {
        messageCount = 4;
    }else{
        messageCount = info.applymsglist.count;
    }
    
    for (int i = 0; i < messageCount; i ++) {
        NSString *name = @"";
        ApplyModel *model = info.applymsglist[i];
        NSString *content = model.applymsg;
        if (model.isme == 1) {
            name = FormatString(@"%@: ", TTLocalString(@"TT_me"));
        }else{
            name = FormatString(@"%@：", info.nickname);
        }
        NSString *total = FormatString(@"%@%@", name,content);
        
        CGFloat labelHeight = [SysTools getHeightContain:total font:[UIFont systemFontOfSize:12] Width:labelWidth];
        
        labelHeight += 12;
        
        totalHeight += labelHeight;
    }
   //下面的值分别是 最后一条信息，回复按钮，背景的地部，cell的底部之前的距离

    return y + totalHeight + 12 + 27 + 12 + 15;
}
@end
