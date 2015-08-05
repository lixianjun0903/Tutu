//
//  UserHeaderCell.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserHeaderCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Additions.h"
#import "UIView+Border.h"
#import "UIButton+WebCache.h"

@implementation UserHeaderCell{
    UserInfo *user;
    CGFloat tWidth;
    
    int dataType;
}

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor=[UIColor clearColor];

    [self.zanButton setTag:UserLikeTag];
    [self.zanButton setBackgroundColor:UIColorFromRGBAlpha(TextGrayColor, 0.5)];
    [self.zanButton.layer setCornerRadius:self.zanButton.frame.size.height/2];
    [self.zanButton.layer setMasksToBounds:YES];
    [self.zanButton setImage:[UIImage imageNamed:@"user_zan"] forState:UIControlStateNormal];
    [self.zanButton setImageEdgeInsets:UIEdgeInsetsMake(6.5, 9.5, 6.5, 30)];
    [self.zanButton setTitle:@"" forState:UIControlStateNormal];
    [self.zanButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.zanButton.titleLabel setFont:ListDetailFont];
    self.zanButton.hidden=YES;
    
    
    [self.nickLabel setNumberOfLines:1];
    [self.nickLabel setFont:ListTitleFont];
    [self.nickLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    
    [self.descLabel setNumberOfLines:0];
    [self.descLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [self.descLabel setFont:ListDetailFont];
    
    [self.tutuNumberLabel setFont:ListDetailFont];
    [self.tutuNumberLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    
    self.editButton.hidden=YES;
    [self.editButton setImageEdgeInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
    [self.editButton setBackgroundColor:[UIColor clearColor]];
    [self.editButton setImage:[UIImage imageNamed:@"user_edit_sel"] forState:UIControlStateHighlighted];
    [self.editButton setImage:[UIImage imageNamed:@"user_edit"] forState:UIControlStateNormal];
    
    self.ageView.layer.cornerRadius=0;
    self.ageView.layer.masksToBounds=YES;
    
    self.avatarImageView.layer.cornerRadius=self.avatarImageView.frame.size.width/2;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.userInteractionEnabled=YES;
    
    
    [self.sendButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.favButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.focusButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fansButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:ListTitleFont];
    [self.sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 12, 0)];
    [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.sendLabel setTextAlignment:NSTextAlignmentCenter];
    [self.sendLabel setFont:ListTimeFont];
    
    [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
    [self.favButton.titleLabel setFont:ListTitleFont];
    [self.favButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 12, 0)];
    [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.favLabel setTextAlignment:NSTextAlignmentCenter];
    [self.favLabel setFont:ListTimeFont];
    
    
    [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
    [self.focusButton.titleLabel setFont:ListTitleFont];
    [self.focusButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 12, 0)];
    [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.focusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.focusLabel setFont:ListTimeFont];
    
    
    [self.adrAndXZLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.adrAndXZLabel setFont:ListDetailFont];
    
    
    [self.fansButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
    [self.fansButton.titleLabel setFont:ListTitleFont];
    [self.fansButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 12, 0)];
    [self.fansLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.fansLabel setTextAlignment:NSTextAlignmentCenter];
    [self.fansLabel setFont:ListTimeFont];
    
    [self.certLabel setFont:ListDetailFont];
    [self.certLabel setTextColor:UIColorFromRGB(TextYellowColor)];
    [self.certLabel setBackgroundColor:UIColorFromRGB(UserTextYellowBg)];
    [self.certLabel setNumberOfLines:0];
    
    
    [self.verticalLine1 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [self.verticalLine2 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [self.verticalLine3 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    
    [self.focusDotImageView setBackgroundColor:[UIColor redColor]];
    self.focusDotImageView.layer.cornerRadius=3;
    self.focusDotImageView.layer.masksToBounds=YES;
    
    
    [self.fansDotsImageView setBackgroundColor:[UIColor redColor]];
    self.fansDotsImageView.layer.cornerRadius=3;
    self.fansDotsImageView.layer.masksToBounds=YES;
    
    [self.sendButton setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(cutBackColor)] forState:UIControlStateHighlighted];
    [self.favButton setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(cutBackColor)] forState:UIControlStateHighlighted];
    [self.focusButton setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(cutBackColor)] forState:UIControlStateHighlighted];
    [self.fansButton setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGB(cutBackColor)] forState:UIControlStateHighlighted];
    
    
    
    
    self.editButton.tag=UserEditBtnTag;
    self.zanButton.tag=UserLikeTag;
    self.avatarImageView.tag=UserChangeAvatarTag;
    self.changeBgButton.tag=UserChangeBgTag;
    self.sendButton.tag=UserMyListBtnTag;
    self.favButton.tag=UserMyCollectionBtnTag;
    self.focusButton.tag=UserMyFocusTag;
    self.fansButton.tag=UserFansTag;
    
    [self.editButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeBgButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarClick:)];
    [self.avatarImageView addGestureRecognizer:tap];
    
    
    [self.menuView setBackgroundColor:[UIColor clearColor]];
    self.menuView.hidden=YES;
    
    self.beKillView.hidden=YES;
    
    self.bgColorView.hidden=YES;
    
    [self.cerificationTagView setHidden:YES];
    [self.certLabel setHidden:YES];
    _sendLabel.text = TTLocalString(@"TT_topic");
    _favLabel.text = TTLocalString(@"TT_collection");
    _fansLabel.text = TTLocalString(@"TT_fans");
    _focusLabel.text = TTLocalString(@"TT_follow");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)dataToView:(UserInfo *)userInfo width:(CGFloat)releaseWidth type:(UserHeaderCellClickTag)clicktag animate:(BOOL)isanimate{
    CGFloat cellheigth=0.0f;
    user=userInfo;
    tWidth=releaseWidth;
    if(userInfo){
        BOOL isMySelf=NO;
        if([userInfo.uid isEqual:[[LoginManager getInstance] getUid]]){
            isMySelf=YES;
        }
        if(userInfo.status==-2){
            self.beKillView.hidden=NO;
        }else{
            self.beKillView.hidden=YES;
        }
        self.zanButton.hidden=NO;
        self.bgColorView.hidden=NO;
        [self.focusDotImageView setHidden:YES];
        [self.fansDotsImageView setHidden:YES];
        
        //头像
        UIImage *image=self.avatarImageView.image;
        if(image==nil){
            image=[UIImage imageNamed:@"avatar_default"];
        }
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:userInfo.uid time:userInfo.avatartime]] placeholderImage:image];
        
        //赞
        NSString *likeNum=[NSString stringWithFormat:@"%d",userInfo.likenum];
        CGFloat likeNumWidth=[SysTools getWidthContain:likeNum font:self.zanButton.titleLabel.font Height:30];
        CGRect f=self.zanButton.frame;
        if(likeNumWidth > 20)
        {
            f.origin.x=f.origin.x-(likeNumWidth-20);
            f.size.width=f.size.width+(likeNumWidth-20);
            [self.zanButton setFrame:f];
            [self.zanButton setImageEdgeInsets:UIEdgeInsetsMake(6.5, 9.5, 6.5, 30+(likeNumWidth-20))];
        }
        [self.zanButton setTitle:likeNum forState:UIControlStateNormal];
        if(userInfo.isliked){
            [self.zanButton setImage:[UIImage imageNamed:@"user_zan_check"] forState:UIControlStateNormal];
        }else{
            [self.zanButton setImage:[UIImage imageNamed:@"user_zan"] forState:UIControlStateNormal];
        }
        
        // 昵称和编辑
        CGRect nf=self.nickLabel.frame;
        CGFloat nameWidth=[SysTools getWidthContain:userInfo.nickname font:ListTitleFont Height:nf.size.height];
        nf.size.width=nameWidth;
        [self.nickLabel setFrame:nf];
        [self.nickLabel setText:CheckNilValue(userInfo.nickname)];
        if(isMySelf){
            CGRect editF=self.editButton.frame;
            editF.origin.x=nf.size.width+nf.origin.x+5;
            [self.editButton setFrame:editF];
            self.editButton.hidden=NO;
            
        }else{
            self.editButton.hidden=YES;
        }
        
        // 年龄
        NSString *gender=@"girl.png";
        [self.ageView setBackgroundColor:UIColorFromRGB(GenderGirlColorBg)];
        if([userInfo.gender intValue]==1){
            gender=@"boy.png";
            [self.ageView setBackgroundColor:UIColorFromRGB(GenderBoyColorBg)];
        }
        [self.ageImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.ageImageView setImage:[UIImage imageNamed:gender]];
        int age=[userInfo.age intValue];
        if(age>=0){
            [self.ageLabel setText:[NSString stringWithFormat:@"%d",age]];
        }
        else
        {
            [self.ageLabel setText:@"0"];
        }

        
        
        //认证、等级
        CGRect levelF=self.levelImageView.frame;
        CGRect ceriticationTagF=self.cerificationTagView.frame;
        if(userInfo.isauth){
            [self.certLabel setHidden:NO];
            [self.cerificationTagView setHidden:NO];
            
            ceriticationTagF.origin.x=self.ageView.frame.size.width+self.ageView.frame.origin.x+5;
            [self.cerificationTagView setFrame:ceriticationTagF];
            
            
            CGRect ceriF=self.certLabel.frame;
            
            [self.certLabel setInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            CGFloat ttheight=[SysTools getHeightContain:userInfo.authreason font:_certLabel.font Width:ceriF.size.width-10];
            ceriF.size.height=ttheight+10;
            [self.certLabel setText:userInfo.authreason];
            [self.certLabel setFrame:ceriF];
            
            
            levelF.origin.x=ceriticationTagF.size.width+ceriticationTagF.origin.x+5;
            [self.levelImageView setFrame:levelF];
            
        }else{
            [self.certLabel setHidden:YES];
            [self.cerificationTagView setHidden:YES];
            levelF.origin.x=self.ageView.frame.size.width+self.ageView.frame.origin.x+5;
            [self.levelImageView setFrame:levelF];
        }
        
        if(userInfo.userhonorlevel==0){
            self.levelImageView.hidden=YES;
        }else{
            self.levelImageView.hidden=NO;
            [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",userInfo.userhonorlevel]]];
        }
        
        // Tutu号
        NSString *tutuNum=[NSString stringWithFormat:@"%@：%@",TTLocalString(@"TT_tutu_number"),CheckNilValue(userInfo.uid)];
        [self.tutuNumberLabel setText:tutuNum];

        
        // 位置和星座
        NSString *address=@"";
        if([@"" isEqual:userInfo.province] && [@"" isEqual:userInfo.city]){
            address=CheckNilValue(userInfo.area);
        }else{
            address=[NSString stringWithFormat:@"%@ %@",CheckNilValue(userInfo.province),CheckNilValue(userInfo.city)];
        }
        NSString *constellation=@"";
        if(userInfo.constellation!=nil && ![@"" isEqual:userInfo.constellation]){
            constellation=[NSString stringWithFormat:@" · %@",userInfo.constellation];
        }
        [self.adrAndXZLabel setText:[NSString stringWithFormat:@"%@%@",address,constellation]];
        
        // 描述
        [self.descLabel setText:userInfo.sign];
        
        CGRect ttF=self.tutuNumberLabel.frame;
        CGRect addresF=self.adrAndXZLabel.frame;
        CGRect descF=self.descLabel.frame;
        if(userInfo.isauth){
            ttF.origin.y=self.certLabel.frame.origin.y+self.certLabel.frame.size.height+2;
        }else{
            ttF.origin.y=self.ageView.frame.origin.y+self.ageView.frame.size.height+15;
        }
        addresF.origin.y=ttF.origin.y+ttF.size.height+2;
        
        CGSize size = [self.descLabel getLabelSize];
        if([@"" isEqual:userInfo.sign]){
            size.height=0;
        }
        CGFloat descHeight=size.height;
        descF.size.height=descHeight;
        descF.origin.y=addresF.origin.y+addresF.size.height+2;
        
        [self.tutuNumberLabel setFrame:ttF];
        [self.adrAndXZLabel setFrame:addresF];
        [self.descLabel setFrame:descF];
        
        
        
        cellheigth=descF.origin.y+descF.size.height;
        
        
        if(!isMySelf){
            UIButton *addFriendbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [addFriendbutton setFrame:CGRectMake(tWidth/2-110, cellheigth+15 , 100, 25)];
            [addFriendbutton setTitle:@"" forState:UIControlStateNormal];
            if ([user.relation intValue]==2) {
                [addFriendbutton setImage:[UIImage imageNamed:@"userinfo_focus_nor"] forState:UIControlStateNormal];
                [addFriendbutton setImage:[UIImage imageNamed:@"userinfo_focus_sel"] forState:UIControlStateHighlighted];
            }else if([user.relation intValue]==3){
                [addFriendbutton setImage:[UIImage imageNamed:@"userinfo_eachfocus_nor"] forState:UIControlStateNormal];
                [addFriendbutton setImage:[UIImage imageNamed:@"userinfo_eachfocus_sel"] forState:UIControlStateHighlighted];
            }else{
                [addFriendbutton setImage:[UIImage imageNamed:@"userinfo_addfocus_nor"] forState:UIControlStateNormal];
                [addFriendbutton setImage:[UIImage imageNamed:@"userinfo_addfocus_sel"] forState:UIControlStateHighlighted];
            }
            [addFriendbutton setBackgroundColor:[UIColor clearColor]];
            addFriendbutton.layer.cornerRadius=12.5;
            addFriendbutton.layer.masksToBounds=YES;
            addFriendbutton.tag=UserFocusActionTag;
            [addFriendbutton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:addFriendbutton];
            
            UIButton *chatbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [chatbutton setFrame:CGRectMake(tWidth/2+10, cellheigth+15 , 100, 25)];
            [chatbutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [chatbutton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
            [chatbutton.titleLabel setFont:ListTitleFont];
            [chatbutton setImage:[UIImage imageNamed:@"userinfo_chat_nor"] forState:UIControlStateNormal];
            [chatbutton setImage:[UIImage imageNamed:@"userinfo_chat_sel"] forState:UIControlStateHighlighted];
            chatbutton.layer.cornerRadius=12.5;
            chatbutton.layer.masksToBounds=YES;
            chatbutton.tag=UserChatTag;
            [chatbutton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:chatbutton];
            
            cellheigth=cellheigth+55;
        }else{
            cellheigth=cellheigth+15;
        }
        
        
        CGRect bf=self.menuView.frame;
        bf.origin.y=cellheigth;
        [self.menuView setFrame:bf];
        
        self.menuView.hidden=NO;
        [self.menuView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1 andViewWidth:tWidth];
        
        cellheigth=cellheigth+bf.size.height;
        
        // 设置底部白色
        [self.bgColorView setBackgroundColor:[UIColor whiteColor]];
        [self.bgColorView setFrame:CGRectMake(0, 250, self.frame.size.width, cellheigth-250)];
        
        
        
        NSString *favString=[NSString stringWithFormat:@"%d",userInfo.favnum];
        [self.favButton setTitle:favString forState:UIControlStateNormal];
        
        NSString *followString=[NSString stringWithFormat:@"%d",userInfo.follownum];
        [self.focusButton setTitle:followString forState:UIControlStateNormal];
        
        
        NSString *fansString=[NSString stringWithFormat:@"%d",userInfo.fansnum];
        [self.fansButton setTitle:fansString forState:UIControlStateNormal];
        
        
        CGRect sendButtonf=self.sendButton.frame;
        CGRect favButtonf=self.favButton.frame;
        CGRect focusButtonf=self.focusButton.frame;
        CGRect fansButtonf=self.fansButton.frame;
        
        CGRect veritalf1=self.verticalLine1.frame;
        CGRect veritalf2 = self.verticalLine2.frame;
        
        CGRect sendLabelf=self.sendLabel.frame;
        CGRect favLabelf=self.favLabel.frame;
        CGRect focusLabelf=self.focusLabel.frame;
        CGRect fansLabelf=self.fansLabel.frame;
        
        CGFloat menuWidth=tWidth/3;
        
        NSString *sendString=[NSString stringWithFormat:@"%d",userInfo.topicnum];
        if(!isMySelf){
            [self.sendButton setTitle:sendString forState:UIControlStateNormal];
            
            menuWidth=menuWidth;
            sendButtonf.origin.x=0;
            sendButtonf.size.width=menuWidth;
            [self.sendButton setFrame:sendButtonf];
            sendLabelf.size.width=menuWidth;
            sendLabelf.origin.x=0;
            [self.sendLabel setFrame:sendLabelf];
            
            veritalf1.origin.x=menuWidth;
            [self.verticalLine1 setFrame:veritalf1];
            veritalf2.origin.x=menuWidth*2;
            [self.verticalLine2 setFrame:veritalf2];
            [self.verticalLine3 setHidden:YES];
            
            [self.favButton setHidden:YES];
            [self.favLabel setHidden:YES];
            
            focusButtonf.origin.x=menuWidth;
            focusButtonf.size.width=menuWidth;
            [self.focusButton setFrame:focusButtonf];
            focusLabelf.origin.x=menuWidth;
            focusLabelf.size.width=menuWidth;
            [self.focusLabel setFrame:focusLabelf];
            
            fansButtonf.origin.x=menuWidth*2;
            fansButtonf.size.width=menuWidth;
            [self.fansButton setFrame:fansButtonf];
            fansLabelf.origin.x=menuWidth*2;
            fansLabelf.size.width=menuWidth;
            [self.fansLabel setFrame:fansLabelf];
            
            
            [self.zanButton addTarget:self action:@selector(buttonDelegateClick:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            sendString=[NSString stringWithFormat:@"%d",userInfo.topicnum];
            [self.sendButton setTitle:sendString forState:UIControlStateNormal];
            
            menuWidth=tWidth/4;
            
            sendButtonf.size.width=menuWidth;
            sendButtonf.origin.x=0;
            [self.sendButton setFrame:sendButtonf];
            sendLabelf.size.width=menuWidth;
            sendLabelf.origin.x=0;
            [self.sendLabel setFrame:sendLabelf];
            
            veritalf1.origin.x=menuWidth;
            [self.verticalLine1 setFrame:veritalf1];
            veritalf2.origin.x=menuWidth*2;
            [self.verticalLine2 setFrame:veritalf2];
            
            favButtonf.origin.x=menuWidth;
            favButtonf.size.width=menuWidth;
            [self.favButton setFrame:favButtonf];
            favLabelf.origin.x=menuWidth;
            favLabelf.size.width=menuWidth;
            [self.favLabel setFrame:favLabelf];
        
            
            focusButtonf.origin.x=menuWidth*2;
            focusButtonf.size.width=menuWidth;
            [self.focusButton setFrame:focusButtonf];
            focusLabelf.origin.x=menuWidth*2;
            focusLabelf.size.width=menuWidth;
            [self.focusLabel setFrame:focusLabelf];
            
            CGRect veritalf3=self.verticalLine3.frame;
            veritalf3.origin.x=menuWidth*3;
            [self.verticalLine3 setFrame:veritalf3];
            [self.verticalLine3 setHidden:NO];
            
            
            fansButtonf.origin.x=menuWidth*3;
            fansButtonf.size.width=menuWidth;
            [self.fansButton setFrame:fansButtonf];
            fansLabelf.origin.x=menuWidth*3;
            fansLabelf.size.width=menuWidth;
            [self.fansLabel setFrame:fansLabelf];
            
            
            if([[RequestTools getInstance] getNewfollowhtcount]>0 || [[RequestTools getInstance] getNewfollowpoicount]>0){
                CGFloat focusW=[SysTools getWidthContain:followString font:self.focusButton.titleLabel.font Height:21];
                
                CGRect focusF=self.focusDotImageView.frame;
                focusF.origin.x=menuWidth*2+menuWidth/2+focusW/2+2;
                [self.focusDotImageView setFrame:focusF];
                [self.focusDotImageView setHidden:NO];
            }
            
            if([[RequestTools getInstance] getNewfanscount]>0){
                CGFloat fansW=[SysTools getWidthContain:fansString font:self.fansButton.titleLabel.font Height:21];
                
                CGRect fansF = self.fansDotsImageView.frame;
                fansF.origin.x=menuWidth*3+menuWidth/2+fansW/2+2;
                [self.fansDotsImageView setFrame:fansF];
                [self.fansDotsImageView setHidden:NO];
            }
        }
        
        dataType=clicktag;
        [self changeData:clicktag isAnimate:isanimate];
    }
    
    CGRect cellFrame=CGRectMake(0, 0, tWidth, cellheigth);
    [self setFrame:cellFrame];
}

-(void)avatarClick:(UIGestureRecognizer *)tap{
    if(user.status==-2){
        return;
    }
    
    UIImageView *tapView=(UIImageView *)tap.view;
    // 调用代理事件
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(headerViewClick:clickView:)]){
        [self.delegate headerViewClick:tapView.tag clickView:tapView];
    }
}


-(IBAction)buttonDelegateClick:(UIButton *)sender{
    //如果封杀，除了头像以为，其它都不可点
//    if(sender.tag!=UserChangeAvatarTag && user.status==-2){
//        return;
    //    }
    if(sender.tag==UserLikeTag || sender.tag==UserFocusActionTag || sender.tag==UserChatTag || sender.tag==UserMyFocusTag || sender.tag==UserFansTag){
        if(user.status==-2){
            return;
        }
        
        if(sender.tag==UserLikeTag){
            [self addAnimationToSubView:sender];
        }
    }
    
    
    // 调用代理事件
    if(self.delegate && [self.delegate respondsToSelector:@selector(headerViewClick:clickView:)]){
        [self.delegate headerViewClick:sender.tag clickView:sender];
    }
}


-(void)handleSwipeMove:(UISwipeGestureRecognizerDirection) dure{
    
    if (dure==UISwipeGestureRecognizerDirectionLeft ) {
        // 调用代理事件
        if(self.delegate && [self.delegate respondsToSelector:@selector(headerViewClick:clickView:)]){
            if([user.uid isEqual:[LoginManager getInstance].getUid]){
            
                if(dataType==1){
                    [self.delegate headerViewClick:UserMyCollectionBtnTag clickView:self.favButton];
                }
                if(dataType==2){
                    [self.delegate headerViewClick:UserMyFocusTag clickView:self.focusButton];
                }
            }else{
                [self.delegate headerViewClick:UserMyFocusTag clickView:self.focusButton];
            }
        }
        
    }
    if(dure==UISwipeGestureRecognizerDirectionRight){
        // 调用代理事件
        if(self.delegate && [self.delegate respondsToSelector:@selector(headerViewClick:clickView:)]){
            if([user.uid isEqual:[LoginManager getInstance].getUid]){
                if(dataType==2){
                    [self.delegate headerViewClick:UserMyListBtnTag clickView:self.sendButton];
                }
                
                if(dataType==3){
                    [self.delegate headerViewClick:UserMyCollectionBtnTag clickView:self.favButton];
                }
            }else{
                [self.delegate headerViewClick:UserMyListBtnTag clickView:self.sendButton];
            }
        }
    }
    
    
}



-(void)changeData:(UserHeaderCellClickTag) tag isAnimate:(BOOL) animate{
    if(tag==1){
        [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.fansButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.sendButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.fansLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.sendLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
    }else if (tag == 2){
        [self.sendButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.fansButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.favButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.favLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
        [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.fansLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    }else if(tag==3){
        
        [self.sendButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.fansButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.focusLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
        [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.fansLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    }else if(tag==4){
        
        [self.sendButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.fansButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.fansLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
        [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    }
    
}


//点赞动画
- (void)addAnimationToSubView:(UIView *)view{
    [view setAlpha:1];
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.0),@(2.0),@(1.0),@(0)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0),@(0.1)];
    k.calculationMode = kCAAnimationLinear;
    [view.layer addAnimation:k forKey:@"SHOW"];
    
}

@end
