//
//  TopicDetailController.h
//  Tutu
//
//  Created by feng on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "TopicModel.h"
#import "SendTopicDelegate.h"
#import "TopicCell.h"
#import "CommentTableCell.h"
#define DetailTabeleContentOffsetY                (ScreenWidth + 65)
@protocol TopicDetailControllerDelegate <NSObject>

- (void)deleteTopicAtIndex:(NSInteger)index;

@end
@interface TopicDetailController : BaseController<SendTopicDelegate,UITableViewDataSource,UITableViewDelegate,SendTopicDelegate,TopicDelegate,UIScrollViewDelegate>

@property(nonatomic,retain) TopicModel *topicModel;

@property(nonatomic)NSInteger tableIndex;

@property(nonatomic) NSInteger commentAvatarIndex;
@property(nonatomic,strong) NSString *topicid;
@property(nonatomic)NSInteger comefrom;//当从动态页，推送跳转过来是，comeFrom == 1,需要通过topicid，去加载topic，如果不存在，显示主题被删除。
@property(nonatomic)NSInteger indexRow;
@property(nonatomic,strong)UITableView *mainTable;
@property(nonatomic,strong) NSString *direction;
@property(nonatomic,strong)NSString *startcommentid;
@property(nonatomic,strong)NSString *uid;

@property(nonatomic,weak) id <TopicDelegate> topicDelegate;

@property(nonatomic,strong)TopicCell *topicCell;


@property(nonatomic,strong)UIButton *commentButton;
@property(nonatomic)BOOL isVisibled;

@property(nonatomic)BOOL isTopicDetailListView;//是否是从详情列表页面跳转过来

- (void)hidenCommentButton;
- (void)showCommentButton;
- (void)resetTableContentOffset:(BOOL) animation;
@end
