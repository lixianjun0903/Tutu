//
//  RCLetterController.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-16.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCLetterController.h"

#define cellIdentifier @"RCLetterCell"
#import "SVWebViewController.h"
#import "TopicDetailController.h"
#import "RCUserInfo.h"
#import "AmrDataConverter.h"
#import "ShareTutuFriendsController.h"
#import "SDWebImageManager.h"

#import "ToReportController.h"
#import "UserInfoDB.h"
#import "ApplyFriendsController.h"
#import "ListTopicsController.h"
#import "SameCityController.h"

#import "RDVTabBarController.h"

#define ListCount 20
#define PhotoViewHeight 216
#define VoiceViewHeight 216

@interface RCLetterController (){
    //表情键盘
    FaceBoard *faceBoard;
    
    UIView *photoView;
    UIView *voiceView;
    UILabel *voiceLabel;
    UILabel *voiceTimeLabel;
    NSTimer *voiceTimer;

    
    int w;
    int h;
    
    //是否显示的表情键盘
    BOOL isShowFace;

    //当前是否有键盘显示，是否是全屏显示消息
    BOOL isShowKeyBoard;
    CGFloat KeyBoardHeight;
    
    // 是否显示图片
    BOOL isShowPhoto;
    
    // 是否显示声音
    BOOL isShowVoice;
    

    CGFloat tableHeight;
    CGFloat tableY;

    //屏幕点击事件，用于隐藏键盘
    UITapGestureRecognizer *tapRecognizer;
    NSMutableArray *mData;
    UITableView *chatTable;
    
    //保存发送的数据，方便发送有结果了，刷新数据
    NSMutableDictionary *sendDict;
    
    //开始录音
    NSURL *tmpFile;
    AVAudioRecorder *recorder;
    BOOL recording;
    AVAudioPlayer *audioPlayer;
    
    //上一次播放的声音
    UIImageView *lastImageView;
    
    //发送图片
    UIImage *tempImage;
    
    //正在做好友请求
    BOOL isRequstFriend;
    BOOL isRequstContent;
    
    RCMessage *reSendItem;
    BOOL isFront;
    
    UserInfo *loginUser;
}

@end

@implementation RCLetterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int sh=iOS7?0:20;
    
    
    w=self.view.mj_width;
    h=self.view.mj_height-sh;
    
    //初始化table
    tableHeight=h-NavBarHeight-self.footView.frame.size.height;
    tableY=NavBarHeight;
    chatTable=[[UITableView alloc] initWithFrame:CGRectMake(0, tableY, w, tableHeight)];
//    [self.view addSubview:chatTable];
//    [self.view sendSubviewToBack:self.view];
    [self.view insertSubview:chatTable atIndex:0];
    
    [self createTitleMenu];
    // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    
    [self.menuRightButton setImage:[UIImage imageNamed:@"topic_more_hl"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"topic_more"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-4, 19/2, 22-4,19/2)];
    
    
    
    chatTable.delegate=self;
    chatTable.dataSource=self;
    [chatTable registerClass:[RCLetterCell class] forCellReuseIdentifier:cellIdentifier];
    [chatTable setSeparatorColor:[UIColor clearColor]];
    [chatTable setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    //初始化其它view，发送相关
    [self createViewWithInit];
    
    
    //添加table下拉事件
    [chatTable addHeaderWithTarget:self action:@selector(headerLoading)];
//    [chatTable getRefreshFooter].transform=CGAffineTransformMakeRotation(M_PI);
    __weak RCLetterController *controller = self;
    __weak UITableView *_table=chatTable;
    [chatTable addHeaderWithCallback:^{
        WSLog(@"没走 addheader");
        [controller hideAll];
        [_table headerEndRefreshing];
    }];
    
    
    //初始化数据值
    mData=[[NSMutableArray alloc] init];
    sendDict=[[NSMutableDictionary alloc] init];
    if(self.lastTime==nil){
        self.lastTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    }
    isShowFace=NO;
    isShowKeyBoard=NO;
    isShowPhoto=NO;
    isShowVoice=NO;
    loginUser=[[LoginManager getInstance] getLoginInfo];
    
    [self getUserInfo];
    
    if([SysTools getApp].isConnect){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self headerLoading];
        });
    }else{
        
        [self.menuTitleButton setTitle:TTLocalString(@"TT_connectting") forState:UIControlStateNormal];
        // 创建连接，实现即时聊天，在其成功代理中，实现加载聊天记录和对方信息
        if([SysTools getApp].RCTokenStr!=nil && ![@"" isEqual:[SysTools getApp].RCTokenStr]){
            [[SysTools getApp] doConnection];
        }else{
            [[SendLocalTools getInstance] connetIM];
        }
    }
    
    //添加键盘监听
    [self handleKeyboard];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    isFront=YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
    if(audioPlayer!=nil && [audioPlayer isPlaying]){
        audioPlayer.currentTime = 0;  //当前播放时间设置为0
        [audioPlayer stop];
    }
    isFront=NO;
}

//取消键盘事件
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


-(void)getUserInfo{
    if(self.sessionModel==nil || self.sessionModel.topicblock==-1|| self.sessionModel.isblock==-1|| self.sessionModel.isblockme==-1){
        [[RequestTools getInstance] get:API_GET_RCUserRelationInfo(self.userid) isCache:NO completion:^(NSDictionary *dict) {
            NSDictionary *objDict=[dict objectForKey:@"data"];
            int cansendmessage=[[objDict objectForKey:@"cansendmessage"] intValue];
            NSString *errormsg=[objDict objectForKey:@"errormsg"];
            NSArray *arr=[objDict objectForKey:@"list"];
            if(arr!=nil && arr.count>0){
                self.sessionModel=[[RCSessionModel alloc] initWithMyDict:[arr objectAtIndex:0]];
                self.sessionModel.cansendmessage=cansendmessage;
                self.sessionModel.errormsg=errormsg;
                
                [self.menuTitleButton setTitle:self.sessionModel.nickname forState:UIControlStateNormal];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }else{
        [self.menuTitleButton setTitle:self.sessionModel.nickname forState:UIControlStateNormal];
    }
}

-(void)headerLoading{
    if(mData!=nil && mData.count>0){
        RCMessage *model=[mData objectAtIndex:0];
        WSLog(@"%ld",model.messageId);
        NSArray *arr=nil;
        
        @try {
            arr=[[RCIMClient sharedRCIMClient] getHistoryMessages:ConversationType_PRIVATE targetId:self.userid oldestMessageId:model.messageId count:ListCount];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        if(arr==nil || arr.count==0){
            return;
        }
        
        //由于tableview旋转了180，所以不用倒叙
        //倒叙插入
        //从最后一个开始插入
        for (RCMessage *item in arr) {
            if(![SysTools checkItemIsBlock:item] && item!=nil){
                [mData insertObject:item atIndex:0];
            }
        }
        
        
        [chatTable reloadData];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGRect  popoverRect = [chatTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:arr.count inSection:0]];
            [chatTable setContentOffset:CGPointMake(0,popoverRect.origin.y-20) animated:NO];
//            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:(arr.count-1)  inSection:0];
//            [chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    }else{
        NSArray *arr=nil;
        @try {
            WSLog(@"%@",self.userid);
            arr=[[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_PRIVATE targetId:self.userid count:10];
        }
        @catch (NSException *exception) {
            WSLog(@"Exception:%@",exception);
        }
        
        if(arr==nil || arr.count==0){
            return;
        }
        
        //倒叙插入
        for (RCMessage *item in arr) {
            if(![SysTools checkItemIsBlock:item] && item!=nil){
                [mData insertObject:item atIndex:0];
//                [mData addObject:item];
            }
        }

        [chatTable reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollTableToFoot:NO];
        });
        
        //设置当前的未读数
        [self setRootMenuBadge];
    }    
}
// 滚动到底部
- (void)scrollTableToFoot:(BOOL)animated {
    NSInteger s = [chatTable numberOfSections];
    if (s<1) return;
    NSInteger r = [chatTable numberOfRowsInSection:s-1];
    if (r<1) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        float x=chatTable.contentSize.height -chatTable.bounds.size.height;
        if(x>0){
            [chatTable setContentOffset:CGPointMake(0, x) animated:animated];
        }
        else{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGFloat fh=h-self.footView.frame.origin.y;
                
                CGFloat ch=chatTable.contentSize.height;
                
                CGFloat th=chatTable.frame.size.height;
                
                CGFloat tx=fh+ch-th;
                CGRect tf=chatTable.frame;
                if(tx>0 && fh>50 ){
                    tf.origin.y=tableY-tx+20;
                    chatTable.frame=tf;
                }
            } completion:^(BOOL finished) {
                
            }];
            
        }
    });
    
    
    //由于翻转180°，所以滚动到底部变为顶部
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
//        [chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}



