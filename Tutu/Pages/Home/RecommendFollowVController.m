//
//  RecommendFollowVController.m
//  Tutu
//
//  Created by gexing on 5/14/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "RecommendFollowVController.h"
#import "RecommendLocationCell.h"
#import "RecommendUserCell.h"
#import "RecommendThemeCell.h"
#import "RecommendUserModel.h"
#import "RecommendLocationModel.h"
#import "RecommendThemeModel.h"
#import "UserDetailController.h"
#import "ListTopicsController.h"
#import "FriendSearchController.h"
#import "SVWebViewController.h"
@interface RecommendFollowVController () <UITableViewDataSource,UITableViewDelegate,RecommendUserCellDelegate,RecommendLocationCellDelegate,RecommendThemeCellDelegate>
@property(nonatomic ,strong)NSMutableArray *poilist;
@property(nonatomic ,strong)NSMutableArray *userlist;
@property(nonatomic ,strong)NSMutableArray *htlist;
@end

static NSString *recommendUserCell = @"RecommendUserCell";
static NSString *recommendThemeCell = @"RecommendThemeCell";
static NSString *recommendLocationCell = @"RecommendLocationCell";

@implementation RecommendFollowVController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight - 50)];
    
    [_mainTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_mainTable setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    if (_type == 0) {
        [self createTitleMenu];
        [self.menuLeftButton setHidden:YES];
        [self.menuRightButton setImage:nil forState:UIControlStateNormal];
        [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
        [self.menuRightButton setTitle:TTLocalString(@"TT_close") forState:UIControlStateNormal];
        [self.menuTitleButton setTitle:TTLocalString(@"TT_recommend") forState:UIControlStateNormal];
        _mainTable.frame = CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight);
        
        [self refreshData];
    }else{
       // [self initModels:_dataDic];
    }

    [self.view addSubview:_mainTable];
    
    _mainTable.delegate = self;
    
    _mainTable.dataSource = self;
    
    [_mainTable registerNib:[UINib nibWithNibName:recommendThemeCell bundle:nil] forCellReuseIdentifier:recommendThemeCell];
    [_mainTable registerNib:[UINib nibWithNibName:recommendUserCell bundle:nil] forCellReuseIdentifier:recommendUserCell];
    [_mainTable registerNib:[UINib nibWithNibName:recommendLocationCell bundle:nil] forCellReuseIdentifier:recommendLocationCell];
    _mainTable.rowHeight = 55;
    if ([_mainTable respondsToSelector:@selector(separatorInset)]) {
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0);
    }
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    
    _htlist = [[NSMutableArray alloc]init];
    _userlist = [[NSMutableArray alloc]init];
    _poilist = [[NSMutableArray alloc]init];
    
}

-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==RIGHT_BUTTON){
        //进入首页
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController.navigationBar setHidden:NO];
        }];
    }
}

