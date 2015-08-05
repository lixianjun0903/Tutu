//
//  InfoTopicListController.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "InfoTopicListController.h"
#import "SynchMarkDB.h"
#import "CoverHeaderView.h"

#define dentifierCoverHeaderView @"CoverHeaderView"
#define staticTopicCollectionViewCell @"TopicCollectionViewCell"

@interface InfoTopicListController (){
    NSMutableArray *listArray;
    
    CGFloat w;
    CGFloat h;
    CGFloat itemSizeWith;
    CGFloat headerHeight;
}

@end

@implementation InfoTopicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    //设置视图到顶部
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    
    itemSizeWith=(w-20)/3;
    headerHeight=426;
    
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection              = UICollectionViewScrollDirectionVertical;
    
    layout.itemSize                     = CGSizeMake(itemSizeWith, itemSizeWith);
    layout.minimumInteritemSpacing      = 5;
    layout.minimumLineSpacing           = 5;
    layout.sectionInset                 = UIEdgeInsetsMake( 5, 5, 5, 5);
    self.listCollectionView.collectionViewLayout = layout;
    self.listCollectionView.alwaysBounceVertical  =YES;
    self.listCollectionView.backgroundColor       = [UIColor clearColor];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([TopicCollectionViewCell class])  bundle:[NSBundle mainBundle]];
    [self.listCollectionView registerNib:cellNib forCellWithReuseIdentifier:staticTopicCollectionViewCell];
    
    UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([CoverHeaderView class])  bundle:[NSBundle mainBundle]];
    [self.listCollectionView registerNib:headerNib forSupplementaryViewOfKind :UICollectionElementKindSectionHeader  withReuseIdentifier: dentifierCoverHeaderView ];  //注册加载头
}

-(void) setTitleHeight:(CGFloat)height{
    headerHeight=height;
    [self reloadTableData];
}

-(void)setLocalData:(NSMutableArray *)arr{
    listArray=arr;
    [self reloadTableData];
}

#pragma 数据查询
-(void)refreshData{
    if(self.isMySelf){
        [self refreshMyInfo];
    }else{
        [self refreshOtherInfo];
    }
}

-(void)loadMoreData{
    if(self.isMySelf){
        [self loadMyListData];
    }else{
        [self loadOtherListData];
    }
}

-(void)refreshMyInfo{
    
    SynchMarkDB *db=[[SynchMarkDB alloc] init];
    NSString *time=[db findWidthUID:SynchMarkTypeUserInfo];
    
    NSString *api=[NSString stringWithFormat:@"%@?localupdatetime=%@",API_GET_SELFINFO,time];
    
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        //        WSLog(@"%@",dict);
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            NSDictionary *item=[dict objectForKey:@"data"];
            NSDictionary *userinfoDict = dict[@"data"][@"userinfo"];
            if(userinfoDict==nil || [userinfoDict isKindOfClass:[NSArray class]]){
                return ;
            }
            UserInfo *dictUser=[[LoginManager getInstance] parseDictData:userinfoDict];
            if(dictUser!=nil && dictUser.uid!=nil){
                self.user=dictUser;
                
                [[LoginManager getInstance] saveInfoToDB:dictUser];
                
                //保存更新时间
                NSString *time=[item objectForKey:@"updatetime"];
                [db saveSynchData:SynchMarkTypeUserInfo withTime:time];
                
            }
        
            [listArray removeAllObjects];
            TopicCacheDB *db=[[TopicCacheDB alloc] init];
            if(self.dataType==1){
                NSMutableArray *sendModels=[db getCacheListWithType:TopicStatusSend];
                [listArray addObjectsFromArray:sendModels];
            }else if(self.dataType==2){
                
                NSMutableArray *favModels=[db getCacheListWithType:TopicStatusCollection];
                [listArray addObjectsFromArray:favModels];
            }
            [self reloadTableData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"%@",request.responseString);
        if(self.listCollectionView.isHeaderRefreshing){
            [self.listCollectionView headerEndRefreshing];
        }
    }];
}
-(void)refreshOtherInfo{
    NSString *api=[NSString stringWithFormat:@"%@&%@&nickname=%@",API_GET_USERINFO(self.uid),
                   @"gettopiclist=1&len=21&richtopicinfo=1",self.nickname];
    
    [[RequestTools getInstance] get:api isCache:YES completion:^(NSDictionary *dict) {
        //        WSLog(@"%@",dict);
        if(self.dataType==1){
            if(!dict[@"data"][@"topiclist"] || ![dict[@"data"][@"topiclist"] isKindOfClass:[NSArray class]]){
                return;
            }
        }else{
            if(!dict[@"data"][@"favlist"] || ![dict[@"data"][@"favlist"] isKindOfClass:[NSArray class]]){
                return;
            }
        }
        if(self.dataType==1){
            NSArray *datas1 = dict[@"data"][@"topiclist"];
            NSArray *topicModels1 = [TopicModel getTopicModelsWithArray:datas1];
            [listArray addObjectsFromArray:topicModels1];
        }else if(self.dataType==2){
            NSArray *datas2 = dict[@"data"][@"favlist"];
            NSArray *topicModels2 = [TopicModel getTopicModelsWithArray:datas2];
            [listArray addObjectsFromArray:topicModels2];
        }
        [self reloadTableData];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        //        WSLog(@"%@",request.responseString);
        if(self.listCollectionView.isHeaderRefreshing){
            [self.listCollectionView headerEndRefreshing];
        }
    }];
}