#pragma mark table数据展示相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCLetterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RCLetterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate=self;
    
    RCMessage *model=[mData objectAtIndex:indexPath.row];
    NSString *time=@"";
    if(indexPath.row>0){
        RCMessage *lm=[mData objectAtIndex:(indexPath.row-1)];
        int minus=(model.sentTime-lm.sentTime)/1000/60.0;
        if(minus>5){
            time=intervalSinceNow(longdateTransformString(@"yyyy-MM-dd HH:mm:ss", model.sentTime));
        }
    }else{
        time=intervalSinceNow(longdateTransformString(@"yyyy-MM-dd HH:mm:ss", model.sentTime));
    }
    cell.targetId=self.userid;
    [cell setLastTime:self.lastTime];
    
    [cell initViewData:model time:time width:self.view.frame.size.width];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RCMessage *model=[mData objectAtIndex:indexPath.row];
    NSString *time=@"";
    if(indexPath.row>0){
        RCMessage *lm=[mData objectAtIndex:(indexPath.row-1)];
        int minus=(model.sentTime-lm.sentTime)/1000/60.0;
        if(minus>5){
            time=intervalSinceNow(longdateTransformString(@"yyyy-MM-dd HH:mm:ss", model.sentTime));
        }
    }else{
        time=intervalSinceNow(longdateTransformString(@"yyyy-MM-dd HH:mm:ss", model.sentTime));
    }
    CGFloat cellheight = [self heightForRowCell:model time:time];
    return cellheight;
}


-(CGFloat)heightForRowCell:(RCMessage *)model time:(NSString *)time{
    CGFloat rowHeight=0;
    
    if(time!=nil && ! [@"" isEqual:time]){
        rowHeight=30;
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
    
    
    if(isCounter){
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
            CGFloat height=[SysTools getHeightContain:item.content font:FONT_CHAT Width:w-50];
            rowHeight=rowHeight+height+35;
        }else{
            CGFloat xheight=[SysTools getHeightContain:item.content font:FONT_CHAT Width:w-50];
            
            if(xheight<40){
                xheight=40;
            }else{
                xheight=xheight+10;
            }
            rowHeight=rowHeight+xheight+20;
        }
    }else{
        rowHeight=rowHeight+10;
        if([model.objectName isEqual:RCRichContentMessageTypeIdentifier]){
            rowHeight=rowHeight+130;
            
            RCRichContentMessage *richmessage=(RCRichContentMessage *)model.content;
            NSDictionary *dict = [[richmessage.extra JSONString] objectFromJSONString];
            if([richmessage.extra isKindOfClass:[NSString class]]){
                dict=[richmessage.extra objectFromJSONString];
            }
            NSString *sendMsg=[dict objectForKey:@"sendmsg"];
            if(sendMsg!=nil){
                CGFloat xy=[SysTools getHeightContain:sendMsg font:ListDetailFont Width:w-90-24];
                rowHeight=rowHeight+xy+20;
            }
        }else if([model.objectName isEqual:RCVoiceMessageTypeIdentifier]){
            rowHeight=rowHeight+20;
        }else if ([model.objectName isEqual:RCTextMessageTypeIdentifier]){
            RCTextMessage *rcmsg=(RCTextMessage *)model.content;
            UIView *msgView=[SysTools assembleMessageWithMessage:rcmsg.content maxWidth:w-100 color:[UIColor whiteColor]];
            CGSize contentSize=msgView.bounds.size;
            if(contentSize.height<10){
                contentSize.height=10;
            }
            
            CGFloat xh=contentSize.height+20;
            rowHeight=rowHeight+xh;
        }else if([RCImageMessageTypeIdentifier isEqual:model.objectName]){
            rowHeight=rowHeight+140;
        }
    }
    
    rowHeight=rowHeight+10;
    return rowHeight;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    WSLog(@"没走 scrollView");
    [self hideAll];
}


#pragma mark 添加视图
-(void)createViewWithInit{
    self.textView.layer.cornerRadius=15;
    self.textView.layer.masksToBounds=YES;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    self.textView.layer.borderWidth=1;
    [self.textView setFont:ListTitleFont];
    self.textView.layer.borderColor=UIColorFromRGB(ListLineColor).CGColor;
    self.textView.returnKeyType=UIReturnKeySend;
    _textView.autoresizesSubviews = YES;
    _textView.autoresizingMask =(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name: UITextViewTextDidChangeNotification object:nil];
    
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:[UIColor clearColor]];
    [self.sendButton.titleLabel setFont:ListDetailFont];
    [self.sendButton setImage:[UIImage imageNamed:@"letter_addvoice_nor"] forState:UIControlStateNormal];
    
    self.footView.backgroundColor=[UIColor whiteColor];
    
    
    [self.textView setEditable:YES];
    [self.faceButton addTarget:self action:@selector(changeFaceBoard:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(changeFaceBoard:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addButton addTarget:self action:@selector(changeFaceBoard:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //添加照相机、相册视图
    photoView=[[UIView alloc] initWithFrame:CGRectMake(0, h, w, PhotoViewHeight)];
    [photoView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:photoView];
    UIButton *btnPhoto1=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhoto1 setFrame:CGRectMake(20, 20, 55, 85)];
    [btnPhoto1 setImage:[UIImage imageNamed:@"letter_camera_nor"] forState:UIControlStateNormal];
    [btnPhoto1 setImage:[UIImage imageNamed:@"letter_camera_sel"] forState:UIControlStateHighlighted];
    [btnPhoto1 setImage:[UIImage imageNamed:@"letter_camera_sel"] forState:UIControlStateSelected];
    [btnPhoto1 setTitle:TTLocalString(@"TT_shooting") forState:UIControlStateNormal];
    [btnPhoto1 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 0)];
    [btnPhoto1.titleLabel setBackgroundColor:[UIColor clearColor]];
    [btnPhoto1.titleLabel setFont:ListDetailFont];
    [btnPhoto1 setTitleColor:UIColorFromRGB(TextRegusterGrayColor) forState:UIControlStateNormal];
    int titleMargin=(55-btnPhoto1.titleLabel.frame.size.width)/2;
    [btnPhoto1 setTitleEdgeInsets:UIEdgeInsetsMake(50, -2*(btnPhoto1.titleLabel.frame.origin.x-titleMargin), 0,0)];
    btnPhoto1.tag=1;
    [btnPhoto1 addTarget:self action:@selector(addMediaMessage:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:btnPhoto1];
    
    UIButton *btnPhoto2=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhoto2 setFrame:CGRectMake(100, 20, 55, 85)];
    [btnPhoto2 setImage:[UIImage imageNamed:@"letter_addphoto_nor"] forState:UIControlStateNormal];
    [btnPhoto2 setImage:[UIImage imageNamed:@"letter_addphoto_sel"] forState:UIControlStateHighlighted];
    [btnPhoto2 setImage:[UIImage imageNamed:@"letter_addphoto_sel"] forState:UIControlStateSelected];
    [btnPhoto2 setTitle:TTLocalString(@"TT_photo_album") forState:UIControlStateNormal];
    [btnPhoto2 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 0)];
    [btnPhoto2 setTitleEdgeInsets:UIEdgeInsetsMake(50, -2*(btnPhoto2.titleLabel.frame.origin.x-titleMargin), 0,0)];
    [btnPhoto2.titleLabel setFont:ListDetailFont];
    [btnPhoto2 setTitleColor:UIColorFromRGB(TextRegusterGrayColor) forState:UIControlStateNormal];
    [btnPhoto2.titleLabel setBackgroundColor:[UIColor clearColor]];
    btnPhoto2.tag=2;
    [btnPhoto2 addTarget:self action:@selector(addMediaMessage:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:btnPhoto2];
    
    
    
    //添加录音视图
    voiceView=[[UIView alloc] initWithFrame:CGRectMake(0, h, w, VoiceViewHeight)];
    [voiceView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:voiceView];
    
    voiceLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 10,w, 25)];
    [voiceLabel setText:TTLocalString(@"TT_hold_down_to_talk_release_can_be_sent")];
    [voiceLabel setFont:ListDetailFont];
    [voiceLabel setTextColor:UIColorFromRGB(TextRegusterGrayColor)];
    [voiceLabel setTextAlignment:NSTextAlignmentCenter];
    [voiceLabel setBackgroundColor:[UIColor clearColor]];
    [voiceView addSubview:voiceLabel];
    
    UIButton *btnVoice=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnVoice setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
    [btnVoice setFrame:CGRectMake((w-195)/2, 25+(VoiceViewHeight-100)/2, 195, 100)];
    [btnVoice setUserInteractionEnabled:NO];
    [btnVoice setBackgroundColor:[UIColor clearColor]];
    btnVoice.tag=3;
    [voiceView addSubview:btnVoice];
    
    voiceTimeLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 35, w, 20)];
    [voiceTimeLabel setText:@""];
    [voiceTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [voiceTimeLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [voiceTimeLabel setBackgroundColor:[UIColor clearColor]];
    [voiceView addSubview:voiceTimeLabel];
    
    
    // 延迟生成FaceBoard，否则页面进入变慢
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( !faceBoard) {
            faceBoard = [[FaceBoard alloc] init:self.view.mj_width h:self.view.mj_height];
            faceBoard.delegate = self;
            [self.view addSubview:faceBoard];
            self.textView.delegate=self;
        }
    });
}

