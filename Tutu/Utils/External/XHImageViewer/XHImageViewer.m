//
//  XHImageViewer.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHImageViewer.h"
#import "XHViewState.h"
#import "XHZoomingImageView.h"
#import "SVWebViewController.h"
#import "AuthorizationGuideController.h"
#import "ShareTutuFriendsController.h"
#import "SDWebImageManager.h"
#import "RCLetterCell.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"


//拍照更换头像，仅仅详情页实现，
//其它要实现这个，请修改代理
//imagePicker.delegate = (UserDetailController *)self.delegate;
#import "UserDetailController.h"

@interface XHImageViewer ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imgViews;

@end

@implementation XHImageViewer

- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.backgroundScale = 0.95;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)setImageViewsFromArray:(NSArray*)views {
    NSMutableArray *imgViews = [NSMutableArray array];
    for(id obj in views){
        if([obj isKindOfClass:[UIImageView class]]){
            [imgViews addObject:obj];
            
            UIImageView *view = obj;
            
            XHViewState *state = [XHViewState viewStateForView:view];
            [state setStateWithView:view];
            
            view.userInteractionEnabled = NO;
        }
    }
    _imgViews = [imgViews copy];
}

- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView {
    [self setImageViewsFromArray:views];
    
    if(_imgViews.count > 0){
        if(![selectedView isKindOfClass:[UIImageView class]] || ![_imgViews containsObject:selectedView]){
            selectedView = _imgViews[0];
        }
        [self showWithSelectedView:selectedView];
    }
}

#pragma mark- Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[backgroundColor colorWithAlphaComponent:0]];
}

- (NSInteger)pageIndex {
    return (_scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5);
}

#pragma mark- View management

- (UIImageView *)currentView {
    return [_imgViews objectAtIndex:self.pageIndex];
}

- (void)showWithSelectedView:(UIImageView*)selectedView {
    for(UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    const NSInteger currentPage = [_imgViews indexOfObject:selectedView];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if(_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        _scrollView.alpha = 0;
    }
    
    
    [self addSubview:_scrollView];
    
    
    const CGFloat fullW = window.frame.size.width;
    const CGFloat fullH = window.frame.size.height;
    
    selectedView.frame = [window convertRect:selectedView.frame fromView:selectedView.superview];
    
    [window addSubview:selectedView];
    
    
    
    if(self.isShowMenu){
        CGRect bounds=[UIScreen mainScreen].bounds;
        UIButton *btnMenu=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnMenu setFrame:CGRectMake(bounds.size.width-50, bounds.size.height-44, 40, 34)];
        [btnMenu setImageEdgeInsets:UIEdgeInsetsMake( 8.5, 10,8.5,10)];
        [btnMenu setImage:[UIImage imageNamed:@"user_show_image"] forState:UIControlStateNormal];
        [btnMenu setImage:[UIImage imageNamed:@"user_show_image_sel"] forState:UIControlStateHighlighted];
        [btnMenu addTarget:self action:@selector(showMenuClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnMenu];
    }
    [window addSubview:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 1;
                         window.rootViewController.view.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
                         
                         selectedView.transform = CGAffineTransformIdentity;
                         
                         CGSize size = (selectedView.image) ? selectedView.image.size : selectedView.frame.size;
                         CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                         CGFloat W = ratio * size.width;
                         CGFloat H = ratio * size.height;
                         selectedView.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                     }
                     completion:^(BOOL finished) {
                         _scrollView.contentSize = CGSizeMake(_imgViews.count * fullW, 0);
                         _scrollView.contentOffset = CGPointMake(currentPage * fullW, 0);
                         
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
                         [_scrollView addGestureRecognizer:gesture];
                         
                         for(UIImageView *view in _imgViews){
                             view.transform = CGAffineTransformIdentity;
                             
                             CGSize size = (view.image) ? view.image.size : view.frame.size;
                             CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             view.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                             
                             XHZoomingImageView *tmp = [[XHZoomingImageView alloc] initWithFrame:CGRectMake([_imgViews indexOfObject:view] * fullW, 0, fullW, fullH)];
                             tmp.imageView = view;
                             
                             [_scrollView addSubview:tmp];
                         }
                     }
     ];
}

