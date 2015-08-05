//


//  TopicDetailController.m
//  Tutu
//
//  Created by feng on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "TopicDetailController.h"
#import "UserDetailController.h"
#import "ReleasePicViewController.h"
#import "UMSocial.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "UIViewController+ScrollingNavbar.h"
#import "ShareTutuFriendsController.h"
#import "UILabel+Additions.h"
#import "BaseController+ScrollNavbar.h"
#import "TTplayView.h"
#import "UserInfoDB.h"
#import "ListTopicsController.h"
#import "HomeController.h"
#import "PhoneModelSetVController.h"

@interface TopicDetailController ()

@property (nonatomic)int length;
@property(nonatomic)NSTimer *animationTimer;
@property(nonatomic)BOOL isShow;

@property(nonatomic)UIView *topMessageView;

@end
static NSString *topicCellIdentifi = @"TopicCell";
static NSString *commentCellIdentifi = @"CommentTableCell";
@implementation TopicDetailController
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_animationTimer invalidate];
    _animationTimer = nil;
}
- (void)backBtnClick:(UIButton *)btn{
    if (_comefrom == 1) {
        //进入首页
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }else{
       [self.navigationController popViewControllerAnimated:YES];
    }

}
#pragma mark  评论开始上传，/上传成功
- (void)startPostComment:(CommentModel *)model{
    model.pointX = [NSString stringWithFormat:@"%f", [model.pointX floatValue] * SCREEN_WIDTH];
    model.pointY = [NSString stringWithFormat:@"%f",[model.pointY floatValue] * SCREEN_WIDTH];
    NSMutableArray *marray = [NSMutableArray arrayWithArray:_topicModel.commentList];
    [marray addObject:model];
    _topicModel.commentList = marray;
    _topicModel.commentnum = [NSString stringWithFormat:@"%ld",(long)[_topicModel.commentnum integerValue] + 1];
    [_topicCell insertCommentWithTopicModel:_topicModel];

}
- (void)successPostComment:(NSDictionary *)dict{
    [self bk_performBlock:^(id obj) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *arr = dict[@"data"][@"commentlist"];
            NSString * count = CheckNilValue(dict[@"data"][@"total"]);
            NSArray *models = [CommentModel getCommentModelList:arr];
            _topicModel.commentnum = count;
            CommentModel *lastModel = [_topicModel.commentList lastObject];
            for (int i = 0; i < models.count; i ++) {
                CommentModel *model = models[i];
                if ([model.localid isEqualToString:lastModel.localid]) {
                    [_topicModel.commentList replaceObjectAtIndex:_topicModel.commentList.count - 1 withObject:model];
                    break;
                }
            }
        }
    } afterDelay:0.4];
}
- (IBAction)buttonClick:(id)sender{
    if (((UIButton *)sender).tag == BACK_BUTTON) {
        [self backBtnClick:sender];
    }
}