#pragma mark textChanged
-(void)textChanged:(id) sender{
    [self textViewDidChange:self.textView];
}

-(void)textViewDidChange:(UITextView *)textView{
    CGFloat textContentSizeHeight=self.textView.contentSize.height;
    if (iOS7) {
        CGRect textFrame=[[self.textView layoutManager]usedRectForTextContainer:[self.textView textContainer]];
        textContentSizeHeight = textFrame.size.height;
    }
    
    
    textContentSizeHeight=textContentSizeHeight+10;
    
    
    //发送完成重置
    if(self.textView.text==nil || [@"" isEqual:self.textView.text]){
        textContentSizeHeight=33;
    }
    
    if(textContentSizeHeight<33){
        textContentSizeHeight=33;
    }
    
    if (textContentSizeHeight > 93) {
        [self.textView setContentOffset:CGPointMake(0, textContentSizeHeight-_textView.frame.size.height)];
        return;
    }
    
    
    CGFloat keyHeight=KeyBoardHeight;
    if(isShowFace || isShowPhoto || isShowVoice){
        keyHeight=PhotoViewHeight;
    }
    
    CGRect footFrame=self.footView.frame;
    CGRect textFrame=self.textView.frame;
    
    footFrame.origin.y=h-keyHeight-50;
    footFrame.size.height=50;
    CGFloat lastHeight=textFrame.size.height;
    textFrame.size.height=32;
    
    if(textContentSizeHeight>33){
        float x=textContentSizeHeight-33;
        footFrame.origin.y=footFrame.origin.y-x;
        footFrame.size.height=footFrame.size.height+x;
        textFrame.size.height=textFrame.size.height+x;
    }
    
    if(lastHeight==textFrame.size.height){
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
           
        self.footView.frame=footFrame;
        self.textView.frame=textFrame;
        
            
//        [self.textView setContentOffset:CGPointMake(0,textContentSizeHeight-textFrame.size.height)];
        
        CGRect tableFrame=chatTable.frame;
        tableFrame.origin.y=tableY-[self getCurTableOriginY:keyHeight]-(self.textView.frame.size.height-32);
            chatTable.frame=tableFrame;
        
        
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
    }];
}

#pragma mark keyboard notification
- (void)handleKeyboard {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    self.view.userInteractionEnabled=YES;
    [self.view addGestureRecognizer:tapRecognizer];
}
//键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    if(!isFront){
        if(!isShowKeyBoard){
            [self hideAll];
        }
        return;
    }
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    // get a rect for the view frame
    [self showKeyBoard:keyboardHeight];
    // commit animations
    [UIView commitAnimations];
    
//    [self.view addGestureRecognizer:tapRecognizer];
}

//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    WSLog(@"没走 didTapAnywhere");
    [self hideAll];
}


//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    
    [UIView commitAnimations];
    
    //    [self.view removeGestureRecognizer:tapRecognizer];
}

//判断删除键
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    WSLog(@"%@",NSStringFromRange(range));
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage:nil type:RCTextMessageTypeIdentifier];
        return NO;
    }
    
    if( [text length] == 0 ) {
        
        if ( range.length < 1 ) {
            return YES;
        }
        else {
            BOOL isDel = [self delFaceItem:range];
            
            [self textChanged:self.textView];
            
            return isDel;
        }
    }
    
    //点击了非删除键
    return YES;
}
#pragma 键盘事件结束end



#pragma mark 发消息
//发送消息
-(void)sendMessage:(UIButton *)sender type:(NSString *) type{
    if(sender!=nil){
        sender.userInteractionEnabled=NO;
    }
    if([self.userid isEqual:[[LoginManager getInstance] getUid]]){
        [self showNoticeWithMessage:TTLocalString(@"TT_you_chat_with_your_own") message:nil bgColor:TopNotice_Block_Color];
        return;
    }
    
    if(self.sessionModel!=nil && self.sessionModel.cansendmessage==0){
        if(sender!=nil)
        {
            sender.userInteractionEnabled=YES;
        }
        if(self.sessionModel.errormsg!=nil && ![@"" isEqual:self.sessionModel.errormsg]){
            [SVProgressHUD showErrorWithStatus:self.sessionModel.errormsg];
        }
        return;
    }
    
    NSMutableDictionary *extraDict=[[NSMutableDictionary alloc] init];
    if(self.sessionModel!=nil && (self.sessionModel.isblock||self.sessionModel.isblockme)){
        [extraDict setObject:@"1" forKey:@"isblock"];
    }
    
    [extraDict setObject:self.sessionModel.nickname forKey:@"nickname"];
    [extraDict setObject:loginUser.nickname forKey:@"sendername"];
    // 我发送了，对方是否可以看见
    // 我是否可以发送
    [extraDict setObject:[NSString stringWithFormat:@"1"] forKey:@"canchat"];
    
    RCMessageContent *content=nil;
    if([RCTextMessageTypeIdentifier isEqual:type]){
        NSString *message=self.textView.text;
        if(message==nil || [@"" isEqual:message]){
            if(sender!=nil)
            {
                sender.userInteractionEnabled=YES;
            }
            return;
        }
        
        [self.textView setText:@""];
        [self textChanged:self.textView];
        
        RCTextMessage *rcmessage = [RCTextMessage messageWithContent:message];
        rcmessage.extra = [extraDict JSONString];
        content=rcmessage;
    }
    
    
    if([RCImageMessageTypeIdentifier isEqual:type] && tempImage!=nil){
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(tempImage, 0.5f)];//1.0f = 100%quality

        RCImageMessage *imageModel=[RCImageMessage messageWithImage:[UIImage imageWithData:data]];
        imageModel.extra=[extraDict JSONString];
        content=imageModel;
    }
    
    if([RCVoiceMessageTypeIdentifier isEqual:type] && tmpFile!=nil){
        NSData *data=[NSData dataWithContentsOfURL:tmpFile];
        NSError *error;
        audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:tmpFile
                                                          error:&error];
        int duration=audioPlayer.duration;
        if(duration<1){
            if(sender!=nil)
            {
                sender.userInteractionEnabled=YES;
            }
            return;
        }
//        data=[[AmrDataConverter shareAmrDataConverter] EncodeWAVEToAMR:data channel:1 nBitsPerSample:16];
        RCVoiceMessage *rcvoice=[RCVoiceMessage messageWithAudio:data duration:duration];
        rcvoice.extra=[extraDict JSONString];
        content=rcvoice;
    }
    
    RCMessage *sendMessage = [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.userid content:content delegate:self object:self.userid];
    
    if(sendMessage!=nil){
        [mData addObject:sendMessage];
        
        [sendDict setObject:sendMessage forKey:[NSString stringWithFormat:@"%ld",sendMessage.messageId]];
    }
    
    // 当发送文本消息时，直接在发送结果中处理，否则会多次刷新table
    [chatTable reloadData];
    [self scrollTableToFoot:YES];