- (void)prepareToDismiss {
    UIImageView *currentView = [self currentView];
    if(currentView==nil){
        return;
    }
    if([self.delegate respondsToSelector:@selector(imageViewer:willDismissWithSelectedView:)]) {
        [self.delegate imageViewer:self willDismissWithSelectedView:currentView];
    }
    
    for(UIImageView *view in _imgViews) {
        if(view != currentView) {
            XHViewState *state = [XHViewState viewStateForView:view];
            view.transform = CGAffineTransformIdentity;
            view.frame = state.frame;
            view.transform = state.transform;
            
            [state.superview addSubview:view ];
        }
    }
}

- (void)dismissWithAnimate {
    UIView *currentView = [self currentView];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect rct = currentView.frame;
    currentView.transform = CGAffineTransformIdentity;
    CGRect curRct=[window convertRect:rct fromView:currentView.superview];
    curRct.origin.y=ScreenHeight/2-curRct.size.height/2;
    currentView.frame =curRct;
    [window addSubview:currentView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 0;
                         window.rootViewController.view.transform =  CGAffineTransformIdentity;
                         
                         XHViewState *state = [XHViewState viewStateForView:currentView];
                         currentView.frame = [window convertRect:state.frame fromView:state.superview];
                         currentView.transform = state.transform;
                     }
                     completion:^(BOOL finished) {
                         XHViewState *state = [XHViewState viewStateForView:currentView];
                         currentView.transform = CGAffineTransformIdentity;
                         currentView.frame = state.frame;
                         currentView.transform = state.transform;
                         
                         [state.superview addSubview:currentView];
                         
                         for(UIView *view in _imgViews){
                             XHViewState *_state = [XHViewState viewStateForView:view];
                             view.userInteractionEnabled = _state.userInteratctionEnabled;
                         }
                         
                         [self removeFromSuperview];
                     }
     ];
}

#pragma mark- Gesture events

- (void)tappedScrollView:(UITapGestureRecognizer*)sender
{
    [self prepareToDismiss];
    [self dismissWithAnimate];
}

- (void)didPan:(UIPanGestureRecognizer*)sender
{
    static UIImageView *currentView = nil;
    
    if(sender.state == UIGestureRecognizerStateBegan){
        currentView = [self currentView];
        
        UIView *targetView = currentView.superview;
        while(![targetView isKindOfClass:[XHZoomingImageView class]]){
            targetView = targetView.superview;
        }
        
        if(((XHZoomingImageView *)targetView).isViewing){
            currentView = nil;
        }
        else{
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            currentView.frame = [window convertRect:currentView.frame fromView:currentView.superview];
            [window addSubview:currentView];
            
            [self prepareToDismiss];
        }
    }
    
    if(currentView){
        if(sender.state == UIGestureRecognizerStateEnded){
            if(_scrollView.alpha>0.5){
                [self showWithSelectedView:currentView];
            }
            else{
                [self dismissWithAnimate];
            }
            currentView = nil;
        }
        else{
            CGPoint p = [sender translationInView:self];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y)/1000, 1 - fabs(p.y)/1000);
            currentView.transform = transform;
            
            CGFloat r = 1-fabs(p.y)/200;
            _scrollView.alpha = MAX(0, MIN(1, r));
        }
    }
}


-(void)showMenuClick{
    if(self.menuType==1){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:@"" delegate:self otherButton:@[@"更换头像",@"查看魅力值"] cancelButton:@"取消"];
        sheet.tag=1;
        [sheet showInCustomView:self];
    }
    if(self.menuType==2){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:@"" delegate:self otherButton:@[@"查看魅力值"] cancelButton:@"取消"];
        sheet.tag=2;
        [sheet showInCustomView:self];
    }
    if(self.menuType==3){
        LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:@"" delegate:self otherButton:@[@"发送给好友",@"保存图片"] cancelButton:@"取消"];
        sheet.tag=10;
        
        [sheet showInCustomView:self];
    }
}

