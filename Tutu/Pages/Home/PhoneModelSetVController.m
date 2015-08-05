//
//  PhoneModelSetVController.m
//  Tutu
//
//  Created by gexing on 5/14/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "PhoneModelSetVController.h"
#import "PhoneModelCell.h"
#import "UILabel+Additions.h"
#import "PhoneModel.h"
#import "NSDate+Helper.h"
@interface PhoneModelSetVController () <PhoneModelCellDelegate>
{
    UIImageView *_avatarView;
    UILabel     *_nameLabel;
    UILabel     *_timeLabel;
    UILabel     *_phoneNameLabel;
    UITextField *_phoneNameField;
    NSMutableArray *_dataArray;
    NSString    *_phoneName;
    int         _phoneType;
}
@end
static NSString * phoneModelCell = @"PhoneModelCell";
@implementation PhoneModelSetVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTitleMenu];
    
    self.view.backgroundColor = HEXCOLOR(0xF2F3F7);
    
    _dataArray = [[NSMutableArray alloc]init];
   
    [self.menuLeftButton setTitle:TTLocalString(@"TT_cancel") forState:UIControlStateNormal];
    [self.menuLeftButton setImage:nil forState:UIControlStateNormal];
    [self.menuLeftButton setImage:nil forState:UIControlStateHighlighted];
    self.menuLeftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.menuLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.menuRightButton setTitle:TTLocalString(@"TT_make_sure") forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
    self.menuRightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.menuRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.menuTitleButton setTitle:TTLocalString(@"TT_my_phone_name") forState:UIControlStateNormal];
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight)];
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    [self.view addSubview:_mainTable];
    _mainTable.separatorStyle = UITableViewCellSelectionStyleNone;
    
    _mainTable.backgroundColor = [UIColor clearColor];
    
    [_mainTable registerNib:[UINib nibWithNibName:phoneModelCell bundle:nil] forCellReuseIdentifier:phoneModelCell];
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    footView.backgroundColor = [UIColor whiteColor];
    _mainTable.tableFooterView = footView;
    _mainTable.rowHeight = 40;
    
    [self refreshData];
}
//加载手机标识
- (void)refreshData{
    [[RequestTools getInstance]get:API_PhoneNameList isCache:NO completion:^(NSDictionary *dict) {
        NSArray *data = dict[@"data"];
        NSArray *models = [PhoneModel initModelsWithArray:data];
        if (models.count > 0) {
            [_dataArray addObjectsFromArray:models];
            for (PhoneModel *model in _dataArray) {
                if (model.isused == 1) {
                    _phoneName = model.typeName;
                    _phoneType = model.typeId;
                }
            }
            [_mainTable reloadData];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}
- (void)phoneNameClick:(PhoneModel *)phoneModel index:(NSInteger)index{
    _phoneNameLabel.text = phoneModel.typeName;
    _phoneType = phoneModel.typeId;
    _phoneName = phoneModel.typeName;
    if (_dataArray.count > index) {
        for (PhoneModel *model in _dataArray) {
            model.isused = 0;
        }
        phoneModel.isused = 1;
        [_mainTable reloadData];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        return _dataArray.count / 2 + ((_dataArray.count % 2 == 0) ? 0: 1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhoneModelCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneModelCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PhoneModel *leftModel = nil;
    if (_dataArray.count > indexPath.row * 2) {
       leftModel = _dataArray[indexPath.row * 2];
    }
    PhoneModel *rightModel = nil;
    if (_dataArray.count > (indexPath.row * 2 + 1)) {
        rightModel = _dataArray[indexPath.row * 2 + 1];
    }
    cell.delegate = self;
    cell.index = indexPath.row;
    [cell relaodWith:leftModel right:rightModel];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *header = [self createHeaderView];
        return header.mj_height;
    }else
        return 0;
}
- (UIView *)createHeaderView{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 245)];
    header.backgroundColor = HEXCOLOR(0xF2F3F7);
  
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth - 20, 130)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 3.f;
    [header addSubview:bgView];
    
    _avatarView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"avatar_default"]];
    _avatarView.frame = CGRectMake(10, 10, 40, 40);
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.mj_width / 2.f;
    _avatarView.userInteractionEnabled = YES;
    [bgView addSubview:_avatarView];
    
    
    _nameLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(DrakGreenNickNameColor)];
    _nameLabel.frame = CGRectMake(_avatarView.max_x + 10, 14, bgView.mj_width - 30 - _avatarView.mj_width, 17);
    _nameLabel.userInteractionEnabled = YES;
    [bgView addSubview:_nameLabel];
    
    UIImageView *timeView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_time_icon"]];
    timeView.frame = CGRectMake(_nameLabel.mj_x, _nameLabel.max_y + 7,10, 10);
    [bgView addSubview:timeView];
    
    _timeLabel = [UILabel labelWithSystemFont:10 textColor:HEXCOLOR(0x99999)];
    _timeLabel.frame = CGRectMake(timeView.max_x + 5, timeView.mj_y,200, 11);
    [bgView addSubview:_timeLabel];
    //显示当前时间
    NSDate *now = [NSDate date];
    NSString *timeSting = [NSDate stringFromDate:now withFormat:[NSDate timeFormatString]];
    _timeLabel.text = timeSting;

    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarNameTap:)];
    [_avatarView addGestureRecognizer:avatarTap];
    
    

    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarNameTap:)];
    [_nameLabel addGestureRecognizer:nameTap];
    
    UserInfo *info = [[LoginManager getInstance] getLoginInfo];
    [_avatarView sd_setImageWithURL:StrToUrl([SysTools getHeaderImageURL:info.uid time:info.avatartime]) placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _nameLabel.text = info.nickname;
    
    UILabel *titleLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(TextBlackColor)];
    titleLabel.text = TTLocalString(@"TT_set_phone_name_desc");
    titleLabel.frame = CGRectMake(_avatarView.mj_x, _avatarView.max_y + 12,bgView.mj_width - 20, 2000);
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textColor = HEXCOLOR(TextBlackColor);
    [titleLabel sizeToFit];
    [bgView addSubview:titleLabel];
    
    UIImageView *phoneFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phone_icon"]];
    phoneFlag.frame = CGRectMake(15, titleLabel.max_y + 12, 7, 10);
    [bgView addSubview:phoneFlag];
    
    _phoneNameLabel = [UILabel labelWithSystemFont:10 textColor:HEXCOLOR(0x999999)];
    _phoneNameLabel.frame = CGRectMake(phoneFlag.max_x + 5, phoneFlag.mj_y, bgView.mj_width - 35, 11);
    [bgView addSubview:_phoneNameLabel];
    _phoneNameLabel.text = _phoneName;
    
    bgView.frame = CGRectMake(bgView.mj_x, bgView.mj_y, bgView.mj_width, _phoneNameLabel.max_y + 12);
    
    UIImageView *pointView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phoneModel_point"]];
    pointView.frame = CGRectMake(50, bgView.max_y,16, 8);
    [header addSubview:pointView];
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.max_y + 18, ScreenWidth,40)];
    buttomView.backgroundColor = [UIColor whiteColor];
    [header addSubview:buttomView];
    
    UILabel *title = [UILabel labelWithSystemFont:15 textColor:HEXCOLOR(TextBlackColor)];
    title.text = TTLocalString(@"TT_choose_phone_model");
    title.frame = CGRectMake(15, 16, 200, 16);
    [buttomView addSubview:title];
    
    header.frame = CGRectMake(header.mj_x, header.mj_y,header.mj_width,buttomView.max_y);
    