//    if([RCTextMessageTypeIdentifier isEqual:type] && !isShowFace){
//        [self showKeyBoard:KeyBoardHeight];
//    }
    
    if(sender!=nil)
    {
        sender.userInteractionEnabled=YES;
    }
}


//切换键盘
-(void)changeFaceBoard:(UIButton *)sender{
    //出来显示表情时，自动切换到发送按钮，其它情况sendButton显示声音按钮
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:[UIColor clearColor]];
    [self.sendButton setImage:[UIImage imageNamed:@"letter_addvoice_nor"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"letter_face_nor"] forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"letter_add_nor"] forState:UIControlStateNormal];
    
    if(sender.tag==102){
        //显示表情
        if(!isShowFace){
            isShowFace=YES;
            
            isShowPhoto=NO;
            isShowVoice=NO;
            
            [self.faceButton setImage:[UIImage imageNamed:@"letter_board_nor"] forState:UIControlStateNormal];
            [self showBoardWithType:1];
            
            
            //切换到发送按钮
            self.sendButton.layer.cornerRadius=15;
            self.sendButton.layer.masksToBounds=YES;
            [self.sendButton setBackgroundColor:UIColorFromRGB(SystemColor)];
            [self.sendButton setTitle:TTLocalString(@"TT_send") forState:UIControlStateNormal];
            [self.sendButton setImage:nil forState:UIControlStateNormal];
        }else{
            //显示键盘
            isShowFace=NO;
            
            [_textView becomeFirstResponder];
            [self.faceButton setImage:[UIImage imageNamed:@"letter_face_nor"] forState:UIControlStateNormal];
        }
    }
    
    //照片相关
    if(sender.tag==101){
        if(!isShowPhoto){
            isShowPhoto=YES;
            isShowVoice=NO;
            isShowFace=NO;
            
            [self showBoardWithType:2];
            [self.addButton setImage:[UIImage imageNamed:@"letter_board_nor"] forState:UIControlStateNormal];
            
        }else{
            //显示键盘
            isShowPhoto=NO;
            
            [_textView becomeFirstResponder];
            [self.addButton setImage:[UIImage imageNamed:@"letter_add_nor"] forState:UIControlStateNormal];
        }
    }
    
    //声音、发送相关
    if(sender.tag==103){
        //如果当前是表情，发送
        if(isShowFace){
            isShowVoice=NO;
            
            NSString *message=self.textView.text;
            if(message!=nil && ![@"" isEqual:message]){
                [self sendMessage:sender type:RCTextMessageTypeIdentifier];
            }
            
            [self.faceButton setImage:[UIImage imageNamed:@"letter_board_nor"] forState:UIControlStateNormal];
            
            
            self.sendButton.layer.cornerRadius=15;
            self.sendButton.layer.masksToBounds=YES;
            [self.sendButton setBackgroundColor:UIColorFromRGB(SystemColor)];
            [self.sendButton setTitle:TTLocalString(@"TT_send") forState:UIControlStateNormal];
            [self.sendButton setImage:nil forState:UIControlStateNormal];
        }else{
            if(!isShowVoice){
                isShowVoice=YES;
                
                isShowFace=NO;
                isShowPhoto=NO;
                
                [self showBoardWithType:3];
                [self.sendButton setImage:[UIImage imageNamed:@"letter_board_nor"] forState:UIControlStateNormal];
                UIButton *vbtn=(UIButton *)[voiceView viewWithTag:3];
                [vbtn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
            }else{
                isShowVoice=NO;
                
                [_textView becomeFirstResponder];
                [self.sendButton setImage:[UIImage imageNamed:@"letter_addvoice_nor"] forState:UIControlStateNormal];
            }
        }
    }
}

// 服务切换键盘事件，用于显示各种表情
// type 1表情、2照片、3声音
-(void)showBoardWithType:(int) type{
    isShowKeyBoard=YES;
    //显示表情，隐藏键盘
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //隐藏键盘
                         [_textView resignFirstResponder];
                         
                         CGRect ff = faceBoard.frame;
                         CGRect pf = photoView.frame;
                         CGRect vf = voiceView.frame;
                         
                         CGRect cf = self.footView.frame;
                         CGRect tf = chatTable.frame;
                         int bh=0;
                         //显示表情
                         if(type==1){
                             bh=FaceViewHeight;
                             
                             ff.origin.x=0;
                             ff.origin.y=h-bh;
                             faceBoard.frame=ff;
                             
                             pf.origin.y=h;
                             photoView.frame=pf;
                             
                             vf.origin.y=h;
                             voiceView.frame=vf;
                             
                         }else if(type==2){
                             //显示相册、相机
                             bh=PhotoViewHeight;
                            
                             ff.origin.y=h;
                             faceBoard.frame=ff;
                             
                             pf.origin.y=h-bh;
                             photoView.frame=pf;
                             
                             vf.origin.y=h;
                             voiceView.frame=vf;
                         }else if(type==3){
                             //显示声音键盘
                             bh=VoiceViewHeight;
                             
                             
                             ff.origin.y=h;
                             faceBoard.frame=ff;
                             
                             pf.origin.y=h;
                             photoView.frame=pf;
                             
                             vf.origin.y=h-bh;
                             voiceView.frame=vf;
                         }
                         
                         
                         
//                         tf.size.height=tableHeight-bh;
                         tf.origin.y=tableY-[self getCurTableOriginY:bh]-(cf.size.height-50);
                         
                         chatTable.frame=tf;
                         
                         cf.origin.y=h-bh-cf.size.height;
                         self.footView.frame=cf;
                         
                         
                         [self scrollTableToFoot:YES];
                     }
                     completion:^(BOOL finished) {
                         //让dataScrollView滚动到底部
                     }
     ];
}

//显示键盘，隐藏所有表情
-(void)showKeyBoard:(CGFloat) boardHeight{
    KeyBoardHeight=boardHeight;
    
    isShowKeyBoard=YES;
    isShowVoice=NO;
    isShowPhoto=NO;
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:[UIColor clearColor]];
    [self.sendButton setImage:[UIImage imageNamed:@"letter_addvoice_nor"] forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"letter_add_nor"] forState:UIControlStateNormal];
    
    isShowFace=NO;
    [self.faceButton setImage:[UIImage imageNamed:@"letter_face_nor"] forState:UIControlStateNormal];
    
    
    //隐藏表情
    CGRect ff = faceBoard.frame;
    ff.origin.y=h;
    faceBoard.frame=ff;
    
    CGRect pf = photoView.frame;
    pf.origin.y=h;
    photoView.frame=pf;
    
    CGRect vf = voiceView.frame;
    vf.origin.y = h;
    voiceView.frame=vf;
    
    
    //设置底部功能
    CGRect toolbarFrame = self.footView.frame;
    toolbarFrame.origin.y = h - boardHeight - toolbarFrame.size.height;
    self.footView.frame = toolbarFrame;
    
    
    //设置table
    CGRect f=chatTable.frame;
    //    f.size.height=tableHeight-boardHeight;
    f.origin.y=tableY-[self getCurTableOriginY:boardHeight]-(toolbarFrame.size.height-50);
    chatTable.frame=f;
//    [self scrollTableToFoot:YES];
}

// 触摸屏幕，隐藏全部表情、键盘、下拉框
-(void)hideAll{
    
    [UIView animateWithDuration:0.3 animations:^{
        WSLog(@"隐藏全部");
        [self.textView resignFirstResponder];
        CGRect tf = chatTable.frame;
        tf.origin.y=tableY;
        chatTable.frame=tf;
        
        
        CGRect cf = self.footView.frame;
        cf.origin.y=h-cf.size.height;
        self.footView.frame=cf;
        
        
        CGRect f = faceBoard.frame;
        f.origin.y=h;
        faceBoard.frame=f;
        
        
        CGRect vf = voiceView.frame;
        vf.origin.y=h;
        voiceView.frame=vf;
        
        
        CGRect pf = photoView.frame;
        pf.origin.y=h;
        photoView.frame=pf;
        
        isShowKeyBoard=NO;
    }];
    
}

