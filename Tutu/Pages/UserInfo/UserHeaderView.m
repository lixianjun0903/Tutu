//
//  UserHeaderView.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserHeaderView.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Additions.h"
#import "UIView+Border.h"

@implementation UserHeaderView{
    int dataType;
    UserInfo *user;
    CGFloat tWidth;
    
}

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor=[UIColor clearColor];
    [self.bottomBackBg setBackgroundColor:[UIColor whiteColor]];
    
    [self.zanButton setTag:ItemClickTag_Zan];
    [self.zanButton setBackgroundColor:UIColorFromRGBAlpha(TextGrayColor, 0.5)];
    [self.zanButton.layer setCornerRadius:self.zanButton.frame.size.height/2];
    [self.zanButton.layer setMasksToBounds:YES];
    [self.zanButton setImage:[UIImage imageNamed:@"user_zan"] forState:UIControlStateNormal];
    [self.zanButton setImageEdgeInsets:UIEdgeInsetsMake(6.5, 9.5, 6.5, 30)];
    [self.zanButton setTitle:@"" forState:UIControlStateNormal];
    [self.zanButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.zanButton.titleLabel setFont:ListDetailFont];
    self.zanButton.hidden=YES;
    
    self.editButton.hidden=YES;
    [self.editButton setImageEdgeInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
    [self.editButton setBackgroundColor:[UIColor clearColor]];
    [self.editButton setImage:[UIImage imageNamed:@"user_edit_sel"] forState:UIControlStateHighlighted];
    [self.editButton setImage:[UIImage imageNamed:@"user_edit"] forState:UIControlStateNormal];
    
    self.ageView.layer.cornerRadius=2;
    self.ageView.layer.masksToBounds=YES;
    
    self.avatarImageView.layer.cornerRadius=self.avatarImageView.frame.size.width/2;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.userInteractionEnabled=YES;
    
    
    [self.sendButton addTarget:self action:@selector(headerItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.favButton addTarget:self action:@selector(headerItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.focusButton addTarget:self action:@selector(headerItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:ListTitleFont];
    [self.sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.sendLabel setTextAlignment:NSTextAlignmentCenter];
    [self.sendLabel setFont:ListTimeFont];
    
    [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
    [self.favButton.titleLabel setFont:ListTitleFont];
    [self.favButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.favLabel setTextAlignment:NSTextAlignmentCenter];
    [self.favLabel setFont:ListTimeFont];
    
    
    [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
    [self.focusButton.titleLabel setFont:ListTitleFont];
    [self.focusButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.focusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.focusLabel setFont:ListTimeFont];
    
    [self.verticalLine1 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [self.verticalLine2 setBackgroundColor:UIColorFromRGB(ListLineColor)];
    
    
    
    self.editButton.tag=ItemClickTag_Edit;
    self.zanButton.tag=ItemClickTag_Zan;
    self.avatarImageView.tag=ItemClickTag_ChangeAvatar;
    self.sendButton.tag=ItemClickTag_Send;
    self.favButton.tag=ItemClickTag_Fav;
    self.focusButton.tag=ItemClickTag_Focus;
    
    [self.editButton addTarget:self action:@selector(headerItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerItemClick:)];
    [self.avatarImageView addGestureRecognizer:tap];
    
    
    [self.menuView setBackgroundColor:[UIColor clearColor]];
    self.menuView.hidden=YES;
    
    self.beKillView.hidden=YES;
    _sendLabel.text = TTLocalString(@"TT_topic");
    _favLabel.text = TTLocalString(@"TT_collection");
    _focusLabel.text = TTLocalString(@"TT_follow");

}


-(CGFloat)dataToView:(UserInfo *)userInfo isSelf:(BOOL)ismy width:(CGFloat)viewWidth{
    CGFloat cellheigth=0.0f;
    user = userInfo;
    tWidth=viewWidth;
    if(userInfo){
        //是否封杀
        if(userInfo.status==-2){
            self.beKillView.hidden=NO;
        }else{
            self.beKillView.hidden=YES;
        }
        
        self.zanButton.hidden=NO;
        if(userInfo.isliked){
            [self.zanButton setImage:[UIImage imageNamed:@"user_zan_check"] forState:UIControlStateNormal];
        }else{
            [self.zanButton setImage:[UIImage imageNamed:@"user_zan"] forState:UIControlStateNormal];
        }
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
        self.zanButton.tag=ItemClickTag_Zan;
        [self.zanButton addTarget:self action:@selector(headerItemClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIImage *image=self.avatarImageView.image;
        if(image==nil){
            image=[UIImage imageNamed:@"avatar_default"];
        }
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:userInfo.uid time:userInfo.avatartime]] placeholderImage:image];
        
        CGRect nf=self.nickLabel.frame;
        CGFloat nameWidth=[SysTools getWidthContain:userInfo.nickname font:ListTitleFont Height:nf.size.height];
        nf.size.width=nameWidth;
        [self.nickLabel setFrame:nf];
        [self.nickLabel setText:CheckNilValue(userInfo.nickname)];
        [self.nickLabel setNumberOfLines:1];
        [self.nickLabel setFont:ListTitleFont];
        [self.nickLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        
        if(ismy){
            CGRect editF=self.editButton.frame;
            editF.origin.x=nf.size.width+nf.origin.x+5;
            [self.editButton setFrame:editF];
            self.editButton.hidden=NO;
            
        }else{
            self.editButton.hidden=YES;
        }
        
        CGRect ttF=self.tutuNumberLabel.frame;
        NSString *tutuNum=[NSString stringWithFormat:@"%@：%@",TTLocalString(@"TT_tutu_number"),CheckNilValue(userInfo.uid)];
        CGFloat ttwidth=[SysTools getWidthContain:tutuNum font:ListTitleFont Height:ttF.size.height];
        ttF.size.width=ttwidth;
        [self.tutuNumberLabel setFrame:ttF];
        [self.tutuNumberLabel setText:tutuNum];
        [self.tutuNumberLabel setFont:ListTitleFont];
        [self.tutuNumberLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        
        CGRect ageF=self.ageView.frame;
        ageF.origin.x=ttF.size.width+ttF.origin.x+10;
        [self.ageView setFrame:ageF];
        NSString *gender=@"girl.png";
        [self.ageView setBackgroundColor:UIColorFromRGB(GenderGirlColorBg)];
        if([userInfo.gender intValue]==1){
            gender=@"boy.png";
            [self.ageView setBackgroundColor:UIColorFromRGB(GenderBoyColorBg)];
        }
        [self.ageImageView setImage:[UIImage imageNamed:gender]];
        int age=[userInfo.age intValue];
        if(age>=0){
            [self.ageLabel setText:[NSString stringWithFormat:@"%d",age]];
        }
        else
        {
            [self.ageLabel setText:@"0"];
        }
        
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
        
        [self.adrAndXZLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.adrAndXZLabel setFont:ListDetailFont];
        [self.adrAndXZLabel setText:[NSString stringWithFormat:@"%@%@",address,constellation]];
        
        if(userInfo.userhonorlevel==0){
            self.levelImageView.hidden=YES;
        }else{
            self.levelImageView.hidden=NO;
            [self.levelImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user_level%d",userInfo.userhonorlevel]]];
        }
        
        [self.descLabel setNumberOfLines:0];
        [self.descLabel setText:userInfo.sign];
        [self.descLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [self.descLabel setFont:ListDetailFont];
        CGSize size = [self.descLabel getLabelSize];
        if([@"" isEqual:userInfo.sign]){
            size.height=0;
        }
        
        CGRect descF=self.descLabel.frame;
        CGFloat descHeight=size.height;
        descF.size.height=descHeight;
        [self.descLabel setFrame:descF];
        
        
        
        cellheigth=descF.origin.y+descF.size.height;
        
        CGRect bf=self.menuView.frame;
        bf.origin.y=cellheigth+10;
        [self.menuView setFrame:bf];
        
        self.menuView.hidden=NO;
        [self.menuView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1 andViewWidth:tWidth];
        
        cellheigth=cellheigth+bf.size.height+10;
        
        // 设置底部白色
//        [self.bgColorView setBackgroundColor:[UIColor whiteColor]];
//        [self.bgColorView setFrame:CGRectMake(0, 250, self.frame.size.width, cellheigth-250)];
        
        
        NSString *sendString=[NSString stringWithFormat:@"%d",userInfo.topicnum];
        [self.sendButton setTitle:sendString forState:UIControlStateNormal];
        
        NSString *favString=[NSString stringWithFormat:@"%d",userInfo.favnum];
        [self.favButton setTitle:favString forState:UIControlStateNormal];
        
        NSString *followString=[NSString stringWithFormat:@"%d",userInfo.follownum];
        [self.focusButton setTitle:followString forState:UIControlStateNormal];
        
        
        CGRect sendButtonf=self.sendButton.frame;
        CGRect favButtonf=self.favButton.frame;
        CGRect focusButtonf=self.focusButton.frame;
        
        
        // 设置底部白色
        [self.bottomBackBg setBackgroundColor:[UIColor whiteColor]];
        [self.bottomBackBg setFrame:CGRectMake(0, 250, self.frame.size.width, cellheigth-250)];
        
        
        CGRect veritalf=self.verticalLine1.frame;
        
        CGRect sendLabelf=self.sendLabel.frame;
        CGRect favLabelf=self.favLabel.frame;
        CGRect focusLabelf=self.focusLabel.frame;
        
        CGFloat menuWidth=tWidth/2;
        
        if(![userInfo.uid isEqual:[[LoginManager getInstance] getUid]]){
            menuWidth=tWidth/2;
            
            sendButtonf.size.width=menuWidth;
            [self.sendButton setFrame:sendButtonf];
            sendLabelf.size.width=menuWidth;
            [self.sendLabel setFrame:sendLabelf];
            
            veritalf.origin.x=menuWidth;
            [self.verticalLine1 setFrame:veritalf];
            [self.verticalLine2 setHidden:YES];
            
            [self.favButton setHidden:YES];
            [self.favLabel setHidden:YES];
            
            focusButtonf.origin.x=menuWidth;
            focusButtonf.size.width=menuWidth;
            [self.focusButton setFrame:focusButtonf];
            focusLabelf.origin.x=menuWidth;
            focusLabelf.size.width=menuWidth;
            [self.focusLabel setFrame:focusLabelf];
            
            
            [self.sendButton setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
            
            [self.zanButton addTarget:self action:@selector(headerItemClick:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            menuWidth=tWidth/3;
            
            sendButtonf.size.width=menuWidth;
            sendButtonf.origin.x=0;
            [self.sendButton setFrame:sendButtonf];
            sendLabelf.size.width=menuWidth;
            sendLabelf.origin.x=0;
            [self.sendLabel setFrame:sendLabelf];
            
            veritalf.origin.x=menuWidth;
            [self.verticalLine1 setFrame:veritalf];
            CGRect verticalf2=self.verticalLine2.frame;
            verticalf2.origin.x=menuWidth*2;
            [self.verticalLine2 setFrame:verticalf2];
            
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
        }
    }
    
    dataType=1;
    
    CGRect cellFrame=CGRectMake(0, 0, tWidth, cellheigth);
    [self setFrame:cellFrame];
    
    return self.frame.size.height;
}



-(void)headerItemClick:(UIButton *)button{
    if(button.tag==ItemClickTag_ChangeAvatar){
    }
    
    if(button.tag==ItemClickTag_Zan){
        [self addAnimationToSubView:button];
        if(self.delegate && [self.delegate respondsToSelector:@selector(itemClick:)]){
            [self.delegate itemClick:(int)button.tag];
        }
    }
    if(button.tag==ItemClickTag_Edit){
        if(self.delegate && [self.delegate respondsToSelector:@selector(itemClick:)]){
            [self.delegate itemClick:(int)button.tag];
        }
    }
    
    if(button.tag==ItemClickTag_Send){
        [self changeMenuButtonStype:ItemClickTag_Send isAnimate:NO];
    }
    
    if(button.tag==ItemClickTag_Fav){
        [self changeMenuButtonStype:ItemClickTag_Fav isAnimate:NO];
        
    }
    
    if(button.tag==ItemClickTag_Focus){
        [self changeMenuButtonStype:ItemClickTag_Focus isAnimate:NO];
        
    }
}



-(void)changeMenuButtonStype:(UserViewHeaderClickTag) tag isAnimate:(BOOL) animate{
    if(tag==ItemClickTag_Send){
        [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.sendButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.sendLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
    }else if (tag == ItemClickTag_Fav){
        [self.sendButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.favButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.favLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
        [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.focusLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    }else if(tag==ItemClickTag_Focus){
        
        [self.sendButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.favButton setTitleColor:UIColorFromRGB(TextBlackColor) forState:UIControlStateNormal];
        [self.focusButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        
        [self.focusLabel setTextColor:UIColorFromRGB(UserInfoMenuHigh)];
        [self.sendLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.favLabel setTextColor:UIColorFromRGB(TextGrayColor)];
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

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        //自动将事件传递到上一层
        return nil;
    }
    return hitView;
}

@end