//    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, 0.7)];
//    lineView.backgroundColor = HEXCOLOR(ListLineColor);
//    [buttomView addSubview:lineView];
    
//    _phoneNameField = [[UITextField alloc]initWithFrame:CGRectMake(15, 10, ScreenWidth - 60, 24)];
//    _phoneNameField.placeholder = @"请输入文字emoji表情";
//    [buttomView addSubview:_phoneNameField];
    
    return header;
}
- (void)avatarNameTap:(id)sender{

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
      return [self createHeaderView];
    }else{
        return nil;
    }
}
- (IBAction)buttonClick:(id)sender{
    if (((UIButton *)sender).tag == BACK_BUTTON) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (_phoneType > 0) {
            [[RequestTools getInstance] get:API_Set_Phone_Name(_phoneType) isCache:NO completion:^(NSDictionary *dict) {
                if ([dict[@"code"]intValue] == 10000) {
                    [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_modify")];
                    [UserDefaults setValue:_phoneName forKey:UserDefaults_PhoneName_Key];
                    //[NOTIFICATION_CENTER postNotificationName:Notification_Phone_Name_Change object:_phoneName];
                    //修改成功后2秒返回上一页
                    [self bk_performBlock:^(id obj) {
                        [self goBack:nil];
                    } afterDelay:1.2];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
        }
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