- (void)appEnterBackground:(NSNotification *)notifi{
    self.isShow = NO;
}
- (void)appEnterForeground:(NSNotification *)notifi{
    
    NSArray *controllers = self.navigationController.viewControllers;
    if ([controllers.lastObject isKindOfClass:[TopicDetailController class]]) {
        self.isShow = YES;
    }
    [self bk_performBlock:^(id obj) {
        if (_topicCell && _isShow == YES) {
            if (_mainTable.contentOffset.y < DetailTabeleContentOffsetY) {
                [_topicCell playVideo];
            }
        }
    } afterDelay:0.01];
}
//修改手机标识后变更手机的名称
- (void)changePhoneName:(NSNotification *)notifi{
    NSString *phoneName = [notifi object];
    if ([_topicModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {
        _topicModel.client = phoneName;
    }
    [_mainTable reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _length = 50;
    
    if (!_isTopicDetailListView) {
        [self createTitleMenu];
        [self.menuRightButton setHidden:YES];
        [self.menuTitleButton setTitle:TTLocalString(@"TT_detail") forState:UIControlStateNormal];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(beginPlayDownloadVideo:) name:NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(changePhoneName:) name:Notification_Phone_Name_Change object:nil];

    }
   
    [NOTIFICATION_CENTER addObserver:self selector:@selector(deleteComment:) name:Notification_Delete_Comment object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(deleteReplyComment:) name:Notification_Delete_Reply_Comment object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(updateUserRelation:) name:NOTICE_ADDFRIEND object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(updateUserRelation:) name:NOTICE_DELADDFRIEND object:nil];
    
    _isVisibled = YES;
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, SelfViewHeight - NavBarHeight)];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainTable.delegate = self;
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    if (iOS7) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    _mainTable.dataSource = self;
    [self.view addSubview:_mainTable];
    
    [self followScrollView:self.mainTable];
    
    [_mainTable registerNib:[UINib nibWithNibName:topicCellIdentifi bundle:nil] forCellReuseIdentifier:topicCellIdentifi];
    [_mainTable registerNib:[UINib nibWithNibName:commentCellIdentifi bundle:nil] forCellReuseIdentifier:commentCellIdentifi];
    
    [self.mainTable addHeaderWithTarget:self action:@selector(refreshData)];
    [self.mainTable addFooterWithTarget:self action:@selector(loadMoreData)];
   
    //监测评论滑动条是否移动
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseTimer) name:Comment_Scroll_BeginDragging object:nil];
    //当_commentID存在时，是从动态页面跳转过来，需要滑动到最后一条评论。
    
    //说明是点击评论数进入的评论详情页。需要创建一个timer来控制评论的滚动

    if (!_isTopicDetailListView) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.backgroundColor = HEXCOLOR(SystemColor);
        _commentButton.alpha = 0.96;
        [_commentButton addTarget:self action:@selector(gotoCommentView:) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.frame = CGRectMake(0,ScreenHeight - 44 - (20- StatusBarHeight), ScreenWidth, 44);
        [_commentButton setImage:[UIImage imageNamed:@"topic_detail_comment"] forState:UIControlStateNormal];
        [_commentButton setImage:[UIImage imageNamed:@"topic_detail_comment_hl"] forState:UIControlStateHighlighted];
        [_commentButton setTitle:TTLocalString(@"TT_post_comment") forState:UIControlStateNormal];
        [_commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commentButton setTitleColor:HEXCOLOR(0xe2e2e2) forState:UIControlStateHighlighted];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_commentButton setImageEdgeInsets:UIEdgeInsetsMake(11, 123 + (ScreenWidth - 320) / 2.0f, 11, 175 + (ScreenWidth - 320) / 2.0f)];
        [self.view addSubview:_commentButton];
        
       //添加监测用户备注变更的通知。
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changeUserName:) name:NOTICE_UPDATE_UserInfo object:nil];
    }
  
    //如果不是从详情列表页面过来。
    if (!_isTopicDetailListView) {
        [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSend:) name:Notification_Topic_Comment_Send object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSendSuccess:) name:Notifcation_Topic_Comment_Send_Success object:nil];
    }
    
    //说明跳转到详情页面，需要先请求数据再reload  TableView
    
    //当传_topcid存在时，说明是从动态页面调整过来的。
    if (_topicid.length > 0 ) {
        [_mainTable setHidden:YES];
        [_commentButton setHidden:YES];
        [self loadTopicDetail];
    }else{
        _topicid = _topicModel.topicid;
        [self loadTopicDetail];
    }
    [self bk_performBlock:^(id obj) {
        if (!_isTopicDetailListView && [_topicDelegate isKindOfClass:[HomeController class]]) {
            [self resetTableContentOffset:NO];
        }
    } afterDelay:0.3];

}
- (void)updateUserRelation:(NSNotification *)notifi{
    UserInfo *info = [notifi object];
    _topicModel.userinfo.relation = info.relation;
    [_mainTable reloadData];
}
//删除被回复的评论
- (void)deleteReplyComment:(NSNotification *)notifi{
    CommentModel *commentModel = [notifi object];
    
    NSMutableIndexSet *setM = [[NSMutableIndexSet alloc]init];
    for (int i = 0; i < _topicModel.commentList.count; i ++) {
        CommentModel *model = _topicModel.commentList[i];
        if ([model.commentid isEqualToString:commentModel.commentid]) {
            model.replyName = nil;
            [setM addIndex:i];
        }
    }
    [_topicModel.commentList removeObjectsAtIndexes:setM];
    
    NSMutableIndexSet *setM1 = [[NSMutableIndexSet alloc]init];
    for (int i = 0; i < _topicModel.newcommentlist.count; i ++) {
        CommentModel *model = _topicModel.newcommentlist[i];
        if ([model.commentid isEqualToString:commentModel.commentid]) {
            model.replyName = nil;
            [setM1 addIndex:i];
        }
    }
    [_topicModel.newcommentlist removeObjectsAtIndexes:setM];

    [_mainTable reloadData];
}
//删除评论
- (void)deleteComment:(NSNotification *)notifi{
    CommentModel *commentModel = [notifi object];
    
    NSMutableIndexSet *setM = [[NSMutableIndexSet alloc]init];
    for (int i = 0; i < _topicModel.commentList.count; i ++) {
        CommentModel *model = _topicModel.commentList[i];
        if ([model.commentid isEqualToString:commentModel.commentid]) {
            [setM addIndex:i];
        }
    }
    [_topicModel.commentList removeObjectsAtIndexes:setM];
    
    NSMutableIndexSet *setM1 = [[NSMutableIndexSet alloc]init];
    for (int i = 0; i < _topicModel.newcommentlist.count; i ++) {
        CommentModel *model = _topicModel.newcommentlist[i];
        if ([model.commentid isEqualToString:commentModel.commentid]) {
            [setM1 addIndex:i];
        }
    }
    [_topicModel.newcommentlist removeObjectsAtIndexes:setM];

    _topicModel.commentnum = IntToString([_topicModel.commentnum intValue] - 1);
   
    [_mainTable reloadData];
    
}
- (void)changeUserName:(NSNotification *)notifi{
    UserInfo *userInfo = notifi.object;
    if (userInfo.uid.length> 0) {
        if ([userInfo.uid isEqualToString:_topicModel.uid]) {
            _topicModel.nickname = userInfo.remarkname;
            [_mainTable reloadData];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y >= (_topicCell.mj_height - 120) && _isVisibled == YES) {
        _isVisibled = NO;
        [[AWEasyVideoPlayer sharePlayer]stop];
    }
    if (scrollView.contentOffset.y < (_topicCell.mj_height - 120) && _isVisibled == NO) {
        _isVisibled = YES;
        [_topicCell playVideo];
    }
}
- (void)hidenCommentButton{
    [UIView animateWithDuration:0.2f animations:^{
        _commentButton.frame = CGRectMake(_commentButton.mj_x, _commentButton.mj_y + 44, _commentButton.mj_width, _commentButton.mj_height);
    }];
}
- (void)showCommentButton{
    [UIView animateWithDuration:0.2f animations:^{
        _commentButton.frame = CGRectMake(_commentButton.mj_x, _commentButton.mj_y - 44, _commentButton.mj_width, _commentButton.mj_height);
    }];
}
- (void)gotoCommentView:(UIButton *)button{
    
    //当前用户status==2,表示被封号，不能评论。
    if ([LoginManager getInstance].getLoginInfo.status == 2) {
        return;
    }
    if ([[LoginManager getInstance]isLogin]) {
        [SysTools playerSoundWith:@"comment"];
        ReleasePicViewController *vc=[[ReleasePicViewController alloc] init];
        vc.topicModel = _topicModel;
        if (_topicModel.type == 5) {
           vc.duration = [[AWEasyVideoPlayer sharePlayer] getCurDuration];
            if (vc.duration != 0) {
                UIImage *image = [[AWEasyVideoPlayer sharePlayer] getCurImage];
                vc.releaseImage = image;
                if (!image) {
                    vc.releaseImage = _topicCell.topicPicView.image;
                }
            }else{
                vc.releaseImage = _topicCell.topicPicView.image;
            }
        }else{
            vc.duration = 0;
            vc.releaseImage = _topicCell.topicPicView.image;
        }
        vc.pageType = 2;
        vc.commentModel=nil;
        vc.comeFrom = 1;
        if (_topicCell.isCanScroll == YES) {
           [self.navigationController pushViewController:vc animated:NO];
        }
        
    }else{
        [[LoginManager getInstance]showLoginView:self];
    }
}
- (void)refreshData{
    _direction = @"up";
    [self.mainTable footerEndRefreshing];
    _startcommentid = CheckNilValue(((CommentModel *)[_topicModel.newcommentlist firstObject]).commentid);
    [[RequestTools getInstance]get:API_NEW_COMMENT_LIST(_topicModel.topicid,_startcommentid, (int)_length,_direction) isCache:NO completion:^(NSDictionary *dict) {
        
        [_topMessageView removeFromSuperview];
        _topMessageView = nil;
        
        NSArray *array = dict[@"data"][@"newcommentlist"];
        if (array.count > 0) {
       
            //移除旧的重新创建消息视图

            _topMessageView = [self showNoticeWithMessage:WebCopy_NewComment((int )array.count) message:nil bgColor:TopNotice_Block_Color];
            
            NSArray *models = [CommentModel getCommentModelList:array];
            NSIndexSet *indexs = [NSIndexSet indexSetWithIndexesInRange:
                                  NSMakeRange(0,[models count])];
            if (_topicModel.newcommentlist) {
               [_topicModel.newcommentlist insertObjects:models atIndexes:indexs];
            }else{
                NSMutableArray *mArray = [NSMutableArray arrayWithArray:models];
                _topicModel.newcommentlist = mArray;
            }
            
            [_mainTable reloadData];
        }else{
         _topMessageView = [self showNoticeWithMessage:WebCopy_NoNewComment message:nil bgColor:TopNotice_Block_Color];
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
    } finished:^(ASIHTTPRequest *request) {
        [self.mainTable headerEndRefreshing];
    }];
}
- (void)loadMoreData{
    _direction = @"down";
    [self.mainTable headerEndRefreshing];
    _startcommentid = CheckNilValue(((CommentModel *)[_topicModel.newcommentlist lastObject]).commentid);
    [[RequestTools getInstance]get:API_NEW_COMMENT_LIST(_topicModel.topicid,_startcommentid, _length,_direction) isCache:NO completion:^(NSDictionary *dict) {
        NSArray *array = dict[@"data"][@"newcommentlist"];
        if (array.count > 0) {
            NSArray *models = [CommentModel getCommentModelList:array];
            [_topicModel.newcommentlist addObjectsFromArray:models];
            [_mainTable reloadData];
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [self.mainTable footerEndRefreshing];
    }];

}
- (void)scrollCommentView{
   // WSLog(@"%@",[self description]);
    [_topicCell scrollAvatarAndComment];
}
- (void)resetTableContentOffset:(BOOL) animation{
    CGFloat totalHeight = 0;
    for (CommentModel *model in _topicModel.newcommentlist) {
        CGFloat height = [CommentTableCell calculateCellHeight:model];
        totalHeight = totalHeight + height;
    }
    totalHeight += 60;
    
    if (totalHeight > ScreenHeight ) {
        [self.mainTable setContentOffset:CGPointMake(0, _topicCell.mj_height ) animated:animation];
    }else{
        [self.mainTable setContentOffset:CGPointMake(0, _topicCell.mj_height - (ScreenHeight - totalHeight)+ 64) animated:animation];
    }
}
#pragma mark  UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat height = [TopicCell getCellHeight:_topicModel isDetail:YES] - 15;
        if (_topicModel.userlist.count > 0) {
            height = height + 32;
        }
        return height;
    }else if (indexPath.section == 1){
        return 0;
    }else{
        CGFloat height = [CommentTableCell calculateCellHeight:_topicModel.newcommentlist[indexPath.row]];
        return height;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        if (_topicModel.newcommentlist.count == 0) {
            return 0;
        }
        return 64;
    }else
        return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    header.backgroundColor = HEXCOLOR(SystemGrayColor);
    
    
   //矩形框
    UIView *rectangleView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    rectangleView.backgroundColor = [UIColor whiteColor];
    [header addSubview:rectangleView];
    //三角形
    UIImageView *triangleView = [[UIImageView  alloc]initWithImage:[UIImage imageNamed:@"topic_comment_point"]];
    triangleView.bounds = CGRectMake(0, 0, 29, 13);
    triangleView.frame = CGRectMake(25, rectangleView.mj_y - triangleView.mj_height, triangleView.mj_width, triangleView.mj_height);
    [header addSubview:triangleView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, ScreenWidth, 0.5)];
    lineView.backgroundColor = HEXCOLOR(ListLineColor);
    [header addSubview:lineView];
    
    UILabel *titleLabel = [UILabel labelWithSystemFont:13 textColor:HEXCOLOR(TextBlackColor)];
    titleLabel.frame = CGRectMake(12, 36, 100, 14);
    titleLabel.text = TTLocalString(@"TT_All comments");
    [header addSubview:titleLabel];
    return header;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return 0;
    }else{
        return _topicModel.newcommentlist.count;
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if (scrollView == _mainTable) {
        [self showNavBarAnimated:YES];
        return YES;
    }else{
        return NO;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TopicCell *cell = [tableView dequeueReusableCellWithIdentifier:topicCellIdentifi forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.isDetail = YES;
        cell.topicDelegate = self;
        [cell loadCellWithModel:_topicModel];
        cell.isShowReportView = YES;
        cell.isTargetCell = YES;
        cell.isShowAddFollow = YES;
        _topicCell = cell;
        return cell;
    }else{
        CommentTableCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifi forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.topicDelegate = self;
        
        cell.topicModel = self.topicModel;
        
        cell.cellIndex = indexPath.row;
        
        [cell loadCellWithModel:_topicModel.newcommentlist[indexPath.row]];
        
        return cell;
    }
}

#pragma mark TopicDelegate

//转发的用户名称点击
- (void)topicReportUserNameClick:(NSString *)userID nickName:(NSString *)name{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicReportUserNameClick:nickName:)]) {
        [_topicDelegate topicReportUserNameClick:userID nickName:name];
    }else{
        UserDetailController *vc = [[UserDetailController alloc]init];
        vc.uid = userID;
        [self openNavWithSound:vc];
    }
}
- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
        [_topicDelegate topicAvatarOrNicknameClick:topicModel];
    }else{
        UserDetailController *vc = [[UserDetailController alloc]init];
        vc.uid = topicModel.uid;
        vc.user = topicModel.userinfo;
        [self openNavWithSound:vc];
    }
}
- (void)topicPhoneNameClick:(id)sender{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPhoneNameClick:)]) {
        [_topicDelegate topicPhoneNameClick:sender];
    }else{
        PhoneModelSetVController *vc = [[PhoneModelSetVController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
        [_topicDelegate topicAtClick:name topicModel:topicModel];
    }else{
        UserDetailController *detail=[[UserDetailController alloc] init];
        detail.nickName=[name stringByReplacingOccurrencesOfString:@"@" withString:@""];
        [self openNav:detail sound:nil];
    }
}
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
        [_topicDelegate topicPoundSignClick:string topicModel:topicModel];
    }else{
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString=string;
        control.pageType=TopicWithDefault;
        [self openNav:control sound:nil];
    }
}
- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex{
    _topicModel = model;
    [_mainTable reloadData];

}
- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex isReload:(BOOL)isReload{
    _topicModel = model;

    if (isReload) {
        [_mainTable reloadData];
    }
}
- (void)topicCommentAvatarClick:(CommentModel *)commentModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentAvatarClick:)]) {
        [_topicDelegate topicCommentAvatarClick:commentModel];
    }else{
        UserDetailController *detail=[[UserDetailController alloc] init];
        detail.uid = commentModel.uid;
        [self openNav:detail sound:nil];
    }
}
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint)commentPoint{
    if (_topicDelegate && [_topicDelegate isKindOfClass:[TopicCollectionCell class]] && [_topicDelegate respondsToSelector:@selector(topicCommentContentClick:topicModel:image:duration:type:point:)]) {
         [_topicDelegate topicCommentContentClick:commentModel topicModel:topicModel image:image duration:duration type:type point:commentPoint];
    }else{
        ReleasePicViewController *vc = [[ReleasePicViewController alloc]init];
        vc.topicModel = topicModel;
        vc.pageType = type;
        vc.comeFrom = 1;
        vc.releaseImage = image;
        vc.commentModel = commentModel;
        vc.commentPoint = commentPoint;
        [self openNavWithSound:vc];
    }
}
- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicLoctionClick:topic:)]) {
        [_topicDelegate topicLoctionClick:location topic:topicModel];
    }else{
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString=location;
        control.poiid=topicModel.poiId;
        control.pageType=TopicWithPoiPage;
        [self openNav:control sound:nil];
    }
}
//分享类型的按钮点击
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicShareButtonClick:type:index:)]) {
        [_topicDelegate topicShareButtonClick:topicModel type:type index:index];
    }else{
        if (type == ActionSheetTypeTutu) {
            ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
            vc.uid = [[LoginManager getInstance] getUid];
            vc.topicModel=topicModel;
            [self openNavWithSound:vc];
        }
        if (type == ActionSheetTypeCopyLink){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString *shareUrl = FormatString(@"%@%@", SHARE_TOPIC_HOST,topicModel.topicid);
            [pasteboard setString:shareUrl];
            [self bk_performBlock:^(id obj) {
                [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_copy_success") duration:1.0];
            } afterDelay:.5];
        }
    }
}
//话题的更多点击
- (void)topicHuaTiMoreClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiMoreClick:)]) {
        [_topicDelegate topicHuaTiMoreClick:topicModel];
    }
}
//莫个话题点击
- (void)topicHuaTiClick:(TopicModel *)topicModel index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiClick:index:)]) {
        [_topicDelegate topicHuaTiClick:topicModel index:index];
    }
}

