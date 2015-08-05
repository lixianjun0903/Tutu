//
//  PhoneModelCell.m
//  Tutu
//
//  Created by gexing on 5/14/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "PhoneModelCell.h"

@implementation PhoneModelCell

- (void)awakeFromNib {
    // Initialization code

}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CGFloat btnWidth = (ScreenWidth - 30) / 2.f;
        for (int i = 0; i < 2; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(10 + (btnWidth + 10) * i, 5,btnWidth , 30);
            [self.contentView addSubview:btn];
            btn.layer.masksToBounds = YES;
            [btn setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateNormal];
            [btn setTitleColor:HEXCOLOR(SystemColor) forState:UIControlStateDisabled];
            btn.layer.borderWidth = 0.7f;
            btn.layer.cornerRadius = btn.mj_height / 2.f;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn addTarget:self action:@selector(phoneNameClick:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                _leftButton = btn;
            }else{
                _rightButton = btn;
            }
        }
    }
    return self;
}
- (void)relaodWith:(PhoneModel *)leftModel right:(PhoneModel *)rightModel{
    _leftModel = leftModel;
    _rightModel = rightModel;
    
    if (leftModel) {
        [_leftButton setHidden:NO];
        [_leftButton setTitle:_leftModel.typeName forState:UIControlStateNormal];
        if (_leftModel.isused == 1) {
            [_leftButton setEnabled:NO];
            _leftButton.layer.borderColor = HEXCOLOR(SystemColor).CGColor;
        }else{
            [_leftButton setEnabled:YES];
            _leftButton.layer.borderColor = HEXCOLOR(TextCCCCCCColor).CGColor;
        }
    }else{
        [_leftButton setHidden:YES];
    }

    if (rightModel) {
        [_rightButton setHidden:NO];
        [_rightButton setTitle:_rightModel.typeName forState:UIControlStateNormal];
        if (_rightModel.isused == 1) {
            _rightButton.layer.borderColor = HEXCOLOR(SystemColor).CGColor;
            [_rightButton setEnabled:NO];
        }else{
            [_rightButton setEnabled:YES];
            _rightButton.layer.borderColor = HEXCOLOR(TextCCCCCCColor).CGColor;
        }
    }else{
        [_rightButton setHidden:YES];
    }
}
- (void)phoneNameClick:(UIButton *)sender{
    
    sender.layer.borderColor = HEXCOLOR(SystemColor).CGColor;
    
    if (sender.tag == 0) {
        _leftModel.isused = 1;
        if (_delegate && [_delegate respondsToSelector:@selector(phoneNameClick:index:)]) {
            [_delegate phoneNameClick:_leftModel index:_index * 2];
        }
    }else{
        _rightModel.isused = 1;
        if (_delegate && [_delegate respondsToSelector:@selector(phoneNameClick:index:)]) {
            [_delegate phoneNameClick:_rightModel index:_index * 2 + 1];
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
