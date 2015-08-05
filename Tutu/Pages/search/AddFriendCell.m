//
//  AddFriendCell.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AddFriendCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+Border.h"

@implementation AddFriendCell

- (void)awakeFromNib {
    // Initialization code
}


-(void)initDataToView:(UserInfo *)model{
    self.backgroundColor = [UIColor whiteColor];
//    [_cellSepetor addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [_cellSepetor setHidden:YES];
    
    
    if(model){
        [self.nickLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [self.signLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        self.avatarImage.layer.cornerRadius=self.avatarImage.frame.size.width/2;
        self.avatarImage.layer.masksToBounds=YES;
        self.nickLabel.text=model.nickname;
        self.signLabel.text=model.sign;
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:model.uid time:model.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.genderView.layer.cornerRadius=0;
        self.genderView.layer.masksToBounds=YES;
        if(model.userhonorlevel==0){
            self.levelImageView.hidden=YES;
        }else{
            [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
        }
        
        NSString *gender=@"girl.png";
        
        [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderGirlColorBg)]];
        if([model.gender intValue]==1){
            gender=@"boy.png";
            [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderBoyColorBg)]];
        }
        [self.genderImage setImage:[UIImage imageNamed:gender]];
        int age=[model.age intValue];
        if(age>0){
            [self.ageLabel setText:[NSString stringWithFormat:@"%d",age]];
        }
        CGFloat width = [SysTools getWidthContain:model.nickname font:self.nickLabel.font Height:CGFLOAT_MAX];
        
        
        CGRect nf=self.nickLabel.frame;
        nf.size.width=width;
        self.nickLabel.frame=nf;
        
        CGRect gf=self.genderView.frame;
        gf.origin.x=nf.origin.x+width+10;;
        self.genderView.frame=gf;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
