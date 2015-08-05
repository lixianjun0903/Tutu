//
//  TopicDetailListController.m
//  Tutu
//
//  Created by gexing on 14/12/3.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "TopicDetailListController.h"
#import "UserDetailController.h"
#import "LoginViewController.h"
#import "UIImageView+WebCache.h"
#import "ShareTutuFriendsController.h"
#import "WXApi.h"
#import "BaseController+ScrollNavbar.h"
#import "TopicCacheDB.h"
#import "ListTopicsController.h"
#import "SVWebViewController.h"
#import "PhoneModelSetVController.h"
@interface TopicDetailListController ()
{
    NSTimer *animationTimer;
    BOOL isShouldPopView;
    UIPanGestureRecognizer *pan;
    CGPoint _beginPoint;
    BOOL isShow;
}
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIImageView *avatarImage;
@property(nonatomic,strong)UserInfo *userInfo;
@end

static NSString *identifier = @"TopicCollectionCell";
@implementation TopicDetailListController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    UITableView *tabelview = _currentCell.topicController.mainTable;
    TopicCell *cell = _currentCell.topicController.topicCell;
    cell.isVisibled = YES;
    cell.isTargetCell = YES;
    if (tabelview.contentOffset.y < cell.mj_height) {
        
        [cell playVideo];
    }
    [self fireTimer];
}
- (void)beginPlayDownloadVideo:(NSNotification *)notifi{
    NSString *videoUrl = [notifi object];
    TopicCell *cell = _currentCell.topicController.topicCell;
    cell.isCanScroll = YES;
    if ([cell.topicModel.videourl isEqualToString:videoUrl]) {
        if (_currentCell.topicController.isVisibled && isShow == YES) {
            [cell playVideo];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginPlayDownloadVideo:) name:NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS object:nil];

    isShow = YES;

    //显示头像
    [self.navigationController setNavigationBarHidden:YES];

}

