//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVWebViewControllerActivityChrome.h"
#import "SVWebViewControllerActivitySafari.h"
#import "SVWebViewController.h"

#import "SvUDIDTools.h"
#import "UIDevice-Hardware.h"

#import "UserDetailController.h"
#import "TopicDetailController.h"
#import "SameCityController.h"
#import "MyFriendViewController.h"

#import "ShareTutuFriendsController.h"
#import "UMSocial.h"
#import "UIImageView+WebCache.h"
#import "ListTopicsController.h"

#import "RDVTabBarController.h"



@interface SVWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@end


@implementation SVWebViewController

#pragma mark - Initialization

- (void)dealloc {
    [self.webView stopLoading];
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.webView.delegate = nil;
}
- (instancetype)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (instancetype)initWithURL:(NSURL*)pageURL {
    NSString * userAgent = [NSString stringWithFormat:@"%@/%@/ios(%@,%@,imsi,%@,%f*%f,,%f)",@"Tutu",[SysTools getAppVersion],[[UIDevice currentDevice] modelName],[SvUDIDTools UDID],[[UIDevice currentDevice] systemVersion],[UIScreen mainScreen].currentMode.size.width,[UIScreen mainScreen].currentMode.size.height,[UIScreen mainScreen].scale];
    
    //设置UserAgent
    NSDictionary *userAgents = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgents];
    
    
    NSMutableURLRequest *requestURL=[NSMutableURLRequest requestWithURL:pageURL];
    NSArray *arr=[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    NSString *cookies=@"";
    for (NSHTTPCookie *cookie in arr) {
        cookies=[NSString stringWithFormat:@"%@%@=%@; ",cookies,cookie.name,cookie.value];
    }
    if(cookies.length>0){
        cookies=[NSString stringWithFormat:@"%@]",cookies];
        cookies=[cookies stringByReplacingOccurrencesOfString:@"; ]" withString:@""];
    }
    [requestURL setValue:cookies forHTTPHeaderField: @"Cookie"];
    
    return [self initWithURLRequest:requestURL];
}

- (instancetype)initWithURLRequest:(NSURLRequest*)request {
    self = [super init];
    if (self) {
        self.request = request;
    }
    return self;
}

- (void)loadRequest:(NSURLRequest*)request {
    [self.webView loadRequest:request];
}

#pragma mark - View lifecycle

- (void)loadView {
    if(iOS7){
        self.view=self.webView;
    }else{
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        UIWebView *web=self.webView;
        CGRect f=web.frame;
        f.origin.y=NavBarHeight;
        f.size.height=f.size.height-44-NavBarHeight-20;
        [web setFrame:f];
        [self.view addSubview:web];
    }
    [self loadRequest:self.request];
}

- (void)viewDidLoad {
	[super viewDidLoad];    

    [self setNavigationBarStyle];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: TitleFont,UITextAttributeTextColor:[UIColor whiteColor]};
    [self createLeftBarItemSelect:@selector(goBack:) imageName:nil heightImageName:nil];
    UIButton *addButton = [self createRightBarItemSelect:@selector(doShare:) imageName:@"share_white" heightImageName:@"share_white_sel"];
    [addButton setFrame:CGRectMake(0, 0, 44, 44)];
    [addButton setImageEdgeInsets:UIEdgeInsetsMake(10.5, 18, 10.5,0)];
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self updateToolbarItems];
    self.webView.scrollView.bounces = NO;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _actionBarButtonItem = nil;
}

