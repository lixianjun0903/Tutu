//
//  RCLetterListController.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCLetterListController.h"

#import "UserDetailController.h"
#import "RCLetterController.h"

#define cellIdentifier @"RCLetterListCell"

#define StrangerCellIdentifier @"StrangerCellIdentifier"

#import "RCIMClient.h"
#import "RCConversation.h"

#import "UserInfoDB.h"
#import "RCMessageDBHelper.h"
#import "PrivacyController.h"

#import "StrangerLetterListController.h"

@interface RCLetterListController (){
    UITableView *listTable;
    NSMutableArray *mData;
    
    NSMutableArray *strangeData;
    int strangeNum;
    
    float oldY;
    BOOL isFront;
    float w;
    
    
    UIView *noticeView;
    
}

@end

@implementation RCLetterListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTitleMenu];
    //[self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    //    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-23/2, 22-23/2, 22-23/2, 22-23/2)];
    self.menuRightButton.hidden=YES;
    [self.menuTitleButton setTitle:@"聊天" forState:UIControlStateNormal];
    if(self.fromRoot){
        self.menuLeftButton.hidden=YES;
    }
    
    w=self.view.frame.size.width;
    
    
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    [listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
//    [listTable setBackgroundColor:[UIColor whiteColor]];
    [listTable setSeparatorColor:UIColorFromRGB(ListLineColor)];
    [listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    if(iOS7){
        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    }
    [listTable registerClass:[UITableViewCell class] forCellReuseIdentifier:StrangerCellIdentifier];
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    
    
    
    //头部色条
    UIView *ivbg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, StatusBarHeight)];
    [ivbg setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.view addSubview:ivbg];
    
    
    mData=[[NSMutableArray alloc] init];
    strangeData=[[NSMutableArray alloc] init];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getListData];
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNotictInfo:) name:NOTICE_UPDATE_UserInfo object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_DOWNLOAD_IMDATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_DELADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_SendMESSAGE object:nil];
 
    NSString *showTimes = [SysTools getValueFromNSUserDefaultsByKey:KeyShowExportNoticeTimes];
    if(showTimes!=nil && [showTimes intValue]>=3){
        return;
    }else{
        if(showTimes!=nil && ![@""isEqual:showTimes]){
            showTimes=[NSString stringWithFormat:@"%d",[showTimes intValue]+1];
        }else{
            showTimes=@"1";
        }
        [SysTools syncNSUserDeafaultsByKey:KeyShowExportNoticeTimes withValue:showTimes];
    }
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    isFront=YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(![SysTools getApp].isConnect){
            [self.menuTitleButton setTitle:TTLocalString(@"TT_connectting") forState:UIControlStateNormal];
            [[SysTools getApp] doConnection];
        }else{
            if(_fromRoot && [[RequestTools getInstance] getMessagesNum]>0){
                [self getListData];
            }
        }
    });
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
    isFront=NO;
}


-(void)updateNotictInfo:(NSNotification *)not{
    UserInfo *info=not.object;
    if(info){
        for (int i=0;i<mData.count;i++) {
            RCSessionModel *item=[mData objectAtIndex:i];
            if([item.uid isEqual:info.uid]){
                item.nickname=info.nickname;
            }
        }
        [listTable reloadData];
    }
}



