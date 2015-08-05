//
//  Tools.h
//  Tutu
//
//  Created by zhanglingyu on 15/3/4.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

/**
 *  得到应用程序中文件的路径
 */
+ (NSString *)bundlePath:(NSString *)fileName;

/**
 *  得到沙河目录中文件的路径
 */
+ (NSString *)documentsPath:(NSString *)fileName;

@end
