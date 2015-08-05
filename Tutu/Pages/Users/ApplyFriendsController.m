//
//  ApplyFriendsController.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-17.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ApplyFriendsController.h"
#import "UIPlaceHolderTextView.h"
#import "UserInfoDB.h"

@interface ApplyFriendsController (){
    UIScrollView *scrollView;
    
    CGFloat w;
    CGFloat h;
    CGFloat textY;
    
    UIView *lastCheck;
    UIPlaceHolderTextView *textfield1;
    
    UILabel *numLabel;
    
    UIGestureRecognizer *tapRecognizer;
}

@end

@implementation ApplyFriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_friends_validation") forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
    [self.menuRightButton setTitle:TTLocalString(@"TT_send") forState:UIControlStateNormal];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(12,8,12,16)];
    self.menuRightButton.tag=RIGHT_BUTTON;
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    w=self.view.bounds.size.width;
    h=self.view.bounds.size.height;
    
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, NavBarHeight, w,h-NavBarHeight)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scrollView];
    
    UILabel *labelTag1=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, w-30, 42)];
    [labelTag1 setText:TTLocalString(@"TT_You need to send verification application, waiting for each other through")];
    [labelTag1 setFont:ListDetailFont];
    [labelTag1 setTextColor:UIColorFromRGB(TextGrayColor)];
    [scrollView addSubview:labelTag1];
    
    [self createEditText:42 textView:1];
    
    
    NSArray *arr=[[NSArray alloc] initWithObjects:TTLocalString(@"TT_Friends in Tu"),TTLocalString(@"TT_Hi, and a friend"),TTLocalString(@"TT_HI! Want to know me?"),TTLocalString(@"TT_Find ah find ah find friends"), nil];
    int randomValue=arc4random()%4;
    [textfield1 setText:[arr objectAtIndex:randomValue]];
    
    numLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 42+65, w-24, 18)];
    [numLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [numLabel setFont:ListTimeFont];
    [numLabel setTextAlignment:NSTextAlignmentRight];
    [numLabel setText:@"20"];
    [scrollView addSubview:numLabel];
    
    
//    [self createEditText:84 textView:2];
//    [textfield2 setPlaceholder:@"备注"];
    
    [self handleKeyboard];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textfield1 becomeFirstResponder];
    });
}


-(void)createEditText:(int) y textView:(int) type{
    textY=y+NavBarHeight;
    UIView *itemView=[[UIView alloc] initWithFrame:CGRectMake(0, y, w, 95)];
    [itemView setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:itemView];
    
    if(type==1){
        textfield1=[[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(15, 3, w-30, 89)];
        [textfield1 setBackgroundColor:[UIColor clearColor]];
        [textfield1 setUserInteractionEnabled:YES];
        textfield1.delegate=self;
        [textfield1 setFont:ListTitleFont];
        [itemView addSubview:textfield1];
    }else if(type==2){
//        textfield2=[[UITextField alloc] initWithFrame:CGRectMake(15, 0, w-30, 44)];
//        [textfield2 setBackgroundColor:[UIColor clearColor]];
//        [textfield2 setEnabled:YES];
//        [textfield2 setUserInteractionEnabled:YES];
//        [itemView addSubview:textfield2];
    }
}

//动态计算文字大小
-(void)textViewDidChange:(UITextView *)textView{
    if (textfield1.text.length>20) {
        [numLabel setTextColor:UIColorFromRGB(NoticeColor)];
    }else{
        [numLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    }
    
    [numLabel setText:[NSString stringWithFormat:@"%d",(int)(20-textfield1.text.length)]];
}
-(void)changeText:(UITextField*)sender {
    
    NSInteger length=20;
    
    //键盘输入模式
    NSString *lang = [[[UITextInputMode activeInputModes] objectAtIndex:0] primaryLanguage];
    //简体中文输入，包括简体拼音，简体五笔，简体手写
    if ([lang isEqualToString:@"zh-Hans"]) {
        
//        UITextRange *selectedRange = [textfield1 markedTextRange];
//        //获取高亮部分
//        if (selectedRange == nil) {
//            
//            if (textfield1.text.length>length) {
//                @try {
//                    [numLabel setText:[NSString stringWithFormat:@"%d",(int)(textfield1.text.length-length)]];
//                }
//                @catch (NSException *exception) {
//                    
//                }
//                @finally {
//                    
//                }
//            }
//        }
        if (textfield1.text.length>length) {
            [numLabel setTextColor:UIColorFromRGB(NoticeColor)];
        }else{
            [numLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        }
        
        [numLabel setText:[NSString stringWithFormat:@"%d",(int)(textfield1.text.length-length)]];
    }
}


-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    
    //提交
    if(sender.tag==RIGHT_BUTTON){
        NSString *text=textfield1.text;
        
//        if(text.length>20){
//            [self showNoticeWithMessage:@"无法提交!" message:@"超出字数限制" bgColor:TopNotice_Red_Color];
//            return;
//        }
        
        [[RequestTools getInstance] get:API_Apply_Friend(self.uid,text, @"") isCache:NO completion:^(NSDictionary *dict) {
            [self showNoticeWithMessage:TTLocalString(@"TT_Send a success") message:nil bgColor:TopNotice_Block_Color];
            UserInfoDB *db = [[UserInfoDB alloc]init];
            UserInfo *info = [db findWidthUID:_uid];
            info.nickname=info.realname;
            info.relation = CheckNilValue(dict[@"data"]);
            [NOTIFICATION_CENTER postNotificationName:NOTICE_SEND_FRIEND_APPLY object:nil];
            [db saveUser:info];
            if (_backBlock) {
                _backBlock(info.relation);
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {

        } finished:^(ASIHTTPRequest *request) {
            
        }];
        [self goBack:nil];
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
    
//    [self.view addGestureRecognizer:tapRecognizer];
}


//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    //    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [scrollView setContentOffset:CGPointMake(0, 0)];
    [textfield1 resignFirstResponder];
    
//    [textfield2 resignFirstResponder];
}

-(void)showKeyBoard:(CGFloat) keyboardHeight{
    
}


//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    [UIView commitAnimations];
//    [self.view removeGestureRecognizer:tapRecognizer];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
