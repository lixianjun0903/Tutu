//
//  TopicViewController.m
//  Tutu
//
//  Created by gexing on 4/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "TopicViewController.h"
#import "SDImageCache.h"
#import "BaseController+ScrollNavbar.h"
#import "AWEasyVideoPlayer.h"
#import "RecommendFollowVController.h"
#import "UserFocusModel.h"
#import "HomeController.h"
@interface TopicViewController ()

@property(nonatomic,strong)NSMutableArray *cacheJsonArray;//缓存最新的数据的json数组。
@property(nonatomic,strong)NSMutableArray *cacheSendTopicArray;//缓存用户还没有发送成功的主题id->localid
@property(nonatomic) BOOL isFirstLoad;//是否是第一次加载
@property(nonatomic)NSInteger currentIndex;
@property(nonatomic,strong)RecommendFollowVController *followController;
@property(nonatomic)BOOL isUpScroll;
@property(nonatomic)CGFloat offsetY;

@end

@implementation TopicViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArrayM = [[NSMutableArray alloc]init];
    
    //用来缓存最新的json数据
    
    _cacheJsonArray = [[NSMutableArray alloc]init];
   
    //用来缓存用户的发送的主题
    
    if (_topicType == TopicListTypeFollow) {
        _cacheSendTopicArray = [[NSMutableArray alloc]init];
    }
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight)];
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    [self.view addSubview:_mainTable];
    _mainTable.separatorStyle = UITableViewCellSelectionStyleNone;
    [_mainTable addHeaderWithTarget:self action:@selector(refreshData)];
    [_mainTable addFooterWithTarget:self action:@selector(loadMoreData)];
    [_mainTable setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    
    [_mainTable registerNib:[UINib nibWithNibName:topicCell bundle:nil] forCellReuseIdentifier:topicCell];
    [_mainTable registerNib:[UINib nibWithNibName:themeCell bundle:nil] forCellReuseIdentifier:themeCell];
    [_mainTable registerNib:[UINib nibWithNibName:huaTiLocationCell bundle:nil] forCellReuseIdentifier:huaTiLocationCell];
    [self getHomePageCacheData];
    [self addNotificationObserver];
    
    _isFirstLoad = YES;
    if ([_mainTable respondsToSelector:@selector(contentInset)]) {
        _mainTable.contentInset = UIEdgeInsetsMake(0, 0,50, 0);
    }
    
    
}
- (void)addNotificationObserver{
    if (_topicType == TopicListTypeFollow) {
        [NOTIFICATION_CENTER addObserver:self selector:@selector(topicSend:) name:Notification_Topic_Send object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(topicSendSuccess:) name:Notification_Topic_Send_Success object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(topicSendFailed:) name:Notification_Topic_Send_Failed object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshFollowTableView:) name:Notification_Del_Focus object:nil];
    }else{
        [NOTIFICATION_CENTER addObserver:self selector:@selector(updateUserRelation:) name:NOTICE_ADDFRIEND object:nil];
        [NOTIFICATION_CENTER addObserver:self selector:@selector(updateUserRelation:) name:NOTICE_DELADDFRIEND object:nil];
    }
    //监测当前用户昵称变化/或者备注的变更
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changeUserName:) name:NOTICE_UPDATE_UserInfo object:nil];
    
   //监测用户关注状态的变化
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userFollowStatusChange:) name:Notification_Topic_Follow_status_change object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(networkChanged:) name:Notification_NetworkChange object:nil];
    
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSend:) name:Notification_Topic_Comment_Send object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSendSuccess:) name:Notifcation_Topic_Comment_Send_Success object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSendFailed:) name:Notifcation_Topic_Comment_Send_Failed object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(beginPlayVedio) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(saveHomePageCacheData) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(deleteMyTopic:) name:Notification_Delete_My_Topic object:nil];
    
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(blockSomebodyTopic:) name:NOTIFICATION_BLOCK_USER_TOPIC object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(downloadVedioSuccess:) name:NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(updateDataSource:) name:Notification_TopicModel_Change object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changePhoneName:) name:Notification_Phone_Name_Change object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(deleteTopic:) name:TOPIC_DELETE object:nil];
    
}
#pragma 网络链接改变时会调用的方法
-(void)networkChanged:(NSNotification *)note
{
    int status = [[note object]intValue];
    if (status == 1) {//网络切换成wifi
        if (![UserDefaults boolForKey:UserDefaults_is_Close_AutoPlay_Under_Wifi]) {
            NSArray *cells = [_mainTable visibleCells];
            for (UITableViewCell *cell in cells) {
                if ([cell isKindOfClass:[TopicCell class]]) {
                    [((TopicCell *)cell).playButton setHidden:YES];
                }
            }
            [self getcurrentPlayCell];
        }
    }else{
        [[TCBlobDownloadManager sharedInstance]cancelAllDownloadsAndRemoveFiles:NO];
        [self getcurrentPlayCell];
    }

}
- (void)deleteTopic:(NSNotification *)notifi{
    TopicModel *model = [notifi object];
    [TopicModel updateDeletedTopic:model array:_dataArrayM];
    [_mainTable reloadData];
}
- (void)updateUserRelation:(NSNotification *)notifi{
    UserInfo *info = [notifi object];
    [TopicModel updateUserRelation:info array:_dataArrayM];
    [_mainTable reloadData];
}
//修改手机标识后变更手机的名称
- (void)changePhoneName:(NSNotification *)notifi{
    NSString *phoneName = [notifi object];
    [TopicModel updateUserPhoneName:phoneName array:self.dataArrayM];
    [_mainTable reloadData];
}
//收到取消关注的消息，刷新关注列表
- (void)refreshFollowTableView:(NSNotification *)notifi{
    if ([[notifi object] isKindOfClass:[UserInfo class]]) {
        NSMutableIndexSet *setM = [[NSMutableIndexSet alloc]init];
        UserInfo *userinfo = [notifi object];
        for (int i = 0; i < _dataArrayM.count; i ++) {
            TopicModel *model = _dataArrayM[i];
            if ([model.userinfo.uid isEqualToString:userinfo.uid]) {
                [setM addIndex:i];
            }
        }
        [_dataArrayM removeObjectsAtIndexes:setM];
        [_mainTable reloadData];
    }else if([[notifi object] isKindOfClass:[UserFocusModel class]]){
        UserFocusModel *focusModel = [notifi object];
        NSMutableIndexSet *setM = [[NSMutableIndexSet alloc]init];
        for (int i = 0; i < _dataArrayM.count; i ++) {
            TopicModel *model = _dataArrayM[i];
            if ([model.topicid isEqualToString:focusModel.resid]) {
                [setM addIndex:i];
            }
        }
        [_dataArrayM removeObjectsAtIndexes:setM];
        [_mainTable reloadData];
    }

}
//当用户对主题点赞，或者收藏，topicModel的某些属性发生了变化，需要更新下数据源

