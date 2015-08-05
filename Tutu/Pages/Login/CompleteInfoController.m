//
//  CompleteInfoController.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "CompleteInfoController.h"
#import "ManagerCell.h"
#import "SetNickName.h"
#import "ChangePassWordViewController.h"
#import "LoginViewController.h"
#import "SignChangeViewController.h"
#import "UIView+Border.h"
#define SEX 8001
#define PHOTO 8000
#define AREA_TAG 100
#define LOGOUT_TAG 1000
#import "XGPush.h"
#import "XGSetting.h"
#import "AppDelegate.h"
#import "AuthorizationGuideController.h"
#import "NSDate+Helper.h"
#import "UserInfoDB.h"

@interface CompleteInfoController ()
{
    NSMutableArray * managerArray;
    float width;
    float height;
    UIDatePicker * datepicker;
    UIImagePickerController * imagepicker;
    
    NSString * fullPathOfFile;
}
@end

@implementation CompleteInfoController

- (void)dealloc
{

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self bk_performBlock:^(id obj) {
        [self refreshDatas];
        [self acquireDate];
    } afterDelay:0.0f];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    

    UIScreen * mainScree = [UIScreen mainScreen];
    width = mainScree.applicationFrame.size.width;
    height = mainScree.applicationFrame.size.height+20;
    
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_account_manager") forState:UIControlStateNormal];
    self.menuTitleButton.titleLabel.font = TitleFont;
  //  [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    [self.menuRightButton setHidden:YES];
    
    
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,84)];
    [footView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];

    _signOut = [UIButton buttonWithType:UIButtonTypeCustom];
    _signOut.frame = CGRectMake(0, 20, self.view.frame.size.width, 44);
    [_signOut addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [_signOut addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];

    [_signOut setTitleColor:UIColorFromRGB(0XF24C4C) forState:UIControlStateNormal];
    [_signOut setBackgroundColor:[UIColor whiteColor]];
    [_signOut setTitle:TTLocalString(@"TT_logout") forState:UIControlStateNormal];
    [_signOut setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _signOut.titleLabel.font = [UIFont systemFontOfSize:16];
    [_signOut addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];
    [_signOut setHidden:YES];
    [footView addSubview:_signOut];
    
    _infoListView.tableFooterView = footView;

    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    
    _dateAnimationView = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, height)];