#pragma mark table数据处理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(mData.count==0){
        return 1;
    }
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 25;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 25)];
        [view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, w-24, 25)];
        [label setFont:ListDetailFont];
        [label setText:TTLocalString(@"TT_i_focus_people")];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromRGB(TextGrayColor)];
        [view addSubview:label];
        return view;
    }
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 1;
    }else{
        return mData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1){
        RCLetterListCell *cell = (RCLetterListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[RCLetterListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        RCSessionModel *model=[mData objectAtIndex:indexPath.row];
        cell.delegate=self;
        [cell initDataToView:model width:w];
        
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        
        return cell;
    }else{
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:StrangerCellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
        
        [cell.textLabel setFont:ListTitleFont];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [cell.textLabel setFrame:CGRectMake(12, 0, w-72, 50)];
        
        cell.textLabel.text=TTLocalString(@"TT_stranger");
        //    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UIImage *image= [ UIImage imageNamed:@"p_right" ];
        CGRect frame = CGRectMake(w-42 , 11.5 , 42, 30);
        
        UIImageView *iv=[[UIImageView alloc] initWithImage:image];
        [iv setFrame:frame];
        [iv setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:iv];
        
        if(strangeNum>0){
            CGFloat xw=[SysTools getWidthContain:[NSString stringWithFormat:@"%d",strangeNum] font:ListDetailFont Height:20]+10;
            if(xw<20){
                xw=20;
            }
            UIImageView *msgBgView=[[UIImageView alloc] initWithFrame:CGRectMake(w-34-xw, 15, xw, 20)];
            msgBgView.layer.cornerRadius=10;
            msgBgView.layer.masksToBounds=YES;
            [msgBgView setImage:[SysTools createImageWithColor:[UIColor redColor]]];
            [cell.contentView addSubview:msgBgView];
            
            UILabel *msgCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(w-34-xw, 15, xw, 20)];
            [msgCountLabel setBackgroundColor:[UIColor clearColor]];
            [msgCountLabel setTextColor:[UIColor whiteColor]];
            [msgCountLabel setText:[NSString stringWithFormat:@"%d",strangeNum]];
            [msgCountLabel setTextAlignment:NSTextAlignmentCenter];
            msgCountLabel.layer.cornerRadius=10;
            [msgCountLabel setFont:ListDetailFont];
            msgCountLabel.layer.masksToBounds=YES;
            [cell.contentView addSubview:msgCountLabel];
            
        }
        
        [cell setFrame:CGRectMake(0, 0, w, 50)];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        return cell;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1){
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if(mData==nil || mData.count<row){
        return;
    }
    
    
    if(indexPath.section==0){
        return;
    }
    
    RCSessionModel *sm=[mData objectAtIndex:row];
    
    // 清空未读消息
    [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:sm.rcconversation.targetId];
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:sm.rcconversation.targetId];
    //删除数据
    [mData removeObjectAtIndex:row];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationLeft];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return TTLocalString(@"TT_delete");
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==1){
        RCSessionModel *sm=[mData objectAtIndex:indexPath.row];
        sm.rcconversation.unreadMessageCount=0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [listTable reloadData];
            
            // 清理未读标记，会自动调用
    //        [[RCIMClient sharedRCIMClient]clearMessages:ConversationType_PRIVATE targetId:sm.rcconversation.targetId];
        });
        
        NSString *avatarTime=[NSString stringWithFormat:@"%lld",sm.lastmsgtime];
        if(avatarTime!=nil && avatarTime.length>=11){
            avatarTime=[avatarTime substringToIndex:10];
        }
        
        RCLetterController *chat=[[RCLetterController alloc] init];
        chat.userid=sm.uid;
        chat.sessionModel=sm;
        chat.lastTime=avatarTime;
        [self openNav:chat sound:nil];
    }else{
        StrangerLetterListController *strangerController=[[StrangerLetterListController alloc] init];
        strangerController.dataArray=strangeData;
        [self openNav:strangerController sound:nil];
    }
}



-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}




//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    //Selected index's color changed.
//    static float newy = 0;
//    newy= scrollView.contentOffset.y ;
//    
//    if (newy != oldY && newy>64) {
//        //Top-YES,Bottom-NO
//        if (newy > oldY && newy<(listTable.contentSize.height-self.view.mj_height)) {
//            if(newy>64)
//            {
//                [self hideFooterButton];
//                oldY = newy;
//            }
//        }else{
//            if(newy<(listTable.contentSize.height-self.view.mj_height)){
//                [self showFooterButton];
//                oldY = newy;
//            }
//        }
//    }
//}
//
//-(void)hideFooterButton{
//    [UIView animateWithDuration:0.3f
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         CGRect rf=self.titleMenu.frame;
//                         rf.origin.y=-self.titleMenu.frame.size.height;
//                         self.titleMenu.frame=rf;
//                         
//                         CGRect vf=self.view.bounds;
//                         listTable.frame=vf;
//                     }
//                     completion:^(BOOL finished) {
//                         //让dataScrollView滚动到底部
//                     }
//     ];
//}
//-(void)showFooterButton{
//    [UIView animateWithDuration:0.3f
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         CGRect rf=self.titleMenu.frame;
//                         rf.origin.y=0;
//                         self.titleMenu.frame=rf;
//                         
//                         
//                         CGRect vf=self.view.bounds;
//                         vf.origin.y=NavBarHeight;
//                         vf.size.height=vf.size.height-vf.origin.y;
//                         listTable.frame=vf;
//                     }
//                     completion:^(BOOL finished) {
//                         //让dataScrollView滚动到底部
//                     }
//     ];
//}