#pragma mark 评论发布后收到通知的处理
- (void)commentSend:(NSNotification *)notification{
    CommentModel *model = [notification object];
    if (model.comeFrom == 2) {
        NSString *topicID= model.topicid;
        for (int i = 0; i < _mutableArray.count; i ++) {
            NSString * topic_id = ((TopicModel *)_mutableArray[i]).topicid;
            if ([topic_id isEqualToString:topicID]) {
                TopicCollectionCell *cell = (TopicCollectionCell *)[_mainCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
                
                TopicCell *topiccell = cell.topicController.topicCell;
                
                TopicModel *topicmodel = topiccell.topicModel;
                if (topicmodel.commentList) {
                    [topicmodel.commentList addObject:model];
                }else{
                    topicmodel.commentList = [NSMutableArray arrayWithObject:model];
                }
                topicmodel.commentnum = [NSString stringWithFormat:@"%ld",(long)[topicmodel.commentnum integerValue] + 1];
                [_mutableArray replaceObjectAtIndex:i withObject:topicmodel];
                [self bk_performBlock:^(id obj) {
                    [topiccell insertCommentWithTopicModel:topicmodel];
                } afterDelay:0.1f];
                
                break;
            }
        }
 
    }
 }
- (void)commentSendSuccess:(NSNotification *)notification{
    NSString *topic_id = nil;
    NSDictionary *dict = [notification object];
    int comeFrom = [dict[@"come_from"]intValue];
    if (comeFrom == 2) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *arr = dict[@"data"][@"commentlist"];
            NSString * count = CheckNilValue(dict[@"data"][@"total"]);
            NSString *topicID= CheckNilValue(dict[@"data"][@"topicid"]);
            for (int i = 0; i < _mutableArray.count; i ++) {
                topic_id = ((TopicModel *)_mutableArray[i]).topicid;
                if ([topic_id isEqualToString:topicID]) {
                    NSArray *models = [CommentModel getCommentModelList:arr];
                    TopicCollectionCell *cell = (TopicCollectionCell *)[_mainCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
                    TopicCell *topiccell = cell.topicController.topicCell;
                    TopicModel *model = _mutableArray[i];
                    CommentModel *lastModel = [model.commentList lastObject];
                    BOOL isSuccess = NO;
                    for (int i = 0; i < models.count; i ++) {
                        CommentModel *newModel = models[i];
                        if ([newModel.localid isEqualToString:lastModel.localid]) {
                            [model.commentList replaceObjectAtIndex:model.commentList.count - 1 withObject:newModel];
                            isSuccess = YES;
                            break;
                        }
                    }
                    if (!isSuccess) {
                        return;
                    }
                    model.commentnum = count;
                    topiccell.topicModel = model;
                    [_mutableArray replaceObjectAtIndex:i withObject:model];
                    break;
                }
            }
            
        }
  
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS object:nil];
    isShow = NO;
    TopicCell *cell = _currentCell.topicController.topicCell;
    cell.isTargetCell = NO;
    [[AWEasyVideoPlayer sharePlayer] stop];
    
    [self stopTimer];
}
- (void)gotoUserCenter{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = ((TopicModel *)_dataArray[_currentIndex]).uid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonClick:(id)sender{
    NSInteger tag = ((UIButton *)sender).tag;
    if (tag == BACK_BUTTON) {
        [self goBack:sender];
    }else if (tag == RIGHT_BUTTON){
        [self showDeleteAlert:sender];
    }

}
- (void)appEnterBackground:(NSNotification *)notifi{
    isShow = NO;
}
- (void)appEnterForeground:(NSNotification *)notifi{
    
    NSArray *controllers = self.navigationController.viewControllers;
    if ([controllers.lastObject isKindOfClass:[TopicDetailListController class]]) {
        isShow = YES;
    }
    [self bk_performBlock:^(id obj) {
        if (isShow ) {
            UITableView *tabelview = _currentCell.topicController.mainTable;
            TopicCell *cell = _currentCell.topicController.topicCell;
            cell.isVisibled = YES;
            if (tabelview.contentOffset.y < DetailTabeleContentOffsetY) {
                [cell playVideo];
            }
        }
    } afterDelay:0.05f];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
    [self.menuRightButton setHidden:YES];
    [self.menuTitleButton setTitle:@"详情" forState:UIControlStateNormal];
    isShouldPopView = YES;
    _userInfo = [[LoginManager getInstance]getLoginInfo];
    if ([_uid isEqualToString:[LoginManager getInstance].getUid] && _uid.length > 0) {
        [self.menuRightButton setHidden:NO];
        [self.menuRightButton setImage:[UIImage imageNamed:@"topic_delete"] forState:UIControlStateNormal];
        [self.menuRightButton setImage:[UIImage imageNamed:@"topic_delete_hl"] forState:UIControlStateHighlighted];
        [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(10, 18, 10, 8)];
    }
    [self.mainCollection registerClass:[TopicCollectionCell class] forCellWithReuseIdentifier:identifier];
    _mainCollection.backgroundColor = [UIColor clearColor];
    if (iOS7) {
    self.mainCollection.frame = CGRectMake(0,0, ScreenWidth, SelfViewHeight + 20);
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        self.wantsFullScreenLayout = YES;
    self.mainCollection.frame = CGRectMake(0,0, ScreenWidth, self.view.mj_height);
    }
    _mainCollection.scrollsToTop = NO;
    
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    pan.delegate = self;
    [_mainCollection addGestureRecognizer:pan];
    
    self.collectionLayout.minimumInteritemSpacing = 0.0;
    self.collectionLayout.minimumLineSpacing = 0.0;
    self.collectionLayout.sectionInset = UIEdgeInsetsZero;
    self.collectionLayout.footerReferenceSize = CGSizeZero;
    self.collectionLayout.headerReferenceSize = CGSizeZero;
    self.collectionLayout.itemSize = self.mainCollection.frame.size;

    
    _mutableArray = [[NSMutableArray alloc]initWithCapacity:0];
    [_mutableArray addObjectsFromArray:_dataArray];
    [_mainCollection reloadData];
   
    [self followScrollView:self.mainCollection];
    [_mainCollection setContentOffset:CGPointMake(_currentIndex * self.mainCollection.mj_width, 0) animated:NO];


    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseTimer) name:Comment_Scroll_BeginDragging object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changeUserName:) name:NOTICE_UPDATE_UserInfo object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSend:) name:Notification_Topic_Comment_Send object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSendSuccess:) name:Notifcation_Topic_Comment_Send_Success object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changePhoneName:) name:Notification_Phone_Name_Change object:nil]; 

    [self bk_performBlock:^(id obj) {
       _currentCell = (TopicCollectionCell *)[_mainCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
    } afterDelay:0.1f];
    
    //创建评论按钮
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.backgroundColor = HEXCOLOR(SystemColor);
    _commentButton.alpha = 0.96;
    [_commentButton addTarget:self action:@selector(gotoCommentView:) forControlEvents:UIControlEventTouchUpInside];
    _commentButton.frame = CGRectMake(0,ScreenHeight - 44 - (20 - StatusBarHeight), ScreenWidth, 44);
    [_commentButton setImage:[UIImage imageNamed:@"topic_detail_comment"] forState:UIControlStateNormal];
    [_commentButton setImage:[UIImage imageNamed:@"topic_detail_comment_hl"] forState:UIControlStateHighlighted];
    [_commentButton setTitle:@"发评论" forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commentButton setTitleColor:HEXCOLOR(0xe2e2e2) forState:UIControlStateHighlighted];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_commentButton setImageEdgeInsets:UIEdgeInsetsMake(11, 123 + (ScreenWidth - 320) / 2.0f, 11, 175 + (ScreenWidth - 320) / 2.0f)];
    [self.view addSubview:_commentButton];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginPlayVedio) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)changeUserName:(NSNotification *)notifi{
    UserInfo *userInfo = notifi.object;
    if (userInfo.uid.length > 0) {
        
        [TopicModel updateUserName:userInfo array:_mutableArray];

        [_mainCollection reloadData];
        if (_topicType == TopicTypeFavoriteList) {
            if (_delegate && [_delegate respondsToSelector:@selector(favoriteModelsChange:)]) {
                [_delegate favoriteModelsChange:(NSArray *)_mutableArray];
            }
        }else{
            if (_delegate && [_delegate respondsToSelector:@selector(topicModelsChange:)]) {
                [_delegate topicModelsChange:(NSArray *)_mutableArray];
            }
        }

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
    
    if ([[LoginManager getInstance]isLogin]) {
        [SysTools playerSoundWith:@"comment"];
        ReleasePicViewController *vc=[[ReleasePicViewController alloc] init];
        TopicModel *topicModel = _mutableArray[_currentIndex];
        vc.topicModel = topicModel;
        vc.pageType = 2;
        vc.commentModel=nil;
        TopicCell *cell = _currentCell.topicController.topicCell;
        if (topicModel.type == 5) {
            vc.releaseImage = [[AWEasyVideoPlayer sharePlayer] getCurImage];
            vc.duration = [[AWEasyVideoPlayer sharePlayer] getCurDuration];
        }else if (topicModel.type == 1){
            vc.releaseImage = cell.topicPicView.image;
            vc.duration = 0.f;
        }
        if (cell.isCanScroll) {
            vc.comeFrom = 2;
           [self.navigationController pushViewController:vc animated:NO];
        }
    }else{
        [[LoginManager getInstance]showLoginView:self];
    }
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
- (void)updateModel:(TopicModel *)topicModel atIndex:(NSInteger)cellIndex{
    // To do debug crash
    [_mutableArray replaceObjectAtIndex:cellIndex withObject:topicModel];
    if (_topicType == TopicTypeFavoriteList) {
        if (_delegate && [_delegate respondsToSelector:@selector(favoriteModelsChange:)]) {
            [_delegate favoriteModelsChange:(NSArray *)_mutableArray];
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(topicModelsChange:)]) {
            [_delegate topicModelsChange:(NSArray *)_mutableArray];
        }
    }
}
- (void)panGesture:(UIPanGestureRecognizer *)panGesture{

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            _beginPoint = [panGesture locationInView:self.view];
            break;
        case UIGestureRecognizerStateChanged:
        {
            UIView *bgView =_currentCell.topicController.topicCell.collectionViewbg;
            CGRect rect = [bgView convertRect:CGRectMake(0, 0, ScreenWidth, bgView.mj_height) toView:self.view];
            CGPoint changePoint = [panGesture locationInView:self.view];
            
            if (CGRectContainsPoint(rect,changePoint)) {
                return;
            }
        //    WSLog(@"++++++%f++++%f",changePoint.x,changePoint.y);

            if ((changePoint.x - _beginPoint.x > 80) && isShouldPopView == YES && _mainCollection.contentOffset.x == 0) {
                isShouldPopView = NO;
                WSLog(@"++++++++++++++++%f",changePoint.x);
                [self goBack:nil];
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == _mainCollection) {
        if (!decelerate) {
            [self getCurrentPlayCell];
        }
    }
}
- (void)getCurrentPlayCell{
    NSInteger index = (NSInteger)_mainCollection.contentOffset.x / (NSInteger)_mainCollection.mj_width;
    _currentIndex = index;
    _currentCell = (TopicCollectionCell *)[_mainCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
    TopicModel *model = _mutableArray[_currentIndex];
    if (model.type == 5) {
        TopicCell *cell = _currentCell.topicController.topicCell;
        [cell playVideo];
    }
    
    [self animationTimer];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self getCurrentPlayCell];
}

- (void)deleteTopicModelAtIndex:(NSInteger)index{
  self.menuRightButton.userInteractionEnabled = NO;

    if (_mutableArray.count > index) {
        TopicModel *model = _mutableArray[index];
        if (![model isHasTopicid]) {
            TopicCacheDB *db=[[TopicCacheDB alloc] init];
            [db deleteTopicWithLoaclId:model.localid];
            [[NSNotificationCenter defaultCenter]postNotificationName:Notification_Delete_My_Topic object:model];
            [_mutableArray removeObjectAtIndex:index];
            [_mainCollection deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0]]];
            if (_delegate && [_delegate respondsToSelector:@selector(deleteTopicModelAtIndex:)]) {
                [_delegate deleteTopicModelAtIndex:index];
            }
            self.menuRightButton.userInteractionEnabled = YES;
            return;
        }
        
        [[RequestTools getInstance]get:[NSString stringWithFormat:@"%@?topicid=%@",API_TOPIC_DELETE,model.topicid] isCache:NO completion:^(NSDictionary *dict) {
            if (model.type ==5) {
                TopicCell *cell = _currentCell.topicController.topicCell;
                [cell stopVideo];
            }
            TopicCacheDB *db = [[TopicCacheDB alloc]init];
            [db deleteTopicByTopicID:model.topicid withType:TopicStatusSend];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:TOPIC_DELETE object:model];
            [_mutableArray removeObjectAtIndex:index];
            [_mainCollection deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0]]];
            if (_delegate && [_delegate respondsToSelector:@selector(deleteTopicModelAtIndex:)]) {
                [_delegate deleteTopicModelAtIndex:index];
            }
            if (_mutableArray.count == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            self.menuRightButton.userInteractionEnabled = YES;
        }];
    }
}