- (void)goBack:(id)sender
{
    if (_comefrom == 1) {
        //进入首页
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController=[stryBoard instantiateInitialViewController];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)doShare:(id)sender{
    WSLog(@"分享");
    ShareActonSheet *sheet = [ShareActonSheet instancedSheetWith:nil type:ActionSheetButtonTypeCopy];
    sheet.delegate = self;
    [sheet showInWindow];
}

-(void)shareActionSheetButtonClick:(NSInteger)imageIndex{
    
    if(![[LoginManager getInstance] isLogin]){
        [[LoginManager getInstance]showLoginView:self];
        return;
    }
    NSString *shareURL=self.request.URL.absoluteString;
    if(imageIndex<=5){
        if (imageIndex == ActionSheetTypeTutu) {
            ShareTutuFriendsController *vc = [[ShareTutuFriendsController alloc]init];
            vc.uid = [LoginManager getInstance].getUid;
            if(self.msg!=nil){
                vc.rcmsg = self.msg;
            }else{
                NSString *strJs=@"document.getElementsByTagName('img')[0].src";
                NSString *sourceURL=[self.webView stringByEvaluatingJavaScriptFromString:strJs];
                
                
                NSString *jscontent=@"document.querySelector('meta[name=\"description\"]').getAttribute('content')";
                NSString *shareText=[self.webView stringByEvaluatingJavaScriptFromString:jscontent];
                NSString *shareTitle=[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
                
                RCRichContentMessage *message=[RCRichContentMessage messageWithTitle:shareTitle digest:shareText imageURL:sourceURL extra:@""];
                RCMessage *msg=[[RCMessage alloc] initWithType:ConversationType_PRIVATE targetId:@"0001" direction:MessageDirection_SEND messageId:0 content:message];
                vc.rcmsg=msg;
            }
            
            
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            NSString *shareTitle=self.title;
            NSString *shareText=@"";
            NSString *sourceURL=@"";
            if(self.msg!=nil){
                if([self.msg.objectName isEqual:RCRichContentMessageTypeIdentifier]){
                    RCRichContentMessage *rcmsg=(RCRichContentMessage *)self.msg.content;
                    sourceURL=rcmsg.imageURL;
                    shareTitle=rcmsg.title;
                    shareText=rcmsg.digest;
                }
                if([self.msg.objectName isEqual:RCImageMessageTypeIdentifier]){
                    RCImageMessage *rcmsg=(RCImageMessage *)self.msg.content;
                    sourceURL=rcmsg.imageUrl;
                }
            }else{
                
                NSString *strJs=@"document.getElementsByTagName('img')[0].src";
                sourceURL=[self.webView stringByEvaluatingJavaScriptFromString:strJs];
                
                
                NSString *jscontent=@"document.querySelector('meta[name=\"description\"]').getAttribute('content')";
                shareText=[self.webView stringByEvaluatingJavaScriptFromString:jscontent];
                shareTitle=[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];

            }
            
            
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
            [UMSocialData defaultData].extConfig.qqData.url = shareURL;
            [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
            [UMSocialData defaultData].extConfig.sinaData.urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:shareURL];
            
            NSArray *types=@[UMShareToWechatSession];
            switch (imageIndex) {
                case ActionSheetTypeWXSection:
                    //                shareText = WebCopy_ShareWeixinFriendDesc;
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    types=@[UMShareToWechatTimeline];
                    break;
                    
                case ActionSheetTypeWXFriend:
                    types=@[UMShareToWechatSession];
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    //                shareText = WebCopy_ShareWeixinTimelineDesc;
                    break;
                case ActionSheetTypeQQ:
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    //                shareText = WebCopy_ShareQQDesc;
                    types=@[UMShareToQQ];
                    break;
                case ActionSheetTypeQQZone:
                    types=@[UMShareToQzone];
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    //                shareText = WebCopy_ShareZoneDesc;
                    break;
                case ActionSheetTypeSina:
                    types=@[UMShareToSina];
                    [UMSocialData defaultData].extConfig.title = shareTitle;
                    //                shareText = WebCopy_ShareSinaDesc;
                    
                    break;
                    
                default:
                    break;
            }
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            
            
            [manager downloadImageWithURL:[NSURL URLWithString:sourceURL] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                UMSocialUrlResource *resourece = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:sourceURL];
                
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:types content:shareText image:image location:nil urlResource:resourece presentedController:self completion:^(UMSocialResponseEntity *response){
                    //            WSLog(@"分享状态：%@，返回数据：%@",response.message,response.data);
                    if (response.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"分享成功！");
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_success") duration:2];
                    }else{
                        // Todo
                        [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_share_faild") duration:2];
                    }
                    
                }];
                
            }];
            
        }
    }else{
        if(imageIndex==ActionSheetTypeCopyLink){
            [[UIPasteboard generalPasteboard] setString:shareURL];
            [self showNoticeWithMessage:TTLocalString(@"TT_copy_success") message:nil bgColor:TopNotice_Block_Color];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    if(_comefrom==1){
        [self.navigationController setNavigationBarHidden:NO];
    }
    
//    if([[SysTools getApp] getCurrentRootViewController]!=nil){
//        UIViewController *controller=[[SysTools getApp] getCurrentRootViewController].childViewControllers[0];
//        if([controller isKindOfClass:[RDVTabBarController class]])
//        {
//            [((RDVTabBarController *)controller) setTabBarHidden:YES];
//        }
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    
    if(_comefrom==1){
        [self.navigationController setNavigationBarHidden:YES];
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Getters

- (UIWebView*)webView {
    if(!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/SVWebViewControllerBack"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goBackTapped:)];
		_backBarButtonItem.width = 18.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/SVWebViewControllerNext"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goForwardTapped:)];
		_forwardBarButtonItem.width = 18.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTapped:)];
    }
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    if (!_stopBarButtonItem) {
        _stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopTapped:)];
    }
    return _stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    }
    return _actionBarButtonItem;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = self.self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.self.webView.canGoForward;
    
    UIBarButtonItem *refreshStopBarButtonItem = self.self.webView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat toolbarWidth = 250.0f;
        fixedSpace.width = 35.0f;
        
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          self.backBarButtonItem,
                          fixedSpace,
                          self.forwardBarButtonItem,
