//
//  locationSearchViewController.m
//  Tutu
//
//  Created by gexing on 15/4/8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "locationSearchViewController.h"
#import "localtionSearchCell.h"
//#import "BMKGeocodeType.h"
//#import "BMKGeocodeSearchOption.h"
//#import "BMKGeocodeSearch.h"
#import <BaiduMapAPI/BMapKit.h>
@interface locationSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, CLLocationManagerDelegate,BMKPoiSearchDelegate,UISearchDisplayDelegate,BMKGeoCodeSearchDelegate>
{
    NSMutableArray *groupArray;
    NSMutableArray *searchArray;
    NSString *searchTitle;
    double  myLatitude;
    double  myLongitude;
    BMKGeoCodeSearch *_geocodesearch;
    
    int page;
}
@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISearchDisplayController *strongSearchDisplayController;


@end


static NSString *cellIdentifier = @"localtion";

@implementation locationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    groupArray=[[NSMutableArray alloc]init];
    searchArray=[[NSMutableArray alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _poisearch = [[BMKPoiSearch alloc]init];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemSelect:@selector(leftButtonClick:) imageName:nil heightImageName:nil];
    self.title = TTLocalString(@"TT_my_location");
    [self creatView];
    
    
    // 如果已经定位成功
    if([SysTools getApp].locSuccess){
        myLatitude=[SysTools getApp].latitude;
        myLongitude=[SysTools getApp].longitude;
        
        [self onClickReverseGeocode];
    }else{
        _locService=[[BMKLocationService alloc] init];
        _locService.delegate=self;
        [_locService startUserLocationService];
    }
}

-(void)creatView
{
    _mainTable = [[UITableView alloc]init];
    _mainTable.frame = CGRectMake(0,0, ScreenWidth, self.view.mj_height);
//    [_mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.rowHeight = 55;
    [_mainTable registerNib:[UINib nibWithNibName:@"localtionSearchCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];

    _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _mainTable.separatorColor = HEXCOLOR(ListLineColor);
    _mainTable.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    _mainTable.sectionIndexColor = HEXCOLOR(SystemColor);
   
    UIView *footView = [[UIView alloc]initWithFrame:CGRectZero];
    _mainTable.tableFooterView = footView;
    [self.view addSubview:_mainTable];
    
    //创建搜索条
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = TTLocalString(@"TT_seek_nearby");
    self.searchBar.delegate = self;
    
    self.searchBar.barStyle=UISearchBarStyleDefault;
    [self.searchBar sizeToFit];
    
    self.searchBar.backgroundColor=[UIColor clearColor];
    //去掉搜索框背景
    
    _mainTable.tableHeaderView = self.searchBar;
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (iOS7) {
        self.searchBar.layer.borderWidth = 1;
        self.searchDisplayController.searchResultsTableView.tag=1;
        self.strongSearchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(60, 0, 0, 0);
        _mainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTable.sectionIndexBackgroundColor = [UIColor clearColor];
        self.searchBar.layer.borderColor = [HEXCOLOR(EmotionListBg) CGColor];
        [self.searchBar setBarTintColor:HEXCOLOR(0XC9C9CE)];
        self.searchBar.opaque = YES;
        
    }else{
        self.mainTable.frame =CGRectMake(0, 44, ScreenWidth, self.view.mj_height - 44);
    }

    [self.strongSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"localtionSearchCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.strongSearchDisplayController.searchResultsTableView.rowHeight = 55;
    _strongSearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self.strongSearchDisplayController.searchResultsTableView addFooterWithTarget:self action:@selector(nearBySearch)];
}


//查找附近
-(void)nearBySearch
{
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex =page;
    option.pageCapacity = 20;
    option.location = CLLocationCoordinate2DMake(myLatitude, myLongitude);
    option.radius=3000;
    option.keyword = searchTitle;
    BOOL flag = [_poisearch poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        NSLog(@"周边检索发送失败");
    }
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

// 查询
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    NSLog(@"%@",searchText);
    [searchArray removeAllObjects];
    searchTitle=searchText;
    page=0;
    [self nearBySearch];
}


#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSArray *tempArray=result.poiList;
    groupArray.array=tempArray;
    [_mainTable reloadData];
}

//查询个人周边的热点
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSArray *array=poiResultList.poiInfoList;
        
        [searchArray addObjectsFromArray:array];
        UITableView *t=(UITableView *)[self.view viewWithTag:1];
        [t reloadData];
        
        page=page+1;
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
    if([self.strongSearchDisplayController.searchResultsTableView isFooterRefreshing]){
        [self.strongSearchDisplayController.searchResultsTableView footerEndRefreshing];
    }
}

-(IBAction)onClickReverseGeocode
{
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){myLatitude, myLongitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark-tableview的代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_mainTable) {
        localtionSearchCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        BMKPoiInfo *info=[groupArray objectAtIndex:indexPath.row];
        [cell setFirstLabel:info.name andSubtitle:info.address];
        if(self.poiInfo!=nil &&  [info.uid isEqual:self.poiInfo.uid]){
            cell.selectedView.hidden=NO;
        }else{
            cell.selectedView.hidden=YES;
        }
        
        
        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
        return cell;


    }else
    {
        //无结果的时候填充空的数据
        if (searchArray.count==0) {
            localtionSearchCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [cell setFirstLabel:@"" andSubtitle:@""];
            cell.selectedView.hidden=YES;
            return cell;

        }else
        {
            localtionSearchCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            BMKPoiInfo *info=[searchArray objectAtIndex:indexPath.row];
            [cell setFirstLabel:info.name andSubtitle:info.address];
            if(self.poiInfo!=nil &&  [info.uid isEqual:self.poiInfo.uid]){
                cell.selectedView.hidden=NO;
            }else{
                cell.selectedView.hidden=YES;
            }
            
            
            [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
            [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
            return cell;

        }
       
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView==_mainTable) {
        return groupArray.count;
    }else
    {
        if (searchArray.count==0) {
            return 10;
        }else
        {
            return searchArray.count;

        }

    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BMKPoiInfo *info;
    if (tableView==_mainTable) {
        info=[groupArray objectAtIndex:indexPath.row];
        
    }else
    {
        info=[searchArray objectAtIndex:indexPath.row];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchPoiItemClick:)]){
        [self.delegate searchPoiItemClick:info];
    }
    [_searchBar endEditing:YES];


    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark 定位回调
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser{
    
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser{
    
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    myLatitude=userLocation.location.coordinate.latitude;
    myLongitude=userLocation.location.coordinate.longitude;
    
    //停止定位
    [_locService stopUserLocationService];
    
    [self onClickReverseGeocode];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.strongSearchDisplayController=nil;
    
    _geocodesearch.delegate = nil;
    _poisearch.delegate = nil;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self;
}

- (void)dealloc {
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    if(_poisearch!=nil){
        _poisearch=nil;
    }
}

- (void)leftButtonClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
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