#pragma mark 表情点击
//点击表情
-(void)onItemClick:(NSString *)faceTag faceName:(NSString *)name index:(int)itemId{
    WSLog(@"点击的东西：%d %@ %@",itemId,faceTag,name);
    self.textView.text=[NSString stringWithFormat:@"%@%@",self.textView.text,name];
    [self textChanged:self.textView];
}


//点击删除表情
-(void)delItem{
    [self delFaceItem];
    
    [self textChanged:self.textView];
}


//表情键盘实现删除一个表情
-(void)delFaceItem{
    NSString *message=_textView.text;
    
    NSInteger lenght=message.length;
    if(lenght==0){
        return;
    }
    
    NSInteger end=-1;
    NSString *lastStr= [message substringWithRange:NSMakeRange(lenght-1, 1)];
    if([lastStr isEqualToString:@"]"]){
        NSRange range=[message rangeOfString:@"[" options:NSBackwardsSearch];
        end=range.location;
    }else{
        end=lenght-1;
    }
    
    message=[message substringToIndex:end];
    _textView.text=message;
}

//随机删除表情
-(BOOL)delFaceItem:(NSRange )range{
    WSLog(@"%@",NSStringFromRange(range));
    NSString *message=_textView.text;
    
    NSInteger lenght=message.length;
    if(lenght==0){
        return YES;
    }
    NSInteger xs=range.location+1;
    
    NSInteger start=0;
    NSInteger end=0;
    NSString *lastStr= [message substringWithRange:range];
    if([lastStr isEqual:@"]"]){
        end=range.location+1;
        
        NSString *backStr=[message substringToIndex:xs];
        NSRange startRange=[backStr rangeOfString:@"[" options:NSBackwardsSearch];
        start=startRange.location;
    }else{
        NSString *backStr=[message substringToIndex:xs];
        NSRange backRange=[backStr rangeOfString:@"[" options:NSBackwardsSearch];
        start=backRange.location;
        end=0;
        if(backRange.length>0){
            NSString *eStr=[message substringFromIndex:xs];
            NSRange endRange=[eStr rangeOfString:@"]"];
            end=endRange.location+xs+1;
        }else{
            start=0;
            end=0;
        }
    }
        
    NSInteger faceLength=end-start;
    if(faceLength>0 && faceLength<=4){
//        NSString *subStr=[message substringWithRange:NSMakeRange(start, faceLength)];
        message=[message stringByReplacingCharactersInRange:NSMakeRange(start, faceLength) withString:@""];
        _textView.text=message;
        return NO;
    }
    return YES;
}



#pragma mark 公用点击事件
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag == BACK_BUTTON){
        if (_comefrom == 1) {
            //进入首页
            UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }else{
            // 清理未读标记
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:self.userid];
            
            [[NoticeTools getInstance] postClearMessageRead];
            
            if(sendDict.count>0){
                [[SendLocalTools getInstance] setFavContacts:self.userid];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NoticeTools getInstance] postSendNewMessage];
                    [sendDict removeAllObjects];
                });
            }
            [self goBack:nil];
        }
        
    }
    if(sender.tag==RIGHT_BUTTON){
        [self hideAll];
        
        NSString *text1= TTLocalString(@"TT_block_his(her)_message");
        if(self.sessionModel && self.sessionModel.isblock){
            text1= TTLocalString(@"TT_unblock_message");
        }
        
        NSString *text2 = TTLocalString(@"TT_block_his(her)_content");
        if(self.sessionModel && self.sessionModel.topicblock){
            text2=TTLocalString(@"TT_unblock_content");
        }
        
//        NSString *text3 = @"添加好友";
//        if(self.sessionModel && (self.sessionModel.relation==2||self.sessionModel.relation==3)){
//            text3=@"删除好友";
//        }
        NSArray *array = [[NSArray alloc] initWithObjects:TTLocalString(@"TT_clean_message"),text1,text2,TTLocalString(@"TT_report_this_person"),TTLocalString(@"TT_cancel"),nil];
        ListMenuView *menuView=[[ListMenuView alloc] initWithDelegate:self items:array];
        menuView.tag=0;
        [menuView showInView:self.view];
    }
}

-(void)didClickOnIndex:(NSInteger)index type:(int)tag{
    
    if(tag==1){
        if(index==0){
            // 重新设置 扩展字段，否则会可能永远发送不出去
            NSMutableDictionary *extraDict=[[NSMutableDictionary alloc] init];
            if(self.sessionModel!=nil && (self.sessionModel.isblock||self.sessionModel.isblockme)){
                [extraDict setObject:@"1" forKey:@"isblock"];
            }
            // 我发送了，对方是否可以看见
            // 我是否可以发送
            [extraDict setObject:[NSString stringWithFormat:@"%d",self.sessionModel.canchat] forKey:@"canchat"];
            
            RCMessageContent *sendContent=reSendItem.content;
            if([reSendItem.objectName isEqual:RCTextMessageTypeIdentifier]){
                RCTextMessage *textContent=(RCTextMessage *)reSendItem.content;
                textContent.extra=[extraDict JSONString];
                sendContent=textContent;
            }
            if([reSendItem.objectName isEqual:RCVoiceMessageTypeIdentifier]){
                RCVoiceMessage *voiceContent=(RCVoiceMessage *)reSendItem.content;
                voiceContent.extra=[extraDict JSONString];
                sendContent=voiceContent;
            }
            if([reSendItem.objectName isEqual:RCImageMessageTypeIdentifier]){
                RCImageMessage *imageContent=(RCImageMessage *)reSendItem.content;
                imageContent.extra=[extraDict JSONString];
                sendContent=imageContent;
            }
            if([reSendItem.objectName isEqual:RCRichContentMessageTypeIdentifier]){
                RCRichContentMessage *richContent=(RCRichContentMessage *)reSendItem.content;
                richContent.extra=[extraDict JSONString];
                sendContent=richContent;
            }
            
            RCMessage *sendMessage = [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.userid content:sendContent delegate:self object:self.userid];
            
            
            if(mData!=nil){
                [mData removeObject:reSendItem];
                reSendItem=nil;
            }
            [mData addObject:sendMessage];
            //    [mData insertObject:sendMessage atIndex:0];
            
            [chatTable reloadData];
            [self scrollTableToFoot:YES];
        }
    }else{
        if(index==4){
            return;
        }
        
        if([self checkBeKill]){
            return;
        }
        
        if(index==0){
            //清除私信
            [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:self.userid];
            [mData removeAllObjects];
            
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:self.userid];
            [chatTable reloadData];
        }
        else if(index==1){
            // 屏蔽私信
            NSString *url=API_BLOCK(self.userid);
            if(self.sessionModel.isblock==1){
                url=API_UNBLOCK(self.userid);
            }
            [[RequestTools getInstance] get:url isCache:NO completion:^(NSDictionary *dict) {
                if(dict!=nil && [[dict objectForKey:@"code"] intValue]==10000){
                    UserInfoDB *db=[[UserInfoDB alloc] init];
                    UserInfo *info=[db findWidthUID:self.userid];
                    if(info!=nil && info.uid!=nil && ![@"" isEqual:info.uid]){
                        info.isBlock=!self.sessionModel.isblock;
                        info.nickname=info.realname;
                        [db saveUser:info];
                    }
                    if(self.sessionModel.isblock==1){
                        self.sessionModel.isblock=0;
//                        [[RCIMClient sharedRCIMClient] removeFromBlacklist:self.sessionModel.uid completion:^{
//                            
//                        } error:^(RCErrorCode status) {
//                            
//                        }];
                    }else{
                        self.sessionModel.isblock=1;
//                        [[RCIMClient sharedRCIMClient] addToBlacklist:self.sessionModel.uid completion:^{
//                            
//                        } error:^(RCErrorCode status) {
//                            
//                        }];
                    }
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
        }
        else if(index==2){
            // 屏蔽内容
            if(self.sessionModel!=nil){
                if(isRequstContent){
                    return;
                }
                isRequstContent=YES;
                if(self.sessionModel.topicblock){
                    [[RequestTools getInstance]get:API_UNBLOCK_USER_FEED(self.sessionModel.uid) isCache:NO completion:^(NSDictionary *dict) {
                        self.sessionModel.topicblock=0;
                        UserInfoDB *db=[[UserInfoDB alloc] init];
                        UserInfo *info=[db findWidthUID:self.userid];
                        if(info!=nil && info.uid!=nil && ![@"" isEqual:info.uid]){
                            info.topicblock=0;
                            info.nickname=info.realname;
                            [db saveUser:info];
                        }
                        info.uid = self.sessionModel.uid;
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_TOPIC object:info];
                    } failure:^(ASIHTTPRequest *request, NSString *message) {
                    } finished:^(ASIHTTPRequest *request) {
                        isRequstContent=NO;
                    }];
                }else{
                    [[RequestTools getInstance]get:API_BLOCK_USER_FEED(self.sessionModel.uid) isCache:NO completion:^(NSDictionary *dict) {
                        self.sessionModel.topicblock=1;
                        UserInfoDB *db=[[UserInfoDB alloc] init];
                        UserInfo *info=[db findWidthUID:self.userid];
                        if(info!=nil && info.uid!=nil && ![@"" isEqual:info.uid]){
                            info.topicblock=1;
                            info.nickname=info.realname;
                            [db saveUser:info];
                        }
                        
                        info.uid = self.sessionModel.uid;
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_TOPIC object:info];
                    } failure:^(ASIHTTPRequest *request, NSString *message) {
                        
                    } finished:^(ASIHTTPRequest *request) {
                        isRequstContent=NO;
                    }];
                }
            }
        }else if(index==3){
            //举报此人
            ToReportController *report=[[ToReportController alloc] init];
            report.uid=self.userid;
            [self.navigationController pushViewController:report animated:YES];
        }
    }
}


