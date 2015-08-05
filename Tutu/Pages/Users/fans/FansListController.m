//
//  FansListController.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FansListController.h"
#import "ChineseFirstLetter.h"
#import "UserDetailController.h"

#define cellIdentifier @"UserFansCell"

@interface FansListController (){
    UITableView *listTable;
    NSMutableArray *listArray;
    //快速遍历,更新用户关系
    NSMutableDictionary *dictData;
    
    CGFloat w;
    UserInfo *doFocusModel;
    
    
    // 排序方式，默认A-Z,0,默认，1时间
    int sortType;
    NSMutableArray *_sectionHeadsKeys;
    NSMutableArray *sortedArrForArrays;
}

@end

@implementation FansListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createTitleMenu];
    self.menuRightButton.hidden=NO;
    [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_nor"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_sel"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(10, 9, 10, 9)];
    
    
    if(_info && ![_info.uid isEqual:[[LoginManager getInstance] getUid]]){
        [self.menuTitleButton setTitle:[NSString stringWithFormat:@"%@的粉丝",_info.nickname] forState:UIControlStateNormal];
    }else{
        [self.menuTitleButton setTitle:[NSString stringWithFormat:@"我的粉丝"] forState:UIControlStateNormal];
    }
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, self.view.mj_width, self.view.mj_height-NavBarHeight)];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [listTable setBackgroundColor:[UIColor whiteColor]];
    [listTable setSeparatorColor:UIColorFromRGB(ListLineColor)];
    listTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    listTable.sectionIndexColor = HEXCOLOR(SystemColor);
    [listTable setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    if([SysTools getSystemVerson] >= 7){
        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    }
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];

    
    [listTable addHeaderWithTarget:self action:@selector(refreshData)];
    [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    
    w=self.view.frame.size.width;
    
    
    sortType=1;

    self.menuRightButton.hidden=YES;
//    if(sortType==1){
//        [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_nor"] forState:UIControlStateNormal];
//        [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_sel"] forState:UIControlStateHighlighted];
//    }
    listArray=[[NSMutableArray alloc] init];
    _sectionHeadsKeys=[[NSMutableArray alloc] init];
    dictData=[[NSMutableDictionary alloc] init];
    
    [listTable headerBeginRefreshing];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:NOTICE_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRelation:) name:NOTICE_DELADDFRIEND object:nil];
}


