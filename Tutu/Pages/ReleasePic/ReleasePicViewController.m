//
//  ReleasePicViewController.m
//  Tutu
//
//  Created by feng on 14-10-18.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ReleasePicViewController.h"
#import "MyTextView.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "VPImageCropperViewController.h"
#import "UIImage+Category.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "FaceCollectionViewCell.h"
#import "UIImage+GIF.h"
#import "UIImageView+Gif.h"

#import "FaceModel.h"
#define staticCollectionViewCell @"FaceCollectionViewCell"


#define MIN_SCALE 2.5
@interface ReleasePicViewController (){
    //评论图片
    UIImageView *topicView;
    
    //悬浮的背景图片或表情
    UIImageView *contentView;
    CGAffineTransform *tempAffine;
    
    //悬浮的输入框
    TTLinkedTextView *commentTextView;
    CGPoint touchStart;
    BOOL isReply;
    
    //开始滚动的坐标
    UIImageView *closeComment;
    
    //回复视图
    UIView *replyView;
    
    //下面发布按钮
    UIView *footerView;
    
    UIImageView *updateInputTagView;
    UIImageView *updateFaceTagView;
    
    //屏幕点击事件，用于隐藏键盘
    UITapGestureRecognizer *tapRecognizer;
    
    float scrollY;
    BOOL isShowBoard;
    float sumRotation;
    
    
    //要上传的评论视图的 缩放比例 和旋转角度
    CGAffineTransform postAffineTransform;
    
    //要上传的缩放比例
    float postScale;
    
    //要上传的旋转系数
    float postRotation;
    
    
    //faceView，分类
    UIView *_faceView;
    UIView *topMenuView;
    
    //当前选中的表情分类按钮
    UIButton * checkButton;
    //当前选择显示的分类列表
    FaceModel * checkModel;
    
    //是否显示表情，显示表情，禁止拖动事件
    BOOL isShowFace;
    
    //点击表情的分类、1、2、3
    int clickTag;
    
    // YES评论、NO表情
    BOOL isTextInput;
    
    //评论背景名称、或表情图片名称
    NSString *contentSource;
    
    //表情数据
    NSMutableArray *faceArray;
    
    //背景图片
    NSMutableArray *itemsbg;
    
    // 显示表情Array
    NSMutableArray *showArr;
    
    
    
    
    UIScrollView *topMenuScrollView;
    
    //计算自适文字大小
    float lastOffsety;
    int fontSize;
    float _lastScale;
    float _lastRotation;
    
    //屏幕宽高
    int w;
    int h;
}

@end

@implementation ReleasePicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    postScale=1.0f;
    postRotation=0.0f;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden=YES;
    
    faceArray=[[NSMutableArray alloc] init];
    itemsbg= [[NSMutableArray alloc] init];
    showArr=[[NSMutableArray alloc] init];
    
    //创建View
    [self createViews];
    
    //创建表情
    [self createFaceView];
    
    scrollY = topicView.center.y-topicView.bounds.size.height/2-44;
    
    
    [self setDefaultStatus];

    //设置背景色
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common_nav7_bg"]]];
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    //添加键盘监听
    [self handleKeyboard];
    
    
    //导致加载慢得原因
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [commentTextView becomeFirstResponder];
    });
}
// for ios 7
- (BOOL)prefersStatusBarHidden{
    return YES;
}

// for ios 6
- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    // 隐藏键盘
    [self didTapAnywhere:nil];
    
    //解除键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: UIKeyboardDidShowNotification object:nil];
    //解除键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name: UIKeyboardDidHideNotification object:nil];
//    [commentTextView removeObserver:self forKeyPath:@"contentSize"];
    [super viewWillDisappear:animated];
    // explicitly set the bar to show or it will remain hidden for other view controllers
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.navigationController.navigationBarHidden=NO;
}



#pragma mark - KVO 监听uitextview内容变化
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *tv = object;
    
    //自适应文字大小
    CGSize constraintSize = CGSizeMake(100, MAXFLOAT);
    CGSize size = [commentTextView sizeThatFits:constraintSize];
    WSLog(@"当前的大小： %f %d",size.height,fontSize);
    if((size.height>74 && fontSize==MinFontSize) || (size.height<47 && fontSize==MaxFontSize)){
        return;
    }
    
    // Center vertical alignment，自适应宽
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
//    CGSize unitSize = [tv.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:tv.font,NSFontAttributeName, nil]];
//    

    
    if(size.height>74){
        if(fontSize<MinFontSize){
            fontSize=MinFontSize;
        }else{
            fontSize=fontSize-1;
        }
    }
    if(size.height<64){
        if(fontSize>MaxFontSize){
            fontSize=MaxFontSize;
        }
        else{
            fontSize=fontSize+1;
        }
    }
    
    commentTextView.font=[UIFont systemFontOfSize:fontSize];
}



//开始滑动
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
//    if(![touch.view isEqual:contentView] && ![touch.view isEqual:closeComment] && ![touch.view isEqual:textView])
//    {
//        return;
//    }
    
    CGPoint point = [touch locationInView:topicView];
    
    //返回触摸点在视图中的当前坐标
    int y = point.y;
    if(y<0 || y>topicView.frame.size.height){
        return;
    }
    
    //显示表情背景时不能拖动rotate

    if(isShowFace){
        return;
    }
    
    touchStart = [touch locationInView:self.view];
    
    //该view置于最前
    [topicView bringSubviewToFront:contentView];
    [commentTextView resignFirstResponder];
    
    
    // Ensure the translation won't cause the view to move offscreen.
    touchStart=[self translateUsingTouchLocation:touchStart];
    WSLog(@"touch bengin");
    
    if(!isShowFace && contentView.hidden==YES){
        [self playerSoundWith:@"comment"];
        contentView.hidden=NO;
        contentView.center = touchStart;
        if(!isTextInput){
            isTextInput=YES;
            [self setInitData];
            contentView.image=[UIImage imageNamed:contentSource];
        }
        
        [commentTextView setTextColor:[SysTools getCommentColor:contentSource]];
        commentTextView.hidden=NO;
        if(isTextInput){
            [commentTextView becomeFirstResponder];
        }
    }
}


