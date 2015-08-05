//
//  NewFriendViewController.m
//  Tutu
//
//  Created by gexing on 3/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "NewFriendViewController.h"
#import "UserDetailController.h"
#import "LoginManager.h"
#import "UIImage+ImageWithColor.h"
#import "UserInfoDB.h"
#import "ApplyFriendsController.h"
#import "ApplyLeaveDB.h"
#import "RequestTools.h"
@implementation FoodDeleteView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0; i < 2; i ++) {
            self.backgroundColor = [UIColor whiteColor];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(ScreenWidth / 2.0f * i, 0,ScreenWidth / 2.0f , 45);
            [btn addTarget:self action:@selector(footButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            btn.tag = i;
            [self addSubview:btn];
            if (i == 0) {
                _selectButton = btn;
                [_selectButton setTitleColor:HEXCOLOR(TextBlackColor) forState:UIControlStateNormal];
                [_selectButton setTitle:TTLocalString(@"TT_select_all") forState:UIControlStateNormal];
            }else{
                _deleteButton = btn;
                _deleteButton.enabled = NO;
                [_deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
                [_deleteButton setTitleColor:HEXCOLOR(0xF24C4C) forState:UIControlStateNormal];
                [_deleteButton setTitle:TTLocalString(@"TT_delete") forState:UIControlStateDisabled];
            }
        }
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        topLine.backgroundColor = HEXCOLOR(0xcacaca);
        [self addSubview:topLine];
        
        UIView *midLine = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width / 2.0, 12, 1, 20)];
        midLine.backgroundColor = HEXCOLOR(0xBDBDBD);
        [self addSubview:midLine];
    }
    return self;
}
- (void)footButtonClick:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(footButtonClick:)]) {
        [_delegate footButtonClick:sender];
    }
}
@end