//    _dateAnimationView.alpha =0.8;
    [_dateAnimationView setBackgroundColor:[UIColor clearColor]];

    UITapGestureRecognizer * tapDismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dateHidden)];
    [_dateAnimationView addGestureRecognizer:tapDismiss];

    

    datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, height-216,width, 216)];
    datepicker.alpha =1;
    [datepicker setBackgroundColor:[UIColor whiteColor]];
    datepicker.datePickerMode = UIDatePickerModeDate;
    datepicker.userInteractionEnabled = YES;
    datepicker.locale=[NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    datepicker.maximumDate = [NSDate date];
    [_dateAnimationView addSubview:datepicker];
    
    UIView * clearview = [[UIView alloc]initWithFrame:CGRectMake(0, 0,width, 20)];
//    [clearview addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];

    [clearview setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    _infoListView.tableHeaderView =clearview;
    
    
    
    UIView * whiteView = [[UIView alloc]initWithFrame:CGRectMake(0,datepicker.frame.origin.y-44, width, 44)];
    [whiteView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [whiteView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [whiteView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];

    
    UIButton * cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame= CGRectMake(0, 0, 44, 44);
    [cancel setImage:[UIImage imageNamed:@"closeDefault.png"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"closeHelight.png"] forState:UIControlStateHighlighted];
    [cancel setImageEdgeInsets:UIEdgeInsetsMake(12,12,12,12)];
//    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(dateHidden) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:cancel];
    
    UIButton * save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.frame= CGRectMake(width - 44 ,0, 44, 44);
    [save setImage:[UIImage imageNamed:@"selectDefault.png"] forState:UIControlStateNormal];
    [save setImage:[UIImage imageNamed:@"selectHelight.png"] forState:UIControlStateHighlighted];
    [save setImageEdgeInsets:UIEdgeInsetsMake(12,12,12,12)];
//    [save setTitle:@"保存" forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveDate) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:save];
    [_dateAnimationView addSubview:whiteView];

    
    [self.view addSubview:_dateAnimationView];

//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector()];
//    [self.view addGestureRecognizer:tap];
    UIControl * control  = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [control addTarget:self action:@selector(dismissDate) forControlEvents:UIControlEventTouchUpInside];
//    [self bk_performBlock:^(id obj) {
//        [self refreshDatas];
//    } afterDelay:0.01f];
   
    _infoListView.separatorColor = HEXCOLOR(ListLineColor);
    _infoListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}




-(void)selectAtIndex:(NSInteger)index
{
    
}

-(void)dismissDate
{
//    消失
}



-(void)acquireDate
{
//    API_GET_USERINFO(model.uid)
    [[RequestTools getInstance] get:API_GET_SELFINFO isCache:NO completion:^(NSDictionary *dict) {
        UserInfo *info=[[LoginManager getInstance] parseDictData:dict[@"data"]];
        [[LoginManager getInstance] saveInfoToDB:info];
        
        [self refreshDatas];

    } failure:^(ASIHTTPRequest *request, NSString *message) {
        [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}






-(void)refreshDatas
{
    [self setTableArray];
    [_infoListView reloadData];
}

-(void)setTableArray
{
    [_signOut setHidden:NO];
    UserInfo * model = [[LoginManager getInstance]getLoginInfo];
    NSString * gender = nil;
    if (model) {
        if (model.gender!=nil && model.gender.integerValue ==1){
            gender = TTLocalString(@"TT_boy");
        }
        else if(model.gender!=nil && model.gender.integerValue ==2)
        {
            gender = TTLocalString(@"TT_girl");
        }
        else
        {
            gender = TTLocalString(@"TT_no_setting");
        }
    }
    NSString * area = nil;
    if (model.province!=nil && model.city!=nil  && ( model.province.length>0 || model.city.length>0)) {
        area = [NSString stringWithFormat:@"%@ %@",model.province,model.city];
    }
    else
    {
        area = model.area;
    }
    NSString * birth = nil;
    if (model.birthday!=nil && model.birthday!=nil) {
        birth = model.birthday;
    }
    else
    {
        birth = TTLocalString(@"TT_no_setting");
    }
    
    NSString * sign = nil;
    if (model.sign!=nil && model.sign!=nil) {
        sign = model.sign;
    }
    else
    {
        sign = TTLocalString(@"TT_no_setting");
    }
    NSString * avatar = @"";
    if (model.avatartime!=nil && model.avatartime) {
        avatar = model.avatartime;
    }
    
    
    NSArray * arry =nil;
   arry=  @[
      @[
          @{@"title":TTLocalString(@"TT_avatar"),@"type":@"1",@"image":avatar,@"detail":@""},
          @{@"title":TTLocalString(@"TT_nickname"),@"type":@"2",@"image":@"",@"detail":model.nickname},
          @{@"title":TTLocalString(@"TT_tutu_number"),@"type":@"3",@"image":@"",@"detail":model.uid},
          @{@"title":TTLocalString(@"TT_gender"),@"type":@"2",@"image":TTLocalString(@"TT_avatar"),@"detail":gender},
          @{@"title":TTLocalString(@"TT_birthday"),@"type":@"2",@"image":@"",@"detail":birth},
          @{@"title":TTLocalString(@"TT_area"),@"type":@"2",@"image":TTLocalString(@"TT_avatar"),@"detail":area},
          @{@"title":TTLocalString(@"TT_sign"),@"type":@"2",@"image":TTLocalString(@"TT_avatar"),@"detail":sign}],
      @[
          @{@"title":TTLocalString(@"TT_change_password"),@"type":@"0",@"image":TTLocalString(@"TT_avatar"),@"detail":@""}
          ]
      ];
    
    if ([model.isQQLogin boolValue]==1) {
        arry =@[
                @[
                    @{@"title":TTLocalString(@"TT_avatar"),@"type":@"1",@"image":avatar,@"detail":@""},
                    @{@"title":TTLocalString(@"TT_nickname"),@"type":@"2",@"image":@"",@"detail":model.nickname},
                    @{@"title":TTLocalString(@"TT_tutu_number"),@"type":@"3",@"image":@"",@"detail":model.uid},
                    @{@"title":TTLocalString(@"TT_gender"),@"type":@"2",@"image":TTLocalString(@"TT_avatar"),@"detail":gender},
                    @{@"title":TTLocalString(@"TT_birthday"),@"type":@"2",@"image":@"",@"detail":birth},
                    @{@"title":TTLocalString(@"TT_area"),@"type":@"2",@"image":TTLocalString(@"TT_avatar"),@"detail":area},
                    @{@"title":TTLocalString(@"TT_sign"),@"type":@"2",@"image":TTLocalString(@"TT_avatar"),@"detail":sign}]
                ];
    }
    managerArray = [[NSMutableArray alloc]init];
    for (NSArray * array in arry) {
        NSMutableArray * aaarrr =[[NSMutableArray alloc]init];
        for (NSDictionary * dictionary in array) {
            ManagerUserModel * model = [[ManagerUserModel alloc]initWithDictionary:dictionary];
            [aaarrr addObject:model];
        }
        [managerArray addObject:aaarrr];
    }
    
}





-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}

-(void)saveDate
{
    NSDate * sendDate=datepicker.date;
    NSDateFormatter * datformatter=[[NSDateFormatter alloc] init];
    [datformatter setDateFormat:@"YYYYMMdd"];

    
    NSDateFormatter * newdatformate=[[NSDateFormatter alloc] init];
    [newdatformate setDateFormat:@"YYYY-MM-dd"];
    NSString * birthString=[newdatformate stringFromDate:sendDate];
    
    [self setUserInfo:@"birthday" object:birthString];
    
    [self dateHidden];
}


-(void)dateHidden
{
    [UIView animateWithDuration:0.3 animations:^{
        _dateAnimationView.alpha = 0;
        _dateAnimationView.frame = CGRectMake(0, height, width, height);
        
    }];
}



-(void)signOut:(id)sender
{

    
    LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:TTLocalString(@"TT_confirm_logout?") delegate:self otherButton:@[TTLocalString(@"TT_logout")] cancelButton:TTLocalString(@"TT_cancel")];
    sheet.tag = LOGOUT_TAG;
    
    [sheet showInView:nil];
}


-(IBAction)toHomePage:(id)sender
{
    UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)completeUserInfo
{
    [self toHomePage:nil];
}



#pragma mark TableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell =[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    NSInteger section = indexPath.section;
    if (section==0) {
        switch (indexPath.row) {
            case 0:
            {
                [_locateView hidden];
//                更改头像
                LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:nil delegate:self otherButton:@[TTLocalString(@"TT_take_photo"),TTLocalString(@"TT_photo_album")] cancelButton:TTLocalString(@"TT_cancel")];
                sheet.tag = PHOTO;
                [sheet showInView:nil];
                break;
            }
            case 1:
            {
//                更改昵称
                [_locateView hidden];
                SetNickName * nicknameController  = [[SetNickName alloc]initWithTitle:TTLocalString(@"TT_set_nickname") accessToken:nil openID:nil];
                [self.navigationController pushViewController:nicknameController animated:YES];

                break;
            }
            case 2:
            {
                [_locateView hidden];
                ManagerCell *managerCell = (ManagerCell *)cell;
                [managerCell.detailInfoLabel becomeFirstResponder];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                [menu setTargetRect:managerCell.detailInfoLabel.frame inView:managerCell.detailInfoLabel];
                [menu setMenuVisible:YES animated:YES];
                break;
            }
            case 3:
            {
                [_locateView hidden];
                //                性别
                LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:nil delegate:self otherButton:@[TTLocalString(@"TT_boy"),TTLocalString(@"TT_girl")] cancelButton:TTLocalString(@"TT_cancel")];
                sheet.tag = SEX;
                [sheet showInView:nil];
                
                
                break;
                
            }
            case 4:
            {
                //                生日
                [_locateView hidden];

                UserInfo *userModel = [[LoginManager getInstance]getLoginInfo];
                if (userModel.birthday.length > 0) {
                    NSDate *date = [NSDate dateFromString:userModel.birthday withFormat:[NSDate dateFormatString]];
                    if(date){
                        [datepicker setDate:date];
                    }else{
                        [datepicker setDate:[NSDate date]];
                    }
                }else{
                    [datepicker setDate:[NSDate date]];
                }
                [UIView animateWithDuration:0.3 animations:^{
                    _dateAnimationView.frame =CGRectMake(0, 0, width, height);
                    _dateAnimationView.alpha = 1;
                }];

                break;
            }
            case 5:
            {
//                [_locateView hidden];
                
//              地区
                _locateView = [[TSLocateView alloc] initWithTitle:TTLocalString(@"TT_location_city") delegate:self];
                _locateView.tag=AREA_TAG;
                [_locateView showInView:self.view];
                break;
            }
            case 6:
            {
                [_locateView hidden];
//              签名
                SignChangeViewController * sign = [[SignChangeViewController alloc]init];
                [self.navigationController pushViewController:sign animated:YES];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        [_locateView hidden];
        
        
//        if () {
//            
//        }
        
        ChangePassWordViewController * passWord = [[ChangePassWordViewController alloc]init];
        [self.navigationController pushViewController:passWord animated:YES];

//        修改密码
    }
}




- (void)copyTutuNumber:(id)sender{


}


#pragma mark UIActionSheetDelegate

- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if (tag == SEX) {
        
        UserInfo * userModel = [[LoginManager getInstance]getLoginInfo];
        switch (buttonIndex) {
            case 0:
            {
                if ([userModel.gender integerValue]==1) {
                    break;
                }
                [self setUserInfo:@"gender" object:@"1"];
                break;
                
            }
            case 1:
            {
                if ([userModel.gender integerValue]==2) {
                    break;
                }
                [self setUserInfo:@"gender" object:@"2"];
                break;
            }
            default:
                break;
        }
    }
    else if(tag == PHOTO)
    {
        switch (buttonIndex) {
            case 0:
            {
                if ([SysTools isHasCaptureDeviceAuthorization]) {
                    imagepicker = nil;
                    imagepicker=[[UIImagePickerController alloc]init];
                    imagepicker.delegate= self;
                    imagepicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                    [self playerSoundWith:@"comment"];
                    imagepicker.allowsEditing=YES;
                    [self presentViewController:imagepicker animated:YES completion:^{
                    }];
                    
                }else{
                    AuthorizationGuideController *vc = [[AuthorizationGuideController alloc]init];
                    vc.authorizatonType = AuthorizationTypeCaptureDevice;
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
                break;
            }
            case 1:
            {
                //                从相册选择
                
                if ([SysTools isHasPhotoLibraryAuthorization]) {
                    imagepicker = nil;
                    imagepicker=[[UIImagePickerController alloc]init];
                    imagepicker.delegate=self;
                    imagepicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    if ([imagepicker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                        [imagepicker.navigationBar setBarTintColor:UIColorFromRGB(SystemColor)];
                        [imagepicker.navigationBar setTranslucent:YES];
                        [imagepicker.navigationBar setTintColor:[UIColor whiteColor]];
                    }else{
                        [imagepicker.navigationBar setBackgroundColor:UIColorFromRGB(SystemColor)];
                    }
                    [imagepicker.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
                    
                    
                    imagepicker.allowsEditing=YES;
                    [self presentViewController:imagepicker animated:YES completion:^{
                        
                    }];
                }else{
                    AuthorizationGuideController *vc = [[AuthorizationGuideController alloc]init];
                    vc.authorizatonType = AuthorizationTypePhotoLibrary;
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
                
                break;
            }
            default:
                break;
        }
    }else if (tag == LOGOUT_TAG){
        if (buttonIndex ==0) {
            [self realSignOut];
        }
    }

}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(actionSheet.tag==AREA_TAG){
        if(buttonIndex == 0) {
            return;
        }

        TSLocateView *locateView = (TSLocateView *)actionSheet;
        
        CityModel *location = locateView.locate;
        NSLog(@"city:%@ lat:%@ lon:%@ province:%@", location.cityname, location.proid, location.citysort,location.pname);
        NSString * st = [NSString stringWithFormat:@"province=%@&city=%@",location.pname,location.cityname];
        [[RequestTools getInstance] get:API_ADD_SETUSERINFOS(st) isCache:NO completion:^(NSDictionary *dict) {
            UserInfo * model =[[LoginManager getInstance]getLoginInfo];
            
            model.city = [[dict objectForKey:@"data"] objectForKey:@"city"];
            model.province = [[dict objectForKey:@"data"] objectForKey:@"province"];
            
            [[LoginManager getInstance] saveInfoToDB:model];
            
            [self refreshDatas];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEUSERINFO object:nil];
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
        
        }];
        //You can uses location to your application.
    }
}



#pragma mark TableViewDateSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return 20;
}
//
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return nil;
    }
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [view addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [view addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    return view;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [managerArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[managerArray objectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ManagerCell" owner:nil options:nil] lastObject];
    }
//    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell.imagePath=fullPathOfFile;
    cell.delegate = self;
    [cell setWithModel:[[managerArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    if (indexPath.row == [[managerArray objectAtIndex:indexPath.section] count]-1) {
        [cell setLineHidden];
    }
    
    [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
    [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    return cell;
}

- (void)label:(TCCopyableLabel *)copyableLabel didCopyText:(NSString *)copiedText{

    [self showNoticeWithMessage:TTLocalString(@"TT_copy_success") message:TTLocalString(@"TT_copy_success") bgColor:TopNotice_Block_Color];

}
#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagepicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage * oriImage = [info objectForKey:UIImagePickerControllerEditedImage];
//        发送图片
        if (oriImage) {
            [self postAvatar:oriImage];
        }
        
    }
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImage * originImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (originImage) {
            [self postAvatar:originImage];
        }
    }
}

-(void)postAvatar:(UIImage*)image
{
    NSDate * imageDate = [NSDate date];
    NSString * dateString = dateTransformStringAsYMDHMS(imageDate);
    NSString * fname = [NSString stringWithFormat:@"image100%@.jpg",dateString];
    
    [self saveImage:image WithName:fname];
}

-(void)setUserInfo:(NSString*)type object:(NSString *)info
{
    [[RequestTools getInstance] get:API_ADD_SETUSERINFO(type, info) isCache:NO completion:^(NSDictionary *dict) {
        UserInfo * model = [[LoginManager getInstance]getLoginInfo];
        
        if ([type isEqualToString:@"gender"]) {
            model.gender=info;
        }
        else if([type isEqualToString:@"birthday"])
        {
            model.birthday=info;
        }
        else
        {
            
        }
        [[LoginManager getInstance] saveInfoToDB:model];
        
        [self refreshDatas];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEUSERINFO object:nil];

    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {

    }];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagepicker dismissViewControllerAnimated:YES completion:^{

    }];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)saveImage:(UIImage *)upImage WithName:(NSString*)imageName
{
//    [SysTools clearAvatar];
    NSData * imageData =UIImageJPEGRepresentation(upImage, 0.5f);
    fullPathOfFile=getImageFilePath(imageName);
    [imageData writeToFile:fullPathOfFile atomically:YES];
    
    [_infoListView reloadData];
    
    [self postDocumentImage:imageName];
}

-(void)postDocumentImage:(NSString *)imageName
{
    NSString * imagePath = getImageFilePath(imageName);
    
    
    ASIFormDataRequest * postImageRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_ADD_SETUSERAVATAR]];
    [postImageRequest setFile:imagePath forKey:@"avatarfile"];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    if (exist) {
        
        [[RequestTools getInstance] post:API_ADD_SETUSERAVATAR filePath:imagePath fileKey:@"avatarfile" params:nil completion:^(NSDictionary *dict) {
            //            上传图片成功
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            UserInfo * model = [[LoginManager getInstance]getLoginInfo];
            
            [SysTools clearAvatar];
            if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"code"]] isEqualToString:@"10000"]) {
                model.avatartime = [[dict objectForKey:@"data"] objectForKey:@"avatartime"];
            }
            
            //保存图片的时间到本地
            [[LoginManager getInstance] saveInfoToDB:model];
            
            [self refreshDatas];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEUSERINFO object:nil];
            
            [imagepicker dismissViewControllerAnimated:YES completion:^{
            }];
        } failure:^(ASIFormDataRequest *request, NSString *message) {
            //            上传图片失败
            [imagepicker dismissViewControllerAnimated:YES completion:^{
            }];
        } finished:^(ASIFormDataRequest *request) {
        }];
    }
    else
    {
        
    }
    
}

//推出登录时，需要先取消推送消息。
-(void)realSignOut
{
    [[RequestTools getInstance]get:API_SSO_LOGOUT isCache:NO completion:^(NSDictionary *dict) {
       [[LoginManager getInstance]loginOut];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
    
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