//                          fixedSpace,
//                          self.actionBarButtonItem,
                          nil];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        toolbar.barStyle = UIBarStyleDefault;
//        toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }
    
    else {
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.backBarButtonItem,
                          flexibleSpace,
                          self.forwardBarButtonItem,
                          flexibleSpace,
                          refreshStopBarButtonItem,
//                          flexibleSpace,
//                          self.actionBarButtonItem,
                          fixedSpace,
                          nil];
        
        self.navigationController.toolbar.barStyle = UIBarStyleDefault;//self.navigationController.navigationBar.barStyle;
        
//        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.toolbarItems = items;
    }
}

#pragma mark - UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.navigationItem.title = TTLocalString(@"TT_loading");
    [self updateToolbarItems];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *string =[NSString stringWithFormat:@"%@",request.mainDocumentURL.relativeString];
    if([string hasPrefix:@"tutu://com.tutuim.mobile/changetitle/"]){
        // 切换标题
        NSString *param=[string stringByReplacingOccurrencesOfString:@"tutu://com.tutuim.mobile/changetitle/" withString:@""];
        self.navigationItem.title=param;
    }else if ([string hasPrefix:@"tutu://com.tutuim.mobile/personal/"])
    {
        //个人页或他人主页
        NSString *param=[string stringByReplacingOccurrencesOfString:@"tutu://com.tutuim.mobile/personal/" withString:@""];
        NSArray *arr=[param componentsSeparatedByString:@"&"];
        UserDetailController *detail = [[UserDetailController alloc] init];
        for (NSString *item in arr) {
            NSString *key=[[item componentsSeparatedByString:@"="] objectAtIndex:0];
            NSString *value=[[item componentsSeparatedByString:@"="] objectAtIndex:1];
            if([@"uid" isEqual:key]){
                detail.uid=value;
            }
        }
        [self.navigationController pushViewController:detail animated:YES];
    }else if ([string hasPrefix:@"tutu://com.tutuim.mobile/topic_detail/"])
    {
        //个人页或他人主页
        NSString *param=[string stringByReplacingOccurrencesOfString:@"tutu://com.tutuim.mobile/topic_detail/" withString:@""];
        NSArray *arr=[param componentsSeparatedByString:@"&"];
        TopicDetailController *detail = [[TopicDetailController alloc] init];
        for (NSString *item in arr) {
            NSString *key=[[item componentsSeparatedByString:@"="] objectAtIndex:0];
            NSString *value=[[item componentsSeparatedByString:@"="] objectAtIndex:1];
            if([@"topicid" isEqual:key]){
                detail.topicid=value;
            }
            if([@"commentid" isEqual:key]){
                detail.startcommentid=value;
            }
        }
        detail.comefrom = 2;
        [self.navigationController pushViewController:detail animated:YES];
    }else if([string hasPrefix:@"tutu://com.tutuim.mobile/friends/"]){
        // 我的好友页
        NSString *param=[string stringByReplacingOccurrencesOfString:@"tutu://com.tutuim.mobile/friends/" withString:@""];
        NSArray *arr=[param componentsSeparatedByString:@"&"];
        MyFriendViewController *detail = [[MyFriendViewController alloc] init];
        for (NSString *item in arr) {
            NSString *key=[[item componentsSeparatedByString:@"="] objectAtIndex:0];
            NSString *value=[[item componentsSeparatedByString:@"="] objectAtIndex:1];
            if([@"uid" isEqual:key]){
                detail.uid=value;
            }
        }
        [self.navigationController pushViewController:detail animated:YES];
    }else if([string hasPrefix:@"tutu://com.tutuim.mobile/localuser/"]){
        // 我的好友页
        SameCityController *detail = [[SameCityController alloc] init];
        [self.navigationController pushViewController:detail animated:YES];
    }else if([string hasPrefix:@"tutu://com.tutuim.mobile/huati/"]){
        //个人页或他人主页
        NSString *param=[string stringByReplacingOccurrencesOfString:@"tutu://com.tutuim.mobile/huati/" withString:@""];
        NSArray *arr=[param componentsSeparatedByString:@"&"];
        
        ListTopicsController *list=[[ListTopicsController alloc] init];
        for (NSString *item in arr) {
            NSString *key=[[item componentsSeparatedByString:@"="] objectAtIndex:0];
            
            NSString *value=[[item componentsSeparatedByString:@"="] objectAtIndex:1];
            if([@"name" isEqual:key]){
                list.topicString = [self decodeFromPercentEscapeString:value];
            }
            
            if([@"type" isEqual:key]){
                if([@"poi" isEqual:value]){
                    list.pageType=TopicWithPoiPage;
                }else{
                    list.pageType=TopicWithDefault;
                }
            }
            
            if([@"htid" isEqual:key]){
                list.poiid=value;
            }
        }
        [self openNav:list sound:nil];
    }
    
    return  YES;
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    NSString*
    outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                             
                                                                             NULL, /* allocator */
                                                                             
                                                                             (__bridge CFStringRef)input,
                                                                             
                                                                             NULL, /* charactersToLeaveUnescaped */
                                                                             
                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                             
                                                                             kCFStringEncodingUTF8);
    
    
    return
    outputStr;
}