#pragma mark Cell代理事件处理
-(void)IconOnClick:(RCMessage *)item view:(UIImageView *)avatarView{
//    NSMutableArray *photos = [[NSMutableArray alloc] init];
//    [photos addObject:avatarView];
//    
//    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
//    imageViewer.delegate = self;
//    [imageViewer setIsShowMenu:YES];
//    [imageViewer setMenuType:2];
//    [imageViewer setParam:item.senderUserId];
//    
//    [imageViewer showWithImageViews:photos selectedView:avatarView];
//    return;
    
    UserDetailController *controller=[[UserDetailController alloc] init];
    controller.uid=item.senderUserId;
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView{
    
}

-(void)voiceClick:(RCMessage *)item view:(UIImageView *)imageView{
    if(lastImageView){
        [lastImageView stopAnimating];
    }
    if([lastImageView isEqual:imageView]){
        if(audioPlayer!=nil && audioPlayer.isPlaying){
            [audioPlayer stop];
            return;
        }
    }
    
    lastImageView=imageView;
    
    [lastImageView startAnimating];
    RCVoiceMessage *message=(RCVoiceMessage *)item.content;
    
    NSData *data=message.wavAudioData;
//    data=[[AmrDataConverter shareAmrDataConverter] DecodeAMRToWAVE:message.wavAudioData];
    [self bofang:nil data:data];
}

-(void)delCellItem:(RCMessage *)item{
    NSArray *arr=[NSArray arrayWithObject:[NSNumber numberWithLong:item.messageId]];
    [[RCIMClient sharedRCIMClient] deleteMessages:arr];

    [mData removeObject:item];
    
    [chatTable reloadData];
}

-(void)copyText:(NSString *)text{
    if ([text isKindOfClass:[NSString class]]) {
        [[UIPasteboard generalPasteboard] setString:text];
        [self showNoticeWithMessage:TTLocalString(@"TT_copy_success") message:nil bgColor:TopNotice_Block_Color];
    }
}


-(void)activeOnClick:(RCMessage *)item type:(RCMessageClickType)clickType{
    if(item==nil || item.content==nil){
        return;
    }
    NSString *url=nil;
    RCRichContentMessage *rcmsg=(RCRichContentMessage *)item.content;
    
    
    NSDictionary *dict = [[rcmsg.extra JSONString] objectFromJSONString];
    if([rcmsg.extra isKindOfClass:[NSString class]]){
        dict=[rcmsg.extra objectFromJSONString];
    }

    if(dict==nil){
        return;
    }
    if(clickType==RCContentClick){
        url=[dict objectForKey:@"contentLink"];
    }else{
        url=[dict objectForKey:@"buttonlink"];
    }
    
    if([url hasPrefix:@"Tutu://uid"]){
        url=[url stringByReplacingOccurrencesOfString:@"Tutu://uid=" withString:@""];
        UserDetailController *detail=[[UserDetailController alloc] init];
        detail.uid=url;
        [self openNav:detail sound:nil];
    }else if([url hasPrefix:@"Tutu://near"]){
        SameCityController *detail = [[SameCityController alloc] init];
        [self openNav:detail sound:nil];
    }
    else if([url hasPrefix:@"Tutu://"]){
        url=[url stringByReplacingOccurrencesOfString:@"Tutu://" withString:@""];
        
        
        
        NSString *topicid=@"";
        NSString *topicstring=@"";
        NSString *type=@"";
        NSString *poiid=@"";
        for (NSString *item in [url componentsSeparatedByString:@"/"]) {
            NSArray *arr1=[item componentsSeparatedByString:@"="];
            if(arr1!=nil && arr1.count>1){
                NSString *key=[arr1 objectAtIndex:0];
                
                NSString *value=[arr1 objectAtIndex:1];
                if([@"topicid" isEqual:key]){
                    topicid=value;
                }
                continue;
            }
            
            
            NSArray *arr2=[item componentsSeparatedByString:@"##"];
            if(arr2!=nil && arr2.count>1){
                NSString *key=[arr2 objectAtIndex:0];
                
                NSString *value=[arr2 objectAtIndex:1];
                
                if([@"topicstring" isEqual:key]){
                    topicstring=value;
                }
                
                if([@"type" isEqual:key]){
                    type=value;
                }
                
                if([@"poiid" isEqual:key]){
                    poiid=value;
                }
            }
        }
        if(![@"" isEqual:topicstring]){
            topicid=@"";
            ListTopicsController *list=[[ListTopicsController alloc] init];
            list.topicString=topicstring;
            list.pageType=[type intValue];
            list.poiid=poiid;
            [self openNav:list sound:nil];
            return;
        }
        
        
        if(![@"" isEqual:topicid] && topicid!=nil){
            TopicDetailController *detail=[[TopicDetailController alloc] init];
            detail.topicid=topicid;
            detail.comefrom = 2;
            [self.navigationController pushViewController:detail animated:YES];
        }
        
    }else{
        SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:url]];
        webView.msg=item;
        webView.title = [dict objectForKey:@"buttonText"];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
        [self.navigationController pushViewController:webView animated:YES];
    }
}

//重新发送
-(void)resendMessage:(RCMessage *)item{
    reSendItem=item;
    WSLog(@"没走 收到消息");
    [self hideAll];
    NSArray *array = [[NSArray alloc] initWithObjects:TTLocalString(@"TT_resend"),TTLocalString(@"TT_cancel"),nil];
    ListMenuView *menuView=[[ListMenuView alloc] initWithDelegate:self items:array];
    menuView.tag=1;
    [menuView showInView:self.view];
}

