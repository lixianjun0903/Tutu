//
//  SameCityCell.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SameCityCell.h"
#import "UIView+Border.h"
#import "UIImageView+WebCache.h"

@implementation SameCityCell{
    UserInfo *user;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)initDataToView:(UserInfo *)model{
    [self initDataToView:model reference:ReferenceSameCityPage];
}

-(void)initDataToView:(UserInfo *)model width:(CGFloat)w reference:(ReferencePage)referencePage{
    self.backgroundColor = [UIColor whiteColor];
//    [_cellSepetor addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    user=model;
    
    if(model){
        [self.nickLabel setFont:ListTitleFont];
        [self.nickLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [self.signLabel setFont:ListDetailFont];
        [self.signLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.distanceLabel setFont:ListTimeFont];
        [self.distanceLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        
        self.headerImage.layer.cornerRadius=self.headerImage.frame.size.width/2;
        self.headerImage.layer.masksToBounds=YES;
        self.nickLabel.text=model.nickname;
        self.signLabel.text=model.sign;
        if(referencePage==ReferenceSameCityPage){
            self.distanceLabel.text=[NSString stringWithFormat:@"%@ | %@",model.distance,model.lasttime];
        }else if(referencePage==ReferenceFocusUserPage){
            self.distanceLabel.text=[NSString stringWithFormat:@"%@",model.addtime];
        }else if(referencePage==ReferenceSearchUserPage){
            self.distanceLabel.text=[NSString stringWithFormat:@""];
        }
        
        
       // NSString *imageName = [NSString stringWithFormat:@"head_placeholder_%d",_indexPath.row % 7 + 1];
        
        [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:model.uid time:model.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.genderView.layer.cornerRadius=0;
        self.genderView.layer.masksToBounds=YES;
        
        if(model.isBlock){
            self.isblockImage.hidden=NO;
        }else{
            self.isblockImage.hidden=YES;
        }
        
        // 昵称实际的最大宽度
        CGFloat nw=w-70-120;
        if(referencePage==ReferenceSearchUserPage){
            nw=w-80;
        }
        [self.nickLabel sizeToFit];
        CGRect nickf=self.nickLabel.frame;
        CGFloat rw=[SysTools getWidthContain:model.nickname font:ListTitleFont Height:21];
        
        // 昵称的实际宽度
        CGFloat nameW= nickf.size.width;
        
        //认证和等级的标识的宽度
        CGFloat sw=0;
        if(model.userhonorlevel>0){
            sw=sw+25;
        }
        if(model.isauth){
            sw=sw+20;
        }
        
        if((nameW+sw) > nw){
            nickf.size.width=nw-sw;
            [self.nickLabel setFrame:nickf];
        }else{
            nickf.size.width=nameW;
            [self.nickLabel setFrame:nickf];
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
            [self.levelImageView setFrame:leveF];
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
        else
        {
            [self.ageLabel setText:@"0"];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