//设置评论位置
- (CGPoint)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = touchPoint;
    CGFloat midPointX = CGRectGetWidth(contentView.frame)/2;
    
    if (newCenter.x > topicView.frame.size.width - midPointX) {
        newCenter.x = topicView.frame.size.width - midPointX;
    }
    
    if (newCenter.x < midPointX) {
        newCenter.x = midPointX;
    }
    
    CGFloat midPointY = CGRectGetWidth(contentView.frame)/2;
    
    if (newCenter.y > (CGRectGetMaxY(topicView.frame)-midPointY)) {
        newCenter.y = (CGRectGetMaxY(topicView.frame)-midPointY);
    }
    
    if (newCenter.y < (midPointY+topicView.frame.origin.y)) {
        newCenter.y = midPointY+topicView.frame.origin.y;
    }
    
    return newCenter;
}

-(BOOL)limit
{
    if (CGRectContainsRect(topicView.frame, contentView.frame)) {
        return NO;
    }
    else
    {
        return YES;
    }
}
// 缩放
-(void)scale:(id)sender {
//    NSLog(@"transfer============%@",NSStringFromCGAffineTransform(contentView.transform));

    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    if ([(UIPinchGestureRecognizer*)sender state]==UIGestureRecognizerStateChanged) {
        CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
        [contentView setTransform:CGAffineTransformScale(contentView.transform, scale, scale)];
        _lastScale = [(UIPinchGestureRecognizer*)sender scale];
    }
    
    if ([(UIPinchGestureRecognizer*)sender state]==UIGestureRecognizerStateEnded) {
        CGPoint temp=[self translateUsingTouchLocation:contentView.center];
        [UIView animateWithDuration:0.1 animations:^{
            [contentView setCenter:temp];
        }];
    

        if (contentView.frame.size.width>SCREEN_WIDTH) {
            CGFloat s=CGRectGetHeight(topicView.bounds)/CGRectGetHeight(contentView.frame);
            [UIView animateWithDuration:0.3 animations:^{
                contentView.transform=CGAffineTransformScale(contentView.transform, s, s);
                CGPoint temp=[self translateUsingTouchLocation:contentView.center];
                [contentView setCenter:temp];

            }];
        
        }else if (contentView.frame.size.width<contentView.bounds.size.width/MIN_SCALE)
        {
            float s=(contentView.bounds.size.width/MIN_SCALE)/contentView.frame.size.width;
            [UIView animateWithDuration:0.3 animations:^{
                contentView.transform=CGAffineTransformScale(contentView.transform,s,s);
                CGPoint temp=[self translateUsingTouchLocation:contentView.center];
                [contentView setCenter:temp];
                
            }];

        }
    }
}

-(CGFloat )radianToDegreen:(CGFloat)radian
{
    float degreen;
    if (radian>=0) {
        
        int tempScale=radian/6;
        if (tempScale>=1) {
            radian-=6*tempScale;
        }
        
         degreen=(radian*180)/M_PI;
        
        
    }
    else
    {
        int tempScale=radian/-6;
        if (tempScale>=1) {
            radian+=6*tempScale;
        }
        degreen=(radian*180)/M_PI;
    }
    
    return degreen;

}


-(CGFloat)degreenToRadian:(CGFloat)degreen
{
    return  (degreen*M_PI)/180;
}

// 旋转
-(void)rotate:(id)sender {
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if ([self limit]) {
            return;
        }
        else
        {
            postRotation+=_lastRotation;
        }
        _lastRotation = 0.0;
        return;
    }
    
    
    if ([self limit]) {
        return;
    }
    else
    {
        CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
        
        CGAffineTransform currentTransform = contentView.transform;
        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
        
        [contentView setTransform:newTransform];
        
        _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    }
}

// 移动
-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
//        _firstX = [photoImage center].x;
//        _firstY = [photoImage center].y;
        
        //显示表情背景时不能拖动
        if(isShowFace){
            return;
        }
        
        touchStart=contentView.center;
        
        //该view置于最前
        [topicView bringSubviewToFront:contentView];
        [commentTextView resignFirstResponder];
        
        
        touchStart=[self translateUsingTouchLocation:touchStart];
        
        
        if(!isShowFace && contentView.hidden==YES){
            [self playerSoundWith:@"comment"];
            contentView.hidden=NO;
            contentView.center = touchStart;
            if(!isTextInput){
                isTextInput=YES;
                
                [self setInitData];
                contentView.image=[UIImage imageNamed:contentSource];
            }
            
            [commentTextView setTextColor:[SysTools getCommentColor:contentSource]];
            commentTextView.hidden=NO;
            if(isTextInput){
                [commentTextView becomeFirstResponder];
            }
        }
    }
    
    translatedPoint = CGPointMake(touchStart.x+translatedPoint.x, touchStart.y+translatedPoint.y);
    
//    [contentView setCenter:translatedPoint];
    [contentView setCenter:[self translateUsingTouchLocation:translatedPoint]];
}



- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    //UISwipeGestureRecognizerDirectionLeft   UISwipeGestureRecognizerDirectionRight  UISwipeGestureRecognizerDirectionUp  UISwipeGestureRecognizerDirectionDown
    if(clickTag==0){
        return;
    }
    
    if (recognizer.direction==UISwipeGestureRecognizerDirectionLeft ) {
        if(clickTag>=faceArray.count){
            return;
        }
        clickTag=clickTag+1;
        [self changeFace:clickTag];

    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight){
        if(clickTag==1){
            return;
        }
        
        clickTag=clickTag-1;
        [self changeFace:clickTag];
    }
    
}

//隐藏评论
-(IBAction)hideAnimationView
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:^{
        _faceView.frame= CGRectMake(0,h,w,h);
    }];
    [UIView commitAnimations];
    
    isShowFace = NO;
}


//发布主题或评论
-(void)postTopic:(UIButton *)btn{
    CGFloat degreen=[self radianToDegreen:postRotation];
    
    postScale= contentView.frame.size.width/contentView.bounds.size.width;

//    postAffineTransform=contentView.transform;
//    postScale=postAffineTransform.a;
//    postRotation=postAffineTransform.b;

    if([self checkBeKill]){
        return;
    }

    [self playerSoundWith:@"send"];
    if(contentSource!=nil && contentSource.length>0 && self.topicModel!=nil){
        if(contentView.hidden){
            [self showNoticeWithMessage:TTLocalString(@"TT_Please enter a comment!") message:nil bgColor:TopNotice_Red_Color];
            return;
        }
        if(isTextInput && (commentTextView.text==nil || [@"" isEqual:commentTextView.text])){
            [self showNoticeWithMessage:TTLocalString(@"TT_Please enter a comment!") message:nil bgColor:TopNotice_Red_Color];
            return;
        }
        
        float centerY=(contentView.center.y-topicView.frame.origin.y)/w;
        NSString *contentStr=[commentTextView getUploadText];
        if(!isTextInput){
            contentStr=@"";
        }
        
        CommentModel *cmModel=[CommentModel new];
        cmModel.commentid=@"";
        cmModel.topicid=self.topicModel.topicid;
        cmModel.uid=[[LoginManager getInstance]getUid];
        if([contentSource rangeOfString:@"input"].location !=NSNotFound){
            cmModel.type=@"1";
        }else{
            cmModel.type=@"2";
        }
        cmModel.comment=contentStr;
        cmModel.commentbg=contentSource;
        cmModel.time=dateTransformString(@"yyyy-MM-dd hh:mm:ss",[NSDate date]);
        if(isReply && self.commentModel!=nil){
            cmModel.pid=self.commentModel.commentid;
        }else{
            cmModel.pid=@"";
        }
        
        cmModel.pointX=[NSString stringWithFormat:@"%f",contentView.center.x/w];
        cmModel.pointY=[NSString stringWithFormat:@"%f",centerY];
        cmModel.rotation=[NSString stringWithFormat:@"%f",degreen];
        cmModel.scale=[NSString stringWithFormat:@"%f",postScale];

        cmModel.nickname=[[LoginManager getInstance]getLoginInfo].nickname;
        cmModel.avatar=[[LoginManager getInstance] getLoginInfo].avatartime;
        cmModel.localtopicid=@"";
        cmModel.localid=[NSString stringWithFormat:@"lc%d%@",(int)[[NSDate date] timeIntervalSince1970],[[LoginManager getInstance]getUid]];
        cmModel.invideotime=[NSString stringWithFormat:@"%f",self.duration];
        
        
        NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
        [params setValue:cmModel.topicid forKey:@"topicid"];
        if(isReply && self.commentModel!=nil){
            [params setValue:cmModel.pid forKey:@"replycommentid"];
            
            // 
            [[SendLocalTools getInstance] setFavContacts:self.commentModel.uid];
        }
        [params setValue:cmModel.pointX  forKey:@"locationx"];
        [params setValue:cmModel.pointY forKey:@"locationy"];
        [params setValue:cmModel.rotation  forKey:@"rotation"];
        [params setValue:cmModel.scale forKey:@"scale"];
        [params setValue:cmModel.commentbg forKey:@"txtframe"];
        [params setValue:cmModel.comment forKey:@"content"];
        
        CommentModel *model = [[CommentModel alloc]init];
        model = cmModel;
        model.pointX = FormatString(@"%f", [cmModel.pointX floatValue] * ScreenWidth);
        model.pointY = FormatString(@"%f", [cmModel.pointY floatValue] *ScreenWidth);
        model.comeFrom = _comeFrom;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Topic_Comment_Send object:model];
        
        if(self.duration>0){
            [params setValue:[NSString stringWithFormat:@"%f",self.duration] forKey:@"invideotime"];
        }
        
        WSLog(@"%@",API_ADD_COMMENT);
        [[RequestTools getInstance] post:API_ADD_COMMENT filePath:nil fileKey:nil  params:params completion:^(NSDictionary *dict) {
//            WSLog(@"%@",dict);
            //成功发送评论
            NSMutableDictionary *dicM = [[NSMutableDictionary alloc]initWithDictionary:dict];
            [dict setValue:@(_comeFrom) forKey:@"come_from"];
            [[NSNotificationCenter defaultCenter] postNotificationName:Notifcation_Topic_Comment_Send_Success object:dicM];
        } failure:^(ASIFormDataRequest *request, NSString *message) {
            TopicCacheDB *db=[[TopicCacheDB alloc] init];
            [db saveTopicComment:cmModel];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Notifcation_Topic_Comment_Send_Failed object:cmModel];
        } finished:^(ASIFormDataRequest *request) {
            btn.userInteractionEnabled=YES;
        }];
        btn.userInteractionEnabled=NO;
        //开始发送评论

        [self goBack:nil];
    }else{
        [self showNoticeWithMessage:TTLocalString(@"TT_Please enter a comment!") message:nil bgColor:TopNotice_Red_Color];
    }
}

