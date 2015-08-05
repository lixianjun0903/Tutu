//
//  TopicsGeneralController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TopicsGeneralController.h"

#import "UserDetailController.h"
#import "ListTopicsController.h"
#import "ShareTutuFriendsController.h"
#import "SVWebViewController.h"

#define cellIdentifier @"TopicCell"


@interface TopicsGeneralController (){
    CGFloat w;
    CGFloat h;
    NSTimer *animationTimer;
}

@end

@implementation TopicsGeneralController

@synthesize showType;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    
    if(_array==nil){
        _array=[[NSMutableArray alloc] init];
    }
    
    [self.listTable setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [self.listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.listTable.showsVerticalScrollIndicator = YES;
    [self.listTable setSeparatorColor:[UIColor clearColor]];
    
    UIView *header=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 140)];
    [header setBackgroundColor:[UIColor clearColor]];
    [self.listTable setTableHeaderView:header];
    
    
    [self.listTable addHeaderWithTarget:self action:@selector(refreshData)];
    [self.listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    [self addNotificationObserver];
}


#pragma mark 外部使用的方法
-(CGPoint)currentContentOffset{
    return self.listTable.contentOffset;
}



#pragma mark 加载数据
//外部设置
-(void)setDataToView:(NSMutableArray *)arr{
    _array=arr;
    [self.listTable reloadData];
}

// 顶部刷新
-(void)refreshData{
    
    NSString *starttopicid=@"";
    if(_array!=nil && _array.count>0){
        TopicModel *item=[_array objectAtIndex:0];
        starttopicid=item.topicid;
    }
    
    
    NSString *sorttype=@"";
    if(showType==1){
        sorttype=@"hot";
    }else if(showType==2){
        sorttype=@"new";
    }
    
    
    NSString *apiURL=@"";
    
    if(self.pageType==TopicWithDefault){
        apiURL=API_GET_TOPIC_LIST(self.topicString, sorttype, starttopicid, @"20", Load_UP);
        if([@"new" isEqual:sorttype]){
            if(_array==nil || _array.count==0){
                starttopicid= CheckNilValue(self.startid);
                apiURL=API_GET_TOPIC_LIST(self.topicString, sorttype, starttopicid, @"20", Load_MORE);
                apiURL=[NSString stringWithFormat:@"%@%@",apiURL,@"&iscontain=1"];
            }
        }
    }
    if(self.pageType==TopicWithPoiPage){
        apiURL=API_GET_POI_TOPIC_LIST(self.topicString, sorttype, starttopicid, @"20", Load_UP);
        if([@"new" isEqual:sorttype]){
            if(_array==nil || _array.count==0){
                starttopicid= CheckNilValue(self.startid);
                apiURL=API_GET_POI_TOPIC_LIST(self.topicString, sorttype, starttopicid, @"20", Load_MORE);
                apiURL=[NSString stringWithFormat:@"%@%@",apiURL,@"&iscontain=1"];
            }
        }
    }
    WSLog(@"%@",apiURL);
    [[RequestTools getInstance] get:apiURL isCache:NO completion:^(NSDictionary *dict) {
        FocusTopicModel *focusModel = [[FocusTopicModel alloc] initWithMyDict:[dict objectForKey:@"data"]];
        if(self.delegate && [self.delegate respondsToSelector:@selector(loadDataByNet:)]){
            [self.delegate loadDataByNet:focusModel];
        }
        if(focusModel!=nil && focusModel.ids!=nil && focusModel.topiclist!=nil){
            for (int i=((int)focusModel.topiclist.count-1);i>=0;i--) {
                [_array insertObject:[focusModel.topiclist objectAtIndex:i] atIndex:0];
            }
            [self reloadTableData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
//        WSLog(@"%@",message);
    } finished:^(ASIHTTPRequest *request) {
//        WSLog(@"%@",request.responseString);
        if([self.listTable isHeaderRefreshing]){
            [self.listTable headerEndRefreshing];
        }
    }];
}

// 底部刷新
-(void)loadMoreData{
    NSString *sorttype=@"";
    if(showType==1){
        sorttype=@"hot";
    }else if(showType==2){
        sorttype=@"new";
    }
    NSString *starttopicid=@"";
    if(_array!=nil && _array.count>0){
        TopicModel *item=[_array objectAtIndex:_array.count-1];
        starttopicid=item.topicid;
    }
    
    NSString *apiURL=@"";
    if(self.pageType==TopicWithDefault){
        apiURL=API_GET_TOPIC_LIST(self.topicString, sorttype, starttopicid, @"20", Load_MORE);
    }
    if(self.pageType==TopicWithPoiPage){
        apiURL=API_GET_POI_TOPIC_LIST(self.topicString, sorttype, starttopicid, @"20", Load_MORE);
    }
    
    
    [[RequestTools getInstance] get:apiURL isCache:NO completion:^(NSDictionary *dict) {
//        WSLog(@"%@",dict);
        FocusTopicModel *focusModel = [[FocusTopicModel alloc] initWithMyDict:[dict objectForKey:@"data"]];
        if(self.delegate && [self.delegate respondsToSelector:@selector(loadDataByNet:)]){
            [self.delegate loadDataByNet:focusModel];
        }
        
        if(focusModel!=nil && focusModel.ids!=nil && focusModel.topiclist!=nil){
            [_array addObjectsFromArray:focusModel.topiclist];
            [self reloadTableData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([self.listTable isFooterRefreshing]){
            [self.listTable footerEndRefreshing];
        }
    }];
}

-(void)reloadTableData{
    [self.listTable reloadData];
    if(_currentPlayCell==nil){
        [self bk_performBlock:^(id obj) {
            [self getcurrentPlayCell];
        } afterDelay:0.1f];
    }
    if(self.startid!=nil && showType==2){
        self.startid=nil;
        [self.listTable setContentOffset:CGPointMake(0, 100) animated:YES];
    }
}



- (void)addNotificationObserver{
    //监测当前用户昵称变化/或者备注的变更
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeUserName:) name:NOTICE_UPDATE_UserInfo object:nil];
    
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(pauseTimer) name:Comment_Scroll_BeginDragging object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSend:) name:Notification_Topic_Comment_Send object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSendSuccess:) name:Notifcation_Topic_Comment_Send_Success object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(commentSendFailed:) name:Notifcation_Topic_Comment_Send_Failed object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(deleteMyTopic:) name:Notification_Delete_My_Topic object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changeCollectionStatus:) name:Notification_Change_Collection_status object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(blockSomebodyTopic:) name:NOTIFICATION_BLOCK_USER_TOPIC object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(downloadVedioSuccess:) name:NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS object:nil];
    
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
    animationTimer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(scrollCommentView) userInfo:nil repeats:YES];
    [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[NSRunLoop currentRunLoop]addTimer:animationTimer forMode:NSDefaultRunLoopMode];
    [animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL]];
    
}