- (void)deleteFavoriteAtIndex:(NSInteger)index{
    if (_mutableArray.count > index) {
        TopicModel *model = _mutableArray[index];
        self.menuRightButton.userInteractionEnabled = NO;
        [[RequestTools getInstance]get:API_TOPIC_FAVORITE_DELETE(model.topicid) isCache:NO completion:^(NSDictionary *dict) {
            if (model.type ==5) {
                TopicCell *cell = _currentCell.topicController.topicCell;
                [cell stopVideo];
            }
            TopicCacheDB *db = [[TopicCacheDB alloc]init];
            [db deleteTopicByTopicID:model.topicid withType:TopicStatusCollection];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATON_FAVORITE_STATUS_CHANGE object:model];
            [_mutableArray removeObjectAtIndex:index];
            [_mainCollection deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0]]];
            if (_delegate && [_delegate respondsToSelector:@selector(deleteFavoriteAtIndex:)]) {
                [_delegate deleteFavoriteAtIndex:index];
            }
            if (_mutableArray.count == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            self.menuRightButton.userInteractionEnabled = YES;
        }];
 
    }
}


-(void)animationTimer {
    [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL]];
}
- (void)scrollCommentView{
   // WSLog(@"%@",[self description]);
    if (_currentCell) {
        TopicCell *cell = _currentCell.topicController.topicCell;
        [cell scrollAvatarAndComment];
    }
}
#pragma mark Timer Stop ,Fire
//，当，评论条人为滑动时暂停几秒timer
- (void)pauseTimer{
    if (animationTimer) {
        [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL2]];
    }
}
- (void)stopTimer{
    [animationTimer invalidate];
    animationTimer = nil;
}
- (void)fireTimer{
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
    //创建一个定时器，让评论头像滚动
    animationTimer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(scrollCommentView) userInfo:nil repeats:YES];
    [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[NSRunLoop currentRunLoop]addTimer:animationTimer forMode:NSDefaultRunLoopMode];
     [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL]];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _mutableArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TopicCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.topicDelegate = self;
    if (_mutableArray.count > indexPath.row) {
        cell.cellIndexPathRow = indexPath.row;
        TopicModel *model = [_mutableArray objectAtIndex:indexPath.row];
        cell.isTopicDetailList = YES;
        [cell loadCellWithModel:model];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //[[AWEasyVideoPlayer sharePlayer]stop];
    
   // [self getCurrentPlayCell];
}

