//
//  RCLetterCell.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCLetterCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+Border.h"
#import "TouchImageView.h"
#import "M13ProgressViewRing.h"
#import "UserDetailController.h"

@implementation RCLetterCell{
    UILabel *_timeLbl;
    UIImageView *_avatarImage;
    TouchImageView *_messageBg;
    UILabel *_sysMessageLbl;
    UIButton *_reSendBtn;
    UIActivityIndicatorView *sendingStatusView;

    RCMessage *messageModel;
    int w;
}

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        // 1、创建时间按钮
        _timeLbl = [[UILabel alloc] init];
        [_timeLbl setBackgroundColor:[UIColor clearColor]];
        [_timeLbl setTextAlignment:NSTextAlignmentCenter];
        [_timeLbl setFont:FONT_CHAT];
        [_timeLbl setTextColor:UIColorFromRGB(TextGrayColor)];
        [self.contentView addSubview:_timeLbl];
        
        // 2、创建头像
        _avatarImage = [[UIImageView alloc] init];
        [_avatarImage setBackgroundColor:[UIColor clearColor]];
        _avatarImage.layer.cornerRadius=20;
        _avatarImage.layer.masksToBounds=YES;
        _avatarImage.userInteractionEnabled=YES;
        UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarClick:)];
        [_avatarImage addGestureRecognizer:tap];
        [self.contentView addSubview:_avatarImage];
        
        // 3、创建内容
        _messageBg = [[TouchImageView alloc] init];
        [_messageBg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_messageBg];
        
        // 4、系统内容
        _sysMessageLbl=[[UILabel alloc] init];
        
        _sysMessageLbl.layer.cornerRadius=5;
        _sysMessageLbl.layer.masksToBounds=YES;
        [_sysMessageLbl setTextAlignment:NSTextAlignmentCenter];
        [_sysMessageLbl setTextColor:[UIColor whiteColor]];
        [_sysMessageLbl setFont:FONT_CHAT];
        [self.contentView addSubview:_sysMessageLbl];
        
        _reSendBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_reSendBtn setBackgroundColor:[UIColor clearColor]];
        [_reSendBtn setImage:[UIImage imageNamed:@"letter_resend"] forState:UIControlStateNormal];
        [_reSendBtn addTarget:self action:@selector(resendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_reSendBtn];
        
        
        
        sendingStatusView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [sendingStatusView setCenter:CGPointMake(0, 0)];
        sendingStatusView.hidden=YES;
        [sendingStatusView stopAnimating];
        [self.contentView addSubview:sendingStatusView];
    }
    return self;
}


