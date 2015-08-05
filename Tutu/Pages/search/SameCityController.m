//
//  SameCityController.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SameCityController.h"
#import "UIView+Border.h"
#import "SameCityCell.h"
#import "UserDetailController.h"
#import "TSLocateView.h"
#import "UILabel+Additions.h"
#import "SendLocalTools.h"

#define ReuseIdentifierCell @"SameCityCell"

@interface SameCityController (){
    UITableView *listTable;
    NSMutableArray *listArray;
    UIButton *btnSearch;
    int w;
    // 1、选择城市查询，2、定位查询
    int searchType;
    int gender;
    //定位失败的视图
    UIView *locationFailedView;
}

@end

@implementation SameCityController

@synthesize province;
@synthesize city;




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    w=self.view.mj_width;
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_nearby") forState:UIControlStateNormal];
    if(self.fromRoot){
        self.menuLeftButton.hidden=YES;
    }
 //   [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    
    
    [self.menuRightButton setImage:[UIImage imageNamed:@"topic_more_hl"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"topic_more"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(22-4, 19/2, 22-4,19/2)];
    
    
    UIView * headBackView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.mj_width,64+StatusBarHeight)];
    [headBackView setBackgroundColor:[UIColor clearColor]];
    
    btnSearch=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setFrame:CGRectMake(0, 20, self.view.mj_width, 44)];
    if(province!=nil){
        [btnSearch setTitle:[NSString stringWithFormat:@"%@ %@",province,city] forState:UIControlStateNormal];
    }
    [btnSearch addTarget:self action:@selector(doSearch:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch addTopBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:1];
    [btnSearch addBottomBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:1];
    [btnSearch setBackgroundColor:[UIColor whiteColor]];
    [btnSearch setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
    [btnSearch setContentEdgeInsets:UIEdgeInsetsMake(0, 32, 0, 0)];
    [btnSearch.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnSearch setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIImageView *uiv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    [uiv setFrame:CGRectMake(15, 14, 16, 16)];
    [btnSearch addSubview:uiv];
    [headBackView addSubview:btnSearch];
    
    
//    [self.view addSubview:btnSearch];
    
    int ty=64;
    listArray=[[NSMutableArray alloc] init];
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0,ty, w, self.view.mj_height-ty)];
    [listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [listTable setSeparatorColor:[UIColor clearColor]];
    [listTable setBackgroundColor:[UIColor clearColor]];
    [listTable registerNib:[UINib nibWithNibName:ReuseIdentifierCell bundle:nil]  forCellReuseIdentifier:ReuseIdentifierCell];
    listTable.delegate=self;
    listTable.dataSource=self;
    listTable.rowHeight = 76;
    [listTable addTopBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:0.75];
    [listTable setTableHeaderView:headBackView];
//    [listTable addBottomBorderWithColor:[UIColor groupTableViewBackgroundColor] andWidth:0.75];
    [self.view addSubview:listTable];
    
    if (ApplicationDelegate.locSuccess == YES) {
        // 获取当前所在的城市名
        self.latitude = ApplicationDelegate.latitude;
        self.longitude = ApplicationDelegate.longitude;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        //根据经纬度反向地理编译出地址信息
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error)
         {
             if (array.count > 0)
             {
                 CLPlacemark *placemark = [array objectAtIndex:0];
                 //将获得的所有信息显示到label上
                 NSLog(@"%@",placemark.name);
                 
                 //获取城市
                 NSString *citylocal = placemark.locality;
                 
                 if (!citylocal) {
                     //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                     citylocal = placemark.administrativeArea;
                 }
                 
                 self.city = placemark.subLocality;
                 self.province = citylocal;
                 
                 [btnSearch setTitle:[NSString stringWithFormat:@"%@ %@",province,city] forState:UIControlStateNormal];
             }
             
             else if (error == nil && [array count] == 0)
             {
                 NSLog(@"No results were returned.");
                 
             }
             
             else if (error != nil)
             {
                 
                 NSLog(@"An error occurred = %@", error);
                 
             }
         }];
        
        [self doSearchText:NO];
    }else{
        [self performSelector:@selector(beginLocation) withObject:nil];
    }
    [listTable addFooterWithTarget:self action:@selector(loadMoreData)];
    gender=0;
    if ([SysTools getValueFromNSUserDefaultsByKey:NEARBYGENDER]!=nil) {
        gender = [[SysTools getValueFromNSUserDefaultsByKey:NEARBYGENDER] intValue];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNotictInfo:) name:NOTICE_UPDATE_UserInfo object:nil];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createLocationFailedView{
    if (locationFailedView == nil) {
       locationFailedView = [[UIView alloc]initWithFrame:CGRectMake(0,NavBarHeight,ScreenWidth, ScreenHeight - NavBarHeight)];
        locationFailedView.backgroundColor = HEXCOLOR(SystemGrayColor);
        UIImageView *locationImageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 89) / 2.0f ,50, 89, 126)];
        locationImageView.image = [UIImage imageNamed:@"location_error_pic_"];
        [locationFailedView addSubview:locationImageView];
        
        UILabel *errorLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(TextBlackColor)];
        errorLabel.frame = CGRectMake(0,locationImageView.max_y + 38,ScreenWidth , 17);
        errorLabel.text = TTLocalString(@"TT_location_error");
        errorLabel.textAlignment = NSTextAlignmentCenter;
        [locationFailedView addSubview:errorLabel];
       
        UILabel *guideLabel = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(TextGrayColor)];
        guideLabel.frame = CGRectMake(15, errorLabel.max_y + 12, ScreenWidth - 30, 300);
        if (iOS7) {
           guideLabel.text = TTLocalString(@"TT_open_location_ios7");
            
        }else{
           guideLabel.text = TTLocalString(@"TT_open_location_ios6");
        
        }
        CGSize size = [guideLabel getLabelSize];
        guideLabel.frame = CGRectMake(guideLabel.mj_x, guideLabel.mj_y,size.width, size.height);
        [locationFailedView addSubview:guideLabel];
    }
    [self.view addSubview:locationFailedView];
    
    
}
#pragma 数据展示
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SameCityCell *cell = (SameCityCell*)[tableView dequeueReusableCellWithIdentifier:ReuseIdentifierCell];
    if (cell == nil) {
        cell = [[SameCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdentifierCell];
    }
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
   cell.indexPath = indexPath;
    UserInfo *model=[listArray objectAtIndex:indexPath.row];
    if(model){
        [cell initDataToView:model width:w reference:ReferenceSameCityPage];
    }
    if(indexPath.row==(listArray.count-1)){
        cell.cellSepetor.hidden=YES;
    }else{
        cell.cellSepetor.hidden=NO;
    }
    
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WSLog(@"%@",indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *user=[listArray objectAtIndex:indexPath.row];
    UserDetailController *uinfo=[[UserDetailController alloc] init];
    uinfo.uid=user.uid;
    [self.navigationController pushViewController:uinfo animated:YES];
}
#pragma table end


- (void)beginLocation
{
    
    
    if ([SysTools isLocatonServicesAvailable]) {
            _locService=[[BMKLocationService alloc] init];
            _locService.delegate=self;
            [_locService startUserLocationService];
        [self.menuRightButton setHidden:NO];
    }else{
    
        [self.menuRightButton setHidden:YES];
        [self createLocationFailedView];
    }
}

#pragma mark - CoreLocation Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    self.latitude=currentLocation.coordinate.latitude;
    self.longitude=currentLocation.coordinate.longitude;
    
    //上传定位服务
    NSString *latitude=[NSString stringWithFormat:@"%f",self.latitude];
    NSString *longitude=[NSString stringWithFormat:@"%f",self.longitude];
    [[SendLocalTools getInstance] sendLocalToServer:latitude lon:longitude];
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
    {
        if (array.count > 0)
        {
            CLPlacemark *placemark = [array objectAtIndex:0];
            //将获得的所有信息显示到label上
            NSLog(@"%@",placemark.name);
            
            //获取城市
            NSString *citylocal = placemark.locality;
            
            if (!citylocal) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                citylocal = placemark.administrativeArea;
            }
            
            self.city = placemark.subLocality;
            self.province = citylocal;
            
            [btnSearch setTitle:[NSString stringWithFormat:@"%@ %@",province,city] forState:UIControlStateNormal];
        }
        
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
            
        }
        
        else if (error != nil)
        {
            
            NSLog(@"An error occurred = %@", error);
            
        }
    }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    
    [manager stopUpdatingLocation];
    
    searchType = 2;
    
    [self doSearchText:NO];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
        
    }
}