- (void)showDeleteAlert:(id)sender{
    if (_mutableArray.count == 0) {
        return;
    }
    NSString *message = @"";
    NSString *deleteMessage = @"";
    if (_topicType == TopicTypeList) {
        message = WebCopy_Delete_topic;
        deleteMessage = TTLocalString(@"TT_make_sure");
    }else{
        message = WebCopy_Cancel_Collect;
        deleteMessage = TTLocalString(@"TT_make_sure");
    }

    LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:message delegate:self otherButton:@[deleteMessage] cancelButton:TTLocalString(@"TT_cancel")];
    [sheet showInView:nil];

}
- (void)didClickOnButtonIndex:(NSInteger )buttonIndex tag:(NSInteger)tag{
    NSArray *cells = [_mainCollection visibleCells];
    for (TopicCollectionCell *cell in cells) {
        NSIndexPath *path = [_mainCollection indexPathForCell:cell];
        _currentIndex = path.row;
        break;
    }
    if (buttonIndex == 0) {
        if (_topicType == TopicTypeList) {
            
            [self deleteTopicModelAtIndex:_currentIndex];
        }else{
            [self deleteFavoriteAtIndex:_currentIndex];
        }
    }else{
        
    }
 
}
#pragma mark
#pragma mark  TopicDelegate
- (void)topicPhoneNameClick:(id)sender{
    PhoneModelSetVController *vc = [[PhoneModelSetVController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = topicModel.uid;
    vc.user = topicModel.userinfo;
    [self openNavWithSound:vc];
}
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel{
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.nickName=[name stringByReplacingOccurrencesOfString:@"@" withString:@""];
    [self openNav:detail sound:nil];
}
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=string;
    control.pageType=TopicWithDefault;
    [self openNav:control sound:nil];
}
- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=location;
    control.poiid = topicModel.poiId;
    control.pageType=TopicWithPoiPage;
    [self openNav:control sound:nil];
}
- (void)topicDetailClick:(TopicModel *)topicModel index:(NSInteger)index{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicModel = topicModel;
    vc.indexRow = index;
    vc.topicDelegate = self;
    [self openNavWithSound:vc];
}
//去详情页
- (void)topicCommentCountClick:(TopicModel *)topicModel{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicModel = topicModel;
    [self openNavWithSound:vc];
}

