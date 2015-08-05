//
//  ChineseFirstLetter.h
//  DynamicHeightTableView
//
//  Created by zhangxinyao on 15/5/8.
//  Copyright (c) 2015年 Jasper. All rights reserved.
//

/*
 * // Example
 *
 * #import "ChineseFirstLetter.h"
 *
 * NSString *hanyu = @"中国共产党万岁！";
 * for (int i = 0; i < [hanyu length]; i++)
 * {
 *     printf("%c", pinyinFirstLetter([hanyu characterAtIndex:i]));
 * }
 *
 */

#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"

char pinyinFirstLetter(unsigned short hanzi);