- (void)scrollCommentView{
    if(_currentPlayCell){
        [_currentPlayCell scrollAvatarAndComment];
    }
}

-(void)setIsVisible:(BOOL)isVisible{
    _isVisible=isVisible;
    
    if(!_isVisible){
        if(_currentPlayCell){
            [_currentPlayCell stopVideo];
            _currentPlayCell.isTargetCell=NO;
        }
        [self pauseTimer];
    }else{
        [self.listTable reloadData];
        [self beginPlayCell];
    }
}

- (void)beginPlayCell{
    if (_isVisible) {
        [self getcurrentPlayCell];
    }
}
-(void)downloadVedioSuccess:(NSNotification *) info{
    if(_currentPlayCell!=nil && [info.object isEqual:_currentPlayCell.topicModel.videourl]){
        [self bk_performBlock:^(id obj) {
            if (_isVisible) {
                [_currentPlayCell  playVideo];
            }
        } afterDelay:0.1];
    }
}

//获得当前页面中的播放视频的cell
-(void)getcurrentPlayCell{
    NSArray *visibleCells = self.listTable.visibleCells;
    TopicCell *cell = nil;
    if (visibleCells.count == 1) {
        cell = visibleCells[0];
    }else if (visibleCells.count == 3){
        cell = visibleCells[1];
    }else if (visibleCells.count == 2){
        
        TopicCell *cell0 = visibleCells[0];
        TopicCell *cell1 = visibleCells[1];
        CGPoint point0 = [cell0 convertPoint:CGPointMake(0, 0) toView:ApplicationDelegate.window];
        CGPoint point1 = [cell1 convertPoint:CGPointMake(0, 0) toView:ApplicationDelegate.window];
        cell = (self.view.mj_height - fabs(point0.y)) > (self.view.mj_height - fabs(point1.y)) ? cell0 : cell1;
    }
    
    
    if(cell!=nil && _currentPlayCell!=nil && [cell isEqual:_currentPlayCell] && _currentPlayCell.isTargetCell){
        if(!_currentPlayCell.isTargetCell){
            _currentPlayCell.isTargetCell = YES;
            if (_isVisible) {
                [self fireTimer];
                [_currentPlayCell playVideo];
            }
        }
        return;
    }
    
    if (cell != nil && ![cell isEqual:_currentPlayCell]) {
        if ([_currentPlayCell isKindOfClass:[TopicCell class]]) {
            [_currentPlayCell stopVideo];
            [self stopTimer];
            _currentPlayCell.isTargetCell = NO;
            _currentPlayCell=nil;
        }
    }
    if ([cell isKindOfClass:[TopicCell class]]) {
        _currentPlayCell = cell;
        _currentPlayCell.isTargetCell = YES;
        if (_isVisible) {
            [self fireTimer];
            [_currentPlayCell playVideo];
        }
    }
}
//变更主题列表中用户的昵称
- (void)changeUserName:(NSNotification *)notification{
    UserInfo *userInfo = [notification object];
    for (int i = 0; i < self.array.count; i ++) {
        TopicModel *model = self.array[i];
        if ([model.uid isEqualToString:userInfo.uid]) {
            model.nickname = userInfo.nickname;
            [self.array replaceObjectAtIndex:i withObject:model];
        }
    }
    [self.listTable reloadData];
}
//改变用户收藏主题的状态
- (void)changeCollectionStatus:(NSNotification *)notification{
    TopicModel *topicModel = [notification object];
    for (int i = 0; i < self.array.count; i ++) {
        TopicModel *model = self.array[i];
        if ([model.topicid isEqualToString:topicModel.topicid]) {
            [self.array replaceObjectAtIndex:i withObject:topicModel];
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
    for (int i = 0;i < self.array.count; i ++) {
        TopicModel *model = self.array[i];
        if ([model.uid isEqualToString:uid]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
            [indexSet addIndex:i];
        }
    }
    [self.array removeObjectsAtIndexes:indexSet];
    [self.listTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self bk_performBlock:^(id obj) {
        [self getcurrentPlayCell];
    } afterDelay:0.1f];
}

#pragma mark 评论发布后收到通知的处理
#pragma mark 评论发布后收到通知的处理
- (void)commentSend:(NSNotification *)notification{
    CommentModel *model = [notification object];
    if (model.comeFrom == 3) {
        NSString *topicID= model.topicid;
        for (int i = 0; i < self.array.count; i ++) {
            NSString * topic_id = ((TopicModel *)self.array[i]).topicid;
            if ([topic_id isEqualToString:topicID]) {
                TopicCell *cell = (TopicCell *)[self.listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                TopicModel *topicmodel = self.array[i];
                if (topicmodel.commentList) {
                    [topicmodel.commentList addObject:model];
                }else{
                    topicmodel.commentList = [NSMutableArray arrayWithObject:model];
                }
                topicmodel.commentnum = [NSString stringWithFormat:@"%ld",(long)[topicmodel.commentnum integerValue] + 1];
                [self.array replaceObjectAtIndex:i withObject:topicmodel];
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
    if (comeFrom == 3) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *arr = dict[@"data"][@"commentlist"];
            NSString * count = CheckNilValue(dict[@"data"][@"total"]);
            NSString *topicID= CheckNilValue(dict[@"data"][@"topicid"]);
            for (int i = 0; i < self.array.count; i ++) {
                topic_id = ((TopicModel *)self.array[i]).topicid;
                if ([topic_id isEqualToString:topicID]) {
                    NSArray *models = [CommentModel getCommentModelList:arr];
                    TopicCell *cell = (TopicCell *)[self.listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    TopicModel *model = self.array[i];
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
                    [self.array replaceObjectAtIndex:i withObject:model];
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
        for (int i = 0; i < self.array.count; i ++) {
            TopicModel *model = self.array[i];
            if ([model.topicid isEqualToString:topicModel.topicid]) {
                [self.array removeObjectAtIndex:i];
                [self.listTable reloadData];
                [self bk_performBlock:^(id obj) {
                    [self getcurrentPlayCell];
                } afterDelay:0.1f];
                break;
            }
        }
    }else{
        for (int i = 0; i < self.array.count; i ++) {
            TopicModel *model = self.array[i];
            if ([model.topicid isEqualToString:topicModel.localid]) {
                [self.array removeObjectAtIndex:i];
                [self.listTable reloadData];
                [self bk_performBlock:^(id obj) {
                    [self getcurrentPlayCell];
                } afterDelay:0.1f];
                break;
            }
        }
    }
    
}


#pragma mark 监听滚动事件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(_currentPlayCell!=nil){
        CGPoint point0 = [_currentPlayCell convertPoint:CGPointMake(0, 0) toView:ApplicationDelegate.window];
        CGFloat th=h-NavBarHeight-fabs(point0.y);
        if(th<(h-NavBarHeight)/2){
            [_currentPlayCell stopVideo];
            [self stopTimer];
            _currentPlayCell.isTargetCell = NO;
        }
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(![scrollView isDecelerating] && ![scrollView isDragging]){
        [self getcurrentPlayCell];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self getcurrentPlayCell];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_currentPlayCell!=nil){
        CGPoint point0 = [_currentPlayCell convertPoint:CGPointMake(0, 0) toView:ApplicationDelegate.window];
        CGFloat th=h-NavBarHeight-fabs(point0.y);
        if(th<(h-NavBarHeight)/2){
            [_currentPlayCell stopVideo];
            [self stopTimer];
            _currentPlayCell.isTargetCell = NO;
            _currentPlayCell=nil;
        }
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(generalScrollDid:type:)]){
        [self.delegate generalScrollDid:scrollView type:self.showType];
    }
}


#pragma mark dataDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

//别忘了设置高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicCell *cell = (TopicCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.topicDelegate = self;
    cell.cellIndex = indexPath.row;
    cell.isDetail = NO;//不需要展开
    [cell loadCellWithModel:[_array objectAtIndex:indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicModel *model = _array[indexPath.row];
    CGFloat height = [TopicCell getCellHeight:model isDetail:NO];
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark TopicDelegate
- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = topicModel.uid;
    vc.user = topicModel.userinfo;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:vc];
    }
}
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel{
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.nickName=[name stringByReplacingOccurrencesOfString:@"@" withString:@""];
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:detail];
    }
}
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=string;
    control.pageType=TopicWithDefault;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:control];
    }
}
- (void)topicDetailClick:(TopicModel *)topicModel{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicModel = topicModel;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:vc];
    }
}