- (void)topicCommentAvatarClick:(CommentModel *)commentModel{
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.uid = commentModel.uid;
    [self openNav:detail sound:nil];
}
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint)commentPoint{
    ReleasePicViewController *vc=[[ReleasePicViewController alloc] init];
    vc.topicModel = topicModel;
    vc.releaseImage = image;
    vc.pageType = type;
    vc.commentModel = commentModel;
    vc.comeFrom = 2;
    vc.commentPoint=commentPoint;
    [self openNavWithSound:vc];
}

//分享类型的按钮点击
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index{
    if (type == ActionSheetTypeTutu) {
        ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
        vc.uid = _userInfo.uid;
        vc.topicModel=topicModel;
        [self openNavWithSound:vc];
    }else if (type == ActionSheetTypeCopyLink){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *shareUrl = FormatString(@"%@%@", SHARE_TOPIC_HOST,topicModel.topicid);
        [pasteboard setString:shareUrl];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_copy_success") duration:1.0];
        } afterDelay:.5];
    }
}
//转发的用户名称点击
- (void)topicReportUserNameClick:(NSString *)userID nickName:(NSString *)name{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = userID;
    [self openNavWithSound:vc];
}
//修改手机标识后变更手机的名称
- (void)changePhoneName:(NSNotification *)notifi{
    NSString *phoneName = [notifi object];
    [TopicModel updateUserPhoneName:phoneName array:_mutableArray];
    [_mainCollection reloadData];
}