//关闭评论
-(void)closeComment{
    WSLog(@"关闭");
    [commentTextView setText:@""];
    contentView.hidden=YES;
}

#pragma mark 显示表情
-(void)showInputOrFaceList:(UIButton *)sender{
    // 显示输入框
    if(sender.tag==2){
        [SysTools syncNSUserDeafaultsByKey:CheckInputUpdate withValue:@"0"];
        if(updateInputTagView!=nil){
            [updateInputTagView setHidden:YES];
            [updateInputTagView removeFromSuperview];
            updateInputTagView=nil;
        }
            
        clickTag=0;
        
        [topMenuScrollView setHidden:YES];
//        [topMenuView setBackgroundColor:UIColorFromRGB(EmotionScrollViewBg)];
    }
    
    // 显示表情
    if(sender.tag==1){
        [SysTools syncNSUserDeafaultsByKey:CheckFaceUpdate withValue:@"0"];
        if(updateFaceTagView!=nil){
            [updateFaceTagView setHidden:YES];
            [updateFaceTagView removeFromSuperview];
            updateFaceTagView=nil;
        }
        
        [topMenuScrollView setHidden:NO];
//        [topMenuView setBackgroundColor:UIColorFromRGB(EmotionMenuColor)];
        
        // 显示表情
        if(clickTag==0){
            if(checkButton!=nil){
                clickTag=(int)checkButton.tag;
            }else{
                checkButton=(UIButton *)[topMenuScrollView viewWithTag:1];
                if(checkButton){
                    [checkButton setBackgroundColor:UIColorFromRGB(EmotionCheckBg)];
                }
                clickTag=1;
            }
        }
    }
    [self changeFace:clickTag];
}

//表情、背景按钮点击事件
-(IBAction)selectImage:(UIButton *)sender{
    //点击输入框
    if(sender.tag==0){
        
        clickTag=0;
        
        [topMenuScrollView setHidden:YES];
        
    }else{
        
        // 显示表情
        if(clickTag==0){
            clickTag=1;
        }else{
            clickTag=(int)sender.tag;
        }
    }
    [self changeFace:clickTag];
}


-(void)changeFace:(int) showItemId{
    [commentTextView resignFirstResponder];
    
    if(clickTag==0){
        if(itemsbg!=nil){
            showArr=[itemsbg mutableCopy];
        }else{
            [showArr removeAllObjects];
        }
    }else{
        UIButton *sender=(UIButton *)[topMenuScrollView viewWithTag:clickTag];
        [topMenuScrollView setHidden:NO];
        if(checkButton !=nil && ![checkButton isEqual:sender]){
            [checkButton setBackgroundColor:[UIColor clearColor]];
        }
        [sender setBackgroundColor:UIColorFromRGB(EmotionScrollViewBg)];
        checkButton=sender;
        
        if(faceArray!=nil && faceArray.count>=clickTag){
            checkModel=[faceArray objectAtIndex:clickTag-1];
            showArr= [[NSMutableArray alloc] initWithArray:checkModel.itemList];
        }else{
            [showArr removeAllObjects];
        }
    }
    [self.listCollectionView reloadData];
    
    [UIView animateWithDuration:ANIMATIONDURATION animations:^{
        [topMenuScrollView setContentOffset:CGPointMake(checkButton.frame.size.width*(clickTag-1), 0)];
        _faceView.frame= CGRectMake(0,0,w,h);
        
    }];
    
    isShowFace=YES;
}

//表情或背景点击
-(IBAction)clickItem:(UIButton *)sender{
    if(clickTag==0){
        isTextInput=YES;
        
        contentSource=[showArr objectAtIndex:sender.tag];
        
        commentTextView.hidden=NO;
    }else{
        isTextInput=NO;

        contentSource=[showArr objectAtIndex:sender.tag];
        
        commentTextView.hidden=YES;
    }
    
    // 播放点击声音
    [self playerSoundWith:@"comment"];
    
    [commentTextView setTextColor:[SysTools getCommentColor:contentSource]];
    [SysTools getEmotionImage:contentSource imageView:contentView];
    contentView.hidden=NO;
    
    
    [self hideAnimationView];
}

#pragma mark keyboard notification
- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    self.view.userInteractionEnabled=YES;
}

//键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    
    
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    WSLog(@"re=curve=%d",[curve intValue]);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    // get a rect for the view frame
    CGRect toolbarFrame = footerView.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height
    - keyboardHeight - toolbarFrame.size.height;
    footerView.frame = toolbarFrame;
    
    if(!isShowBoard){
        isShowBoard=YES;
        CGPoint cc=contentView.center;
        cc.y=cc.y-scrollY;
        contentView.center=cc;
    }
    
    CGRect f=topicView.frame;
    f.origin.y=44;
    topicView.frame=f;
    // commit animations
    [UIView commitAnimations];
    
    [self.view addGestureRecognizer:tapRecognizer];
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect toolbarFrame = footerView.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
    footerView.frame = toolbarFrame;
    
    [UIView commitAnimations];
    
    if(self.pageType==2){
        topicView.center=self.view.center;
        
        
        if(isShowBoard){
            isShowBoard=NO;
            CGPoint cc=contentView.center;
            cc.y=cc.y+scrollY;
            contentView.center=cc;
        }
    }
    [self.view removeGestureRecognizer:tapRecognizer];
}

//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [commentTextView resignFirstResponder];
    
    
}