-(void)avatarOnClick:(RCSessionModel *)item{
    if(item && item.uid!=nil){
        UserDetailController *controller=[[UserDetailController alloc] init];
        controller.uid=item.uid;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




/**
 *  回调成功。
 *
 *  @param userId 当前登录的用户 Id，既换取登录 Token 时，App 服务器传递给融云服务器的用户 Id。
 */
-(void)connectRCSuccess:(NSString *)userId{
    WSLog(@"%@",userId);
    
    [self.menuTitleButton setTitle:TTLocalString(@"TT_chat") forState:UIControlStateNormal];
    [self.menuTitleButton setImage:nil forState:UIControlStateNormal];
    [self.menuTitleButton setTitleEdgeInsets:UIEdgeInsetsZero];
    [self getListData];
}

/**
 *  回调出错。
 *
 *  @param errorCode 连接错误代码。
 */
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
    [self.menuTitleButton setTitle:TTLocalString(@"TT_connectting") forState:UIControlStateNormal];
    [self.menuTitleButton setImage:nil forState:UIControlStateNormal];
    [self.menuTitleButton setImageEdgeInsets:UIEdgeInsetsZero];
    [self.menuTitleButton setTitleEdgeInsets:UIEdgeInsetsZero];
    [[SysTools getApp] doConnection];
}

-(void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object{
    @try {
        
        if([SysTools getApp].isConnect){
            if(isFront && nleft==0){
                [self getListData];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

//屏蔽改变了
-(void)pushBlockNotice:(NSString *)action uid:(NSString *)userid{
    if(isFront){
        [self getListData];
    }
}

-(void)getListData{
    [self.menuTitleButton setTitle:TTLocalString(@"TT_charge...") forState:UIControlStateNormal];
    NSArray *arr=nil;
    @try {
        arr=[[RCIMClient sharedRCIMClient] getConversationList:[NSArray arrayWithObjects:[NSNumber numberWithInt:ConversationType_PRIVATE],[NSNumber numberWithInt:ConversationType_SYSTEM],[NSNumber numberWithInt:ConversationType_CUSTOMERSERVICE],nil]];
    }
    @catch (NSException *exception) {
        [self.menuTitleButton setTitle:TTLocalString(@"TT_charge_fail") forState:UIControlStateNormal];
        
    }
    @finally {
        
    }
    
    // 陌生人消息数
    strangeNum=0;
    
    UserInfo *loginInfo=[[LoginManager getInstance] getLoginInfo];
    UserInfoDB *db = [[UserInfoDB alloc] init];
    [mData removeAllObjects];
    [strangeData removeAllObjects];
    NSMutableDictionary *userDict=[db findAllRelationDict];
    
    for (RCConversation *rcconversation in arr) {
//        WSLog(@"%@---%@----LoginUID:%@",rcconversation.senderUserId,rcconversation.conversationTitle,[[LoginManager getInstance] getUid]);
        if([@"998" isEqual:rcconversation.targetId]){
            //这条消息，不应该被收到，直接删除
            NSArray *arr=[NSArray arrayWithObject:rcconversation.lastestMessageId];
            [[RCIMClient sharedRCIMClient] deleteMessages:arr];
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rcconversation.targetId];
            continue;
        }
        if([@"999" isEqual:rcconversation.targetId]){
            
            //这条消息，不应该被收到，直接删除
            @try {
                if([rcconversation.objectName isEqual:RCTextMessageTypeIdentifier]){
                    RCTextMessage *rcmsg=(RCTextMessage *)rcconversation.lastestMessage;
                    NSDictionary *dict=[[rcmsg.extra JSONString] objectFromJSONString];
                    NSString *uid=[dict objectForKey:@"frienduid"];
                    UserInfoDB *db=[[UserInfoDB alloc] init];
                    UserInfo *uinfo=[db findWidthUID:uid];
                    if(uinfo!=nil && uinfo.uid!=nil){
                        uinfo.canchat=[[dict objectForKey:@"canchat"] boolValue];
                        uinfo.relation=[dict objectForKey:@"relation"];
                        uinfo.nickname=uinfo.realname;
                        [db saveUser:uinfo];
                    }
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            //这条消息，不应该被收到，直接删除
            NSArray *arr=[NSArray arrayWithObject:rcconversation.lastestMessageId];
            [[RCIMClient sharedRCIMClient] deleteMessages:arr];
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rcconversation.targetId];
            continue;
        }
        
        if(loginInfo!=nil && [loginInfo.uid isEqual:rcconversation.targetId]){
            //这条消息，不应该被收到，直接删除
            NSArray *arr=[NSArray arrayWithObject:rcconversation.lastestMessageId];
            [[RCIMClient sharedRCIMClient] deleteMessages:arr];
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rcconversation.targetId];
            continue;
        }
        
        
        UserInfo *info=[userDict objectForKey:rcconversation.targetId];
        
        //我把对方删了，不显示
//        if(info!=nil && [info.relation intValue]==6){
//            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rcconversation.targetId];
//            continue;
//        }
        
        if(info && info.uid!=nil && ![@"" isEqual:info.uid]){
            RCSessionModel *model=[RCSessionModel new];
            model.uid = info.uid;
            model.nickname = [@"" isEqual:CheckNilValue(info.nickname)]?rcconversation.conversationTitle:info.nickname;
            model.isblock=info.isBlock;
            model.topicblock=info.topicblock;
            model.relation=[info.relation intValue];
            model.isblockme=info.isblockme;
            model.lastmsgtime = [info.lasttime longLongValue];
            model.lastmsg = @"";
            model.userhonorlevel=info.userhonorlevel;
            model.rcconversation=rcconversation;
            model.cansendmessage=[@"" isEqual:CheckNilValue(loginInfo.errormsg)]?1:[loginInfo.cansendmessage intValue];
            model.errormsg=loginInfo.errormsg;
            model.canchat=info.canchat;
            model.lastmsgtime=[info.avatartime longLongValue];
            model.isauth=info.isauth;
            
            if([info.relation intValue]==2 || [info.relation intValue]==3){
                [mData addObject:model];
            }else{
                strangeNum=strangeNum+(int)rcconversation.unreadMessageCount;
                [strangeData addObject:model];
            }
        }else{
            RCSessionModel *model=[RCSessionModel new];
            model.uid = rcconversation.targetId;
            model.nickname = rcconversation.conversationTitle;
            if(model.nickname==nil || [@"" isEqual:model.nickname]){
                model.nickname=[SysTools getNicknameByExtra:rcconversation objectName:rcconversation.objectName];
            }
            model.isblock=-1;
            model.topicblock=-1;
            model.relation=0;
            model.isblockme=-1;
            model.lastmsgtime = rcconversation.sentTime;
            model.lastmsg = @"";
            model.userhonorlevel=0;
            model.rcconversation=rcconversation;
            model.cansendmessage= [@"" isEqual:CheckNilValue(loginInfo.errormsg)]?1:[loginInfo.cansendmessage intValue];
            model.errormsg=loginInfo.errormsg;
            model.canchat=1;
            
            strangeNum=strangeNum+(int)rcconversation.unreadMessageCount;
            [strangeData addObject:model];
        }
    }
    [listTable reloadData];
    
    [self checkExportData];
    
    [self.menuTitleButton setTitle:TTLocalString(@"TT_chat") forState:UIControlStateNormal];
}


#pragma mark 没有数据，但是可以导入数据时，显示UI
-(void)createExportNoticeView{
    [self hideTableHeader];
    if(mData==nil || mData.count==0){
        
        noticeView=[[UIView alloc] initWithFrame:listTable.frame];
        [noticeView setBackgroundColor:[UIColor whiteColor]];
        noticeView.userInteractionEnabled=YES;
        noticeView.tag=10;
        [self.view addSubview:noticeView];
     
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2-125/2, 61, 125 , 113)];
        [iv setBackgroundColor:[UIColor clearColor]];
        [iv setImage:[UIImage imageNamed:@"letter_no_listmsg"]];
        [noticeView addSubview:iv];
        
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(20, 220, ScreenWidth-40, 30)];
        [lblTitle setText:TTLocalString(@"TT_have_chat_history")];
        
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setTextColor:UIColorFromRGB(TextBlackColor)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setFont:ListTitleFont];
        [noticeView addSubview:lblTitle];
        
        UILabel *lblMsg=[[UILabel alloc] initWithFrame:CGRectMake(20, 255, ScreenWidth-40, 50)];
        [lblMsg setBackgroundColor:[UIColor clearColor]];
        [lblMsg setText:TTLocalString(@"TT_download_chat_history_desc")];
        [lblMsg setNumberOfLines:0];
        [lblMsg setTextColor:UIColorFromRGB(TextGrayColor)];
        [lblMsg setFont:ListDetailFont];
        [noticeView addSubview:lblMsg];
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(ScreenWidth/2-80, 345, 160, 40)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn.layer setBorderColor:UIColorFromRGB(SystemColor).CGColor];
        [btn.layer setBorderWidth:1];
        [btn setTitle:TTLocalString(@"TT_download_chat_history") forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(SystemColorHigh) forState:UIControlStateHighlighted];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:20];
        btn.userInteractionEnabled=YES;
        btn.tag=1;
//        [btn addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
        [noticeView addSubview:btn];
        
        
        UIGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableHeaderTap:)];
        [btn addGestureRecognizer:tap1];
        
    }else{
        
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 55)];
        [view setBackgroundColor:UIColorFromRGB(LetterListTopBgColor)];
        view.userInteractionEnabled=YES;
        view.tag=10;
        
        UILabel *lblMsg=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth-70, 55)];
        [lblMsg setBackgroundColor:[UIColor clearColor]];
        [lblMsg setNumberOfLines:0];
        [lblMsg setFont:ListDetailFont];
        [lblMsg setText:WebCopy_HadExport_message];
        [lblMsg setTextColor:UIColorFromRGB(LetterListTopTextColor)];
        lblMsg.userInteractionEnabled=YES;
        lblMsg.tag=1;
        [view addSubview:lblMsg];
        
        UIImageView *ivClose=[[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-40, 55/2-10, 20, 20)];
        [ivClose setImage:[UIImage imageNamed:@"letter_listtop_close"]];
        [ivClose setBackgroundColor:[UIColor clearColor]];
        [ivClose setContentMode:UIViewContentModeScaleAspectFill];
        ivClose.userInteractionEnabled=YES;
        ivClose.tag=2;
        [view addSubview:ivClose];
        
        
        UIGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableHeaderTap:)];
        [lblMsg addGestureRecognizer:tap1];
        
        UIGestureRecognizer *tap2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableHeaderTap:)];
        [ivClose addGestureRecognizer:tap2];
        
        
        listTable.tableHeaderView=view;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    UIButton *btn=object;
    if([@"highlighted" isEqual:keyPath]){
        if([[change objectForKey:@"new"] intValue]==1){
            [btn.layer setBorderColor:UIColorFromRGB(SystemColorHigh).CGColor];
        }else{
            [btn.layer setBorderColor:UIColorFromRGB(SystemColor).CGColor];
        }
    }
}


