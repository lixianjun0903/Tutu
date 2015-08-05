//
//  Tools.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/4.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "Tools.h"

@implementation Tools

/**
 *  得到应用程序中文件的路径
 */
+ (NSString *)bundlePath:(NSString *)fileName
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

/**
 *  得到沙河目录中文件的路径
 */
+ (NSString *)documentsPath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

@end