-(int)initViewData:(RCMessage *)model time:(NSString *)time width:(int)width{
    int y=0;
    w=width;
    messageModel=model;
    self.msg=model;
    
    [_timeLbl setText:@""];
    [_sysMessageLbl setText:@""];
    [_sysMessageLbl setBackgroundColor:[UIColor clearColor]];
    
    _reSendBtn.hidden=YES;
    [sendingStatusView stopAnimating];
    
    _avatarImage.hidden=YES;
    _messageBg.hidden=YES;
    for (UIView *view in _messageBg.subviews) {
        [view removeFromSuperview];
    }
    
    _messageBg.userInteractionEnabled=YES;
    
    if(time!=nil && ! [@"" isEqual:time]){
        [_timeLbl setText:time];
        [_timeLbl setFrame:CGRectMake(0, 10, w, 20)];
        y=30;
    }
    
    BOOL isCounter=NO;
    //判断是否为系统消息
    if([model.objectName isEqual:RCTextMessageTypeIdentifier]){
        RCTextMessage *item = (RCTextMessage *)model.content;
        NSString *extra=item.extra;
        @try {
            NSDictionary *msgDict=[[extra JSONString] objectFromJSONString];
            NSString *counter=[msgDict objectForKey:@"counter"];
            if(counter!=nil && [@"isSystem" isEqual:counter]){
                isCounter=YES;
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    
    UIView *msgView=nil;
    if(![self.targetId isEqual:model.senderUserId]){
        _messageBg.hidden=NO;
        _avatarImage.hidden=NO;
        //自己
        [_avatarImage setFrame:CGRectMake(w-50, y+5, 40, 40)];
        
        y=y+10;
        msgView=[self parseDataToView:y isSelf:YES];

        //当对方删除我时，也显示红色,或者我发送失败时
        if(model.sentStatus == SentStatus_FAILED){
            _reSendBtn.hidden=NO;
            CGRect f = CGRectMake(_messageBg.frame.origin.x-30, _messageBg.frame.origin.y+(_messageBg.frame.size.height-24)/2, 24, 24);
            [_reSendBtn setFrame:f];
        }else if(model.sentStatus == SentStatus_SENDING){
            [sendingStatusView setCenter:CGPointMake(_messageBg.frame.origin.x-30+12, _messageBg.frame.origin.y+(_messageBg.frame.size.height-24)/2+12)];
            [sendingStatusView startAnimating];
        }
    }else if(isCounter){
        
        RCTextMessage *item = (RCTextMessage *)model.content;
        int systemType=1;
        @try {
            NSDictionary *msgDict=[[item.extra JSONString] objectFromJSONString];
            NSString *st=[msgDict objectForKey:@"systemType"];
            if(st!=nil){
                systemType=[st intValue];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        if(systemType==2){
            y=y+10;
            _messageBg.hidden=NO;
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:item.content];
            [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(SendFriendApply) range:NSMakeRange(item.content.length-6,6)];
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            [btn setAttributedTitle:string forState:UIControlStateNormal];
            [btn.titleLabel setFont:FONT_CHAT];
            [btn.titleLabel setNumberOfLines:0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:UIColorFromRGB(ChatSysMessageBg)];
            [btn setTintColor:UIColorFromRGB(ChatSysMessageBgHigh)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            btn.layer.cornerRadius=5;
            btn.layer.masksToBounds=YES;
            [btn addTarget:self action:@selector(btnGoUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            
            CGFloat height=[SysTools getHeightContain:item.content font:FONT_CHAT Width:w-50];
            
//            UILabel *sendLabel=[[UILabel alloc] initWithFrame:CGRectMake(35, height, w-50-40, 25)];
//            [sendLabel setText:@"发送好友请求"];
//            [sendLabel setTextColor:UIColorFromRGB(SendFriendApply)];
//            [sendLabel setFont:FONT_CHAT];
//            [btn addSubview:sendLabel];
            [_messageBg addSubview:btn];
            
            [_messageBg setFrame:CGRectMake(25, y, w-50, height+25)];
            [btn setFrame:_messageBg.bounds];
            
            y=y+height+25;
            
        }else{
            [_sysMessageLbl setNumberOfLines:0];
            [_sysMessageLbl setText:item.content];
            [_sysMessageLbl setBackgroundColor:UIColorFromRGB(ChatSysMessageBg)];
            
            CGFloat height=[SysTools getHeightContain:item.content font:_sysMessageLbl.font Width:w-50];
                
            if(height<40){
                height=40;
            }else{
                height=height+10;
            }
            [_sysMessageLbl setFrame:CGRectMake(25, y+10, w-50, height)];
            y=y+height+20;
        }
    }else{
        _messageBg.hidden=NO;
        _avatarImage.hidden=NO;
        
        //对方
        [_avatarImage setFrame:CGRectMake(10, y+5, 40, 40)];
        
        y=y+10;
        msgView=[self parseDataToView:y isSelf:NO];
    }
    
    
    
    int h=0;
    if(_messageBg && !_messageBg.hidden){
        h=_messageBg.bounds.size.height;
    }
    y=y+h+10;
    [self setFrame:CGRectMake(0, 0, w, y)];
    
    [_messageBg addLongPress:messageModel delegate:self.delegate];
    
    return y;
}

-(void)avatarClick:(UITapGestureRecognizer *) tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(IconOnClick:view:)]){
        [self.delegate IconOnClick:messageModel view:(UIImageView *)tap.view];
    }
}

-(void)otherClick:(UITapGestureRecognizer *)tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(activeOnClick:type:)]){
        [self.delegate activeOnClick:messageModel type:RCContentClick];
    }
}

-(void)voiceClick:(UITapGestureRecognizer *)tap{
    UIImageView *iv=(UIImageView *)[tap.view viewWithTag:100];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(voiceClick:view:)]){
        [self.delegate voiceClick:messageModel view:iv];
    }
}

-(IBAction)btnClick:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(activeOnClick:type:)]){
        [self.delegate activeOnClick:messageModel type:RCButtonClick];
    }
}

-(void)resendMessage:(UIButton *) sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(resendMessage:)]){
        [self.delegate resendMessage:messageModel];
    }
}

-(void)btnGoUserInfo:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(goUserInfoApplyFriend)]){
        [self.delegate goUserInfoApplyFriend];
    }
}


