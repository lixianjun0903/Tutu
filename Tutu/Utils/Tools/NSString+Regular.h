//
//  NSString+Regular.h
//  CustomView
//
//  Created by zhangxinyao on 15-4-8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString(Regular)

-(NSMutableAttributedString *) stringToAttributedString;
-(NSMutableAttributedString *) stringToAttributedString:(NSMutableDictionary *)dict textColor:(UIColor *)color;




-(NSMutableDictionary *)defaultAttributes;

-(NSMutableDictionary *)highlightedAttributes;

@end