#pragma mark 设置初始数据
-(void)setInitData{
    int randomValue=arc4random()%27+1;
    
    NSString *tag=@"input_22_";
    int color_tag=0;
    if(randomValue<10){
        tag=@"input_22_0";
    }
    if(randomValue>=12 && randomValue<=15){
        color_tag=1;
    }else{
        color_tag=0;
    }
    contentSource=[NSString stringWithFormat:@"%@%d_%d",tag,randomValue,color_tag];
}

#pragma 创建视图布局
-(void)createViews{
    
    int y=0;//StatusBarHeight;
    if(y==0){
        y=44;
    }
    
    w=self.view.mj_width;
    h=self.view.mj_height;
    
    //头部（返回、发布）黑条
    UIView *topview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, y)];
//    [topview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common_nav7_bg"]]];
    [topview setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.view addSubview:topview];
    
    //返回
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(10, y-44, 44, 44) ;
    [btn setTitle:TTLocalString(@"TT_cancel") forState:UIControlStateNormal];
    [topview addSubview:btn];
    
    //发布
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 addTarget:self action:@selector(postTopic:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(w-54, y-44, 44, 44) ;
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 setTitle:TTLocalString(@"TT_send") forState:UIControlStateNormal];
    [topview addSubview:btn2];
    
    
    
    //待评论图片
    topicView=[[UIImageView alloc] initWithImage:self.releaseImage];
    [topicView setFrame:CGRectMake(0, y, w, w)];
    topicView.userInteractionEnabled=YES;
    if (_topicModel.type == 5) {
        [topicView setContentMode:UIViewContentModeScaleAspectFill];
    }else{
        [topicView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [topicView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
   // [topicView setBackgroundColor:UIColorFromRGB(DragImageColor)];
//    UIImage *image=[UIImage imageNamed:@"topic_default"];
//    image=[SysTools scaleToSize:image size:topicView.frame.size];
//    [topicView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    topicView.layer.masksToBounds=YES;
    
    [self.view addSubview:topicView];
    
    //评论背景、或者表情图片
    contentView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];

    contentView.userInteractionEnabled=YES;
    contentView.center=CGPointMake([_commentModel.pointX floatValue], [_commentModel.pointY floatValue]);
    [contentView setBackgroundColor:[UIColor clearColor]];
    
    //评论文字
    commentTextView = [[TTLinkedTextView alloc] initWithFrame:CGRectMake(20, 40, 100, 62)];
    //用户touch传递，必须填写，否则textView拖动无效
//    textView.delegate=self;
    [commentTextView setBackgroundColor:[UIColor clearColor]];
    commentTextView.showsVerticalScrollIndicator=NO;
    commentTextView.delegate=self;
    
    //设置默认值
    fontSize=MaxFontSize;
    commentTextView.font=[UIFont systemFontOfSize:14];
    [commentTextView setTextColor:[SysTools getCommentColor:@"input_22_01_0"]];
    [commentTextView setTextAlignment:NSTextAlignmentLeft];
    commentTextView.userInteractionEnabled=YES;
    [commentTextView setDelegate:self];
    [commentTextView setScrollEnabled:YES];
    [commentTextView setBackgroundColor:[UIColor clearColor]];
//    [commentTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    commentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:commentTextView];
    
    
    UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeComment)];
    
    closeComment=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    closeComment.userInteractionEnabled=YES;
    [closeComment setImage:[UIImage imageNamed:@"close_comment"]];
    [closeComment addGestureRecognizer:tap];
    [contentView addSubview:closeComment];
    
//    [topicView addSubview:contentView];
    [self.view addSubview:contentView];
    
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    topicView.center=self.view.center;
    
    
    footerView=[[UIView alloc] initWithFrame:CGRectMake(0, h-45, w, 45)];
//    [footerView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:footerView];
    
    UIButton *leftBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, 45/2-35/2, 35, 35)];
