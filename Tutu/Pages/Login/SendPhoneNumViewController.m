//
//  SendPhoneNumViewController.m
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SendPhoneNumViewController.h"
#import "FindPassWordViewController.h"
#import "UIView+Border.h"

#import "SVWebViewController.h"

@interface SendPhoneNumViewController ()
{
    NSString * mytitlestring;
    NSInteger count;
    
    CGFloat w;
    UIImageView *checkView;
    BOOL isCheck;
}
@end

@implementation SendPhoneNumViewController
- (IBAction)buttonClick:(id)sender{
    NSInteger tag = ((UIButton *)sender).tag;
    if (tag == BACK_BUTTON) {
        [self goBack:sender];
    }else if (tag == RIGHT_BUTTON){
        [self goNext:sender];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    w=self.view.frame.size.width;
    
    [self createTitleMenu];
    [self.menuTitleButton setTitle:mytitlestring forState:UIControlStateNormal];
    [self.menuRightButton setHidden:NO];
    [self.menuRightButton setFrame:CGRectMake(w-65, StatusBarHeight, 60, 44)];
    [self.menuRightButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.menuRightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.menuRightButton setImage:nil forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
    
    
    
    [_nextButton setBackgroundColor:UIColorFromRGB(SystemColor)];
    _nextButton.layer.cornerRadius = 5;
    _nextButton.layer.masksToBounds = YES;
    
    [_num setValue:UIColorFromRGB(TextRegusterGrayColor) forKeyPath:@"_placeholderLabel.textColor"];
    [_textBack addTopBorderWithColor:UIColorFromRGB(TextRegusterGrayColor) andWidth:0.5];
    [_textBack addBottomBorderWithColor:UIColorFromRGB(TextRegusterGrayColor) andWidth:0.5];
    
    
    [_num addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // 显示用户协议
    if(self.type==FindPasswordTypeRegist){
        isCheck=YES;
        
        [self createCheckView];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_num becomeFirstResponder];
    });
}


-(void)textFieldChanged:(UITextField *)textField{
    
    if (count > textField.text.length) {
        //删除
        if (count == 5 || count == 10) {
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",textField.text];
            textField.text = [str substringToIndex:count -2];
        }
    }
    else if (count < textField.text.length){
        //增加
        if (count == 3 || count == 8) {
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",textField.text];
            [str insertString:@" " atIndex:count];
            textField.text = str;
        }
    }
    //通过count的值和当前的textField内容的长度比较，如果count大那么证明是删除，反之增加
    count = textField.text.length;
}



-(void)setTitleWithString:(NSString*)string
{
    mytitlestring  = string;
}


//发送验证码
- (IBAction)goNext:(UIButton *)btn {
    
    NSString *text=[_num.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (text==nil || [@"" isEqual:text]) {
        [_num shake];
        return;
    }
    
    
    
    if(!validateMobile(text)){
        [_num shake];
        return;
    }
    

    btn.userInteractionEnabled=NO;
    if (_type == FindPasswordTypeRegist) {
        if(!isCheck){
            [self showNoticeWithMessage:@"你还没有同意用户协议！" message:nil bgColor:TopNotice_Red_Color];
            btn.userInteractionEnabled=YES;
            return;
        }
        
//        注册发送验证码
        [[RequestTools getInstance] get:API_REGIST_GET_REGVERIFY_CODE(text) isCache:NO completion:^(NSDictionary *dict) {
            WSLog(@"%@",dict);
            if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                FindPassWordViewController * findPassWord = [[FindPassWordViewController alloc]initWithPhoneNum:text title:@"填写验证码"];
                findPassWord.type = _type;
                [self.navigationController pushViewController:findPassWord animated:YES];
            }else{
                [self showNoticeWithMessage:@"验证码错误！" message:nil bgColor:TopNotice_Red_Color];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
        } finished:^(ASIHTTPRequest *request) {
            btn.userInteractionEnabled=YES;
        }];
    }
    else if(_type == FindPasswordTypeFind)
    {
//        找密码发送验证码
        [[RequestTools getInstance] get:APP_CHECKNUM_LOGIN(text) isCache:NO completion:^(NSDictionary *dict) {
            if(dict && [[dict objectForKey:@"code"] intValue]==10000){
                FindPassWordViewController * findPassWord = [[FindPassWordViewController alloc]initWithPhoneNum:text title:@"填写验证码"];
                findPassWord.type = _type;
                [self.navigationController pushViewController:findPassWord animated:YES];
            }else{
                [self showNoticeWithMessage:@"验证码错误！" message:nil bgColor:TopNotice_Red_Color];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            [_num becomeFirstResponder];

        } finished:^(ASIHTTPRequest *request) {
//            WSLog(@"%@",request.responseString);
            btn.userInteractionEnabled=YES;
        }];
    }else if(_type==BindPhoneNumber){
        //        找密码发送验证码
        [[RequestTools getInstance] get:API_CHECK_PHONEBIND(text) isCache:NO completion:^(NSDictionary *dict) {
            FindPassWordViewController * findPassWord = [[FindPassWordViewController alloc]initWithPhoneNum:text title:@"填写验证码"];
            findPassWord.type = _type;
            [self.navigationController pushViewController:findPassWord animated:YES];
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            [self showNoticeWithMessage:message message:nil bgColor:TopNotice_Red_Color];
            [_num becomeFirstResponder];
            
        } finished:^(ASIHTTPRequest *request) {
            //            WSLog(@"%@",request.responseString);
            btn.userInteractionEnabled=YES;
        }];
    }
}


-(void)createCheckView{
    
    UIView *itemView=[[UIView alloc] initWithFrame:CGRectMake(0, 156, w, 20)];
    [itemView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:itemView];
    
    checkView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 1, 18, 18)];
    [checkView setImage:[UIImage imageNamed:@"user_report_sel"]];
    [itemView addSubview:checkView];
    
    
    NSString *agreementText=@"我已阅读并同意";
    
    CGFloat aw=[SysTools getWidthContain:agreementText font:ListDetailFont Height:20];
    UILabel *label1=[[UILabel alloc] initWithFrame:CGRectMake(40, 0, aw, 20)];
    [label1 setText:agreementText];
    [label1 setTextColor:UIColorFromRGB(TextBlackColor)];
    [label1 setFont:ListDetailFont];
    [itemView addSubview:label1];
    
    
    
    UIButton *agreeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [agreeButton setFrame:CGRectMake(40+aw, 0, w-40-aw, 20)];
    [agreeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [agreeButton setTitle:@"用户协议" forState:UIControlStateNormal];
    [agreeButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [agreeButton setTitleColor:UIColorFromRGB(DrakGreenNickNameColor) forState:UIControlStateHighlighted];
    [agreeButton.titleLabel setFont:ListDetailFont];
    [agreeButton addTarget:self action:@selector(lookAgreeMent:) forControlEvents:UIControlEventTouchUpInside];
    [itemView addSubview:agreeButton];
    
    itemView.userInteractionEnabled=YES;
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemCheckClick:)];
    [itemView addGestureRecognizer:tap];
}



-(void)itemCheckClick:(UIGestureRecognizer *)tap{
    if(isCheck){
        isCheck=NO;
        [checkView setImage:[UIImage imageNamed:@"user_report_nor"]];
    }else{
        isCheck=YES;
        [checkView setImage:[UIImage imageNamed:@"user_report_sel"]];
    }
}

//查看用户协议
-(IBAction)lookAgreeMent:(id)sender{
    SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/static/agreement.html",API_HOST]]];
    webView.title = @"用户协议";
    [self openNav:webView sound:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
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
