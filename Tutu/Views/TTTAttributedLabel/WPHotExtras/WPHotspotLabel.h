//
//  WPHotspotLabel.h
//  WPAttributedMarkupDemo
//
//  Created by Nigel Grange on 20/10/2014.
//  Copyright (c) 2014 Nigel Grange. All rights reserved.
//

//NSDictionary* style3 = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:22.0],
//                         @"help":[WPAttributedStyleAction styledActionWithAction:^(NSString *clickText){
//                             NSLog(@"Help action");
//                         }],
//                         @"help1":[WPAttributedStyleAction styledActionWithAction:^(NSString *clickText){
//                             NSLog(@"Help action");
//                         }],
//                         @"settings":[WPAttributedStyleAction styledActionWithAction:^(NSString *clickText){
//                             NSLog(@"Settings action");
//                         }],
//                         @"link": [UIColor redColor]};
//self.label3.attributedText = [@"Tap <help>here</help> to show help or <settings>here</settings> to show settings<link> hhh </link>"
// 添加WPAttributedStyleAction的标签都可以点击，link为所有标签的颜色


#import "WPTappableLabel.h"

@interface WPHotspotLabel : WPTappableLabel

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