- (void)stopTimer{
    [_animationTimer invalidate];
    _animationTimer = nil;
}

- (void)fireTimer{
    if (_animationTimer) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    _animationTimer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(scrollCommentView) userInfo:nil repeats:YES];
    [_animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[NSRunLoop currentRunLoop]addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
    [_animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL]];
}
//发表评论后，收到数据 ，插入评论
- (void)commentSend:(NSNotification *)notification{
    CommentModel *model = [notification object];
    if (model.comeFrom == 1) {
        NSMutableArray *arrayM = nil;
        if (_topicModel.commentList.count > 0) {
            
            arrayM = [NSMutableArray arrayWithArray:_topicModel.commentList];
        }else{
            arrayM = [@[]mutableCopy];
        }
        [arrayM addObject:model];
        _topicModel.commentList = arrayM;
        
        [_topicCell insertCommentWithTopicModel:_topicModel];
        
    }
}
- (void)commentSendSuccess:(NSNotification *)notification{
    NSDictionary *dict = [notification object];
    int comeFrom = [dict[@"come_from"]intValue];
    if (comeFrom == 1) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *arr = dict[@"data"][@"commentlist"];
            NSArray *models = [CommentModel getCommentModelList:arr];
            _topicModel.commentnum = FormatString(@"%lu",(long) ([_topicModel.commentnum integerValue] + 1));
            _topicModel.commentList = (NSMutableArray *)models;
        }
    }

}
//，当，评论条人为滑动时暂停几秒timer
- (void)pauseTimer{
    if (_animationTimer) {
        [_animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL2]];
    }
}
- (void)loadTopicDetail{
    [[RequestTools getInstance]get:API_TOPIC_DETAIL(_topicid, _startcommentid) isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *listArray = dict[@"data"][@"list"];
            if (listArray.count > 0) {
                TopicModel *model = [TopicModel initTopicModelWith:listArray[0]];
                _topicModel = model;
                [NOTIFICATION_CENTER postNotificationName:Notification_TopicModel_Change object:_topicModel];
                if (_topicModel.topicid.length > 0) {
                    [_commentButton setHidden:NO];
                    [_mainTable setHidden:NO];
                    [_mainTable reloadData];
                   [self bk_performBlock:^(id obj) {
                       if (_isVisibled) {
                          [_topicCell playVideo];
                       }
                   } afterDelay:0.1f];
                    
                    //当有_startcommentid,说明需要滚动到对应的评论.
                    if (_startcommentid.length > 0) {
                        for (int i = 0; i < _topicModel.newcommentlist.count; i ++) {
                            CommentModel *model = _topicModel.newcommentlist[i];
                            if ([model.commentid isEqualToString:_startcommentid]) {
                                [self bk_performBlock:^(id obj) {
                                    [_mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                } afterDelay:0.3];
                                break;
                            }

                        }

                    }
                }
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        if (_comefrom == 1 || _comefrom ==2) {
            if ([message isEqualToString:TTLocalString(@"TT_Theme does not exist")]) {
                UIImageView *PlaceholderView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_deleted_bg"]];
                PlaceholderView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
                PlaceholderView.center = CGPointMake(ScreenWidth / 2.0, (ScreenHeight  / 2.0 ));
                [self.view addSubview:PlaceholderView];
            }
        }

    } finished:^(ASIHTTPRequest *request) {
        
    }];
    
}

- (CGFloat)getContentSizeViewHeight{
    
    return ScreenWidth + 164;
}

- (void)CommentAvatarAnimation{
}
-(void)reporttopic:(TopicModel *) model{
    [[RequestTools getInstance] get:API_REPORTTOPIC(model.topicid) isCache:NO completion:^(NSDictionary *dict) {
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
- (void)blockSomebodyTopic:(TopicModel *)topicModel{
    
    [[RequestTools getInstance]get:API_BLOCK_USER_FEED(topicModel.uid) isCache:NO completion:^(NSDictionary *dict) {
        UserInfo *userinfo = [[UserInfo alloc]init];
        userinfo.uid = topicModel.uid;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLOCK_USER_TOPIC object:userinfo];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
    } finished:^(ASIHTTPRequest *request) {
    }];
    
}


/**
 *  发送主题删去请求
 */
- (void)sendTopicDeleteRequest{

    self.menuRightButton.userInteractionEnabled = NO;
    [[RequestTools getInstance]get:[NSString stringWithFormat:@"%@?topicid=%@",API_TOPIC_DELETE,_topicModel.topicid] isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            [[NSNotificationCenter defaultCenter]postNotificationName:TOPIC_DELETE object:@{@"topic_id":_topicid}];

            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        self.menuRightButton.userInteractionEnabled = YES;
    } finished:^(ASIHTTPRequest *request) {
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginPlayDownloadVideo:(NSNotification *)notifi{
    NSString *videoUrl = [notifi object];
    _topicCell.isCanScroll = YES;
    if ([_topicModel.videourl isEqualToString:videoUrl]) {
        if (_isVisibled == YES && _isShow == YES) {
            [_topicCell playVideo];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (!_isTopicDetailListView) {
        
        [self fireTimer];
    }
    _topicCell.isTargetCell = YES;
    [self.navigationController setNavigationBarHidden:YES];
    _isShow = YES;
    if (_isShow && _isVisibled) {
        [_topicCell playVideo];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [[AWEasyVideoPlayer sharePlayer]stop];
    [_topMessageView removeFromSuperview];
    _topMessageView = nil;
    
    [SVProgressHUD dismiss];
    if (!_isTopicDetailListView) {
        [self stopTimer];
    }
    _isShow = NO;
    _topicCell.isTargetCell = NO;
    [_topicCell stopVideo];
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