//    UIButton *leftBtn=[[UIButton alloc] initWithFrame:CGRectMake(w-95, 45/2-35/2, 35, 35)];
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 4, 5, 4)];
    [leftBtn setImage:[UIImage imageNamed:@"input_button"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"input_button_click"] forState:UIControlStateSelected];
    [leftBtn setImage:[UIImage imageNamed:@"input_button_click"] forState:UIControlStateHighlighted];
    leftBtn.tag=2;
    [leftBtn addTarget:self action:@selector(showInputOrFaceList:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:leftBtn];
    
    updateInputTagView = [[UIImageView alloc ] initWithFrame:CGRectMake(2, 2, 31, 31)];
    updateInputTagView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"new_input_face1.png"],
                                         [UIImage imageNamed:@"new_input_face2.png"],
                                         [UIImage imageNamed:@"new_input_face3.png"],
                                         [UIImage imageNamed:@"new_input_face4.png"], nil];
    updateInputTagView.animationDuration=1.0;
    updateInputTagView.animationRepeatCount=0;
    [updateInputTagView setContentMode:UIViewContentModeScaleAspectFit];
    [leftBtn addSubview:updateInputTagView];
    
    if([@"1" isEqual:[SysTools getValueFromNSUserDefaultsByKey:CheckInputUpdate]]){
        [updateInputTagView setHidden:NO];
        [updateInputTagView startAnimating];
    }else{
        [updateInputTagView setHidden:YES];
        [updateInputTagView stopAnimating];
    }

    
    UIButton *rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(w-50, 45/2-20, 40, 40)];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [rightBtn setImage:[UIImage imageNamed:@"facebuttonnor"] forState:UIControlStateNormal];
    rightBtn.tag=1;
    [rightBtn setImage:[UIImage imageNamed:@"facebuttonself"] forState:UIControlStateSelected];
    [rightBtn setImage:[UIImage imageNamed:@"facebuttonself"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(showInputOrFaceList:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:rightBtn];
    
    
    updateFaceTagView = [[UIImageView alloc ] initWithFrame:CGRectMake(2, 2, 31, 31)];
    [updateFaceTagView setImageWithLocalName:@"new_input_face"];
    updateFaceTagView.animationImages = [NSArray arrayWithObjects:
                          [UIImage imageNamed:@"new_input_face1.png"],
                          [UIImage imageNamed:@"new_input_face2.png"],
                          [UIImage imageNamed:@"new_input_face3.png"],
                          [UIImage imageNamed:@"new_input_face4.png"], nil];
    updateFaceTagView.animationDuration=1.0;
    updateFaceTagView.animationRepeatCount=0;
    [updateFaceTagView setContentMode:UIViewContentModeScaleAspectFit];
    [rightBtn addSubview:updateFaceTagView];
    if([@"1" isEqual:[SysTools getValueFromNSUserDefaultsByKey:CheckFaceUpdate]]){
        [updateFaceTagView setHidden:NO];
        [updateFaceTagView startAnimating];
    }else{
        [updateFaceTagView setHidden:YES];
        [updateFaceTagView stopAnimating];
    }
    
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [rotationRecognizer setDelegate:self];
//    [self.view addGestureRecognizer:rotationRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self.view addGestureRecognizer:panRecognizer];
    
    //点击事件，暂不添加
//    UITapGestureRecognizer *tapProfileImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//    [tapProfileImageRecognizer setNumberOfTapsRequired:1];
//    [tapProfileImageRecognizer setDelegate:self];
//    [contentView addGestureRecognizer:tapProfileImageRecognizer];
}


/**
 * 创建表情
 */
-(void)createFaceView{
    _faceView = [[UIView alloc]initWithFrame:CGRectMake(0, h, w, h)];
    [_faceView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_faceView];
    
    
    [self addSwipeGesture];
    
    
    topMenuView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    [topMenuView setBackgroundColor:UIColorFromRGB(EmotionMenuColor)];
    [_faceView addSubview:topMenuView];
    
    
    
    
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"tab_close_nor"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"tab_close_sel"] forState:UIControlStateHighlighted];
    
    [closeButton setBackgroundColor:[UIColor clearColor]];
    closeButton.frame = CGRectMake(w - 55, 0, 50, 44);
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(9, 12, 9, 12)];
    [closeButton addTarget:self action:@selector(hideAnimationView) forControlEvents:UIControlEventTouchUpInside];
    [topMenuView addSubview:closeButton];
    
    
    topMenuScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w-55, 44)];
    topMenuScrollView.showsHorizontalScrollIndicator=NO;
    
    [_faceView addSubview:topMenuScrollView];
    [self loadInputAndFaceData:0];
    
    float itemSizeWith=(w-80)/3;
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection              = UICollectionViewScrollDirectionVertical;
    
    layout.itemSize                     = CGSizeMake(itemSizeWith, itemSizeWith);
    layout.minimumInteritemSpacing      = 20;
    layout.minimumLineSpacing           = 20;
    layout.sectionInset                 = UIEdgeInsetsMake(20, 20, 20, 20);
    
    
    self.listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, w, h-44) collectionViewLayout:layout];
    self.listCollectionView.dataSource=self;
    self.listCollectionView.delegate=self;
    self.listCollectionView.alwaysBounceVertical  =YES;
    self.listCollectionView.backgroundColor       = [UIColor clearColor];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([FaceCollectionViewCell class])  bundle:[NSBundle mainBundle]];
    [self.listCollectionView registerNib:cellNib forCellWithReuseIdentifier:staticCollectionViewCell];
    [self.listCollectionView setFrame:CGRectMake(0, 44, w, h-44)];
    [self.listCollectionView setBackgroundColor:UIColorFromRGB(EmotionScrollViewBg)];
    [_faceView addSubview:self.listCollectionView];
    
    
    isShowFace=NO;
    
}