-(void)refreshRow:(UITableViewCell *) cell{
    NSIndexPath * path = [chatTable indexPathForCell:cell];
    if(path==nil){
        return;
    }
    [chatTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)showBigImageView:(RCMessage *)item{
    WSLog(@"没走 showBig");
    [self hideAll];
}

-(void)goUserInfoApplyFriend{
    UserDetailController *controller=[[UserDetailController alloc] init];
    controller.uid=self.userid;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark 保存图像
-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if(tag==1){
        if(buttonIndex==0){
            ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
            vc.uid = [self getUID];
            vc.rcmsg = reSendItem;
            [self.navigationController pushViewController:vc animated:YES];
            
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            @try {
                UIView *views=[window viewWithTag:10];
                for (UIView *v in views.subviews) {
                    [v removeFromSuperview];
                }
                [views removeFromSuperview];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        if(buttonIndex==1){
            @try {
                RCImageMessage *msg=(RCImageMessage *)reSendItem.content;
                
                if(msg.originalImage!=nil){
                    UIImageWriteToSavedPhotosAlbum(msg.originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }else{
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:msg.imageUrl] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                    }];
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            @try {
                UIView *views=[window viewWithTag:10];
                for (UIView *v in views.subviews) {
                    [v removeFromSuperview];
                }
                [views removeFromSuperview];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil)
    {
        [self showNoticeWithMessage:TTLocalString(@"TT_save_pic_success") message:@"" bgColor:TopNotice_Block_Color];
    }
    else
    {
        [self showNoticeWithMessage:TTLocalString(@"TT_save_pic_fail") message:@"" bgColor:TopNotice_Red_Color];
    }
}

#pragma mark 融云相关

/**
 *  回调成功。
 *
 *  @param userId 当前登录的用户 Id，既换取登录 Token 时，App 服务器传递给融云服务器的用户 Id。
 */
-(void)connectRCSuccess:(NSString *)userId{
    WSLog(@"连接成功了 %@",userId);
    if(self.sessionModel!=nil && self.sessionModel.nickname!=nil){
        [self.menuTitleButton setTitle:self.sessionModel.nickname forState:UIControlStateNormal];
    }else{
        [self.menuTitleButton setTitle:@"" forState:UIControlStateNormal];
    }
    [self.menuTitleButton setImage:nil forState:UIControlStateNormal];
    [self.menuTitleButton setTitleEdgeInsets:UIEdgeInsetsZero];
    
    [self headerLoading];
}
-(void)connectRCError:(NSString *)errorMsg{
    [self.menuTitleButton setTitle:TTLocalString(@"TT_connect_fail") forState:UIControlStateNormal];
    
    UIImage *refreshImage=[UIImage imageNamed:@"connect_refresh"];
    [self.menuTitleButton setImage:refreshImage forState:UIControlStateNormal];
    [self.menuTitleButton setImageEdgeInsets:UIEdgeInsetsMake(15,65,15,-65)];
    
    [self.menuTitleButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.menuTitleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -28, 0, 28)];
    
    [self.menuTitleButton addTarget:self action:@selector(reContent) forControlEvents:UIControlEventTouchUpInside];
}
-(void)reContent{
    [[SysTools getApp] doConnection];
}

/**
 *  发送消息成功。
 *
 *  @param errorCode    状态码。
 *  @param messageId 消息 Id。
 *  @param object    调用对象。
 */
- (void)responseSendMessageStatus:(RCErrorCode)errorCode messageId:(long)messageId object:(id)object{
    
    tempImage=nil;
    tmpFile=nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        RCMessage *item=[sendDict objectForKey:[NSString stringWithFormat:@"%ld",messageId]];
        if(item){
            item.sentStatus=SentStatus_SENT;
//            NSArray *arr=[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:i inSection:0], nil];
//            [chatTable reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
            
            [chatTable reloadData];
            [self scrollTableToFoot:YES];
            if([RCTextMessageTypeIdentifier isEqual:item.objectName] && !isShowFace){
                [self showKeyBoard:KeyBoardHeight];
            }
        }
    });
}


/**
 *  发送消息出错。
 *
 *  @param errorCode 发送消息错误代码。
 *  @param messageId  消息 Id。
 *  @param object     调用对象。
 */
-(void)responseError:(int)errorCode messageId:(long)messageId object:(id)object{
    WSLog(@"失败了，你也给个星儿啊code=%d---%@",errorCode,object);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i=((int)mData.count-1);i>=0;i--) {
            RCMessage *item=[mData objectAtIndex:i];
            if(item.messageId==messageId){
                item.sentStatus=SentStatus_FAILED;
                NSArray *arr=[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:i inSection:0], nil];
                [chatTable reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
            
//                [chatTable reloadData];
//                [self scrollTableToFoot:YES];
//                if([RCTextMessageTypeIdentifier isEqual:item.objectName] && !isShowFace){
//                    [self showKeyBoard:KeyBoardHeight];
//                }
                break;
            }
        }
    });
}

/**
 *  发送消息进度。图片或视频类需要上传的消息会有上传进度。
 *
 *  @param progress 发送消息的进度值，0-100。
 *  @param messageId 消息 Id。
 *  @param object    调用对象。
 */
-(void)responseProgress:(int)progress messageId:(long)messageId object:(id)object{
    WSLog(@"消息发送进度：%d",progress);
    
}


