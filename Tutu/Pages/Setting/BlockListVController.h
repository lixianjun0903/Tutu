//
//  BlockListVController.h
//  Tutu
//
//  Created by gexing on 14/11/24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

typedef NS_ENUM(NSInteger, BlockType) {
    BlockTypeMessage,//屏蔽私信
    BlockTypeTopic,//屏蔽主题
};


#import "BaseController.h"
#import "MyFriendCell.h"
@interface BlockListVController : BaseController<SWTableViewCellDelegate,MyFriendCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

//type为0是屏蔽私信列表，1是屏蔽主题列表
@property(nonatomic)BlockType blockType;
@property(nonatomic,strong)NSMutableArray *dataArray;
@end