- (void)updateDataSource:(NSNotification *)notifi{
    TopicModel *model = [notifi object];
    [TopicModel updateTopicModel:model array:_dataArrayM];
    [_mainTable reloadData];
}

//当在详情页面点赞后，需要刷新首页列表
//- (void)refreshTableView:(NSNotification *)notifi{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.mainTable reloadData];
//    });
//}
//变更主题中用户的关系
- (void)userFollowStatusChange:(NSNotification *)notifi{
    TopicModel *topicModel = [notifi object];
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
    NSMutableArray *indexs = [@[]mutableCopy];
    for (int i = 0; i < _dataArrayM.count; i ++ ) {
        TopicModel *model = _dataArrayM[i];
        if ([model.uid isEqualToString:topicModel.uid]) {
            model.userinfo.relation = topicModel.userinfo.relation;
            [_dataArrayM replaceObjectAtIndex:i withObject:model];
            [set addIndexes:[NSIndexSet indexSetWithIndex:i]];
            [indexs addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    //如果是关注列表，
    if (_topicType == TopicListTypeFollow) {
        [_dataArrayM removeObjectsAtIndexes:set];
        [_mainTable reloadRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)beginPlayVedio{
    [self bk_performBlock:^(id obj) {
        [self getcurrentPlayCell];
    } afterDelay:0.5];
}

-(void)downloadVedioSuccess:(NSNotification *) info{
    if ([_currentPlayCell isKindOfClass:[TopicCell class]]) {
        TopicCell *topicCell = (TopicCell *)_currentPlayCell;
        if ([topicCell.topicModel.videourl isEqualToString:info.object]) {
            if (_isVisible) {
              [topicCell playVideo];
            }
        }
    }
}
//获得当前页面中的播放视频的cell
-(void)getcurrentPlayCell{
    NSArray *cells = [_mainTable visibleCells];
    if (cells.count == 0) {
        return;
    }
    
    UITableViewCell *cell = nil;
    if (cells.count == 1) {
        cell = cells[0];
    }else if (cells.count == 3){
        cell = cells[1];
    }else if (cells.count == 2){
        
        UITableViewCell *cell0 = cells[0];
        UITableViewCell *cell1 = cells[1];
        CGPoint point0 = [cell0 convertPoint:CGPointMake(0, 0) toView:ApplicationDelegate.window];
        CGPoint point1 = [cell1 convertPoint:CGPointMake(0, 0) toView:ApplicationDelegate.window];
        cell = (cell0.mj_height - fabs(point0.y)) > (self.view.mj_height - fabs(point1.y)) ? cell0 : cell1;
    }else if (cells.count == 5){
        cell = cells[2];
    }else if (cells.count == 4){
        UITableViewCell *cell0 = cells[1];
        UITableViewCell *cell1 = cells[2];
        cell = cell0.mj_height  > cell1.mj_height ? cell0 : cell1;
    }
    
    if (_currentPlayCell == nil && [_mainTable indexPathForCell:cell].row == 0 ) {
        _currentPlayCell = cell;
        if ([_currentPlayCell isKindOfClass:[TopicCell class]]) {
            ((TopicCell *)_currentPlayCell).isTargetCell = YES;
            if (_isVisible) {
                [((TopicCell *)_currentPlayCell) playVideo];
            }
        }
    }else{
        if (([_mainTable indexPathForCell:cell].row) != [_mainTable indexPathForCell:_currentPlayCell].row) {
            if ([_currentPlayCell isKindOfClass:[TopicCell class]]) {
                ((TopicCell *)_currentPlayCell).isTargetCell = NO;
            }
            [[AWEasyVideoPlayer sharePlayer] stop];
            [[AWEasyVideoPlayer sharePlayer]removeFromSuperview];
            _currentPlayCell = cell;
            if ([_currentPlayCell isKindOfClass:[TopicCell class]]) {
                ((TopicCell *)_currentPlayCell).isTargetCell = YES;
                if (_isVisible) {
                    [((TopicCell *)_currentPlayCell) playVideo];
                }
            }
        }
    }
}
//变更主题列表中用户的昵称
- (void)changeUserName:(NSNotification *)notification{
    UserInfo *info = [notification object];
    [TopicModel updateUserName:info array:_dataArrayM];
    [_mainTable reloadData];
}
//改变用户收藏主题的状态
- (void)changeCollectionStatus:(NSNotification *)notification{
    TopicModel *topicModel = [notification object];
    for (int i = 0; i < _dataArrayM.count; i ++) {
        TopicModel *model = _dataArrayM[i];
        if ([model.topicid isEqualToString:topicModel.topicid]) {
            [_dataArrayM replaceObjectAtIndex:i withObject:topicModel];
            break;
        }
    }
}
//屏蔽莫人的主题
- (void)blockSomebodyTopic:(NSNotification *)notification{
    UserInfo *info = (UserInfo *)notification.object;
    NSString *uid = info.uid;
    NSMutableArray *indexPaths = [@[]mutableCopy];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
    for (int i = 0;i < _dataArrayM.count; i ++) {
        TopicModel *model = _dataArrayM[i];
        if ([model.uid isEqualToString:uid]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
            [indexSet addIndex:i];
        }
    }
    [_dataArrayM removeObjectsAtIndexes:indexSet];
    [_mainTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self bk_performBlock:^(id obj) {
        [self getcurrentPlayCell];
    } afterDelay:0.1f];
}
#pragma mark 主题发送后收到通知的处理
- (void)topicSend:(NSNotification *)notification{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicScrollIndex:)]) {
        [_topicDelegate topicScrollIndex:1];
    }
    if (_topicType == TopicListTypeFollow) {
        TopicModel *model = [notification object];
        //发布后插到table的最上面
        [_dataArrayM insertObject:model atIndex:0];
        [_mainTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        //页面数据加载后，滑动最上面的
        [self bk_performBlock:^(id obj) {
            [_mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            //页面滑动结束后重新获得可以播放视频的cell.
            [self bk_performBlock:^(id obj) {
                [self getcurrentPlayCell];
            } afterDelay:0.2f];
        } afterDelay:0.3];
        [_cacheSendTopicArray addObject:model.topicid];
    }
}
- (void)topicSendSuccess:(NSNotification *)notification{
    
    TopicModel *topicModel = (TopicModel *)[notification object];
    for (int i = 0; i < _dataArrayM.count; i ++) {
        TopicModel *topic = _dataArrayM[i];
        if ([topic.localid isEqualToString:topicModel.localid]) {
            topicModel.topicType = @"1";
            topicModel.isUploadFailed = NO;
            topicModel.iskana = topic.iskana;
            if (topicModel.type == 5) {//发布的是视频主题
                NSString *temp= topic.videourl;
                NSString *fileName = [[NSURL URLWithString:topicModel.videourl] lastPathComponent];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",getVideoPath(),fileName];
                [[NSFileManager defaultManager] moveItemAtPath:temp toPath:filePath error:nil];
            }
            [[SDImageCache sharedImageCache]storeImage:[UIImage imageWithContentsOfFile:getDocumentsFilePath(topic.sourcepath)] forKey:topicModel.sourcepath toDisk:YES];
            [_dataArrayM replaceObjectAtIndex:i withObject:topicModel];
            [_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self bk_performBlock:^(id obj) {
                [self getcurrentPlayCell];
            } afterDelay:0.1f];
            break;
        }
    }
}
- (void)topicSendFailed:(NSNotification *)notification{
    TopicModel *topicMode = (TopicModel *)[notification object];
    for (int i = 0; i < _dataArrayM.count; i ++) {
        TopicModel *model = _dataArrayM[i];
        if ([model.localid isEqualToString:topicMode.localid]) {
            topicMode.isUploadFailed = YES;
            [_dataArrayM replaceObjectAtIndex:i withObject:topicMode];
            [_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            TopicCell *cell = (TopicCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell.topicPicView addSubview:[AWEasyVideoPlayer sharePlayer]];
            [self bk_performBlock:^(id obj) {
                 [self getcurrentPlayCell];
            } afterDelay:0.1f];
        }
    }
}

#pragma mark 评论发布后收到通知的处理
- (void)commentSend:(NSNotification *)notification{
    CommentModel *model = [notification object];
    if (model.comeFrom == 0) {
        NSString *topicID= model.topicid;
        for (int i = 0; i < _dataArrayM.count; i ++) {
            NSString * topic_id = ((TopicModel *)_dataArrayM[i]).topicid;
            if ([topic_id isEqualToString:topicID]) {
                TopicCell *cell = (TopicCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                TopicModel *topicmodel = _dataArrayM[i];
                if (topicmodel.commentList) {
                    [topicmodel.commentList addObject:model];
                }else{
                    topicmodel.commentList = [NSMutableArray arrayWithObject:model];
                }
                topicmodel.commentnum = [NSString stringWithFormat:@"%ld",(long)[topicmodel.commentnum integerValue] + 1];
                [_dataArrayM replaceObjectAtIndex:i withObject:topicmodel];
                [self bk_performBlock:^(id obj) {
                    [cell insertCommentWithTopicModel:topicmodel];
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
    if (comeFrom == 0) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *arr = dict[@"data"][@"commentlist"];
            NSString * count = CheckNilValue(dict[@"data"][@"total"]);
            NSString *topicID= CheckNilValue(dict[@"data"][@"topicid"]);
            for (int i = 0; i < _dataArrayM.count; i ++) {
                topic_id = ((TopicModel *)_dataArrayM[i]).topicid;
                if ([topic_id isEqualToString:topicID]) {
                    NSArray *models = [CommentModel getCommentModelList:arr];
                    TopicCell *cell = (TopicCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    TopicModel *model = _dataArrayM[i];
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
                    cell.topicModel = model;
                    [_dataArrayM replaceObjectAtIndex:i withObject:model];
                    break;
                }
            }
            
        }
 
    }
  }
- (void)commentSendFailed:(NSNotification *)notification{
    
}
//屏蔽某人主题的通知


/**
 *  删除自己的主题
 *
 *  @param notification
 */
- (void)deleteMyTopic:(NSNotification *)notification{
    TopicModel *topicModel = (TopicModel *)[notification object];
    if ([topicModel isHasTopicid]) {
        for (int i = 0; i < _dataArrayM.count; i ++) {
            TopicModel *model = _dataArrayM[i];
            if ([model.topicid isEqualToString:topicModel.topicid]) {
                [_dataArrayM removeObjectAtIndex:i];
                [_mainTable reloadData];
                [self bk_performBlock:^(id obj) {
                     [self getcurrentPlayCell];
                } afterDelay:0.1f];
                break;
            }
        }
    }else{
        for (int i = 0; i < _dataArrayM.count; i ++) {
            TopicModel *model = _dataArrayM[i];
            if ([model.topicid isEqualToString:topicModel.localid]) {
                [_dataArrayM removeObjectAtIndex:i];
                [_mainTable reloadData];
                [self bk_performBlock:^(id obj) {
                     [self getcurrentPlayCell];
                } afterDelay:0.1f];
                break;
            }
        }
    }
    
}

- (void)saveHomePageCacheData{
    //缓存热门的列表前面N条
    if (_cacheJsonArray.count  > 0) {
        if (_topicType == TopicListTypeHot) {
           [UserDefaults setValue:[_cacheJsonArray JSONData] forKey:UserDefaults_Index_Hot_List];
        }else{
           [UserDefaults setValue:[_cacheJsonArray JSONData] forKey:UserDefaults_Index_Friend_List];
        }
    }
}
//从userdefaults 中取得缓存的数据
- (void)getHomePageCacheData{
    NSData *cacheData = nil;
    if (_topicType == TopicListTypeHot) {
        cacheData = [UserDefaults objectForKey:UserDefaults_Index_Hot_List];
        NSArray *cacheJsonArray = [cacheData objectFromJSONData];
        if (cacheJsonArray.count > 0) {
            NSArray *models = [TopicModel getTopicModelsWithArray:cacheJsonArray];
            [_dataArrayM addObjectsFromArray:models];
            [_mainTable reloadData];

        }
    }else{
//        cacheData = [UserDefaults objectForKey:UserDefaults_Index_Friend_List];
//        NSArray *cacheJsonArray = [cacheData objectFromJSONData];
//        if (cacheJsonArray.count > 0) {
//            NSArray *models = [TopicModel getTopicModelsWithArray:cacheJsonArray];
//            [_dataArrayM addObjectsFromArray:models];
//            [_mainTable reloadData];
//        }
    }
//    [self bk_performBlock:^(id obj) {
//        [self getcurrentPlayCell];
//    } afterDelay:0.2];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self getcurrentPlayCell];
    
    
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//
//}
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if(![scrollView isDecelerating] && ![scrollView isDragging]){
//        
//        [self getcurrentPlayCell];
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if(!decelerate){
//        
//        [self getcurrentPlayCell];
//    }
//}

#pragma mark UITableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArrayM.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    TopicModel *model = _dataArrayM[indexPath.row];
    if (model.type == 9) {
        ThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:themeCell forIndexPath:indexPath];
        cell.topicDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell reloadCellWithModel:model];
        return cell;
    }else if (model.type == 20 || model.type == 21){
        HuaTiLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:huaTiLocationCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.topicDelegate = self;
        if (model.type == 20) {
            cell.cellType = CellTypeHuaTi;
        }else{
            cell.cellType = CellTypeLocation;
        }
        [cell reloadCellWithModel:model];
        return cell;
    }else{
        TopicCell *cell = [tableView dequeueReusableCellWithIdentifier:topicCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.topicDelegate = self;
        cell.tabelIndex = _topicType;
        cell.cellIndex = indexPath.row;
        cell.isDetail = NO;//不需要展开
        if (_topicType == TopicListTypeFollow) {
            cell.isShowReportView = YES;
            cell.isShowAddFollow = YES;
        }else{
            cell.isShowAddFollow = YES;
        }
        [cell loadCellWithModel:model];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[TopicCell class]]) {
        ((TopicCell *)cell).isTargetCell = NO;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicModel *model = _dataArrayM[indexPath.row];
    if (model.type == 9) {
        return [ThemeCell getCellHeight];
    }else if (model.type == 20 || model.type == 21){
        return [HuaTiLocationCell getCellHeight];
    }else{
        
      CGFloat height = [TopicCell getCellHeight:model isDetail:NO];
        if (model.userlist.count > 0) {
            height = height + 32;
        }
      return height;
    }
}
/**
 *  通过topicid，删除本地的主题
 *
 *  @param topicids
 */
- (void)deleteTopicWithID:(NSArray *)topicids{
    if (topicids.count == 0) {
        return;
    }
    NSMutableDictionary *mDic = [@{}mutableCopy];
    for (int i = 0; i < _dataArrayM.count; i ++) {
        
        TopicModel *model = _dataArrayM[i];
        if ([model isHasTopicid]) {
            [mDic setObject:@(i) forKey:model.topicid];
        }
    }
    NSMutableIndexSet *mIndexSet = [NSMutableIndexSet indexSet];
    for (NSString *topicid in topicids) {
        if ([mDic objectForKey:topicid]) {
            NSInteger index = [[mDic objectForKey:topicid]integerValue];
            [mIndexSet addIndex:index];
        }
    }
    if (mIndexSet.count > 0) {
        [_dataArrayM removeObjectsAtIndexes:mIndexSet];
    }
}
//主题列表的信息（评论数，喜欢数，等）变动比较大，所以下拉时的逻辑是清空原有数据，重新加载。
-(void)refreshData{
    int len = 17;
   
    [[AWEasyVideoPlayer sharePlayer]stop];
    [[AWEasyVideoPlayer sharePlayer]removeFromSuperview];
    NSString *starttopicid = @"";
    NSString *endtopicid = @"";
    if (_dataArrayM!=nil && _dataArrayM.count>0) {
        starttopicid = CheckNilValue([(TopicModel *)[_dataArrayM firstObject] topicid]);
        endtopicid = CheckNilValue([(TopicModel *)[_dataArrayM lastObject] topicid]);
        //过滤掉未发送成功的主题id.
        for (int i = 0; i < _dataArrayM.count; i ++) {
            TopicModel *topicModel = _dataArrayM[i];
            if (topicModel.topicid.length > 0) {
                starttopicid = topicModel.topicid;
                break;
            }
        }
    }

    NSString *url = nil;
    if (_topicType == TopicListTypeHot) {
        url = API_index_hot_list(starttopicid, endtopicid, len, @"up");
    }else{
       
        url = API_Index_Follow_List(starttopicid, endtopicid, len, @"up");
    }
    
    WSLog(@"++下拉+++%@",url);
    [[RequestTools getInstance]get:url isCache:NO completion:^(NSDictionary *dict) {
        NSArray *list = dict[@"data"][@"list"];
        NSArray *topicids = dict[@"data"][@"deletelist"];
        
        NSInteger showtuijianlist = [dict[@"data"][@"showtuijianlist"]intValue];
        if (showtuijianlist == 1) {
            NSDictionary *tuijianDic = dict[@"data"][@"tuijianlist"];
            if (!_followController) {
                 _followController = [[RecommendFollowVController alloc]init];
            }
            _followController.type = 1;
            _followController.controller = (BaseController *)self.topicDelegate;
            [self.view addSubview:_followController.view];
            [_followController initModels:tuijianDic];
        }else{
            [_followController.view removeFromSuperview];
            _followController = nil;
            //通过服务器返回的topicid删去本地的主题
            [self deleteTopicWithID:topicids];
            NSArray *models = [TopicModel getTopicModelsWithArray:list];
            NSMutableArray *modelsM = [NSMutableArray arrayWithArray:models];
            if (modelsM.count > 0) {
                [_cacheJsonArray removeAllObjects];
                //缓存数组存储最新的json数据。
                [_cacheJsonArray addObjectsFromArray:list];
                
                //如何_hotArrayM里有数据，就需要滑动到index.Row == models.count
                //如果是好友列表，需要过滤掉本地topicid里面的
                
                if (_topicType == TopicListTypeFollow) {
                    for (NSString *localid in _cacheSendTopicArray) {
                        for (int i = 0; i < modelsM.count; i ++) {
                            TopicModel *model = _dataArrayM [i];
                            if ([model.localid isEqualToString:localid]) {
                                [modelsM removeObject:model];
                                break;
                            }
                        }
                    }
                }
                //如何刷新获得model个数n大于零，就滚动到第n行。只有第一加载数据列外。
                if (modelsM.count > 0) {
                    if (!_isFirstLoad) {
                        [self bk_performBlock:^(id obj) {
                            CGRect  popoverRect = [_mainTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:modelsM.count inSection:0]];
                            [_mainTable setContentOffset:CGPointMake(0,popoverRect.origin.y - 160) animated:NO];
                        } afterDelay:0.1];
                    }else{
                        _isFirstLoad = NO;
                        [_dataArrayM removeAllObjects];
                    }
                    
                    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, modelsM.count)];
                    //在数组头部，插入新数据
                    [_dataArrayM insertObjects:modelsM atIndexes:set];
                    [_mainTable reloadData];
                    
                    //如何是第一次刷新，并且是请求关注列表，关注列表的数为空时，加载推荐列表
                    
                }
            }
        }
        if (_topicType == TopicListTypeHot) {
            [[RequestTools getInstance] doSetNewhottopiccount:@"0"];
        }else{
            [[RequestTools getInstance] doSetNewfollowtopiccount:@"0"];
            [((HomeController *)_topicDelegate).focusDotView setHidden:YES];
        }

    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [_mainTable headerEndRefreshing];
        _currentPlayCell = nil;
        [self bk_performBlock:^(id obj) {
            [self getcurrentPlayCell];
        } afterDelay:0.2];
    }];
}


-(void)loadMoreData{
     int len = 17;
       NSString *starttopicid = @"";
       NSString *endtopicid = @"";
    if (_dataArrayM!=nil && _dataArrayM.count>0) {
        starttopicid=CheckNilValue([(TopicModel *)[_dataArrayM lastObject] topicid]);
        endtopicid=CheckNilValue([(TopicModel *)[_dataArrayM firstObject] topicid]);
    }
    [[AWEasyVideoPlayer sharePlayer]stop];
    [[AWEasyVideoPlayer sharePlayer]removeFromSuperview];
    
    NSString *url = nil;
    if (_topicType == TopicListTypeHot) {
        url = API_index_hot_list(starttopicid, endtopicid, len, @"down");
    }else{
        url = API_Index_Follow_List(starttopicid, endtopicid, len, @"down");
    }
    
    WSLog(@"++上拉+%@++%@",endtopicid,url);
    [[RequestTools getInstance]get:url isCache:NO completion:^(NSDictionary *dict) {
       NSArray *list = dict[@"data"][@"list"];
       NSArray *topicids = dict[@"data"][@"deletelist"];
       //通过服务器返回的topicid删去本地的主题
       [self deleteTopicWithID:topicids];
       NSArray *models = [TopicModel getTopicModelsWithArray:list];
       if (models.count > 0) {
           [_dataArrayM addObjectsFromArray:models];
           [_mainTable reloadData];
       }

    } failure:^(ASIHTTPRequest *request, NSString *message) {
       
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
       _currentPlayCell = nil;
       [_mainTable footerEndRefreshing];
       [self bk_performBlock:^(id obj) {
           [self getcurrentPlayCell];
       } afterDelay:0.1];
    }];
 }

#pragma mark TopicDelegate
//关注页面的位置，话题 title点击
- (void)topicThemeTitleOrLocationClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicThemeTitleOrLocationClick:)]) {
        [_topicDelegate topicThemeTitleOrLocationClick:topicModel];
    }
}
//关注页面的位置，话题 item 点击
- (void)topicLocationAndHuaTiClick:(NSString *)topicid{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicLocationAndHuaTiClick:)]) {
        [_topicDelegate topicLocationAndHuaTiClick:topicid];
    }
}

- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
        [_topicDelegate topicAvatarOrNicknameClick:topicModel];
    }else{
    
    
    }
}
- (void)topicPhoneNameClick:(id)sender{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPhoneNameClick:)]) {
        [_topicDelegate topicPhoneNameClick:sender];
    }
}
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
        [_topicDelegate topicAtClick:name topicModel:topicModel];
    }else{
    
    }
}
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
        [_topicDelegate topicPoundSignClick:string topicModel:topicModel];
    }else{
    
    }
}