-(void)loadMyListData{
    // 当dataType为2的时候，重新赋值
    NSString *startTime=@"";
    NSString *endTime=@"";
    NSString *updateTime=@"";
    NSString *locallisttype=@"";
    
    SynchMarkDB *synchDB=[[SynchMarkDB alloc] init];
    if(self.dataType==2){
        locallisttype=@"favlist";
        updateTime=[synchDB findWidthUID:SynchMarkTypeTopicCollection];
    }else{
        locallisttype=@"publishlist";
        updateTime=[synchDB findWidthUID:SynchMarkTypeTopicSend];
    }
    if(listArray!=nil && listArray.count>0){
        startTime=((TopicModel *)[listArray objectAtIndex:0]).time;
        endTime=((TopicModel *)[listArray objectAtIndex:(listArray.count-1)]).time;
    }

    NSString *api=API_GET_SelfUSER_TOPIC(startTime, endTime, updateTime, locallisttype);
    
    
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        //        WSLog(@"%@",dict);
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            NSArray *adddatas = dict[@"data"][@"addlist"];
            NSArray *delList = dict[@"data"][@"dellist"];
            NSArray *topicModels=nil;
            if(dict[@"data"][@"addlist"] && [dict[@"data"][@"addlist"] isKindOfClass:[NSArray class]]){
                topicModels =[TopicModel getTopicModelsWithArray:adddatas];
            }
            NSArray *delTopicModels=nil;
            if(dict[@"data"][@"dellist"] && [dict[@"data"][@"dellist"] isKindOfClass:[NSArray class]]){
                delTopicModels = [TopicModel getTopicModelsWithArray:delList];
            }
            
            TopicCacheDB *db=[[TopicCacheDB alloc] init];
            SynchMarkDB *synchDB=[[SynchMarkDB alloc] init];
            //保存更新时间
            NSString *updateTime=dict[@"data"][@"updatetime"];
            
            if(self.dataType==1){
                [synchDB saveSynchData:SynchMarkTypeTopicSend withTime:updateTime];
                if(topicModels!=nil && topicModels.count>0){
                    for (TopicModel *item in topicModels) {
                        item.topicStatus=@"3";
                        item.topicType=@"0";
                        [db saveTopic:item];
                    }
                }
                if(delTopicModels !=nil && delTopicModels.count>0){
                    for (TopicModel *item in delTopicModels) {
                        [db deleteTopicByTopicID:item.topicid withType:TopicStatusSend];
                    }
                }
                
                NSMutableArray *arr=[db getCacheListWithType:TopicStatusSend];
                if(arr!=nil){
                    [listArray removeAllObjects];
                    [listArray addObjectsFromArray:arr];
                }
            }else{
                [synchDB saveSynchData:SynchMarkTypeTopicCollection withTime:updateTime];
                if(topicModels!=nil && topicModels.count>0){
                    for (TopicModel *item in topicModels) {
                        item.topicStatus=@"4";
                        item.topicType=@"0";
                        [db saveTopic:item];
                    }
                }
                if(delTopicModels !=nil && delTopicModels.count>0){
                    for (TopicModel *item in delTopicModels) {
                        [db deleteTopicByTopicID:item.topicid withType:TopicStatusCollection];
                    }
                }
                
                NSMutableArray *arr=[db getCacheListWithType:TopicStatusCollection];
                if(arr!=nil){
                    [listArray removeAllObjects];
                    [listArray addObjectsFromArray:arr];
                }
            }
        }
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:@"" bgColor:TopNotice_Red_Color];
        
    } finished:^(ASIHTTPRequest *request) {
        if([self.listCollectionView isFooterRefreshing]){
            [self.listCollectionView footerEndRefreshing];
        }
        [self reloadTableData];
        
    }];
}

