//
//  UserFansCell.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserFansCell.h"
#import "UIImageView+WebCache.h"

@implementation UserFansCell{
    UserInfo *user;
}

- (void)awakeFromNib {
    // Initialization code
}


-(void)dataToView:(UserInfo *)model{
    [self dataToView:model followTime:nil];
}

-(void)dataToView:(UserInfo *)model followTime:(NSString *)time{
    
    user=model;
    
    if(model){
        [self.nickLabel setFont:ListTitleFont];
        [self.nickLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [self.signLabel setFont:ListDetailFont];
        [self.signLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.distanceLabel setFont:ListTimeFont];
        [self.distanceLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        
        self.headerImage.layer.cornerRadius=self.headerImage.frame.size.width/2;
        self.headerImage.layer.masksToBounds=YES;
        self.nickLabel.text=model.nickname;
        self.signLabel.text=model.sign;
        
        
        
        [self.timeView setBackgroundColor:[UIColor clearColor]];
        if(time==nil){
            self.distanceLabel.text=model.followtime;
        }else{
            self.distanceLabel.text=time;
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
        
        
        [self.nickLabel sizeToFit];
        CGRect nickF=self.nickLabel.frame;
//        CGFloat nw=[SysTools getWidthContain:model.nickname font:ListTitleFont Height:nickF.size.height]+5;
//        nickF.size.width=nw;
        
        [self.nickLabel setFrame:nickF];
        
        CGFloat sw=0;
        if(model.userhonorlevel>0){
            sw=sw+25;
        }
        if(model.isauth){
            sw=sw+20;
        }
        
        if((nickF.size.width+sw)>(self.doActionButton.frame.origin.x-70)){
            nickF.size.width=self.doActionButton.frame.origin.x-70-sw;
            
            [self.nickLabel setFrame:nickF];
        }
        
        self.certificationImageView.hidden=YES;
        if(model.isauth){
            self.certificationImageView.hidden=NO;
            
            CGRect certificationF=self.certificationImageView.frame;
            certificationF.origin.x=nickF.size.width+nickF.origin.x;
            [self.certificationImageView setFrame:certificationF];
        }
        
        if(model.userhonorlevel==0){
            self.levelImageView.hidden=YES;
        }else{
            self.levelImageView.hidden=NO;
            
            CGRect levelF=self.levelImageView.frame;
            if(model.isauth){
                
                levelF.origin.x=self.certificationImageView.frame.size.width+self.certificationImageView.frame.origin.x+5;
            }else{
                levelF.origin.x=self.nickLabel.frame.size.width+self.nickLabel.frame.origin.x+5;
            }
            [[self levelImageView] setFrame:levelF];
            [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
        }
        
        NSString *gender=@"girl.png";
        [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderGirlColorBg)]];
        //        [self.genderView setBackgroundColor:UIColorFromRGB(GenderGirlColorBg)];
        if([model.gender intValue]==1){
            gender=@"boy.png";
            [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderBoyColorBg)]];
            //            [self.genderView setBackgroundColor:UIColorFromRGB(GenderBoyColorBg)];
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
        
        
        [self.doActionButton addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
        if([model.relation intValue]==0||[model.relation intValue]==1){
            [self.doActionButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor0"] forState:UIControlStateNormal];
            [self.doActionButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel0"] forState:UIControlStateHighlighted];
        }else if([model.relation intValue]==3){
            [self.doActionButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor2"] forState:UIControlStateNormal];
            [self.doActionButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel2"] forState:UIControlStateHighlighted];
        }else{
            [self.doActionButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor1"] forState:UIControlStateNormal];
            [self.doActionButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel1"] forState:UIControlStateHighlighted];
        }
    }
}

-(void)actionClick:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemFocusClick:)]){
        [self.delegate itemFocusClick:user];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
