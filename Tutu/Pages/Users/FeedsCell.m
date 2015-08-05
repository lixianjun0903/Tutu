//
//  FeedsCell.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-28.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "FeedsCell.h"
#import "UIImageView+WebCache.h"

@implementation FeedsCell{
    FeedsModel *feedsModel;
}

- (void)awakeFromNib {
    // Initialization code
}


-(void)initDataToView:(FeedsModel *)model{
//    _cellSepetor.alpha = 0.3;
    feedsModel=model;
    if(model){
        self.avatarImage.layer.cornerRadius=self.avatarImage.frame.size.width/2;
        self.avatarImage.layer.masksToBounds=YES;
        [self.timeLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.messageLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        
        
        [self.nickLabel setFont:ListTitleFont];
        [self.messageLabel setFont:ListDetailFont];
        [self.timeLabel setFont:ListTimeFont];
        
        self.nickLabel.text=model.nickname;
        self.messageLabel.text=model.data;
        
        self.nickLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.nickLabel sizeToFit];
        
        
        
        if([model.read intValue]==0){
            self.newsDotImage.hidden = YES;
        }else{
            self.newsDotImage.hidden = YES;
        }
        
        
        self.timeLabel.text=intervalSinceNow(model.addtime);
        
        
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:model.actionuid time:model.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
        [self.avatarImage addGestureRecognizer:tap];
        self.avatarImage.userInteractionEnabled=YES;
        
        CGRect nickF=self.nickLabel.frame;
        CGFloat nw=[SysTools getWidthContain:model.nickname font:ListTitleFont Height:nickF.size.height]+5;
        nickF.size.width=nw;
        [self.nickLabel setFrame:nickF];
        CGFloat sw=0;
        if(model.userhonorlevel>0){
            sw=sw+25;
        }
        if(model.isauth){
            sw=sw+20;
        }
        
        if((nw+sw)>(self.timeLabel.frame.origin.x+20)){
            nickF.size.width=self.timeLabel.frame.origin.x+20-sw;
            
            [self.nickLabel setFrame:nickF];
        }
        
        self.certificationImageView.hidden=YES;
        if(model.isauth){
            self.certificationImageView.hidden=NO;
            
            CGRect certificationF=self.certificationImageView.frame;
            certificationF.origin.x=self.nickLabel.frame.size.width+self.nickLabel.frame.origin.x+5;
            [self.certificationImageView setFrame:certificationF];
        }
        
        if(model.userhonorlevel==0){
            self.levelImageView.hidden=YES;
        }else{
            CGRect levelF=self.levelImageView.frame;
            if(model.isauth){
                levelF.origin.x=self.certificationImageView.frame.origin.x+self.certificationImageView.frame.size.width+5;
            }else{
                levelF.origin.x=nickF.size.width+nickF.origin.x+5;
            }
            [self.levelImageView setFrame:levelF];
            
            self.levelImageView.hidden=NO;
            [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
        }
    }
}

-(void)itemClick:(UITapGestureRecognizer *)tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(headerClick:)]){
        [self.delegate headerClick:feedsModel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