-(void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if(tag==1){
        if(buttonIndex==0){
            LXActionSheet *sheet=[[LXActionSheet alloc] initWithTitle:@"" delegate:self otherButton:@[@"拍照",@"从相册选择"] cancelButton:@"取消"];
            sheet.tag=3;
            [sheet showInCustomView:self];
        }
        if(buttonIndex==1){
            SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:@"http://api.tutuim.com/static/honour.html"]];
            webView.title = @"魅力值";
            ((UIViewController *)self.delegate).navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            [((UIViewController *)self.delegate).navigationController pushViewController:webView animated:YES];
            [self dismissWithAnimate];
        }
    }
    
    if(tag==2){
        if(buttonIndex==0){
            SVWebViewController * webView = [[SVWebViewController alloc]initWithURL:[NSURL URLWithString:@"http://api.tutuim.com/static/honour.html"]];
            webView.title = @"魅力值";
            ((UIViewController *)self.delegate).navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
            [((UIViewController *)self.delegate).navigationController pushViewController:webView animated:YES];
            
            [self dismissWithAnimate];
        }
    }
    
    
    //修改头像
    if(tag==3){
        
        if (buttonIndex == 0) {
            if ([SysTools isHasCaptureDeviceAuthorization]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.allowsEditing=YES;
#warning 单一支持UserDetailController
                imagePicker.delegate = (UserDetailController *)self.delegate;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [((UIViewController *)self.delegate) presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }else{
                AuthorizationGuideController *vc = [[AuthorizationGuideController alloc]init];
                vc.authorizatonType = AuthorizationTypeCaptureDevice;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [((UIViewController *)self.delegate) presentViewController:nav animated:YES completion:^{
                    
                }];
            }
            
            [self dismissWithAnimate];
        }else if(buttonIndex == 1){
            if ([SysTools isHasPhotoLibraryAuthorization]) {
                UIImagePickerController*imagePicker = [[UIImagePickerController alloc] init];
#warning 单一支持UserDetailController
                imagePicker.delegate = (UserDetailController *)self.delegate;
                imagePicker.allowsEditing=YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                //        imagePicker.allowsEditing = YES;
                if ([imagePicker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                    [imagePicker.navigationBar setBarTintColor:UIColorFromRGB(SystemColor)];
                    [imagePicker.navigationBar setTranslucent:YES];
                    [imagePicker.navigationBar setTintColor:[UIColor whiteColor]];
                    
                }else{
                    [imagePicker.navigationBar setBackgroundColor:UIColorFromRGB(SystemColor)];
                }
                
                [imagePicker.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,TitleFont, NSFontAttributeName, nil]];
                [((UIViewController *)self.delegate) presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }else{
                AuthorizationGuideController *vc = [[AuthorizationGuideController alloc]init];
                vc.authorizatonType = AuthorizationTypePhotoLibrary;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [((UIViewController *)self.delegate) presentViewController:nav animated:YES completion:^{
                    
                }];
            }
            
            [self dismissWithAnimate];
        }
    }
    if(tag==10){
        if(buttonIndex==0){
            [self prepareToDismiss];
            [self dismissWithAnimate];
            
            ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
            vc.uid = [[LoginManager getInstance] getUid];
            vc.rcmsg = self.rcmsg;
            [((BaseController *)((RCLetterCell *)self.delegate).delegate) openNavWithSound:vc];
        }
        if(buttonIndex==1){
            @try {
                RCImageMessage *msg=(RCImageMessage *)self.rcmsg.content;
//
//                if(msg.originalImage!=nil){
//                    UIImageWriteToSavedPhotosAlbum(msg.originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//                }else{
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:msg.imageUrl] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                        [library saveImage:image toAlbum:@"Tutu" withCompletionBlock:^(NSError *error) {
                            [self showSaveNotice:error];
                        }];
                    }];
//                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
}


- (void)showSaveNotice:(NSError *) error
{
    if (error == nil)
    {
        [((BaseController *)((RCLetterCell *)self.delegate).delegate) showNoticeWithMessage:@"保存图片成功" message:@"" bgColor:TopNotice_Block_Color];
    }
    else
    {
        [((BaseController *)((RCLetterCell *)self.delegate).delegate) showNoticeWithMessage:@"保存图片失败!" message:@"" bgColor:TopNotice_Red_Color];
    }
    [self prepareToDismiss];
    [self dismissWithAnimate];
}


#pragma mark 拍照处理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    WSLog(@"%@",picker.title);
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
                    NSString *filePath=[SysTools writeImageToDocument:image fileName:@"avatar.png"];
            
        [[RequestTools getInstance] post:API_ADD_SETUSERAVATAR filePath:filePath fileKey:@"avatarfile" params:nil completion:^(NSDictionary *dict) {
            //            上传图片成功
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            UserInfo *info=[[LoginManager getInstance] getLoginInfo];
            
            [SysTools clearAvatar];
            if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"code"]] isEqualToString:@"10000"]) {
                info.avatartime = [[dict objectForKey:@"data"] objectForKey:@"avatartime"];
            }
            
            //保存图片的时间到本地
            [[LoginManager getInstance] saveInfoToDB:info];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEUSERINFO object:nil];
        } failure:^(ASIFormDataRequest *request, NSString *message) {
            //            上传图片失败
        } finished:^(ASIFormDataRequest *request) {
        }];
    }];
    
    
}
@end
