//
//  RCLetterListCell.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCLetterListCell.h"
#import "UIImageView+WebCache.h"
#import "RCIMClientHeader.h"

@implementation RCLetterListCell
{
    RCSessionModel *model;
}

- (void)awakeFromNib {
    // Initialization code
    
}


-(void)initDataToView:(RCSessionModel *)item  width:(CGFloat)w{
    model=item;
    self.backgroundColor=[UIColor whiteColor];
    
    [self.nickLabel setFont:ListTitleFont];
    [self.messageLabel setFont:ListDetailFont];
    [self.timeLabel setFont:ListTimeFont];
    [self.newsNumLabel setFont:ListTimeFont];
    
    [self.nickLabel setText:@""];
    [self.messageLabel setText:@""];
    [self.timeLabel setText:@""];
    [self.newsNumLabel setText:@""];
    
    self.dotImageView.hidden=YES;
    
    if(item){
        self.avatarImage.layer.cornerRadius=25;
        self.avatarImage.layer.masksToBounds=YES;
        self.avatarImage.userInteractionEnabled=YES;
        UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarClick:)];
        [self.avatarImage addGestureRecognizer:tap];
        
        [self.timeLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.messageLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.newsNumLabel setTextColor:[UIColor whiteColor]];
        
        NSString *avatarTime=[NSString stringWithFormat:@"%lld",item.lastmsgtime];
        if(avatarTime!=nil && avatarTime.length>=11){
            avatarTime=[avatarTime substringToIndex:10];
        }
        NSString *avatarURL=[SysTools getHeaderImageURL:item.uid time:avatarTime];
        
//        WSLog(@"%@==%@",item.nickname,avatarURL);
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        
        self.nickLabel.text=item.nickname;
        self.timeLabel.text=intervalSinceNow(longdateTransformString(@"yyyy-MM-dd HH:mm:ss", item.rcconversation.sentTime));
        [self.nickLabel sizeToFit];
        
        
        int sw=0;
        if(model.userhonorlevel>0){
            sw=sw+25;
        }
        if(model.isauth){
            sw=sw+20;
        }
        
        if(self.timeLabel.frame.origin.x < (self.nickLabel.frame.size.width+self.nickLabel.frame.origin.x+sw)){
            CGRect nf=self.nickLabel.frame;
            nf.size.width=self.timeLabel.frame.origin.x-sw-70-5;
            [self.nickLabel setFrame:nf];
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
            self.levelImageView.hidden=NO;
            CGRect levelF=self.levelImageView.frame;
            if(model.isauth){
                levelF.origin.x=self.certificationImageView.frame.size.width+self.certificationImageView.frame.origin.x+5;
            }else{
                levelF.origin.x=self.nickLabel.frame.size.width+self.nickLabel.frame.origin.x+5;
            }
            [self.levelImageView setFrame:levelF];
            
            [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",model.userhonorlevel]]];
        }
        
        if(item.isblockme==1){
            self.messageLabel.text= item.lastmsg;
            self.timeLabel.text=intervalSinceNow(longdateTransformString(@"yyyy-MM-dd HH:mm:ss", item.lastmsgtime));
        }else{
            if([RCTextMessageTypeIdentifier isEqual:item.rcconversation.objectName]){
                RCTextMessage *rcmsg=(RCTextMessage *)item.rcconversation.lastestMessage;
                self.messageLabel.text= rcmsg.content;
            }else if([RCRichContentMessageTypeIdentifier isEqual:item.rcconversation.objectName]){
                RCRichContentMessage *rcmsg=(RCRichContentMessage *)item.rcconversation.lastestMessage;
                self.messageLabel.text= [NSString stringWithFormat:@"[链接]%@",CheckNilValue(rcmsg.title)];
            }else if([RCImageMessageTypeIdentifier isEqual:item.rcconversation.objectName]){
    //            RCImageMessage *rcmsg=(RCImageMessage *)item.lastestMessage;
                self.messageLabel.text= [NSString stringWithFormat:@"[图片]"];
            }else if([RCVoiceMessageTypeIdentifier isEqual:item.rcconversation.objectName]){
    //            RCVoiceMessage *rcmsg=(RCVoiceMessage *)item.lastestMessage;
                self.messageLabel.text= [NSString stringWithFormat:@"[语音]"];
            }
        }
        
        if(item.isblock==1){
            self.dotImageView.hidden=NO;
        }else{
            self.dotImageView.hidden=YES;
        }
        
        if(item.rcconversation.unreadMessageCount>0){
            self.newsNumLabel.hidden=NO;
            CGFloat newsW=[SysTools getWidthContain:[NSString stringWithFormat:@"%d",(int)item.rcconversation.unreadMessageCount] font:ListTimeFont Height:19];
            if(newsW<19){
                newsW=19;
            }else{
                newsW=newsW+5;
            }
            
            self.newsNumLabel.layer.cornerRadius=9.5f;
            self.newsNumLabel.layer.masksToBounds=YES;
            [self.newsNumLabel setBackgroundColor:UIColorFromRGB(NoticeColor)];
            [self.newsNumLabel setText:[NSString stringWithFormat:@"%ld",(long)item.rcconversation.unreadMessageCount]];
            CGRect rect=CGRectMake(self.frame.size.width-10-newsW, self.newsNumLabel.frame.origin.y, newsW, 19);
            self.newsNumLabel.frame=rect;
            [self.newsNumLabel setHighlightedTextColor:[UIColor clearColor]];
        }else{
            self.newsNumLabel.hidden=YES;
        }
    }
}

-(void)avatarClick:(UIGestureRecognizer *)tap{
    if(self.delegate){
        [self.delegate avatarOnClick:model];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