#pragma 百度地图
-(void)didFailToLocateUserWithError:(NSError *)error{
    //没有权限获取
    if (error.code == kCLErrorDenied) {
    }
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation{
    CLLocation *currentLocation = userLocation.location;
    
    self.latitude=currentLocation.coordinate.latitude;
    self.longitude=currentLocation.coordinate.longitude;
    
    //上传定位服务
    NSString *latitude=[NSString stringWithFormat:@"%f",self.latitude];
    NSString *longitude=[NSString stringWithFormat:@"%f",self.longitude];
    [[SendLocalTools getInstance] sendLocalToServer:latitude lon:longitude];
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //将获得的所有信息显示到label上
             NSLog(@"%@",placemark.name);
             
             //获取城市
             NSString *citylocal = placemark.locality;
             
             if (!citylocal) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 citylocal = placemark.administrativeArea;
             }
             
             self.city = placemark.subLocality;
             self.province = citylocal;
             
             [btnSearch setTitle:[NSString stringWithFormat:@"%@ %@",province,city] forState:UIControlStateNormal];
         }
         
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
             
         }
         
         else if (error != nil)
         {
             
             NSLog(@"An error occurred = %@", error);
             
         }
     }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [_locService stopUserLocationService];
    
    searchType=2;
    [self doSearchText:NO];
}

