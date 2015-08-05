//
//  WebViewController.h
//  fun_beta
//
//  Created by 刘大治 on 14-10-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface WebViewController : BaseController
@property(strong,nonatomic)    UIWebView * webView;
@property(copy,nonatomic)    NSString * webUrl;
-(void)settitleName:(NSString*)newName andURL:(NSString*)url;
@end