-(UIView *)parseDataToView:(int) y isSelf:(BOOL) ismy{
    if(messageModel==nil){
        return nil;
    }
    NSString *avatarURL=[SysTools getHeaderImageURL:messageModel.senderUserId time:[NSString stringWithFormat:@"%@",self.lastTime]];
    if(ismy){
        avatarURL=[SysTools getHeaderImageURL:messageModel.senderUserId time:[NSString stringWithFormat:@"%@",[[LoginManager getInstance] getLoginInfo].avatartime]];
    }
    
    
    [_avatarImage sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    UIView *msgView=nil;
    if([messageModel.objectName isEqual:RCRichContentMessageTypeIdentifier]){
        msgView=[self createRichMessageView:ismy];
        if(ismy){
            [_messageBg setImage:[[UIImage imageNamed:@"letter_rich_mybg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 15, 25)]];
            
        }else{
            [_messageBg setImage:[[UIImage imageNamed:@"letter_rich_otherbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 25, 15, 15)]];
        }
        
        
        _messageBg.userInteractionEnabled=YES;
        [_messageBg addSubview:msgView];
    }else if([messageModel.objectName isEqual:RCVoiceMessageTypeIdentifier]){
        RCVoiceMessage *voiceModel=(RCVoiceMessage *)messageModel.content;
        msgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        
        UILabel *durationLabel=[[UILabel alloc] init];
        [durationLabel setFont:ListDetailFont];
        [durationLabel setText:[NSString stringWithFormat:@"%ld″",voiceModel.duration]];
        [msgView addSubview:durationLabel];
        
        UIImageView *iv=[[UIImageView alloc] init];
        if(ismy){
            [durationLabel setFrame:CGRectMake(10, 0, 60, 20)];
            [durationLabel setTextAlignment:NSTextAlignmentRight];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setBackgroundColor:[UIColor clearColor]];
            
            [iv setFrame:CGRectMake(80,0, 14, 20)];
            [iv setImage:[UIImage imageNamed:@"letter_whitevoice3"]];
            iv.animationImages = [NSArray arrayWithObjects:
                                  [UIImage imageNamed:@"letter_whitevoice1.png"],
                                  [UIImage imageNamed:@"letter_whitevoice2.png"],
                                  [UIImage imageNamed:@"letter_whitevoice3.png"], nil];
        }else{
            [durationLabel setFrame:CGRectMake(40, 0, 60, 20)];
            [durationLabel setTextAlignment:NSTextAlignmentLeft];
            [durationLabel setTextColor:UIColorFromRGB(TextBlackColor)];
            
            [iv setFrame:CGRectMake(10,0, 14, 20)];
            [iv setImage:[UIImage imageNamed:@"letter_highvoice3"]];
            
            iv.animationImages = [NSArray arrayWithObjects:
                                  [UIImage imageNamed:@"letter_highvoice1.png"],
                                  [UIImage imageNamed:@"letter_highvoice2.png"],
                                  [UIImage imageNamed:@"letter_highvoice3.png"], nil];
        }
        iv.tag=100;
        
        
        iv.animationDuration = 1.0f;
        iv.animationRepeatCount = 0;
        
        [msgView addSubview:iv];
        [msgView setFrame:CGRectMake(10, 10, msgView.bounds.size.width, msgView.bounds.size.height)];
        
        msgView.userInteractionEnabled=YES;
        UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceClick:)];
        [msgView addGestureRecognizer:tap];

        [_messageBg addSubview:msgView];
    }else if ([messageModel.objectName isEqual:RCTextMessageTypeIdentifier]){
        RCTextMessage *rcmsg=(RCTextMessage *)messageModel.content;
        if(ismy){
            
            msgView=[SysTools assembleMessageWithMessage:rcmsg.content maxWidth:w-100 color:[UIColor whiteColor]];
            
            CGRect f=msgView.frame;
            if(f.size.width<40){
                f.size.width=40;
            }
            [msgView setFrame:f];
            
            [msgView setFrame:CGRectMake(10, 10, msgView.bounds.size.width, msgView.bounds.size.height)];
        }else{
            msgView=[SysTools assembleMessageWithMessage:rcmsg.content maxWidth:w-100 color:UIColorFromRGB(TextBlackColor)];
            
            
            CGRect f=msgView.frame;
            if(f.size.width<40){
                f.size.width=40;
            }
            [msgView setFrame:f];
            
            [msgView setFrame:CGRectMake(15, 10, msgView.bounds.size.width, msgView.bounds.size.height)];
        }
        [msgView setBackgroundColor:[UIColor clearColor]];
        [_messageBg addSubview:msgView];
    }else if([RCImageMessageTypeIdentifier isEqual:messageModel.objectName]){
        
        RCImageMessage *rcmsg=(RCImageMessage *)messageModel.content;
        
        CGFloat imgWidth=100;
        CGFloat imgHeight=140;
//        if(rcmsg!=nil && rcmsg.thumbnailImage!=nil){
//            imgWidth=rcmsg.thumbnailImage.size.width;
//            imgHeight=rcmsg.thumbnailImage.size.height;
//        }
        
        CGRect imgFrame=CGRectMake(0, 0, imgWidth,imgHeight);
        msgView=[[UIView alloc] initWithFrame:imgFrame];
        UIImageView *iv=[[UIImageView alloc] initWithFrame:imgFrame];
        if(rcmsg.thumbnailImage){
            [iv setImage:rcmsg.thumbnailImage];
        }else if([rcmsg.imageUrl hasPrefix:@"http:"]){
            [iv sd_setImageWithURL:[NSURL URLWithString:rcmsg.imageUrl] placeholderImage:[UIImage imageNamed:@"message_default"]];
        }else if([rcmsg.imageUrl rangeOfString:@"/Documents/"].location !=NSNotFound)
        {
            int location=(int)[rcmsg.imageUrl rangeOfString:@"/Documents/"].location;
            NSString *imgurl=[rcmsg.imageUrl substringFromIndex:location+11];
            imgurl=getDocumentsFilePath(imgurl);
            [iv setImage:[UIImage imageWithContentsOfFile:imgurl]];
        }else{
            [iv setImage:[UIImage imageNamed:@"message_default"]];
        }
        iv.contentMode=UIViewContentModeScaleAspectFill;
        iv.layer.masksToBounds=YES;
        iv.userInteractionEnabled=YES;
        iv.tag=1;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPhoto:)];
        [iv addGestureRecognizer:tap];
        [msgView addSubview:iv];
        
        UIImageView *ivbg=[[UIImageView alloc] initWithFrame:imgFrame];
        if(ismy){
            [ivbg setImage:[[UIImage imageNamed:@"letter_image_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(45, 30, 30, 35)]];
            
        }else{
            [ivbg setImage:[[UIImage imageNamed:@"letter_image_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(45, 35, 30, 30)]];
        }
        [msgView addSubview:ivbg];
        [_messageBg addSubview:msgView];
        
    }
    int h=0;
    if(ismy){
        CGSize contentSize=msgView.bounds.size;
        if(contentSize.height<10){
            contentSize.height=10;
        }
        
        h=contentSize.height+20;
        if([RCTextMessageTypeIdentifier isEqual:messageModel.objectName] || [RCVoiceMessageTypeIdentifier isEqual:messageModel.objectName]){
            [_messageBg setImage:[[UIImage imageNamed:@"letter_greenbg_nor"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 12, 18)]];
            [_messageBg setFrame:CGRectMake(w-msgView.bounds.size.width-80, y, msgView.bounds.size.width+25, h)];
        }else if([RCImageMessageTypeIdentifier isEqual:messageModel.objectName]){
            [_messageBg setImage:nil];
            [_messageBg setFrame:CGRectMake(w-msgView.bounds.size.width-55, y, msgView.bounds.size.width, h-20)];
        }else if([RCRichContentMessageTypeIdentifier isEqual:messageModel.objectName]){
            h=h-20;
            [_messageBg setFrame:CGRectMake(w-msgView.bounds.size.width-65, y, msgView.bounds.size.width+10, h)];
            [msgView setFrame:CGRectMake(2, 0, msgView.bounds.size.width, msgView.bounds.size.height)];
        }
        
    }else{
        CGSize contentSize=msgView.bounds.size;
        if(contentSize.height<10){
            contentSize.height=10;
        }
        
        h=contentSize.height+20;
        
        if([RCTextMessageTypeIdentifier isEqual:messageModel.objectName] || [RCVoiceMessageTypeIdentifier isEqual:messageModel.objectName]){
            [_messageBg setImage:[[UIImage imageNamed:@"letter_graybg_nor"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 18, 12, 12)]];
            [_messageBg setFrame:CGRectMake(55, y, contentSize.width+25, h)];
        }else if([RCImageMessageTypeIdentifier isEqual:messageModel.objectName]){
            [_messageBg setImage:nil];
            [_messageBg setFrame:CGRectMake(55, y, contentSize.width+25, h-20)];
        }else if([RCRichContentMessageTypeIdentifier isEqual:messageModel.objectName]){
            h=h-20;
            [_messageBg setFrame:CGRectMake(55, y, msgView.bounds.size.width+10, h)];
            [msgView setFrame:CGRectMake(9, 0, msgView.bounds.size.width, msgView.bounds.size.height)];
        }
    }
    return msgView;
}


-(UIView *) createRichMessageView:(BOOL) isMySelf{
    int iw=w-90;
    
    int xy=0;
    
    RCRichContentMessage *richmessage=(RCRichContentMessage *)messageModel.content;
    NSDictionary *dict = [[richmessage.extra JSONString] objectFromJSONString];
    if([richmessage.extra isKindOfClass:[NSString class]]){
        dict=[richmessage.extra objectFromJSONString];
    }
    NSString *sendMsg=[dict objectForKey:@"sendmsg"];
    if(sendMsg!=nil){
        xy=[SysTools getHeightContain:sendMsg font:ListDetailFont Width:iw-24];
        xy=xy+20;
    }
    
    
    UIView *activeView=[[UIView alloc] initWithFrame:CGRectMake(0, 10, iw, 130+xy)];
    [activeView setBackgroundColor:[UIColor clearColor]];
    activeView.userInteractionEnabled=YES;
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(otherClick:)];
    [activeView addGestureRecognizer:tap];
    
    
    UIButton *goButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setBackgroundColor:[UIColor clearColor]];
    [goButton setFrame:CGRectMake(0, 90+xy, iw, 35)];
    [goButton.titleLabel setFont:ListDetailFont];
    goButton.layer.masksToBounds=YES;
    goButton.layer.cornerRadius=5;
    [goButton setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
    [goButton setTitle:[dict objectForKey:@"buttonText"] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [activeView addSubview:goButton];
    
    
    
    
    UIView *topView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iw, 94+xy)];
    [topView setBackgroundColor:[UIColor clearColor]];
    [topView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    [activeView addSubview:topView];
    
    
    if(xy>10){
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(12,0, iw-24, xy)];
        [titleLabel setFont:ListDetailFont];
        [titleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [titleLabel setText:sendMsg];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setNumberOfLines:0];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [topView addSubview:titleLabel];
        
        UIImageView *lineView=[[UIImageView alloc] initWithFrame:CGRectMake(12,xy, iw-24, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
        [topView addSubview:lineView];
    }
    

    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(12, 15+xy, 65, 65)];
    [iv sd_setImageWithURL:[NSURL URLWithString:richmessage.imageURL] placeholderImage:[UIImage imageNamed:@"message_default"]];
    [iv setBackgroundColor:[UIColor clearColor]];
    iv.layer.masksToBounds=YES;
    iv.layer.cornerRadius=5;
    [iv setContentMode:UIViewContentModeScaleAspectFill];
    [topView addSubview:iv];
    
    int xw=iw-89;
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(89,15+xy, xw-10, 15)];
    [titleLabel setFont:ListTitleFont];
    [titleLabel setTextColor:UIColorFromRGB(SystemColor)];
    [titleLabel setText:richmessage.title];
    [titleLabel setNumberOfLines:1];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:titleLabel];
    
    UILabel *msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(89, 30+xy, xw-10, 50)];
    [msgLabel setFont:ListTimeFont];
    [msgLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [msgLabel setText:richmessage.digest];
    [msgLabel setNumberOfLines:3];
    [msgLabel setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:msgLabel];
    
    
    return activeView;
}



-(void)showBigPhoto:(UITapGestureRecognizer *) tap
{
    UIImageView *_picView=(UIImageView *)tap.view;
    if(messageModel==nil || messageModel.content==nil || ![RCImageMessageTypeIdentifier isEqual:messageModel.objectName]){
        return;
    }

    RCImageMessage *msg=(RCImageMessage *)messageModel.content;
    if(msg==nil || msg.imageUrl==nil){
        return;
    }
    

    [_picView sd_setImageWithURL:[NSURL URLWithString:msg.imageUrl] placeholderImage:_picView.image options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(image){
            [_picView setImage:image];
        }
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:_picView];
    
    //
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    imageViewer.delegate = self;
    imageViewer.isShowMenu=YES;
    imageViewer.menuType=3;
    imageViewer.rcmsg=messageModel;
    [imageViewer showWithImageViews:photos selectedView:_picView];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(showBigImageView:)]){
        [self.delegate showBigImageView:messageModel];
        
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - XHImageViewerDelegate

- (void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView {
    //    NSLog(@"index : %d", index);
    
    for (UIView *v in selectedView.subviews) {
        [v removeFromSuperview];
    }
    [selectedView removeFromSuperview];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(refreshRow:)]){
        [self.delegate refreshRow:self];
        
    }
    
}

@end
