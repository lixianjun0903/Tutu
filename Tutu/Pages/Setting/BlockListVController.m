//
//  BlockListVController.m
//  Tutu
//
//  Created by gexing on 14/11/24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BlockListVController.h"
#import "UserDetailController.h"

#import "RCIMClient.h"

@interface BlockListVController ()
{
    NSInteger _length;
    NSString *_startuid;
}
@end
static NSString *cellIdentifier = @"MyFriendCell";
@implementation BlockListVController
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  //  [self setNavigationBarStyle];
    
    
    [self createTitleMenu];
    [self.menuRightButton setHidden:YES];
    
    _dataArray = [[NSMutableArray alloc]init];
    _length = 20;
    [_mainTable addHeaderWithTarget:self action:@selector(refreshData)];
    [_mainTable addFooterWithTarget:self action:@selector(loadMoreData)];
    _mainTable.separatorStyle = UITableViewCellSelectionStyleNone;
    _mainTable.rowHeight = 77;
    [_mainTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    _mainTable.frame = CGRectMake(0, NavBarHeight, ScreenWidth, SelfViewHeight - NavBarHeight);
    [self.view addSubview:_mainTable];
    if (_blockType == BlockTypeMessage) {
        [self.menuTitleButton setTitle:TTLocalString(@"TT_block_his(her)_message") forState:UIControlStateNormal];
    }else{
        [self.menuTitleButton setTitle:TTLocalString(@"TT_block_his(her)_content") forState:UIControlStateNormal];
    
    }
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    if (iOS7) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    }
    UIView *footView = [[UIView alloc]initWithFrame:CGRectZero];
    _mainTable.tableFooterView = footView;
    
    [_mainTable headerBeginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)refreshData{
    NSString *url = nil;
    if (_dataArray.count > 0) {
        _startuid = ((UserInfo *)_dataArray.firstObject).uid;
        if (_blockType == BlockTypeTopic) {
            url = [NSString stringWithFormat:@"%@len=%d&direction=up&startuid=%@",API_BLOCK_USER_TOPIC_LIST,_length,_startuid];
        }else{
            
            url = [NSString stringWithFormat:@"%@len=%d&direction=up&startuid=%@",API_BLOCK_USER_MESSAGE_LIST,_length,_startuid];
        }
    }else{
        if (_blockType == BlockTypeTopic) {
            url = [NSString stringWithFormat:@"%@len=%d&direction=up",API_BLOCK_USER_TOPIC_LIST,_length];
        }else{
            
            url = [NSString stringWithFormat:@"%@len=%d&direction=up",API_BLOCK_USER_MESSAGE_LIST,_length];
        }
    }

    [[RequestTools getInstance]get:url isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *list = dict[@"data"][@"list"];
            NSMutableArray *marray = [@[]mutableCopy];
            if (list.count > 0) {
                for (NSDictionary *dic in list) {
                    UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
                    [marray addObject:info];
                }
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                        NSMakeRange(0,[marray count])];
                [_dataArray insertObjects:marray atIndexes:indexSet];
                [_mainTable reloadData];
                
                if (_dataArray.count == 0) {
                    if (_blockType == BlockTypeTopic) {
                        [self createPlaceholderView:CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f - 64) message:TTLocalString(@"TT_you_not_block_any_content") withView:nil];
                    }else{
                        [self createPlaceholderView:CGPointMake(ScreenWidth / 2.0f, ScreenHeight / 2.0f - 64) message:TTLocalString(@"TT_have_not_hate_people") withView:nil];
                    }
                }else{
                    [self removePlaceholderView];
                }
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [_mainTable headerEndRefreshing];
    }];
}
- (void)loadMoreData{
    NSString *url = nil;
    if (_dataArray.count > 0) {
        _startuid = ((UserInfo *)_dataArray.lastObject).uid;
        if (_blockType == BlockTypeTopic) {
            url = [NSString stringWithFormat:@"%@len=%d&direction=down&startuid=%@",API_BLOCK_USER_TOPIC_LIST,_length,_startuid];
        }else{
            
            url = [NSString stringWithFormat:@"%@len=%d&direction=down&startuid=%@",API_BLOCK_USER_MESSAGE_LIST,_length,_startuid];
        }
    }
    [[RequestTools getInstance]get:url isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]integerValue] == 10000) {
            NSArray *list = dict[@"data"][@"list"];
            NSMutableArray *marray = [@[]mutableCopy];
            if (list.count > 0) {
                for (NSDictionary *dic in list) {
                    UserInfo *info = [[UserInfo alloc]initWithMyDict:dic];
                    [marray addObject:info];
                }
                [_dataArray addObjectsFromArray:marray];
                [_mainTable reloadData];
            }
        }
 
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [_mainTable headerEndRefreshing];
        [_mainTable footerEndRefreshing];
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyFriendCell *cell = (MyFriendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_blockType == BlockTypeMessage) {
        cell.cellType = CellTypeBlockMessage;
    }else{
        cell.cellType = CellTypeBlockTopic;
    }
    cell.cellDelegate = self;
    cell.delegate = self;
    if (_dataArray.count > indexPath.row) {
        UserInfo *model = _dataArray[indexPath.row];
        [cell cellReloadWithModel:model];
        [cell setRightUtilityButtons:[cell setRightButtons]];
    }
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}

#pragma mark SWTableViewCellDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_dataArray.count > indexPath.row) {
        UserInfo *model = _dataArray[indexPath.row];
        UserDetailController *vc = [[UserDetailController alloc]init];
        vc.uid = model.uid;
        [self.navigationController pushViewController:vc animated:YES];
    }

}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    
}

// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    if (index == 0) {
        MyFriendCell *mycell = (MyFriendCell *)cell;
        NSIndexPath *cellIndexpath = [_mainTable indexPathForCell:mycell];
        NSString *url = nil;
        if (_blockType == BlockTypeTopic) {
            
            url = API_UNBLOCK_USER_FEED(mycell.userModel.uid);
        }else{
               
            
            url = API_UNBLOCK(mycell.userModel.uid);
        }
        [[RequestTools getInstance]get:url isCache:NO completion:^(NSDictionary *dict) {
            if ([dict[@"code"]integerValue] == 10000) {
                [_dataArray removeObjectAtIndex:cellIndexpath.row];
                [_mainTable deleteRowsAtIndexPaths:@[cellIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
//            if(_blockType==BlockTypeMessage){
//                [[RCIMClient sharedRCIMClient] removeFromBlacklist:mycell.userModel.uid completion:^{
//                    
//                } error:^(RCErrorCode status) {
//                    
//                }];
//            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
        } finished:^(ASIHTTPRequest *request) {
        }];
    }
}

// utility button open/close event
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{
    
}

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

// prevent cell(s) from displaying left/right utility buttons
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{

    return YES;
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