#pragma mark 刷新数据
-(void)refreshData{
    NSString *startid=@"";
    if(listArray!=nil && listArray.count>0){
        UserInfo *info=[listArray objectAtIndex:0];
        startid=info.uid;
    }
    
    [[RequestTools getInstance] get:API_GET_FansList(_info.uid, Load_UP, 20, startid) isCache:NO completion:^(NSDictionary *dict) {
        [[RequestTools getInstance] setNewfanscount:@"0"];
        
        [[NoticeTools getInstance] postClearMessageRead];
        
        NSArray *arr=dict[@"data"][@"list"];
        if(arr!=nil && arr.count>0){
            NSArray* reversedArray = [[arr reverseObjectEnumerator] allObjects];
            
            for (NSDictionary *item in reversedArray) {
                UserInfo *info=[[UserInfo alloc] initWithMyDict:item];
                [listArray insertObject:info atIndex:0];
                [dictData setObject:info forKey:info.uid];
            }
            
//            sortedArrForArrays=[self getChineseStringArr:listArray];
            
            [listTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([listTable isHeaderRefreshing]){
            [listTable headerEndRefreshing];
        }
    }];
}

-(void)loadMoreData{
    NSString *startid=@"";
    if(listArray!=nil && listArray.count>0){
        UserInfo *info=[listArray objectAtIndex:listArray.count-1];
        startid=info.uid;
    }
    [[RequestTools getInstance] get:API_GET_FansList(_info.uid, Load_MORE, 20, startid) isCache:NO completion:^(NSDictionary *dict) {
        NSArray *arr=dict[@"data"][@"list"];
        if(arr!=nil && arr.count>0){
            for (NSDictionary *item in arr) {
                UserInfo *info = [[UserInfo alloc] initWithMyDict:item];
                [listArray addObject:info];
                
                [dictData setObject:info forKey:info.uid];
            }
            
//            sortedArrForArrays=[self getChineseStringArr:listArray];
            
            [listTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        if([listTable isFooterRefreshing]){
            [listTable footerEndRefreshing];
        }
    }];
}



#pragma mark table 代理开始
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(sortType==0){
        return  [[sortedArrForArrays objectAtIndex:section] count];
    }else{
        return listArray.count;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(sortType==0){
        return _sectionHeadsKeys;
    }else{
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(sortType==0){
        return [sortedArrForArrays count];
    }else{
        return 1;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(sortType==1){
        return 0;
    }else{
        return 25;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(sortType==1){
        return nil;
    }
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 25)];
    [view setBackgroundColor:UIColorFromRGB(ButtonViewBgColor)];
    
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, w-20, 25)];
    [textLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:ListTitleFont];
    [view addSubview:textLabel];
    
    [textLabel setText:[_sectionHeadsKeys objectAtIndex:section]];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserFansCell *cell = (UserFansCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UserFansCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate=self;
    
    UserInfo *info=[listArray objectAtIndex:indexPath.row];
    if(sortType==0){
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        info = [arr objectAtIndex:indexPath.row];
    }
    [cell dataToView:info];
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *info=[listArray objectAtIndex:indexPath.row];
    if(sortType==0){
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        info = [arr objectAtIndex:indexPath.row];
    }
    UserDetailController *detail=[[UserDetailController alloc] init];
    detail.uid=info.uid;
    [self openNav:detail sound:nil];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if([_info.uid isEqual:[LoginManager getInstance].getUid]){
        return YES;
    }else{
        return NO;
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    UserInfo *user=[listArray objectAtIndex:row];
    if(sortType==0){
        user=[[sortedArrForArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
        
    [[RequestTools getInstance] get:API_DEL_UserFans(user.uid) isCache:NO completion:^(NSDictionary *dict) {
        //删除数据
        [listArray removeObject:user];
        sortedArrForArrays=[self getChineseStringArr:listArray];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationLeft];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}


#pragma mark TableCell代理
-(void)itemFocusClick:(UserInfo *)info{
    [self doFocus:info del:NO];
}


#pragma mark 本页面事件处理
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        if(_comefrom==1){
            //进入首页
            UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            [self goBack:nil];
        }
    }
    
    if(sender.tag==RIGHT_BUTTON){
        if(sortType==0){
            sortType=1;
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_nor"] forState:UIControlStateNormal];
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_time_sel"] forState:UIControlStateHighlighted];
            [listTable reloadData];
        }else{
            sortType=0;
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_nor"] forState:UIControlStateNormal];
            [self.menuRightButton setImage:[UIImage imageNamed:@"sort_char_sel"] forState:UIControlStateHighlighted];
            [listTable reloadData];
        }
    }
}

//用户关注
-(void)doFocus:(UserInfo *)info del:(BOOL) isDel{
    if(!isDel && info!=nil && ([info.relation intValue]==2 || [info.relation intValue]==3)){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:TTLocalString(@"TT_maksure_cancel_follow") delegate:self otherButton:@[TTLocalString(@"TT_make_sure")] cancelButton:TTLocalString(@"TT_cancel")];
        sheet.tag=4;
        [sheet showInView:self.view];
        
        doFocusModel=info;
    }else{
        
        NSString *doFocusORDelAPI=API_ADD_Follow_User(info.uid);
        if(isDel){
            doFocusORDelAPI=API_DEL_Follow_User(info.uid);
        }
        
        [[RequestTools getInstance] get:doFocusORDelAPI isCache:NO completion:^(NSDictionary *dict) {
            if([info.relation intValue]==0){
                info.relation=@"2";
            }else if([info.relation intValue]==1){
                info.relation=@"3";
            }else if([info.relation intValue]==3){
                info.relation=@"1";
            }else if([info.relation intValue]==2){
                info.relation=@"0";
            }
            [listTable reloadData];
            
            if(isDel){
                [[NoticeTools getInstance] postdelFocus:info];
            }else{
                [[NoticeTools getInstance] postAddFocus:info];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }
    
}



#pragma mark 其它控件代理监听
-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    // 取消关注
    if(tag==4){
        if(buttonIndex==0){
            [self doFocus:doFocusModel del:YES];
        }
    }
    
}


#pragma mark 数据处理
// 固定代码 , 每次使用只需要将数据模型替换就好 , 这个方法是获取首字母 , 将填充给 cell 的值按照首字母排序
- ( NSMutableArray *)getChineseStringArr:( NSMutableArray *)arrToSort
{
    [_sectionHeadsKeys removeAllObjects];
    // 创建一个临时的变动数组
    NSMutableArray *chineseStringsArray = [ NSMutableArray array ];
    for ( int i = 0 ; i < [arrToSort count ]; i++)
    {
        // 创建一个临时的数据模型对象
        UserInfo *userInfo=[arrToSort objectAtIndex:i];
        
        // 给模型赋值
        if (userInfo.nickname == nil )
        {
            userInfo.nickname = @"" ;
        }
        
        if (![userInfo.nickname isEqual: @"" ])
        {
            //join( 链接 ) the pinYin (letter 字母 )  链接到首字母
            NSString *pinYinResult = [ NSString string ];
            // 按照数据模型中 row 的个数循环
            for ( int j = 0 ;j < userInfo.nickname.length ; j++)
            {
                NSString *singlePinyinLetter = [[ NSString stringWithFormat : @"%c" ,
                                                 pinyinFirstLetter([userInfo.nickname characterAtIndex :j])] uppercaseString ];
                pinYinResult = [pinYinResult stringByAppendingString :singlePinyinLetter];
            }
            userInfo.pinYin = pinYinResult;
        } else {
            userInfo.pinYin = @"#";
        }
        
        if(userInfo.pinYin!=nil && userInfo.pinYin.length>0){
            NSMutableString *strchar= [NSMutableString stringWithString:userInfo.pinYin ];
            NSString *sr= [strchar substringToIndex : 1 ];
            if(!validdatePinYin(sr)){
                userInfo.pinYin=@"#";
            }
        }else{
            userInfo.pinYin=@"#";
        }
        
        [chineseStringsArray addObject :userInfo];
    }
    
    //sort( 排序 ) the ChineseStringArr by pinYin( 首字母 )
    NSArray *sortDescriptors = [ NSArray arrayWithObject :[ NSSortDescriptor sortDescriptorWithKey : @"pinYin" ascending : YES ]];
    
    [chineseStringsArray sortUsingDescriptors :sortDescriptors];
    
    
    NSMutableArray *arrayForArrays = [ NSMutableArray array ];
    
    BOOL checkValueAtIndex= NO ;  //flag to check
    
    NSMutableArray *TempArrForGrouping = nil ;
    
    for ( int index = 0 ; index < [chineseStringsArray count ]; index++)
    {
        UserInfo *chineseStr = [chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString :chineseStr.pinYin ];
        NSString *sr= [strchar substringToIndex : 1 ];
        
        // 检查字符是否已经选择头键
        if (![_sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [ _sectionHeadsKeys addObject :[sr uppercaseString ]];
            TempArrForGrouping = [[ NSMutableArray alloc ] initWithObjects : nil];
            checkValueAtIndex = NO ;
        }
        
        if ([_sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:chineseStr];
            if (checkValueAtIndex == NO )
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES ;
            }
        }
    }
    return arrayForArrays;
}


//更新用户关系
-(void)updateRelation:(NSNotification *) nsInfo{
    if(nsInfo){
        UserInfo *info=nsInfo.object;
        if(info){
            UserInfo *dInfo = [dictData objectForKey:info.uid];
            if(dInfo){
                dInfo.relation=info.relation;
                
                [listTable reloadData];
            }
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