static NSString *cellidentifi = @"NewFriendTableCell";
@interface NewFriendViewController ()
@property(nonatomic)BOOL isEditing;
@property(nonatomic)BOOL isSelectAll;
@property(nonatomic)NSMutableArray *deleteArray;//存放需要删除的cell的index;
@property(nonatomic)NSMutableIndexSet *deleteIndexSets;
@property(nonatomic)FoodDeleteView *footDeleteView;
@property(nonatomic,strong)NSString *startid;
@property(nonatomic,strong)NSString *direction;
@property(nonatomic)int page;
@end
@implementation NewFriendViewController
- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:YES];
    if (_updateBlock) {
        _updateBlock(nil,1);
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    _page = 0;
    
    [self createTitleMenu];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.menuRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
    [self.menuRightButton setTitle:TTLocalString(@"TT_edite") forState:UIControlStateNormal];
    [self.menuRightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    
    [self.menuTitleButton setTitle:TTLocalString(@"TT_friends_validation") forState:UIControlStateNormal];
    
    
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight)];
    _mainTable.rowHeight = 300;
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    [_mainTable registerNib:[UINib nibWithNibName:cellidentifi bundle:nil] forCellReuseIdentifier:cellidentifi];
    [self.view addSubview:_mainTable];
    _isEditing = NO;
  
    if (iOS7) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
    }
    
    [self.menuRightButton setEnabled:NO];
    _mainTable.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _overButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _overButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:_overButton];
    _overButton.enabled = NO;
    [_overButton addTarget:self action:@selector(hidenKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    _inputView = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.mj_height,ScreenWidth, 46)];
    [self.view addSubview:_inputView];
    _inputView.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.6f)];
    lineView.backgroundColor = HEXCOLOR(0xCCCCCC);
    [_inputView addSubview:lineView];
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _sendButton.frame = CGRectMake(ScreenWidth - 53, 7 , 46, 32);
    [_sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = _sendButton.mj_height / 2.f;
    [_sendButton setTitle:TTLocalString(@"TT_send") forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:HEXCOLOR(SystemColor)];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_inputView addSubview:_sendButton];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(7, _sendButton.mj_y, _sendButton.mj_x - 14, _sendButton.mj_height)];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = bgView.mj_height / 2.f;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.borderColor = HEXCOLOR(0xCCCCCC).CGColor;
    bgView.layer.borderWidth = 0.6f;
    [_inputView addSubview:bgView];
    
    _fieldView = [[UITextField alloc]initWithFrame:CGRectMake(16,5,bgView.mj_width - 32 ,22)];
    _fieldView.delegate = self;
    [bgView addSubview:_fieldView];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [_mainTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    _dataArray = [[NSMutableArray alloc]init];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshData) name:NOTICE_SEND_FRIEND_APPLY object:nil];
    
    [self loadDataFromDB];
    [self refreshData];
}
- (void)loadDataFromDB{
    _page ++;
    ApplyLeaveDB *db = [[ApplyLeaveDB alloc]init];
    NSMutableArray *array = [db findAllWithPage:_page len:200];
    if (array) {
        [_dataArray addObjectsFromArray:array];
        if (_dataArray.count > 0) {
            [self.menuRightButton setEnabled:YES];
        }
        [_mainTable reloadData];
    }
}
- (void)hidenKeyboard:(id)sender{
    ApplyFriendModel *model = _dataArray[_currentIndexPath.row];
    model.inputText = _fieldView.text;
    _fieldView.text = @"";
    ApplyLeaveDB *applydb = [[ApplyLeaveDB alloc]init];
    [applydb updateApplyToDB:model];
    
    [_dataArray replaceObjectAtIndex:_currentIndexPath.row withObject:model];
    [_fieldView resignFirstResponder];
    [UIView animateWithDuration:0.2f animations:^{
        _inputView.frame = CGRectMake(0, self.view.mj_height,_inputView.mj_width, _inputView.mj_height);
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _overButton.enabled = YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    _overButton.enabled = NO;

}
- (void)sendButtonClick:(id)sender{
    
    NSString *comment = _fieldView.text;
    comment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (comment.length == 0) {
        return;
    }
    _overButton.enabled = NO;
    ApplyFriendModel *model = _dataArray[_currentIndexPath.row];
    [self hidenKeyboard:nil];
    [[RequestTools getInstance]get:API_friend_reply_apply(model.frienduid, comment) isCache:NO completion:^(NSDictionary *dict) {
        ApplyModel *aplModel = [[ApplyModel alloc]init];
        aplModel.isme = YES;
        aplModel.uid = [[LoginManager getInstance] getUid];
        aplModel.applymsg = comment;
        if (model.applymsglist.count <=3) {
            [model.applymsglist addObject:aplModel];
        }else{
            [model.applymsglist removeObjectAtIndex:0];
            [model.applymsglist addObject:aplModel];
        }
        model.inputText = @"";
        ApplyLeaveDB *applydb = [[ApplyLeaveDB alloc]init];
        [applydb updateApplyToDB:model];
        [_dataArray replaceObjectAtIndex:_currentIndexPath.row withObject:model];
        [_mainTable reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
/**
 *  删除好友，id用逗号隔开
 *
 *  @param notifi
 */
- (void)deleteApplyFriend{
    NSString *friendID = @"";
      ApplyLeaveDB *db = [[ApplyLeaveDB alloc]init];
    if (_isSelectAll) {
        NSMutableArray *allArray =  [db findAllApplyModel];
        for (ApplyFriendModel *model in allArray) {
           friendID = FormatString(@"%@,%@",friendID,model.frienduid);
            
        }
        [db delApplyDBWidthArray:allArray];
    }else{
        NSMutableArray *deleteModel = [@[]mutableCopy];
        for (NSIndexPath *indexPath  in _deleteArray) {
            ApplyFriendModel *model = _dataArray[indexPath.row];
            [deleteModel addObject:model];
            friendID = FormatString(@"%@,%@",friendID,model.frienduid);
        }
        [db delApplyDBWidthArray:deleteModel];
    }
    [_dataArray removeObjectsAtIndexes:_deleteIndexSets];
    [_deleteArray removeAllObjects];
    [_deleteIndexSets removeAllIndexes];
    [self hideDeleteView];
    [[RequestTools getInstance]post:API_friend_apply_delete filePath:nil fileKey:nil params:[@{@"frienduid" : friendID}mutableCopy] completion:^(NSDictionary *dict) {
        [db delAllIsDelApplyDB];
    } failure:^(ASIFormDataRequest *request, NSString *message) {
        
    } finished:^(ASIFormDataRequest *request) {
        
    }];

}
- (void)keyboardChange:(NSNotification *)notifi{
    NSDictionary* info = [notifi userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    CGFloat keyboardHeight = kbSize.height;
    if ([_fieldView isFirstResponder]) {
       [UIView animateWithDuration:0.3f animations:^{
           _inputView.frame = CGRectMake(0,self.view.mj_height - keyboardHeight - _inputView.mj_height,_inputView.mj_width, _inputView.mj_height);
       }];
    }
}
- (IBAction)buttonClick:(id)sender{
    if (((UIButton *)sender).tag == BACK_BUTTON) {
        [self goBack:nil];
    }else{
        if (_isEditing) {
            
            [self hideDeleteView];
            
        }else{

            [self showDeleteView];
        }
        
    }
}

#pragma mark  NewFriendTableCellDelegate

- (void)acceptButtonClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath{
    [[RequestTools getInstance]get:API_friend_agreeapply(model.frienduid) isCache:NO completion:^(NSDictionary *dict) {
        model.applystatus = 1;
        NSInteger relation = [dict[@"data"]integerValue];
        model.relation = relation;
        ApplyLeaveDB *applydb = [[ApplyLeaveDB alloc]init];
        [applydb updateApplyToDB:model];
        
        UserInfoDB *db = [[UserInfoDB alloc]init];
        UserInfo *info = [db findWidthUID:model.frienduid];
        info.relation = CheckNilValue(dict[@"data"]);
        info.nickname=info.realname;
        [db saveUser:info];

        if (_updateBlock) {
            _updateBlock(nil,2);
        }
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        [_mainTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
- (void)addFriendButtonClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath{

    ApplyFriendsController *apply=[[ApplyFriendsController alloc] init];
    
    apply.uid= model.frienduid;
    
    [apply setBackBlock:^(id info){
        model.relation = [info integerValue];
        model.applystatus = 0;
        
        ApplyLeaveDB *applydb = [[ApplyLeaveDB alloc]init];
        [applydb updateApplyToDB:model];
        
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        [_mainTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    [self openNavWithSound:apply];
}

- (void)replyButtonClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath{
    
    _currentIndexPath = indexPath;
    
    ApplyFriendModel *applyModel = _dataArray[_currentIndexPath.row];
    if (applyModel.inputText.length > 0) {
        _fieldView.text = applyModel.inputText;
    }else{
        _fieldView.placeholder = FormatString(@"%@:%@",TTLocalString(@"TT_reply"),model.nickname);
    }
    [_fieldView becomeFirstResponder];
}
- (void)avatarClick:(ApplyFriendModel *)model indexPath:(NSIndexPath *)indexPath{
    UserDetailController *vc = [[UserDetailController alloc]init];
    vc.uid = model.frienduid;
    __weak NewFriendViewController * weakSelf = self;
    [vc setBackBlock:^(id objec){
        [weakSelf refreshData];
    }];
    [self openNavWithSound:vc];
}
//显示下方的删除视图
- (void)showDeleteView{
    
    if (iOS7) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 70 + 32, 0, 0);
    }
    [[_mainTable getRefreshHeader]setHidden:YES];
    [[_mainTable getRefreshFooter]setHidden:YES];
    [self.menuRightButton setTitle:TTLocalString(@"TT_cancel") forState:UIControlStateNormal];
    
    _isSelectAll = NO;
    
    for (ApplyFriendModel *model in _dataArray) {
        model.isSelected = NO;
    }
    _isEditing = YES;
    _mainTable.frame = CGRectMake(_mainTable.mj_x, _mainTable.mj_y, _mainTable.mj_width, _mainTable.mj_height - 46);
    _deleteArray = [[NSMutableArray alloc]init];
    _deleteIndexSets = [[NSMutableIndexSet alloc]init];
    
    _footDeleteView = [[FoodDeleteView alloc]initWithFrame:CGRectMake(0,self.view.mj_height, ScreenWidth, 45)];
    _footDeleteView.delegate = self;
    [self.view addSubview:_footDeleteView];

    [UIView animateWithDuration:0.3 animations:^{
        _footDeleteView.frame = CGRectMake(0, self.view.mj_height - 45, ScreenWidth, 45);
    }];
    [_mainTable reloadData];
}
//隐藏下方的删除视图
- (void)hideDeleteView{
   _isEditing = NO;
    [[_mainTable getRefreshHeader]setHidden:NO];
    [[_mainTable getRefreshFooter]setHidden:NO];
    [self.menuRightButton setTitle:TTLocalString(@"TT_edite") forState:UIControlStateNormal];
    if (iOS7) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
    }
    _mainTable.frame = CGRectMake(_mainTable.mj_x,_mainTable.mj_y,_mainTable.mj_width , _mainTable.mj_height + 46);
    [UIView animateWithDuration:0.3 animations:^{
        _footDeleteView.frame = CGRectMake(0,self.view.mj_height, ScreenWidth, 45);
    } completion:^(BOOL finished) {
        _footDeleteView.delegate = nil;
        [_footDeleteView removeFromSuperview];
        _footDeleteView = nil;
    }];
    [_mainTable reloadData];
}
//底部删除视图点击，
- (void)footButtonClick:(UIButton *)sender{
    if (sender.tag == 0) {
        [_deleteArray removeAllObjects];
        [_deleteIndexSets removeAllIndexes];
        if (_isSelectAll) {
            _isSelectAll = NO;
            _footDeleteView.deleteButton.enabled = NO;
            for (ApplyFriendModel *model in _dataArray) {
                model.isSelected = NO;
            }
            [_footDeleteView.selectButton setTitle:TTLocalString(@"TT_select_all") forState:UIControlStateNormal];
        }else{
            _isSelectAll = YES;
            _footDeleteView.deleteButton.enabled = YES;
            [_footDeleteView.selectButton setTitle:TTLocalString(@"TT_cancel_select_all") forState:UIControlStateNormal];
            ApplyLeaveDB *db = [[ApplyLeaveDB alloc]init];
            NSArray *allArray = [db findAllApplyModel];
            [_footDeleteView.deleteButton setTitle:FormatString(@"%@(%lu)", TTLocalString(@"TT_delete"),(long)[allArray count]) forState:UIControlStateNormal];
            for (int i = 0; i < _dataArray.count; i ++) {
                [_deleteArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                [_deleteIndexSets addIndex:i];
                ApplyFriendModel *model = _dataArray[i];
                model.isSelected = YES;
            }
        }
        
        [_mainTable reloadData];
        
    }else{
        
        //发送网络请求删除
        
        if (_deleteArray.count > 0) {
            [self deleteApplyFriend];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isEditing) {
        if ([_deleteArray containsObject:indexPath]) {
            [_deleteIndexSets removeIndex:indexPath.row];
            [_deleteArray removeObject:indexPath];
            ApplyFriendModel *model = _dataArray[indexPath.row];
            model.isSelected = NO;
            [_dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        }else{
            [_deleteArray addObject:indexPath];
            [_deleteIndexSets addIndex:indexPath.row];
            ApplyFriendModel *model = _dataArray[indexPath.row];
            model.isSelected = YES;
            [_dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        }
        
        [_mainTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (_deleteArray.count > 0) {
            _footDeleteView.deleteButton.enabled = YES;
            [_footDeleteView.deleteButton setTitle:FormatString(@"%@(%lu)",TTLocalString(@"TT_delete"), (unsigned long)[_deleteArray count]) forState:UIControlStateNormal];
        }else{
            _footDeleteView.deleteButton.enabled = NO;
        }
    }
}

- (void)refreshData{
    ApplyLeaveDB *db = [[ApplyLeaveDB alloc] init];
    NSString *new = [db findNewModel].uptime;
    NSString *old = [db findOldModel].uptime;
    [[RequestTools getInstance]get:API_Get_friend_applylis(new,old) isCache:NO completion:^(NSDictionary *dict) {
        NSArray *datas = dict[@"data"];

        if([datas isKindOfClass:[NSArray class]] && datas && datas.count>0){
            // 循环插入/更新
            for (NSDictionary  *dic in datas) {
                ApplyFriendModel *model = [ApplyFriendModel initWithDic:dic];
                [db saveApplyToDB:model];
            }
            
            // 重新查询数据,顺序不正确，最新的始终在顶部
            _page=1;
            _dataArray=[db findAllWithPage:_page len:200];
            [_mainTable reloadData];
            
            // 请求完成，不管是否成功，都设置
            if (_dataArray.count > 0) {
                [self.menuRightButton setEnabled:YES];
            }
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([_mainTable isHeaderRefreshing]){
            [_mainTable headerEndRefreshing];
        }
        
        // 优化sql语句
        [db updateReadStatus:_dataArray];
        
        NSString *friendID = @"";
        
        NSMutableArray *allArray = [db findAllApplyWithIsRead:YES];
        
        for (ApplyFriendModel *model in allArray) {
           friendID = FormatString(@"%@,%@", friendID,model.frienduid);
        }
        
        [[RequestTools getInstance]post:API_Set_apply_read filePath:nil fileKey:nil params:[@{@"frienduid" : friendID}mutableCopy] completion:^(NSDictionary *dict) {
//            WSLog(@"更新成功%@",dict);
        } failure:^(ASIFormDataRequest *request, NSString *message) {
            
        } finished:^(ASIFormDataRequest *request) {
            
        }];
    }];
}
- (void)loadMoreData{
    [self loadDataFromDB];
    [self bk_performBlock:^(id obj) {
        [_mainTable footerEndRefreshing];
    } afterDelay:0.1];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewFriendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifi forIndexPath:indexPath];
    if (_isEditing) {
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ApplyFriendModel *model = _dataArray[indexPath.row];
    
    cell.isEditing = _isEditing;
    cell.delegate = self;
    cell.indexPath = indexPath;
    [cell loadCellWith:model];
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ApplyFriendModel *model = _dataArray[indexPath.row];
    return [NewFriendTableCell calculateCellHeight:model isEditinag:_isEditing];
}

@end