#pragma mark 判断倒数显示UI
-(void)checkExportData{
    [self removePlaceholderView];
    [self hideTableHeader];
    
    if([[SendLocalTools getInstance] checkExportIMData]){
        if(mData==nil || mData.count==0){
            CGPoint point = CGPointMake(ScreenWidth / 2.0f, (ScreenHeight - NavBarHeight)/2.0f);
            [self createPlaceholderView:point message:WebCopy_None_message withView:listTable];
        }
        return;
    }
    
    NSString *show = [SysTools getValueFromNSUserDefaultsByKey:KeyShowExportNotice];
    if(show!=nil && [@"1" isEqual:show]){
        if(mData==nil || mData.count==0){
            CGPoint point = CGPointMake(ScreenWidth / 2.0f, (ScreenHeight - NavBarHeight)/2.0f);
            [self createPlaceholderView:point message:WebCopy_None_message withView:listTable];
        }
        return;
    }
    NSString *showTimes = [SysTools getValueFromNSUserDefaultsByKey:KeyShowExportNoticeTimes];
    if(showTimes!=nil && [showTimes intValue]>=3){
        if(mData==nil || mData.count==0){
            CGPoint point = CGPointMake(ScreenWidth / 2.0f, (ScreenHeight - NavBarHeight)/2.0f);
            [self createPlaceholderView:point message:WebCopy_None_message withView:listTable];
        }
        return;
    }else{
        [self createExportNoticeView];
    }
    
    [[SendLocalTools getInstance] checkhadExportIMData:^(int isExport) {
        if(isExport==1){
            [self createExportNoticeView];
        }else{
            if(mData==nil || mData.count==0){
                CGPoint point = CGPointMake(ScreenWidth / 2.0f, (ScreenHeight - NavBarHeight)/2.0f);
                [self createPlaceholderView:point message:WebCopy_None_message withView:listTable];
            }
        }
    }];
}



#pragma mark 头部点击事件
-(void)tableHeaderTap:(UIGestureRecognizer *)tap{
    // 以后不显示了
    [SysTools syncNSUserDeafaultsByKey:KeyShowExportNotice withValue:@"1"];
    [self hideTableHeader];
    
    //跳转
    if(tap.view.tag==1){
        
        
        PrivacyController *pcv=[[PrivacyController alloc] init];
        pcv.fromPage=1;
        [self openNavWithSound:pcv];
    }
    
    //关闭
    if(tap.view.tag==2){
        
    }
}


-(void)hideTableHeader{
    if(noticeView!=nil){
        noticeView.hidden=YES;
        for (UIView *v in noticeView.subviews) {
            [v removeFromSuperview];
        }
        [noticeView removeFromSuperview];
    }
    
    [listTable beginUpdates];
    listTable.tableHeaderView=nil;
    [listTable endUpdates];

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
