//
//  ToReportController.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-27.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ToReportController.h"
#import "UIView+Border.h"

@interface ToReportController (){
    UIScrollView *scrollView;
    
    CGFloat w;
    CGFloat h;
    CGFloat textY;
    
    UIView *lastCheck;
    UITextField *textfield;
    
    UIGestureRecognizer *tapRecognizer;
    
    BOOL isCheck;
    UIImageView *checkView;
}

@end

@implementation ToReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_report") forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickDefautl.png"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickHelight.png"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(12,8,12,16)];
    self.menuRightButton.tag=RIGHT_BUTTON;
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    w=self.view.bounds.size.width;
    h=self.view.bounds.size.height;
    
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, NavBarHeight, w,h-NavBarHeight)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scrollView];
    
    [self createLabel:2 with:TTLocalString(@"TT_Please select a report")];
    
    [self createItemView:0 text:TTLocalString(@"TT_porn") bottom:NO];
    [self createItemView:1 text:TTLocalString(@"TT_Fraud cheat money") bottom:NO];
    [self createItemView:2 text:TTLocalString(@"TT_Insulting slander") bottom:NO];
    [self createItemView:3 text:TTLocalString(@"TT_The ads") bottom:NO];
    [self createItemView:4 text:TTLocalString(@"TT_political") bottom:NO];
    [self createItemView:5 text:TTLocalString(@"TT_Go figure") bottom:YES];
    
    
    [self createEditText:326];
    
    
    [self createLabel:370 with:TTLocalString(@"TT_The account recently 10 information will also be submitted as evidence")];
    
    isCheck=YES;
    [self createCheckView:414];
    
    [scrollView setContentSize:CGSizeMake(w, 444)];
    
    
    [self handleKeyboard];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)createLabel:(int)y with:(NSString *)text{
    UILabel *labe=[[UILabel alloc] initWithFrame:CGRectMake(15, y , w-30, 40)];
    [labe setFont:ListDetailFont];
    [labe setTextColor:UIColorFromRGB(TextGrayColor)];
    [labe setText:text];
    [scrollView addSubview:labe];
}


-(void)createItemView:(int) itemtype text:(NSString *)text bottom:(BOOL) isbottom{
    UIView *itemView=[[UIView alloc] initWithFrame:CGRectMake(0, itemtype*44+42, w, 44)];
    itemView.tag=itemtype;
    [itemView setBackgroundColor:[UIColor whiteColor]];
    itemView.userInteractionEnabled=YES;
    [scrollView addSubview:itemView];
    
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
    [itemView addGestureRecognizer:tap];
    
    
    UILabel *labe=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, w-30, 44)];
    [labe setFont:ListTitleFont];
    [labe setTextColor:UIColorFromRGB(TextBlackColor)];
    [labe setText:text];
    [itemView addSubview:labe];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(w-33, 15, 18, 14)];
    [imageView setImage:[UIImage imageNamed:@"user_report_check"]];
    imageView.tag=12;
    imageView.hidden=YES;
    [itemView addSubview:imageView];
    
    if(itemtype==0){
        [itemView addTopBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
        UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(15, 43, w-15, 1)];
        [line setBackgroundColor:UIColorFromRGB(ListLineColor)];
        [itemView addSubview:line];
    }else if(isbottom){
        [itemView addBottomBorderWithColor:UIColorFromRGB(ListLineColor) andWidth:1];
    }else{
        UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(15, 43, w-15, 1)];
        [line setBackgroundColor:UIColorFromRGB(ListLineColor)];
        [itemView addSubview:line];
    }
    
}
-(void)createCheckView:(int ) y{
    UIView *itemView=[[UIView alloc] initWithFrame:CGRectMake(0, y, w, 40)];
    [itemView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:itemView];
    
    checkView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 1, 18, 18)];
    [checkView setImage:[UIImage imageNamed:@"user_report_sel"]];
    [itemView addSubview:checkView];
    
    
    UILabel *label1=[[UILabel alloc] initWithFrame:CGRectMake(40, 0, w-55, 20)];
    [label1 setText:TTLocalString(@"TT_Blocked the account")];
    [label1 setTextColor:UIColorFromRGB(TextBlackColor)];
    [label1 setFont:ListDetailFont];
    [itemView addSubview:label1];
    
    
    UILabel *label2=[[UILabel alloc] initWithFrame:CGRectMake(40, 20, w-55, 20)];
    [label2 setText:TTLocalString(@"TT_You will no longer receive any message from him")];
    [label2 setTextColor:UIColorFromRGB(TextGrayColor)];
    [label2 setFont:ListDetailFont];
    [itemView addSubview:label2];
    
    itemView.userInteractionEnabled=YES;
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemCheckClick:)];
    [itemView addGestureRecognizer:tap];
}

-(void)createEditText:(int) y{
    textY=y+NavBarHeight;
    UIView *itemView=[[UIView alloc] initWithFrame:CGRectMake(0, y, w, 44)];
    [itemView setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:itemView];
    
    textfield=[[UITextField alloc] initWithFrame:CGRectMake(15, 0, w-30, 44)];
    [textfield setBackgroundColor:[UIColor clearColor]];
    [itemView addSubview:textfield];
}


-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    
    if(lastCheck==nil){
        return;
    }
    NSString *type=@"";
    switch (lastCheck.tag) {
        case 0:
            type=@"seqing";
            break;
        case 1:
            type=@"qizha";
            break;
        case 2:
            type=@"wuru";
            break;
        case 3:
            type=@"guanggao";
            break;
        case 4:
            type=@"zhengzhi";
            break;
        case 5:
            type=@"daotu";
            break;
        default:
            break;
    }
    
    //提交
    if(sender.tag==RIGHT_BUTTON){
        [[RequestTools getInstance] get:API_GET_REPORT_USER(self.uid, type, textfield.text, isCheck) isCache:NO completion:^(NSDictionary *dict) {
            WSLog(@"发送成功了%@",dict);
            [self showNoticeWithMessage:TTLocalString(@"TT_To report success! Administrators are handled in a timely manner!") message:nil bgColor:TopNotice_Block_Color block:^{
                [self goBack:nil];
            }];
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            WSLog(@"发送完成了%@",request.responseString);
        }];
    }
}


#pragma mark keyboard notification
- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    self.view.userInteractionEnabled=YES;
    [self.view addGestureRecognizer:tapRecognizer];
}
//键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self showKeyBoard:keyboardHeight];
                     }
                     completion:^(BOOL finished) {
                         //让dataScrollView滚动到底部
                     }
     ];
    
    [self.view addGestureRecognizer:tapRecognizer];
}


//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
//    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    [textfield resignFirstResponder];
}

-(void)showKeyBoard:(CGFloat) keyboardHeight{
    CGFloat scrollValue=h-textY-128;
    if(scrollValue<keyboardHeight){
        scrollValue=keyboardHeight-(h-textY-128);
        
        [scrollView setContentOffset:CGPointMake(0, scrollValue)];
    }
}


//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    [UIView commitAnimations];
    [self.view removeGestureRecognizer:tapRecognizer];
}

-(void)itemClick:(UITapGestureRecognizer *) tap{
    UIView *view=tap.view;
    if(lastCheck){
        UIImageView *uiview=(UIImageView *)[lastCheck viewWithTag:12];
        uiview.hidden=YES;
    }
    
    UIImageView *uiview=(UIImageView *)[view viewWithTag:12];
    uiview.hidden=NO;
    lastCheck=view;
    
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