-(void)loadOtherListData{
    NSString *topicid=@"";
    if(listArray!=nil && listArray.count>0){
        topicid=((TopicModel *)[listArray lastObject]).topicid;
    }
    
    NSString *api=API_GET_USER_TOPIC(self.uid,topicid, @"21");
    
    // 当dataType为2的时候，重新赋值
    if(self.dataType==2){
        api=API_TOPIC_FAVORITE_LIST(21,Load_MORE,topicid);
    }
    api=[NSString stringWithFormat:@"%@&richtopicinfo=1",api];
    
    [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
        if(dict && [[dict objectForKey:@"code"] intValue]==10000){
            NSArray *datas = dict[@"data"][@"list"];
            NSArray *topicModels = [TopicModel getTopicModelsWithArray:datas];
            if (topicModels.count > 0) {
                [listArray addObjectsFromArray:topicModels];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
        [self showNoticeWithMessage:message message:@"" bgColor:TopNotice_Red_Color];
        
    } finished:^(ASIHTTPRequest *request) {
        
        if([self.listCollectionView isFooterRefreshing]){
            
            [self.listCollectionView footerEndRefreshing];
        }
        [self reloadTableData];
    }];
}

-(void)reloadTableData{
    [self.listCollectionView reloadData];
}




#pragma mark 代理开始
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(w, headerHeight);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)itemcollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CoverHeaderView *view = [itemcollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:dentifierCoverHeaderView forIndexPath:indexPath];
    
    [view setBackgroundColor:[UIColor clearColor]];
    [view setTitle:@""];
    [view setAccessibilityViewIsModal:YES];
//    [view setTitle:[NSString stringWithFormat:@"·%@",dataArr[indexPath.section][@"typename"]]];
    return view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return listArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TopicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:staticTopicCollectionViewCell forIndexPath:indexPath];
    
    TopicModel *item=[listArray objectAtIndex:indexPath.row];
    [cell dataToView:item width:itemSizeWith];
    
    return cell;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
    TopicDetailListController *rvc = [[TopicDetailListController alloc] init];
    
    rvc.currentIndex = indexPath.row;
    
    rvc.dataArray = listArray;
    if(self.dataType==1){
        rvc.topicType=TopicTypeList;
    }else if(self.dataType==2){
        rvc.topicType=TopicTypeFavoriteList;
    }
    
    rvc.uid = self.uid;
    
    rvc.delegate = self;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(openController:)]){
        [self.delegate openController:rvc];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



#pragma mark 调用父类相关代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(topicScrollDidView:)]){
        [self.delegate topicScrollDidView:scrollView];
    }
}



#pragma mark 主题详情代理
- (void)topicModelsChange:(NSArray *)topicModels{
    [listArray removeAllObjects];
    [listArray addObjectsFromArray:topicModels];
    
    [self reloadTableData];
    
}

- (void)favoriteModelsChange:(NSArray *)models{
    
    [listArray removeAllObjects];
    
    [listArray addObjectsFromArray:models];
    
    [self reloadTableData];
}

- (void)deleteTopicModelAtIndex:(NSInteger)index{
    if(listArray.count>index){
        [listArray removeObjectAtIndex:index];
        self.dataType = 1;
        if(self.user!=nil){
            self.user.topicnum=self.user.topicnum-1;
            if(self.user.topicnum<0){
                self.user.topicnum=0;
            }
        }
        [self reloadTableData];
    }
}

- (void)deleteFavoriteAtIndex:(NSInteger)index{
    if(listArray.count>index){
        self.dataType = 2;
        [listArray removeObjectAtIndex:index];
        if(self.user!=nil){
            self.user.favnum=self.user.favnum-1;
            if(self.user.favnum<0){
                self.user.favnum=0;
            }
        }
        [self reloadTableData];
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
