//
//  ChineseToPinyin.h
//  LianPu
//
//  Created by shawnlee on 10-12-16.
//  Copyright 2010 lianpu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChineseToPinyin : NSObject {
    
}

+ (NSString *) pinyinFromChiniseString:(NSString *)string;
+ (char) sortSectionTitle:(NSString *)string;
/**返回拼音的第一个字母*/
+ (NSString*) firstPinyinCharacter:(NSString*)string;
@end