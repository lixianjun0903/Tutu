//
//  SetNickName.m
//  Tutu
//
//  Created by 刘大治 on 14-10-22.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SetNickName.h"
#import "UIView+Border.h"
#import "RecommendFollowVController.h"

@interface SetNickName ()
{
    UserInfo * model;
    int type;
    
}
@end

@implementation SetNickName

-(id)initWithTitle:(NSString* )title accessToken:(NSString*)token openID:(NSString*)openid
{
    self = [super init];
    if (self) {
        _nick = title;
        _accesstoken = token;
        _qqOpenid = openid;
        type=1;
    }
    return self;
}

-(id)initWithTitle:(NSString *)title accessToken:(NSString *)token wbuid:(NSString *)uid date:(NSDate *)expirsindate{
    self = [super init];
    if (self) {
        _nick = title;
        _accesstoken = token;
        _wbid = uid;
        _expiresinDate=expirsindate;
        type=2;
    }
    return self;
}

- (IBAction)buttonClick:(id)sender{
    NSInteger tag = ((UIButton *)sender).tag;
    if (tag == BACK_BUTTON) {
        [self goBack:sender];
    }else if (tag == RIGHT_BUTTON){
        [self saveNickName];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    model = [[LoginManager getInstance] getLoginInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNicknameuserable) name:UITextFieldTextDidChangeNotification object:nil];
    
    _textBackView.layer.cornerRadius = 3;
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    
    [self createTitleMenu];
    
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];

    [self.menuTitleButton setTitle:_nick forState:UIControlStateNormal];
    
    
    if ([_nick isEqualToString:TTLocalString(@"TT_set_nickname")]) {
        [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickDefautl"] forState:UIControlStateNormal];
        [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickHelight"] forState:UIControlStateHighlighted];
        [self.menuLeftButton setTitle:nil forState:UIControlStateNormal];
        [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(12,8,12,16)];
        self.nickInput.text=model.nickname;
    }
    else
    {
        [self.menuRightButton setImage:nil forState:UIControlStateNormal];
        [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
        [self.menuRightButton setTitle:TTLocalString(@"TT_finish") forState:UIControlStateNormal
         ];
        self.nickInput.text=_nickname;
    }
    
    [self.nickInput setBackgroundColor:[UIColor clearColor]];
    [self.nickInput setTextColor:UIColorFromRGB(TextBlackColor)];
    
    
    [self.msgLabel setTextColor:UIColorFromRGB(NoticeColor)];
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapResignresponder)];
    [self.view addGestureRecognizer:gesture];
    
    [_textBackView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    [_textBackView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:0.5];
    // Do any additional setup  after loading the view from its nib.
    
    //导致加载慢得原因
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_nickInput becomeFirstResponder];
//    });
}

-(void)tapResignresponder
{
    [_nickInput resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [_nickInput resignFirstResponder];
}

-(void)leftButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)saveNickName
{

    if ([_nick isEqualToString:TTLocalString(@"TT_set_nickname")]) {
        if(_nickInput.text==nil || [@"" isEqual:_nickInput.text]){
            [self showNoticeWithMessage:TTLocalString(@"TT_new_a_nickname!") message:nil bgColor:TopNotice_Red_Color];
            [_nickInput becomeFirstResponder];
            return;
        }
        if(!validateNickName(_nickInput.text)){
            [self.msgLabel setText:TTLocalString(@"TT_set_nickname_desc")];
            
            [_nickInput becomeFirstResponder];
            return;
        }
        if([_nickInput.text isEqualToString: model.nickname])
        {
            return;
        }
        NSString *api = API_ADD_SETUSERINFO(@"nickname", _nickInput.text);
        [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
            model.uid=model.uid;
            model.area=model.area;
            model.gender=model.gender;
            model.nickname=model.nickname;
            [[LoginManager getInstance] saveInfoToDB:model];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEUSERINFO object:nil];

        } failure:^(ASIHTTPRequest *request, NSString *message) {
            _msgLabel.text = message;
        } finished:^(ASIHTTPRequest *request) {
        }];
        //    保 存成功后退出页面
    
        if ([_nick isEqualToString:TTLocalString(@"TT_set_nickname")]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        NSString *api=@"";
        if(type==1){
            api = API_QQFISTREGIST(_accesstoken, _qqOpenid, _nickInput.text);
        }else{
            api = API_LOGIN_SinaReg(_wbid, _accesstoken, (int)[_expiresinDate timeIntervalSince1970], _nickInput.text);
        }
        //    完善信息
        [[RequestTools getInstance] get:api isCache:NO completion:^(NSDictionary *dict) {
            [[LoginManager getInstance] doLoginWidthDict:[dict objectForKey:@"data"]];
            RecommendFollowVController *vc = [[RecommendFollowVController alloc]init];
            [self openNav:vc sound:nil];
            
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self.msgLabel setText:message];
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }
    

    
}

-(void)checkNicknameuserable
{
//    int size = getStringCharCount(_nickInput.text);
    
    
        if (!validateNickName(_nickInput.text)) {
            [self.msgLabel setText:TTLocalString(@"TT_set_nickname_desc")];
            [_nickInput becomeFirstResponder];
            return;
        }
        if([_nickInput.text isEqualToString: model.nickname])
        {
            return;
        }
        [[RequestTools getInstance] get:API_CHECKRENAME(_nickInput.text) isCache:NO completion:^(NSDictionary *dict) {
            if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"code"]] isEqualToString:@"10000"]) {
                [self.menuRightButton setEnabled:YES];
                [self.msgLabel setText:@""];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
            NSDictionary * dictionary = [request.responseString objectFromJSONString];
            if ([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]]isEqualToString:@"100007"]) {
                if ([_nick isEqualToString:TTLocalString(@"TT_perfect_information")]) {
                    [self.msgLabel setText:@""];
                    return;
                }
            }
            [self.msgLabel setText:message];
            
        } finished:^(ASIHTTPRequest *request) {
            [self.menuRightButton setEnabled:YES];
            
        }];
    
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
