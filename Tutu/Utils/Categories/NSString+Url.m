//
//  NSString+Url.m
//  HGG_Fun
//
//  Created by Addintel on 13/8/14.
//  Copyright (c) 2014年 Addintel. All rights reserved.
//

#import "NSString+Url.h"
@implementation NSString (Url)
-(NSURL *)toImageUrl{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"",self]];
    return url;
}
- (NSURL *)stringToUrl{
    return [NSURL URLWithString:self];
}
@end