- (void)initModels:(NSDictionary *)dict{

    NSArray *htlist = dict[@"htlist"];
    NSArray *userlist = dict[@"userlist"];
    NSArray *poilist = dict[@"poilist"];
    if (htlist.count > 0) {
        NSArray *recommendThemeModels = [RecommendThemeModel arrayOfModelsFromDictionaries:htlist];
        if (recommendThemeModels) {
            [_htlist removeAllObjects];
            [_htlist addObjectsFromArray:recommendThemeModels];
        }
    }
    if (userlist.count > 0) {
        NSArray *recommendUserModels = [RecommendUserModel arrayOfModelsFromDictionaries:userlist];
        if (recommendUserModels) {
            [_userlist removeAllObjects];
           [_userlist addObjectsFromArray:recommendUserModels];
        }
    }
    if (poilist.count > 0) {
        
        NSArray *recommendLocationModels = [RecommendLocationModel arrayOfModelsFromDictionaries:poilist];
        if (recommendLocationModels) {
            [_poilist removeAllObjects];
           [_poilist addObjectsFromArray:recommendLocationModels];
        }
        
    }
    [_mainTable reloadData];
}
- (void)refreshData{
    [[RequestTools getInstance]get:API_Friend_RecommendList(ApplicationDelegate.latitude,ApplicationDelegate.longitude) isCache:NO completion:^(NSDictionary *dict) {
        NSDictionary *data = dict[@"data"];
        [self initModels:data];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section % 2 == 0) {
        return 0;
    }else{
        if (section == 1) {
            return self.userlist.count;
        }else if (section == 3){
            return self.htlist.count;
        }else{
            return self.poilist.count;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        RecommendUserCell *cell = [tableView dequeueReusableCellWithIdentifier:recommendUserCell forIndexPath:indexPath];
        RecommendUserModel *model = _userlist[indexPath.row];
        cell.cellIndex = indexPath.row;
        cell.delegate = self;
        [cell loadCellWithModel:model];
        return cell;
    }else if (indexPath.section == 3){
        RecommendThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:recommendThemeCell forIndexPath:indexPath];
        cell.cellIndex = indexPath.row;
        cell.delegate = self;
        RecommendThemeModel *model = _htlist[indexPath.row];
        [cell loadCellWithModel:model];
        return cell;
    }else if (indexPath.section == 5){
        RecommendLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:recommendLocationCell forIndexPath:indexPath];
        cell.cellIndex = indexPath.row;
        cell.delegate = self;
        RecommendLocationModel*model = _poilist[indexPath.row];
        [cell loadCellWithModel:model];
        return cell;
    }else
        return nil;
}
- (void)userAvatarClick:(RecommendUserModel *)model index:(NSInteger)index{
    if (_controller) {
        UserDetailController *vc = [[UserDetailController alloc]init];
        vc.uid = IntToString(model.uid);
        [self.controller openNavWithSound:vc];
    }else{
        UserDetailController *vc = [[UserDetailController alloc]init];
        vc.uid = IntToString(model.uid);
        [self openNavWithSound:vc];
    }
}
- (void)locationClick:(RecommendLocationModel *)model index:(NSInteger)index{
    if (_controller) {
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString = model.idstext;
        control.pageType=TopicWithPoiPage;
        [self.controller openNavWithSound:control];
    }else{
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString = model.idstext;
        control.poiid = model.ids;
        control.pageType=TopicWithPoiPage;
        [self openNavWithSound:control];
    }
}
- (void)themeClick:(RecommendThemeModel *)model index:(NSInteger)index{

    if (_controller) {
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString = model.idstext;
        control.pageType=TopicWithDefault;
        [self.controller openNavWithSound:control];
    }else{
        ListTopicsController *control=[[ListTopicsController alloc] init];
        control.topicString = model.idstext;
        control.pageType=TopicWithDefault;
        [self openNavWithSound:control];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        RecommendUserModel *model = _userlist[indexPath.row];
        if (_controller) {
            UserDetailController *vc = [[UserDetailController alloc]init];
            vc.uid = IntToString(model.uid);
            [self.controller openNavWithSound:vc];
        }else{
            UserDetailController *vc = [[UserDetailController alloc]init];
            vc.uid = IntToString(model.uid);
            [self openNavWithSound:vc];
        }
    }else if (indexPath.section == 3){
        RecommendThemeModel *model = _htlist[indexPath.row];
        if (_controller) {
            ListTopicsController *control=[[ListTopicsController alloc] init];
            control.topicString = model.idstext;
            control.pageType=TopicWithDefault;
            [self.controller openNavWithSound:control];
        }else{
            ListTopicsController *control=[[ListTopicsController alloc] init];
            control.topicString = model.idstext;
            control.pageType=TopicWithDefault;
            [self openNavWithSound:control];
        }
    }else if (indexPath.section == 5){
        RecommendLocationModel *model = _poilist[indexPath.row];
        if (_controller) {
            ListTopicsController *control=[[ListTopicsController alloc] init];
            control.topicString = model.idstext;
            control.pageType=TopicWithPoiPage;
            [self.controller openNavWithSound:control];
        }else{
            ListTopicsController *control=[[ListTopicsController alloc] init];
            control.topicString = model.idstext;
            control.poiid = model.ids;
            control.pageType=TopicWithPoiPage;
            [self openNavWithSound:control];
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        if (_type == 0) {
            if (_userlist.count == 0) {
                return 0;
            }else{
                return 35;
            }
        }else{
            return 75;
        }
    }else if (section == 2){
        if (_htlist.count == 0) {
            return 0;
        }
        return 50;
    }else if (section == 4){
        if (_poilist.count == 0) {
            return 0;
        }
        return 50;
    }
    return 0;
}
- (void)moreButtonClick:(UIButton *)sender{
    BaseController *vc = nil;
    switch (sender.tag) {
        case 0:
            vc =[[FriendSearchController alloc] init];
            break;
        case 1:
            vc = [[SVWebViewController alloc]initWithURL:StrToUrl(URL_HuaTi_GuangChang)];
            break;
        case 2:
           vc = [[SVWebViewController alloc]initWithURL:StrToUrl(URL_HuaTi_GuangChang)];
            break;
            
        default:
            break;
    }
    if (vc) {
        if (_controller) {
            [self.controller openNavWithSound:vc];
        }else{
            [self openNavWithSound:vc];
        }
    }

}
- (UIView *)createHeaderView:(NSString *)title buttonTag:(NSInteger)tag{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    header.backgroundColor = HEXCOLOR(SystemGrayColor);
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, ScreenWidth, 35)];
    [header addSubview:bgView];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(TextBlackColor)];
    titleLabel.frame = CGRectMake(10, 12, 200, 17);
    titleLabel.text = title;
    [bgView addSubview:titleLabel];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(ScreenWidth - 66, 0, 66, 44);
    [moreButton setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    [moreButton setTitleColor:HEXCOLOR(0xcccccc) forState:UIControlStateHighlighted];
    [moreButton setTitle:TTLocalString(@"topic_more") forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    moreButton.tag = tag;
    [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:moreButton];
    
    UIImageView *moreImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"photo_to_right"]];
    moreImageView.frame = CGRectMake(ScreenWidth - 16, 0, 7, 11);
    moreImageView.center = CGPointMake(moreImageView.center.x, moreButton.center.y);
    [bgView addSubview:moreImageView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 63, 2)];
    lineView.backgroundColor = HEXCOLOR(SystemColor);
    [bgView addSubview:lineView];
    if (tag == 0) {
        if (_type == 0) {//进入app的推荐页面
            header.frame = CGRectMake(0, 0, ScreenWidth, 35);
            bgView.frame = CGRectMake(0, 0, ScreenWidth, 35);
            [lineView setHidden:YES];
        }else{//关注页面的推荐列表
            header.frame = CGRectMake(0, 0, ScreenWidth, 75);
            bgView.frame = CGRectMake(0, 40, ScreenWidth, 35);
            UILabel *headerLabel = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(TextGrayColor)];
            headerLabel.text = TTLocalString(@"TT_you_have_not_any_follow");
            headerLabel.frame = CGRectMake(0, 12, ScreenWidth, 15);
            headerLabel.textAlignment = NSTextAlignmentCenter;
            [header addSubview:headerLabel];
        }
    }
    return header;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *header = [self createHeaderView:TTLocalString(@"TT_maybe_interest_people") buttonTag:0];
        return header;
    }else if (section == 2){
        return [self createHeaderView:TTLocalString(@"topic_hot_huati") buttonTag:1];
    }else if (section == 4){
        return [self createHeaderView:TTLocalString(@"topic_hot_loaction") buttonTag:2];
    }
    return nil;
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
