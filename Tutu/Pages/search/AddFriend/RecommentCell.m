//
//  RecommentCell.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/14.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "RecommentCell.h"
#import "UIImageView+WebCache.h"

@implementation RecommentCell{
    UserInfo *model;
}

- (void)awakeFromNib {
    // Initialization code
    [_genderView.layer setCornerRadius:0];
    _genderView.layer.masksToBounds = YES;
    
    
    _nickLabel.font = ListTitleFont;
    [_nickLabel setTextColor:UIColorFromRGB(TextGreenDColor)];
    
    
    _descLabel.textColor = UIColorFromRGB(TextGrayColor);
    _descLabel.adjustsFontSizeToFitWidth = NO;
    _descLabel.font = ListDetailFont;
    _ageLabel.textColor = [UIColor whiteColor];
    
    _avatarView.image = [UIImage imageNamed:@"avatar_default"];
    [_avatarView.layer setCornerRadius:_avatarView.mj_width/2.0];
    _avatarView.layer.masksToBounds = YES;
    [_bottomLineView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    
    _attentButton.tag=RecommentItemFocus;
    [_attentButton addTarget:self action:@selector(focusClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _topicView1.tag=RecommentItemImageView1;
    _topicView2.tag=RecommentItemImageView2;
    _topicView3.tag=RecommentItemImageView3;
    _topicView1.userInteractionEnabled=YES;
    _topicView2.userInteractionEnabled=YES;
    _topicView3.userInteractionEnabled=YES;
    [_topicView1 setContentMode:UIViewContentModeScaleAspectFit];
    [_topicView2 setContentMode:UIViewContentModeScaleAspectFit];
    [_topicView3 setContentMode:UIViewContentModeScaleAspectFit];
    
    
    _topicView1.layer.borderColor=UIColorFromRGB(SystemGrayColor).CGColor;
    _topicView1.layer.borderWidth=0.75f;
    _topicView2.layer.borderColor=UIColorFromRGB(SystemGrayColor).CGColor;
    _topicView2.layer.borderWidth=0.75f;
    _topicView3.layer.borderColor=UIColorFromRGB(SystemGrayColor).CGColor;
    _topicView3.layer.borderWidth=0.75f;
    
    
}


-(void)dataToView:(UserInfo *)info with:(CGFloat)w{
    model=info;
    if(info){
        [self.nickLabel setText:info.nickname];
        [self.nickLabel setFont:ListTitleFont];
        
        [self.descLabel setText:info.descinfo];
        
        CGRect nickF=self.nickLabel.frame;
        CGFloat nw=[SysTools getWidthContain:info.nickname font:ListTitleFont Height:nickF.size.height];
        nickF.size.width=nw;
        [self.nickLabel setFrame:nickF];
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:info.uid time:info.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        
        CGFloat sw=30;
        if(model.userhonorlevel>0){
            sw=sw+25;
        }
        if(model.isauth){
            sw=sw+20;
        }
        
        if((nw+sw)>(self.attentButton.frame.origin.x-60)){
            nickF.size.width=self.attentButton.frame.origin.x-60-sw;
            [self.nickLabel setFrame:nickF];
        }
        
        CGRect genderF=self.genderView.frame;
        genderF.origin.x=nickF.origin.x+nickF.size.width+5;
        [self.genderView setFrame:genderF];
        
        self.certificationImageView.hidden=YES;
        if(model.isauth){
            self.certificationImageView.hidden=NO;
            
            CGRect certificationF=self.certificationImageView.frame;
            certificationF.origin.x=self.genderView.frame.size.width+self.genderView.frame.origin.x+5;
            [self.certificationImageView setFrame:certificationF];
        }
        
        if(model.userhonorlevel==0){
            self.levelImage.hidden=YES;
            
        }else{
            [self.levelImage setHidden:NO];
            [self.levelImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
            
            CGRect leveF=self.levelImage.frame;
            if(model.isauth){
                leveF.origin.x=self.certificationImageView.frame.size.width+self.certificationImageView.frame.origin.x+5;
            }else{
                leveF.origin.x=self.genderView.frame.size.width+self.genderView.frame.origin.x+5;
            }
            [self.levelImage setFrame:leveF];
        }
        
        if ([info.gender isEqualToString:@"1"]) {
            self.genderTagImage.image = [UIImage imageNamed:@"boy"];
            [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderBoyColorBg)]];
        }else if([info.gender isEqualToString:@"2"]){
            self.genderTagImage.image = [UIImage imageNamed:@"girl"];
            [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderGirlColorBg)]];
        }
        
        if(model.isBlock){
            self.blockTagView.hidden=NO;
        }else{
            self.blockTagView.hidden=YES;
        }
        
        
        NSString *gender=@"girl.png";
        [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderGirlColorBg)]];
        if([model.gender intValue]==1){
            gender=@"boy.png";
            [self.genderView setImage:[SysTools createImageWithColor:UIColorFromRGB(GenderBoyColorBg)]];
        }
        
        if([model.relation intValue]==0||[model.relation intValue]==1){
            [self.attentButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor0"] forState:UIControlStateNormal];
            [self.attentButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel0"] forState:UIControlStateHighlighted];
        }else if([model.relation intValue]==3){
            [self.attentButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor2"] forState:UIControlStateNormal];
            [self.attentButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel2"] forState:UIControlStateHighlighted];
        }else{
            [self.attentButton setImage:[UIImage imageNamed:@"userinfo_item_focus_nor1"] forState:UIControlStateNormal];
            [self.attentButton setImage:[UIImage imageNamed:@"userinfo_item_focus_sel1"] forState:UIControlStateHighlighted];
        }
        
        [self.ageLabel setText:info.age];
        if([@"" isEqual:info.age]){
            [self.ageLabel setText:@"0"];
        }
        
        if(model.topicList!=nil){
            for (int i=0;i<model.topicList.count;i++) {
                TopicModel *tm=[model.topicList objectAtIndex:i];
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                if(i==0){
                    [self.topicView1 sd_setImageWithURL:[NSURL URLWithString:tm.sourcepath]];
                    [self.topicView1 addGestureRecognizer:tap];
                }else if(i==1){
                    [self.topicView2 sd_setImageWithURL:[NSURL URLWithString:tm.sourcepath]];
                    [self.topicView2 addGestureRecognizer:tap];
                }else if(i==2){
                    [self.topicView3 sd_setImageWithURL:[NSURL URLWithString:tm.sourcepath]];
                    [self.topicView3 addGestureRecognizer:tap];
                }
            }
        }
        
        if(w>320){
            CGFloat xw=(w-20)/3;
            CGFloat iy=self.topicView1.frame.origin.y;
            
            [self.topicView1 setFrame:CGRectMake(5, iy, xw, xw)];
            [self.topicView2 setFrame:CGRectMake(xw+10, iy, xw, xw)];
            [self.topicView3 setFrame:CGRectMake(2*xw+15, iy, xw, xw)];
            
            [self setFrame:CGRectMake(0, 0, w, iy+xw+20)];
        }
    }
}

-(void)focusClick:(UIButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemClick:tag:)]){
        [self.delegate itemClick:model tag:(int)btn.tag];
    }
}

-(void)handleTap:(UIGestureRecognizer *)tap{
    UIView *v=tap.view;
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemClick:tag:)]){
        [self.delegate itemClick:model tag:(int)v.tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