#pragma 定位结束


-(void)loadMoreData{
    [self doSearchText:YES];
}


-(IBAction)doSearch:(id)sender{
    TSLocateView *view=[[TSLocateView alloc] initWithTitle:@"" delegate:self];
    view.tag=110;
    [view setDefaultValue:1];
    [view showInView:self.view];
}


//type 1、查询城市 2、定位
-(void)doSearchText:(BOOL) isMore{
    NSString *startid=@"";
    if(isMore && listArray.count>0){
        startid=((UserInfo *)[listArray objectAtIndex:listArray.count-1]).uid;
    }
    
    NSString *str_api=API_Find_SameCity(startid,@"100",Load_MORE);
    str_api=[NSString stringWithFormat:@"%@&latitude=%f&longitude=%f&gender=%d",str_api,self.latitude,self.longitude,gender];
    
    //type==1为选择城市查询
    if(searchType==1){
        if([@"不限" isEqual:city]){
            self.city=@"";
        }
        str_api=[NSString stringWithFormat:@"%@&province=%@&city=%@",str_api,province,city];
    }
    
    WSLog(@"%@",str_api);
    [[RequestTools getInstance] get:str_api isCache:NO completion:^(NSDictionary *dict) {
        if(!isMore){
            [listArray removeAllObjects];
        }
        
        NSArray *datas = dict[@"data"][@"list"];
        if(datas.count==0){
            return ;
        }
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in datas) {
            UserInfo *model = [[ UserInfo alloc]initWithMyDict:dic];
            [mArray addObject:model];
        }
        
        [listArray addObjectsFromArray:mArray];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        [listTable reloadData];
        [self showPlaceholderView];
        if([listTable isFooterRefreshing]){
            [listTable footerEndRefreshing];
        }
    }];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag==110){
    TSLocateView *locateView = (TSLocateView *)actionSheet;
        if(buttonIndex==1){
            self.province=locateView.locate.pname;
            self.city=locateView.locate.cityname;
            
            [btnSearch setTitle:[NSString stringWithFormat:@"%@ %@",province,city] forState:UIControlStateNormal];
            
            searchType=1;
            [self doSearchText:NO];
        }
    }else if(actionSheet.tag==120){
        
    }
}




-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        if (_comefrom == 1) {
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
        NSArray *array = [[NSArray alloc] initWithObjects:TTLocalString(@"TT_all"),TTLocalString(@"TT_look_only_boy"),TTLocalString(@"TT_look_only_girl"),@"取消",nil];
        ListMenuView *menuView=[[ListMenuView alloc] initWithDelegate:self items:array];
        [menuView showInView:self.view];
    }
}

//选择按钮
-(void)didClickOnIndex:(NSInteger)index type:(int)tag{
    if(index<3){
        gender=(int)index;
        [SysTools syncNSUserDeafaultsByKey:NEARBYGENDER withValue:[NSString stringWithFormat:@"%d",(int)index]];
        [self doSearchText:NO];
    }
}


-(void)updateNotictInfo:(NSNotification *)not{
    UserInfo *info=not.object;
    if(info){
        for (int i=0;i<listArray.count;i++) {
            UserInfo *item=[listArray objectAtIndex:i];
            if([item.uid isEqual:info.uid]){
                item.nickname=info.nickname;
            }
        }
        [listTable reloadData];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    [self.navigationController setNavigationBarHidden:YES];
    //[self locate];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}


#pragma mark 显示提示
- (void)showPlaceholderView{
    CGPoint point = CGPointMake(ScreenWidth / 2.0f, (ScreenHeight-NavBarHeight)/2);
    if (listArray==nil || listArray.count==0){
        [self createPlaceholderView:point message:TTLocalString(@"TT_have_not_a_friend_nearby") withView:listTable];
    }else{
        [self removePlaceholderView];
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