- (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@""
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0,
                                                      [outputStr length])];
    
    return
    [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    
    
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}



#pragma mark - Target actions

- (void)goBackTapped:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (void)goForwardTapped:(UIBarButtonItem *)sender {
    [self.webView goForward];
}

- (void)reloadTapped:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (void)stopTapped:(UIBarButtonItem *)sender {
    [self.webView stopLoading];
	[self updateToolbarItems];
}

- (void)actionButtonTapped:(id)sender {
    NSURL *url = self.webView.request.URL ? self.webView.request.URL : self.request.URL;
    if (url != nil) {
        NSArray *activities = @[[SVWebViewControllerActivitySafari new], [SVWebViewControllerActivityChrome new]];
        
        if ([[url absoluteString] hasPrefix:@"file:///"]) {
            UIDocumentInteractionController *dc = [UIDocumentInteractionController interactionControllerWithURL:url];
            [dc presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
        } else {
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:activities];
            
#ifdef __IPHONE_8_0
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 &&
                UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIPopoverPresentationController *ctrl = activityController.popoverPresentationController;
                ctrl.sourceView = self.view;
                ctrl.barButtonItem = sender;
            }
#endif
            
            [self presentViewController:activityController animated:YES completion:nil];
        }
    }
}

- (void)doneButtonTapped:(id)sùender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