- (void)topicCommentCountClick:(TopicModel *)topicModel{
    TopicDetailController *vc = [[TopicDetailController alloc]init];
    vc.topicModel = topicModel;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:vc];
    }
}
- (void)topicLikeCountClick:(TopicModel *)topicModel index:(NSInteger)index{
    [_array replaceObjectAtIndex:index withObject:topicModel];
}
- (void)topicCommentAvatarClick:(CommentModel *)commentModel{
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.uid = commentModel.uid;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:detail];
    }
}
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint)commentPoint{
    ReleasePicViewController *vc=[[ReleasePicViewController alloc] init];
    vc.topicModel = topicModel;
    vc.pageType = type;
    vc.releaseImage = image;
    vc.commentModel = commentModel;
    vc.comeFrom = 3;
    vc.commentPoint=commentPoint;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:vc];
    }
    
}
- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString=topicModel.location;
    control.pageType=TopicWithPoiPage;
    control.poiid=topicModel.poiId;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:control];
    }
}
//分享类型的按钮点击
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index{
    if (type == ActionSheetTypeTutu) {
        ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
        vc.uid = [[LoginManager getInstance] getUid];
        vc.topicModel=topicModel;
        if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
            [self.delegate openNewController:vc];
        }
    }
}
//话题的更多点击
- (void)topicHuaTiMoreClick:(TopicModel *)topicModel{
    SVWebViewController *vc = [[SVWebViewController alloc]initWithURL:StrToUrl(topicModel.morelink)];
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:vc];
    }
}
//莫个话题点击
- (void)topicHuaTiClick:(TopicModel *)topicModel index:(NSInteger)index{
    ListTopicsController *control=[[ListTopicsController alloc] init];
    control.topicString = [topicModel.huatilist[index] huatitext];
    control.pageType=TopicWithDefault;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openNewController:)]){
        [self.delegate openNewController:control];
    }
}
- (void)dealloc
{
    [NOTIFICATION_CENTER removeObserver:self];
}
#pragma mark - Navigation

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