- (void)topicHuaTiMoreClick:(TopicModel *)topicModel{
    SVWebViewController *vc = [[SVWebViewController alloc]initWithURL:StrToUrl(URL_HuaTi_GuangChang)];
    [self openNavWithSound:vc];
}
- (void)topicHuaTiClick:(TopicModel *)topicModel index:(NSInteger)index{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString = [topicModel.huatilist[index] huatitext];
    control.pageType=TopicWithDefault;
    [self openNav:control sound:nil];
}

#pragma mark HomePageCellDelegate
/**
 *  社交平台的分享选择
 *
 *  @param imageIndex imageIndex，从0开始，一次对应 视图上面的分享
 */
-(void)reporttopic:(TopicModel *) model{
    WSLog(@"%@",API_REPORTTOPIC(model.topicid));
    [[RequestTools getInstance] get:API_REPORTTOPIC(model.topicid) isCache:NO completion:^(NSDictionary *dict) {
        WSLog(@"%@",dict);
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
- (void)sendAddFavorite:(TopicModel *)topicModel{
    [[RequestTools getInstance]get:API_TOPIC_FAVORITE_ADD(topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_FAVORITE_ADD object:topicModel];
        for (int i = 0; i < _mutableArray.count; i ++) {
            TopicModel *model = _mutableArray[i];
            if ([model.topicid isEqualToString:topicModel.topicid]) {
                [_mutableArray removeObjectAtIndex:i];
                topicModel.favorite = YES;
                [_mutableArray insertObject:topicModel atIndex:i];
                if (_delegate && [_delegate respondsToSelector:@selector(topicModelsChange:)]){
                    [_delegate topicModelsChange:_mutableArray];
                }
                break;
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
//取消收藏
- (void)sendCancelFavorite:(TopicModel *)topicModel{
    [[RequestTools getInstance]get:API_TOPIC_FAVORITE_DELETE(topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_FAVORITE_DELETE object:topicModel];
        for (int i = 0; i < _mutableArray.count; i ++) {
            TopicModel *model = _mutableArray[i];
            
            if ([model.topicid isEqualToString:topicModel.topicid]) {
                [_mutableArray removeObjectAtIndex:i];
                topicModel.favorite = NO;
                [_mutableArray insertObject:topicModel atIndex:i];
                if (_delegate && [_delegate respondsToSelector:@selector(topicModelsChange:)]){
                    [_delegate topicModelsChange:_mutableArray];
                }
                break;
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
    
}

#pragma mark  评论开始上传，/上传成功
- (void)startPostComment:(CommentModel *)model{
    NSString *topicID= model.topicid;
    model.pointX = [NSString stringWithFormat:@"%f", [model.pointX floatValue] * SCREEN_WIDTH];
    model.pointY = [NSString stringWithFormat:@"%f",[model.pointY floatValue] * SCREEN_WIDTH];
    for (int i = 0; i < _mutableArray.count; i ++) {
        NSString * topic_id = ((TopicModel *)_mutableArray[i]).topicid;
        if ([topic_id isEqualToString:topicID]) {
            
            TopicCollectionCell *cell = (TopicCollectionCell *)[_mainCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            TopicModel *topicmodel = _mutableArray[i];
            NSMutableArray *mArr = [NSMutableArray arrayWithArray:topicmodel.commentList];
            [mArr addObject:model];
            
            topicmodel.commentList = (NSMutableArray *)mArr;
            topicmodel.commentnum = [NSString stringWithFormat:@"%lu",(long)[topicmodel.commentnum integerValue] + 1];
            TopicCell *topicCell = cell.topicController.topicCell;
            [topicCell insertCommentWithTopicModel:topicmodel];
           
            [_mutableArray replaceObjectAtIndex:i withObject:topicmodel];
            if (_delegate && [_delegate respondsToSelector:@selector(topicModelsChange:)]){
                [_delegate topicModelsChange:_mutableArray];
            }
            [self bk_performBlock:^(id obj) {
            } afterDelay:0.4];
            
            break;
        }
    }
}

- (void)successPostComment:(NSDictionary *)dict{
    
    NSString *topic_id = nil;
    if ([dict[@"code"]integerValue] == 10000) {
        NSArray *arr = dict[@"data"][@"commentlist"];
        NSString * count = CheckNilValue(dict[@"data"][@"total"]);
        NSString *topicID= CheckNilValue(dict[@"data"][@"topicid"]);
        for (int i = 0; i < _mutableArray.count; i ++) {
            topic_id = ((TopicModel *)_mutableArray[i]).topicid;
            if ([topic_id isEqualToString:topicID]) {
                NSArray *models = [CommentModel getCommentModelList:arr];
                TopicModel *model = _mutableArray[i];
                CommentModel *lastComment = [model.commentList lastObject];
                BOOL isSuccess = NO;
                for (int i = 0; i < models.count; i ++) {
                    CommentModel *model1 = models[i];
                    if ([model1.localid isEqualToString:lastComment.localid]) {
                        [model.commentList replaceObjectAtIndex:model.commentList.count - 1 withObject:model1];
                        isSuccess = YES;
                        break;
                    }
                }
                if (!isSuccess) {
                    return;
                }
                model.commentnum = count;
                [_mutableArray replaceObjectAtIndex:i withObject:model];
                if (_delegate && [_delegate respondsToSelector:@selector(topicModelsChange:)]){
                    [_delegate topicModelsChange:_mutableArray];
                }
                break;
            }
        }
        
    }
    
}
#pragma mark  主题开始上传/上传成功
////分享点击
//- (void)shareButtonClick:(TopicModel *)topicModel{
//    LXActivity *activity = [[LXActivity alloc]initWithDelegate:self model:topicModel];
//    [activity showInView:self.view];
//}
////名字点击
//- (void)nickNameClick:(TopicModel *)topicModel{
//    UserDetailController *vc = [[UserDetailController alloc] init];
//    vc.uid = topicModel.uid;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//动态评论点击
//- (void)commentClick:(CommentModel *)commentModel topic:(TopicModel *)topicModel index:(NSInteger)topicIndex {
//    [SysTools playerSoundWith:@"comment"];
//    if ([[UserModel shareUserModel]isLogin]) {
//        ReleasePicViewController *vc=[[ReleasePicViewController alloc] init];
//        vc.topicModel=topicModel;
//        vc.delegate = self;
//        vc.pageType=2;
//        vc.commentModel = commentModel;
//        //vc.releaseImage=[SysTools getImageWithName:topicModel.sourcepath];
//        [self.navigationController pushViewController:vc animated:NO];
//    }else{
//        [self showLoginView];
//    }
//    
//}

- (void)resetTableContentOffset{
    CGFloat totalHeight = 0;
    TopicModel *topicModel = _mutableArray[_currentIndex];
    for (CommentModel *model in topicModel.newcommentlist) {
        CGFloat height = [CommentTableCell calculateCellHeight:model];
        totalHeight = totalHeight + height;
    }
    [_currentCell.topicController resetTableContentOffset:YES];
}

#pragma mark UITableViewDelegate

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