#pragma mark 手势处理
-(void)addSwipeGesture{
    [self.view setUserInteractionEnabled:YES];
    _faceView.userInteractionEnabled=YES;
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [_faceView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [_faceView addGestureRecognizer:recognizer];
}

-(void)createReplyView{
    int rw=115;
    replyView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, rw, 45)];
    [replyView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [footerView addSubview:replyView];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 45)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:TTLocalString(@"TT_reply")];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:UIColorFromRGB(TextGrayColor)];
    [replyView addSubview:label];
    
    
    UIButton *btnDel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnDel setFrame:CGRectMake(50, 2, 40, 40)];
    btnDel.layer.cornerRadius=15;
    btnDel.layer.masksToBounds=YES;
    [btnDel setBackgroundColor:[UIColor clearColor]];
    [btnDel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDel sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:self.commentModel.uid time:self.commentModel.avatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    btnDel.layer.cornerRadius=20;
    btnDel.layer.masksToBounds=YES;
    btnDel.layer.borderColor=[UIColor whiteColor].CGColor;
    btnDel.layer.borderWidth=2;
    [btnDel addTarget:self action:@selector(delReply:) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:btnDel];
    
    
    UIButton *jdelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    jdelButton.layer.cornerRadius=9;
    jdelButton.layer.masksToBounds=YES;
    [jdelButton setBackgroundColor:UIColorFromRGB(NoticeColor)];
    [jdelButton setFrame:CGRectMake(84, 13, 18, 18)];
    [jdelButton setTitle:@"﹣" forState:UIControlStateNormal];
    [jdelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    jdelButton.layer.borderColor=[UIColor whiteColor].CGColor;
    jdelButton.layer.borderWidth=2;
    [jdelButton addTarget:self action:@selector(delReply:) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:jdelButton];
 
    UIButton *leftBtn=(UIButton *)[footerView viewWithTag:2];
    CGRect f = leftBtn.frame;
    f.origin.x=125;
    leftBtn.frame=f;
}


//设置页面显示
-(void)setDefaultStatus{
    clickTag=1;
    isTextInput=YES;
    
    [self setInitData];
    
    
    //回复
    if(self.topicModel !=nil ){
        contentView.hidden=NO;
        
        //设置图片资源
        if(self.topicModel.type==5){
            [topicView setImage:self.releaseImage];
        }else{
            [topicView sd_setImageWithURL:[NSURL URLWithString:self.topicModel.sourcepath] placeholderImage:[UIImage imageNamed:@"default_topic"]];
        }
        
        CGPoint centerPoint=self.view.center;
        
        
        int sh=iOS7?0:20;
        //回复
        if(self.commentModel!=nil){
            isReply=YES;
            [commentTextView setPlaceholder:[NSString stringWithFormat:@"%@%@",TTLocalString(@"TT_reply"),self.commentModel.nickname]];
            centerPoint=CGPointMake([self.commentModel.pointX floatValue], [self.commentModel.pointY floatValue]+topicView.frame.origin.y-sh);
            //如果太低，看不到输入框
            if(centerPoint.y>self.view.bounds.size.height-220){
                centerPoint.y=self.view.bounds.size.height-220;
            }
            
            if(self.commentModel.comment!=nil && ![@"" isEqual:self.commentModel.comment]){
                contentSource=self.commentModel.commentbg;
            }
            
//            // 回复人相关视图
            [self createReplyView];
            
            [self autoSizeToTextView];
        }else{
            [commentTextView setPlaceholder:TTLocalString(@"TT_send_comment")];
            
            if(self.commentPoint.x>0 && self.commentPoint.y>0){
                centerPoint=CGPointMake(self.commentPoint.x, self.commentPoint.y+topicView.frame.origin.y-sh);
                
                
                centerPoint=[self translateUsingTouchLocation:centerPoint];
                
                //如果太低，看不到输入框
                if(centerPoint.y>self.view.bounds.size.height-220){
                    centerPoint.y=self.view.bounds.size.height-220;
                }
                
            }
        }
        
        contentView.center=centerPoint;
//        contentView.image=[UIImage imageNamed:contentSource];
        [SysTools getEmotionImage:contentSource imageView:contentView];
        [commentTextView setTextColor:[SysTools getCommentColor:contentSource]];
    }
}

-(void)delReply:(UIButton *)btn{
    isReply=NO;
    [commentTextView setText:@""];
    [commentTextView setPlaceholder:TTLocalString(@"TT_send_comment")];
    
    if(replyView){
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rf = replyView.frame;
            rf.origin.x=-125;
            replyView.frame=rf;
            
            UIButton *leftBtn=(UIButton *)[footerView viewWithTag:2];
            CGRect f = leftBtn.frame;
            f.origin.x=10;
            leftBtn.frame=f;
            
            
            for (UIView *v in replyView.subviews) {
                [v removeFromSuperview];
            }
            [replyView removeFromSuperview];
        }];
    }
}


-(IBAction)goBack:(id)sender{
    
    if(self.navigationController==nil){
        NSLog(@"self");
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
//        UIViewController *controller = self.presentingViewController;
//        if(![controller isKindOfClass:[VPImageCropperViewController class]]){
//            [self dismissViewControllerAnimated:NO completion:^{
//                [controller dismissViewControllerAnimated:YES completion:^{
//                    
//                }];
//            }];
//        }else{
//            [self dismissViewControllerAnimated:YES completion:^{
//                
//            }];
//        }
    }else{
        UIViewController *pc=nil;
        if(self.navigationController.childViewControllers.count>2){
            pc=[self.navigationController.childViewControllers objectAtIndex:self.navigationController.childViewControllers.count-2];
        }
        if([pc isKindOfClass:[VPImageCropperViewController class]]){
            pc=[self.navigationController.childViewControllers objectAtIndex:self.navigationController.childViewControllers.count-3];
            [self.navigationController popToViewController:pc animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//动态计算文字大小
-(void)textViewDidChange:(UITextView *)textView{
    [self autoSizeToTextView];
}


-(void)autoSizeToTextView{
    fontSize = MaxFontSize;
    CGFloat curHeight=0;
    if([@"" isEqual:commentTextView.text]){
        fontSize=14;
    }else{
//        WSLog(@"%@",[commentTextView.attributedText string]);
        curHeight= [SysTools getHeightContain:commentTextView.text font:[UIFont systemFontOfSize:fontSize] Width:commentTextView.frame.size.width]+5;
        while (curHeight>commentTextView.frame.size.height) {
            fontSize=fontSize-1;
            curHeight= [SysTools getHeightContain:commentTextView.text font:[UIFont systemFontOfSize:fontSize] Width:commentTextView.frame.size.width-10]+5;
        }
        
        if(fontSize<MinFontSize){
            fontSize=MinFontSize;
        }
    }
    commentTextView.font=[UIFont systemFontOfSize:fontSize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [commentTextView setContentInset:UIEdgeInsetsZero];
        [commentTextView setFrame:CGRectMake(20, 40, 100, 62)];
        
    });
}


#pragma mark 代理开始
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(showArr!=nil && showArr.count>0){
        return showArr.count;
    }
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:staticCollectionViewCell forIndexPath:indexPath];
    NSURL *url=[SysTools getEmotionURL:[showArr objectAtIndex:indexPath.row]];
    UIButton * button;
    if(cell.contentView.subviews!=nil && cell.contentView.subviews.count>0){
        button=[cell.contentView.subviews objectAtIndex:0];
        button.tag=indexPath.row;
        
        [button sd_setImageWithURL:url forState:UIControlStateNormal];
    }
    
    if(button==nil){
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0,0,cell.frame.size.width,cell.frame.size.width);
        button.tag=indexPath.row;
        [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGBAlpha(0xFFFFFF,0.2)] forState:UIControlStateNormal];
        
        [button setBackgroundImage:[SysTools createImageWithColor:UIColorFromRGBAlpha(0xFFFFFF,0.06)] forState:UIControlStateHighlighted];
        button.layer.masksToBounds=YES;
        button.layer.cornerRadius=cell.frame.size.width/2;
        [button setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        [button sd_setImageWithURL:url forState:UIControlStateNormal];
        [cell.contentView addSubview:button];
    }
    return cell;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor whiteColor];
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark 搜索用户代理
-(void)tableItemClick:(UserInfo *)user{
    if([commentTextView.text hasSuffix:@"@"]){
        commentTextView.text=[commentTextView.text substringToIndex:commentTextView.text.length-1];
    }
    
    NSUInteger pointLocation=commentTextView.selectedRange.location;
    
    NSMutableString *tempStr=[[NSMutableString alloc]initWithString:commentTextView.text];
    
    
    NSString *string=[NSString stringWithFormat:@"<atuser>%@</atuser> ",user.realname];
    [tempStr insertString:string atIndex:pointLocation];
    
    [commentTextView setText:tempStr];
    [commentTextView setSelectedRange:NSMakeRange(pointLocation+string.length-16,0)];
    
    [self autoSizeToTextView];
}