- (void)topicDetailClick:(TopicModel *)topicModel index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicDetailClick: index:)]) {
        [_topicDelegate topicDetailClick:topicModel index:index];
    }
}
- (void)topicCommentCountClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentCountClick:)]) {
        [_topicDelegate topicCommentCountClick:topicModel];
    }
}
- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex{
    [_dataArrayM replaceObjectAtIndex:index withObject:model];
    [_mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex isReload:(BOOL)isReload{
    [_dataArrayM replaceObjectAtIndex:index withObject:model];
}
- (void)topicCommentAvatarClick:(CommentModel *)commentModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentAvatarClick:)]) {
        [_topicDelegate topicCommentAvatarClick:commentModel];
    }
}
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint)commentPoint{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentContentClick:topicModel:image:duration:type:point:)]) {
        [_topicDelegate topicCommentContentClick:commentModel topicModel:topicModel image:image duration:duration type:type point:commentPoint];
    }
}
- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicLoctionClick:topic:)]) {
        [_topicDelegate topicLoctionClick:location topic:topicModel];
    }
}
//分享类型的按钮点击
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicShareButtonClick:type:index:)]) {
        [_topicDelegate topicShareButtonClick:topicModel type:type index:index];
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
//转发的用户名称点击
- (void)topicReportUserNameClick:(NSString *)userID nickName:(NSString *)name{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicReportUserNameClick:nickName:)]) {
        [_topicDelegate topicReportUserNameClick:userID nickName:name];
    }
}
- (void)dealloc
{
    [NOTIFICATION_CENTER removeObserver:self];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
