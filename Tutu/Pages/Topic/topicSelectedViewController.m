//
//  topicSelectedViewController.m
//  Tutu
//
//  Created by gexing on 15/4/16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "topicSelectedViewController.h"
#import "topicSelectedCell.h"
@interface topicSelectedViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *groupArray;
    NSMutableArray *searchArray;
}
@end

static NSString *cellIdentifier = @"topicHot";

@implementation topicSelectedViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    groupArray=[[NSMutableArray alloc]init];
    searchArray=[[NSMutableArray alloc]init];
    self.view.backgroundColor=[UIColor clearColor];
    [self creatView];
    
    
    [self doSearchText:@"" widthType:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}
-(void)creatView
{
    [self createLeftBarItemSelect:@selector(leftButtonClick:) imageName:nil heightImageName:nil];
    self.title = TTLocalString(@"topic_hot_huati");
    
    
    _mainTable = [[UITableView alloc]init];
    _mainTable.frame = CGRectMake(0,0, ScreenWidth, self.view.mj_height);
//        [_mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.rowHeight = 60;
    [_mainTable registerNib:[UINib nibWithNibName:@"topicSelectedCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectZero];
    _mainTable.tableFooterView = footView;
    [self.view addSubview:_mainTable];
    
   
    //创建搜索条
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = TTLocalString(@"TT_topic_search");
    self.searchBar.delegate = self;
    
    self.searchBar.barStyle=UISearchBarStyleDefault;
    [self.searchBar sizeToFit];
    
    self.searchBar.backgroundColor=[UIColor clearColor];
    
    _mainTable.tableHeaderView = self.searchBar;

    //去掉搜索框背景
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (iOS7) {
        self.searchBar.layer.borderWidth = 1;
        self.searchDisplayController.searchResultsTableView.tag=10;
        self.strongSearchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(60, 0, 0, 0);
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTable.sectionIndexBackgroundColor = [UIColor clearColor];
        self.searchBar.layer.borderColor = [HEXCOLOR(EmotionListBg) CGColor];
        [self.searchBar setBarTintColor:HEXCOLOR(0XC9C9CE)];
        self.searchBar.opaque = YES;
        
    }else{
        self.mainTable.frame =CGRectMake(0, 44, ScreenWidth, self.view.mj_height - 44);
    }
    
    [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"topicSelectedCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.strongSearchDisplayController.searchResultsTableView.rowHeight = 60;
    _strongSearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchArray removeAllObjects];
    
    WSLog(@"开始搜索%@",searchText);
    [self doSearchText:searchText widthType:YES];
}

#pragma mark-tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = HEXCOLOR(0xF8F8F8);
    headView.frame = CGRectMake(0, 0, ScreenWidth, 20);
    UILabel *headLabel =[[UILabel alloc]initWithFrame:CGRectMake(13, 0, 200, 20)];
    headLabel.text=TTLocalString(@"topic_hot_huati");
    headLabel.font=ListTimeFont;
    headLabel.textColor=UIColorFromRGB(TextSixAColor);
    headLabel.frame = CGRectMake(13, 0, 200, 20);
    [headView addSubview:headLabel];
    return headView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.mainTable) {
        return groupArray.count;
    }
    else
    {
        return searchArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    topicSelectedCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView==self.mainTable) {
        topicHotModel *model=[groupArray objectAtIndex:indexPath.row];

        [cell cellLoadWith:model];
    }
    else
    {
        topicHotModel *model=[searchArray objectAtIndex:indexPath.row];
       
        [cell cellLoadWith:model];

    }

    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    topicHotModel *model;
    if (tableView==self.mainTable) {
        model=[groupArray objectAtIndex:indexPath.row];
        
    }else
    {
        model=[searchArray objectAtIndex:indexPath.row];
       
    }
    if ([self.delegate respondsToSelector:@selector(sendText:)]) {
        [self.delegate sendText:model];
    }

    [self.navigationController popViewControllerAnimated:YES];
}



-(void)doSearchText:(NSString *)text widthType:(BOOL) isSearch{
    NSString *str_api=API_RELEASE_HOT_TOPIC(text, @"100");
    if(isSearch && [@"" isEqual:text]){
        return;
    }
    
    [[RequestTools getInstance]get:str_api isCache:NO completion:^(NSDictionary *dict) {
        NSArray *tempArray=dict[@"data"][@"list"];
        for (NSDictionary *dic in tempArray) {
            topicHotModel *model=[topicHotModel initWithMyDict:dic];
            if(isSearch){
                [searchArray addObject:model];
            }else{
                [groupArray addObject:model];
            }
        }
        
        if(isSearch){
            [self.searchDisplayController.searchResultsTableView reloadData];
        }else{
            [self.mainTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}



//- (NSInteger) lengthWithInRangeWithreplacementText:(NSString *)string {
//    NSInteger textLength = 0;
//    UITextRange *selectedRange = [self markedTextRange];
//    //获取高亮部分
//    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
//    if (!position) {
//        textLength = [self.text length];
//    }
//    if (string.length > 0) {
//        //输入状态
//        NSString * newText = [self textInRange:selectedRange];
//        WSLog(@"newtext=%@",newText);
//        if (newText && [string length] > 1) {       //候选词替换高亮拼音时
//            
//            if (newText != nil) {
//                NSInteger tvLength = [self.text length];
//                textLength += (tvLength-[newText length]);
//            }
//            
//            textLength += [string length];
//        }else {
//            [self setText:string];
//            
//            if (newText != nil) {
//                NSInteger tvLength = [self.text length];
//                textLength += (tvLength-[newText length]);
//            }
//            
//            textLength += 1;
//        }
//    }else {
//        //删除状态
//        if (self.text.length > 0) {
//            NSString * newText = [self textInRange:selectedRange];
//            if (newText != nil) {
//                NSInteger newLength = [newText length];
//                NSInteger tvLength = [self.text length];
//                textLength += (tvLength-newLength);
//                if (newLength > 1) {
//                    textLength += 1;
//                }
//            }
//            else {
//                //                textLength = [[self.text substringToIndex:range.location] length];
//            }
//        }
//    }
//    
//    return textLength;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)leftButtonClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self.navigationController setNavigationBarHidden:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.strongSearchDisplayController=nil;
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self.navigationController setNavigationBarHidden:NO];
    
}

@end
