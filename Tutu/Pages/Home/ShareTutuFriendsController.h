//
//  ShareTutuFriendsController.h
//  Tutu
//
//  Created by gexing on 14/12/10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "NavBaseController.h"
#import "ShareCustomView.h"
#import "RCMessage.h"
#import "FocusTopicModel.h"

@interface ShareTutuFriendsController : NavBaseController<ShareCustomViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,RCSendMessageDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property(nonatomic,strong)NSString    *uid;
@property(nonatomic,strong)NSMutableArray *dataArray;

@property(nonatomic,strong)RCMessage *rcmsg;

@property(nonatomic,strong)NSString *message;

@property(nonatomic,strong)TopicModel *topicModel;

@property(nonatomic,strong)FocusTopicModel *focusModel;
@property(nonatomic,assign)int focusType;


@property(nonatomic) NSInteger comeForm;
@property(nonatomic,strong)ShareCustomView *shareView;
@end
