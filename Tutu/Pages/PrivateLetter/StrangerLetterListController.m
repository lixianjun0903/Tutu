//
//  StrangerLetterListController.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/11.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "StrangerLetterListController.h"

#import "UserDetailController.h"
#import "RCLetterController.h"

#define cellIdentifier @"RCLetterListCell"
#import "RCIMClient.h"
#import "RCConversation.h"

#import "UserInfoDB.h"
#import "RCMessageDBHelper.h"
#import "PrivacyController.h"

@interface StrangerLetterListController (){
    UITableView *listTable;
    
    float oldY;
    BOOL isFront;
    
    
    UIView *noticeView;
    
}

@end

@implementation StrangerLetterListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTitleMenu];
    //[self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    //    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-23/2, 22-23/2, 22-23/2, 22-23/2)];
    self.menuRightButton.hidden=YES;
    [self.menuTitleButton setTitle:TTLocalString(@"TT_stranger") forState:UIControlStateNormal];
    
    
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    [listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [listTable setSeparatorColor:UIColorFromRGB(ListLineColor)];
    [listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    if(iOS7){
        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    }
    
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    
    //头部色条
    UIView *ivbg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mj_width, StatusBarHeight)];
    [ivbg setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.view addSubview:ivbg];
    
    if(_dataArray==nil){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _dataArray=[[NSMutableArray alloc] init];
            [self getListData];
        });
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNotictInfo:) name:NOTICE_UPDATE_UserInfo object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_DOWNLOAD_IMDATA_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_DELADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListData) name:NOTICE_SendMESSAGE object:nil];
}


-(void)updateNotictInfo:(NSNotification *)not{
    UserInfo *info=not.object;
    if(info){
        for (int i=0;i<_dataArray.count;i++) {
            RCSessionModel *item=[_dataArray objectAtIndex:i];
            if([item.uid isEqual:info.uid]){
                item.nickname=info.nickname;
            }
        }
        [listTable reloadData];
    }
}



#pragma mark table数据处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCLetterListCell *cell = (RCLetterListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RCLetterListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    RCSessionModel *model=[_dataArray objectAtIndex:indexPath.row];
    cell.delegate=self;
    [cell initDataToView:model width:tableView.frame.size.width];
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if(_dataArray==nil || _dataArray.count<row){
        return;
    }
    
    RCSessionModel *sm=[_dataArray objectAtIndex:row];
    
    // 清空未读消息
    [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:sm.rcconversation.targetId];
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:sm.rcconversation.targetId];
    //删除数据
    [_dataArray removeObjectAtIndex:row];
    
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
    RCSessionModel *sm=[_dataArray objectAtIndex:indexPath.row];
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
    [self.navigationController pushViewController:chat animated:YES];
}



-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //目的是让私信列表从新刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DOWNLOAD_IMDATA_SUCCESS object:nil];
        });
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


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    isFront=YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(![SysTools getApp].isConnect){
            [self.menuTitleButton setTitle:TTLocalString(@"TT_connectting") forState:UIControlStateNormal];
            [[SysTools getApp] doConnection];
        }
    });
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
    isFront=NO;
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
    
    [self.menuTitleButton setTitle:TTLocalString(@"TT_stranger") forState:UIControlStateNormal];
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
        if([SysTools getApp].isConnect && nleft==0){
            if(isFront){
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
    //    if(arr!=nil && arr.count>0){
    //
    //    }
    //    NSString *userids=@"";
    UserInfo *loginInfo=[[LoginManager getInstance] getLoginInfo];
    UserInfoDB *db = [[UserInfoDB alloc] init];
    [_dataArray removeAllObjects];
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
        
        //自己给自己发
        //        if([rcconversation.targetId isEqual:loginInfo.uid]){
        //            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rcconversation.targetId];
        //            continue;
        //        }
        
        if(loginInfo!=nil && [loginInfo.uid isEqual:rcconversation.targetId]){
            //这条消息，不应该被收到，直接删除
            NSArray *arr=[NSArray arrayWithObject:rcconversation.lastestMessageId];
            [[RCIMClient sharedRCIMClient] deleteMessages:arr];
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rcconversation.targetId];
            continue;
        }
        
        UserInfo *info=[userDict objectForKey:rcconversation.targetId];//[db findWidthUID:rcconversation.targetId];
        //我把对方删了，不显示
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
            
            if([info.relation intValue]!=2 && [info.relation intValue]!=3){
                [_dataArray addObject:model];
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
            model.canchat=0;
            
            [_dataArray addObject:model];
        }
    }
    [listTable reloadData];
    
    [self.menuTitleButton setTitle:TTLocalString(@"TT_stranger") forState:UIControlStateNormal];
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