// To do debug  0x001495ec -[RCLetterController reciveRCMessage:num:object:]
-(void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object{
    @try {
        if([@"999" isEqual:object]){
            UserInfoDB *db=[[UserInfoDB alloc] init];
            UserInfo *login=[db findWidthUID:self.userid];
            if(login!=nil && login.uid!=nil && ![@"" isEqual:login.uid]){
    //            UserInfo *login=[[LoginManager getInstance] getLoginInfo];
    //            self.sessionModel.canchat=login.canchat;
                self.sessionModel.canchat=login.canchat;
//                self.sessionModel.canchat=1;
                self.sessionModel.relation=[login.relation intValue];
    //            self.sessionModel.cansendmessage=[login.cansendmessage intValue];
    //            self.sessionModel.errormsg=login.errormsg;
            }
            return;
        }
        
        
        if(!message){
            return;
        }
        
        if(![message.targetId isEqual:self.userid]){
            return;
        }
        
        // 我屏蔽了对方，我不接收对方的消息
        if(self.sessionModel!=nil && self.sessionModel.isblock==1){
            return;
        }
        
        //因为数据翻转了一次，所以倒叙
        [mData addObject:message];
        //        [mData insertObject:message atIndex:0];
        
        [chatTable reloadData];
        [self scrollTableToFoot:YES];
        
        if(isFront){
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:self.userid];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

}

-(void)pushBlockNotice:(NSString *)action uid:(NSString *)userid{
    if(userid!=nil && [self.userid isEqual:CheckNilValue(userid)] && self.sessionModel!=nil){
        if([XG_TYPE_UNBLOCK isEqual:action]){
            self.sessionModel.isblock=0;
        }else{
            self.sessionModel.isblock=1;
        }
    }
}


#pragma mark 图片事件
-(IBAction)addMediaMessage:(UIButton *)sender{
    if(sender.tag==1){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        //        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }else if(sender.tag == 2){
        UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        //        imagePicker.allowsEditing = YES;
        if ([imagePicker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            [imagePicker.navigationBar setBarTintColor:UIColorFromRGB(SystemColor)];
            [imagePicker.navigationBar setTranslucent:YES];
            [imagePicker.navigationBar setTintColor:[UIColor whiteColor]];
            
        }else{
            [imagePicker.navigationBar setBackgroundColor:UIColorFromRGB(SystemColor)];
        }
        [imagePicker.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

#pragma mark  裁剪界面入口
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //UIImagePickerControllerEditedImage
    tempImage = info[UIImagePickerControllerOriginalImage];
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
//    {
//        image = info[UIImagePickerControllerOriginalImage];
//    }
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self sendMessage:nil type:RCImageMessageTypeIdentifier];
    }];
}


// 声音移除事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view removeGestureRecognizer:tapRecognizer];
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    UIButton *vbtn=(UIButton *)[voiceView viewWithTag:3];
    CGPoint p=[touch locationInView:vbtn];
    if(p.x>0 && p.y>0 && p.y<vbtn.frame.size.height && p.x<vbtn.frame.size.width){
        [vbtn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
        UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [animatedImageView setFrame:vbtn.bounds];
        animatedImageView.tag=10;
        animatedImageView.animationImages = [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"letter_greenvoice2.png"],
                                             [UIImage imageNamed:@"letter_greenvoice3.png"],
                                             [UIImage imageNamed:@"letter_greenvoice1.png"], nil];
        animatedImageView.animationDuration = .8f;
        animatedImageView.animationRepeatCount = 0;
        [animatedImageView startAnimating];
        [vbtn addSubview:animatedImageView];
        
        
        [voiceTimeLabel setText:[NSString stringWithFormat:@"0″"]];
        [self luyin];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    UIButton *vbtn=(UIButton *)[voiceView viewWithTag:3];
    
    CGPoint p=[touch locationInView:vbtn];
    
    if(p.y<0 || p.y>vbtn.frame.size.height || p.x<0 || p.x>vbtn.frame.size.width){
        [vbtn setImage:[UIImage imageNamed:@"letter_redvoice1"] forState:UIControlStateNormal];
        UIImageView *iv=(UIImageView *)[vbtn viewWithTag:10];
        iv.hidden=YES;
        
        [recorder pause];
        
        [voiceLabel setText:TTLocalString(@"TT_fingers_slide_cancel_sending")];
        [voiceLabel setTextColor:UIColorFromRGB(NoticeColor)];
    }else{
        UIImageView *iv=(UIImageView *)[vbtn viewWithTag:10];
        iv.hidden=NO;
        [vbtn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
        
        
        [voiceLabel setText:TTLocalString(@"TT_fingers_slide_cancel_sending")];
        [voiceLabel setTextColor:UIColorFromRGB(TextRegusterGrayColor)];
        [recorder record];
    }
}

//移动会进入end
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint p=[touch locationInView:[voiceView viewWithTag:3]];
    WSLog(@"结束事件：%@",NSStringFromCGPoint(p));
    UIButton *btn=(UIButton *)[voiceView viewWithTag:3];
    if(btn!=nil){
        UIImageView *iv=(UIImageView *)[btn viewWithTag:10];
        if(iv!=nil){
            [iv removeFromSuperview];
        }
    }
    
    
    if(recording){
        //停止录音
        [self luyin];
        if(p.y<0 || p.y>btn.frame.size.height || p.x<0 || p.x>btn.frame.size.width){
            [btn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
        }else{
            [btn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
            [self sendMessage:nil type:RCVoiceMessageTypeIdentifier];
        }
    }
    
    [self.view addGestureRecognizer:tapRecognizer];
}

//不移动会进入cancel
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint p=[touch locationInView:[voiceView viewWithTag:3]];
    WSLog(@"取消事件：%@",NSStringFromCGPoint(p));
    
    UIButton *btn=(UIButton *)[voiceView viewWithTag:3];
    if(btn!=nil){
        UIImageView *iv=(UIImageView *)[btn viewWithTag:10];
        if(iv!=nil){
            [iv removeFromSuperview];
        }
    }
    if(recording){
        [self luyin];
    }
    
    [self.view addGestureRecognizer:tapRecognizer];
}


//动态显示时间
-(void)timerDiscount{
    int duration=(int)recorder.currentTime;
    [voiceTimeLabel setText:[NSString stringWithFormat:@"%d″",duration]];
    
    //大于60秒，停止录音
    if(duration>=60){
        UIButton *btn=(UIButton *)[voiceView viewWithTag:3];
        if(btn!=nil){
            UIImageView *iv=(UIImageView *)[btn viewWithTag:10];
            if(iv!=nil){
                [iv removeFromSuperview];
            }
        }
        
        
        if(recording){
            //停止录音
            [self luyin];
            
            [btn setImage:[UIImage imageNamed:@"letter_greenvoice1"] forState:UIControlStateNormal];
            [self sendMessage:nil type:RCVoiceMessageTypeIdentifier];
            
            [self.view addGestureRecognizer:tapRecognizer];
        }
    }
}



-(void)luyin{
    if (!recording) {
        recording = YES;
        tmpFile = [NSURL fileURLWithPath:
                   [NSTemporaryDirectory() stringByAppendingPathComponent:
                    [NSString stringWithFormat: @"%@.%@",
                     @"tempAudio",
                     @"wav"]]];
        [self startForFilePath:tmpFile];
        [recorder prepareToRecord];
        [recorder record];
        
        voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
    } else {
        [voiceTimer invalidate];
        
        
        [voiceTimeLabel setText:@""];
        [voiceLabel setText:TTLocalString(@"TT_hold_down_to_talk_release_can_be_sent")];
        [voiceLabel setTextColor:UIColorFromRGB(TextRegusterGrayColor)];
        recording = NO;
        [recorder stop];
        
        
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    }
    
}

//播放音频
//fileType 1 data,2 url
-(void)bofang:(NSURL *)audioURL data:(NSData *)data{
    if(audioPlayer!=nil && [audioPlayer isPlaying]){
        [audioPlayer stop];
        
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    
    NSError *error;
    if(data!=nil){
        audioPlayer=[[AVAudioPlayer alloc]initWithData:data error:&error];
    }else{
        audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:audioURL
                                                          error:&error];
    }
    audioPlayer.delegate=self;
    audioPlayer.volume=1;
    if (error) {
        NSLog(@"error:%@",[error description]);
        if(lastImageView){
            [lastImageView stopAnimating];
        }
        return;
    }
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    
    //准备播放
    [audioPlayer prepareToPlay];
    //播放
    [audioPlayer play];
}

#pragma mark 播放停止、失败
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    WSLog(@"走了完成的代理-----");
    if(lastImageView){
        [lastImageView stopAnimating];
        lastImageView=nil;
        
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [audioPlayer stop];
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    WSLog(@"走了失败的代理-----");
    if(lastImageView){
        [lastImageView stopAnimating];
        lastImageView=nil;
        
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}
// 当音频播放过程中被中断时
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    // 当音频播放过程中被中断时，执行该方法。比如：播放音频时，电话来了！
    // 这时候，音频播放将会被暂停。
    if(lastImageView){
        [lastImageView stopAnimating];
    }
}

// 当中断结束时
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
    // AVAudioSessionInterruptionFlags_ShouldResume 表示被中断的音频可以恢复播放了。
    // 该标识在iOS 6.0 被废除。需要用flags参数，来表示视频的状态。
    
    NSLog(@"中断结束，恢复播放");
    if (flags == AVAudioSessionInterruptionOptionShouldResume && player != nil){
        [player play];
        if(lastImageView){
            [lastImageView startAnimating];
        }
    }
    
}


#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        //没黑屏幕
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (![audioPlayer isPlaying]) {//没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}



- (void)startForFilePath:(NSURL *)filePath {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
//        NSLog(@"audioSession: %@ %d %@", [err domain], (int)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
//        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[tmpFile path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[tmpFile path] error:&err];
    }
    
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:tmpFile settings:[SysTools getAudioRecorderSettingDict] error:&err];
    if(!recorder){
//        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    
    [recorder record];
    recorder.meteringEnabled = YES;
    
    //时间
    [recorder recordForDuration:(NSTimeInterval) 60];
}


////////////////////////////////////////////////////////////
// 公用方法
////////////////////////////////////////////////////////////

//查询结果按照messageId倒叙
-(NSArray *) sort:(NSArray *)arr{
    //第一种方式，messageId为要排序的key
    // ascending: YES 倒叙
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:YES];
    //    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    //    [arr sortedArrayUsingDescriptors:sortDescriptors];
    
    // 第二种方式
    return [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RCMessage *item1=(RCMessage *)obj1;
        RCMessage *item2=(RCMessage *)obj2;
        NSComparisonResult result=[[NSNumber numberWithLong:item2.messageId] compare:[NSNumber numberWithLong:item1.messageId]];
        switch (result) {
            case NSOrderedAscending:
                return NSOrderedDescending;
                break;
            case NSOrderedDescending:
                return NSOrderedAscending;
            case NSOrderedSame:
                return NSOrderedSame;
            default:
                return NSOrderedSame;
                break;
        }
    }];
}


-(CGFloat )getCurTableOriginY:(CGFloat )boardHeight{
    if(mData==nil || mData.count==0){
        return 0;
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:(mData.count-1)  inSection:0];
    CGRect rect=[chatTable rectForRowAtIndexPath:indexPath];
    CGFloat cellLastBottom=rect.origin.y+rect.size.height+20;
    if((h-cellLastBottom-tableY-boardHeight-self.footView.frame.size.height)>0){
        return 0;
    }
    
    CGFloat xh=h-cellLastBottom-tableY-self.footView.frame.size.height;
    
    
    if(xh>0 && boardHeight>xh){
        return boardHeight-xh;
    }else{
        return boardHeight;
    }
    
}


-(void)setRootMenuBadge{
    
    if([[SysTools getApp] getCurrentRootViewController]!=nil){
        UIViewController *controller=[[SysTools getApp] getCurrentRootViewController].childViewControllers[0];
        if([controller isKindOfClass:[RDVTabBarController class]])
        {
            ((RDVTabBarController*)controller).chatnum=[[RequestTools getInstance] getMessagesNum];
            
            [((RDVTabBarController*)controller) checkNewcount];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