//话题回调
-(void)sendText:(topicHotModel *)hotModel
{
    if([commentTextView.text hasSuffix:@"#"]){
        commentTextView.text=[commentTextView.text substringToIndex:commentTextView.text.length-1];
    }
    NSUInteger pointLocation=commentTextView.selectedRange.location;
    
    
    NSMutableString *tempStr=[[NSMutableString alloc]initWithString:commentTextView.text];
    
    [tempStr insertString:[NSString stringWithFormat:@"#%@ ",hotModel.httext] atIndex:pointLocation];
//    [tempStr appendString:[NSString stringWithFormat:@"#%@ ",hotModel.httext]];
    
    [commentTextView setText:tempStr];
    [commentTextView setSelectedRange:NSMakeRange(pointLocation+hotModel.httext.length+2,0)];
    [self autoSizeToTextView];
}

//判断删除键
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //#按钮
    if([@"#" isEqual:text]){
        topicSelectedViewController *topic=[[topicSelectedViewController alloc]init];
        topic.delegate=self;
        [self.navigationController pushViewController:topic animated:YES];
    }
    
    if([@"@" isEqual:text]){
        //@按钮
        UserSearchController *searchUser=[[UserSearchController alloc] init];
        searchUser.delegate=self;
        [self.navigationController pushViewController:searchUser animated:YES];
    }
    
    commentTextView.tempText=[NSString stringWithFormat:@"%@%@",textView.text,text];
    
    if( [text length] == 0 ) {
        // 没有内容
        if (range.length < 1 ) {
            return YES;
        }
        else {
            return [commentTextView doDelete];
        }
    }
    
    //点击了非删除键
    return YES;
}


#pragma mark 加载表情数据
//loadType 0,加载所有，1加载表情，2加载输入框
-(void)loadInputAndFaceData:(int) loadType{
    if(loadType==0 || loadType==1){
        int xw=85;
        int sw=0;
        NSDictionary *dict=[SysTools getValueFromNSUserDefaultsByKey:API_Get_FaceList];
        if(dict!=nil && dict.count>0){
            for (UIView *v in topMenuScrollView.subviews) {
                [v removeFromSuperview];
            }
            [topMenuScrollView setContentOffset:CGPointMake(0, 0)];
            
            int i=1;
            NSArray *arr=[dict objectForKey:@"data"];
            for (NSDictionary *item in arr) {
                FaceModel *model=[[FaceModel alloc] initWithMyDict:item];
                [faceArray addObject:model];
                
                UIButton *picButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [picButton setBackgroundColor:[UIColor clearColor]];
                [picButton sd_setImageWithURL:[SysTools getEmotionURL:model.typepic] forState:UIControlStateNormal];
                picButton.frame = CGRectMake(sw, 0, xw, 44);
                [picButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
                [picButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
                picButton.tag = i;
                [picButton addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
                [topMenuScrollView addSubview:picButton];
                
                if(i==1){
                    checkModel=model;
                    [picButton setBackgroundColor:UIColorFromRGB(EmotionScrollViewBg)];
                    checkButton=picButton;
                }
                i=i+1;
                sw=sw+xw+1;
            }
            
            if(sw>(w-55)){
                [topMenuScrollView setContentSize:CGSizeMake(sw, 44)];
            }
        }else{
            [[SendLocalTools getInstance] synchronousInputList:^(int isSuccess) {
                [self loadInputAndFaceData:1];
            }];
        }
    }
    
    if(loadType==0 || loadType==2){
        NSDictionary *inputDict=[SysTools getValueFromNSUserDefaultsByKey:API_Get_InputList];
        if(inputDict!=nil && inputDict.count>0){
            NSDictionary *arr=[inputDict objectForKey:@"data"];
            itemsbg=[[NSMutableArray alloc] initWithArray:[arr objectForKey:@"list"]];
        }else{
            [[SendLocalTools getInstance] synchronousFaceList:^(int isSuccess) {
                [self loadInputAndFaceData:2];
            }];
        }
    }
}


#pragma mark 内存警告
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
