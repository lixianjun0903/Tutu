//
//  TTLinkedTextView.h
//  CustomView
//
//  Created by zhangxinyao on 15-4-8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Regular.h"


/**
 * Block 当点击链接时掉用
 * @param tag，点击数据的类型：#、@
 * @param linkedString 点击的内容
 */
typedef void (^LinkedStringTapHandler)(NSString *tag,NSString *linkedString);

@interface TTLinkedTextView : UITextView{
    NSString *placeholder;
    UIColor *placeholderColor;

    @private
    UILabel *placeHolderLabel;
}

@property(nonatomic, retain) UIFont *fixedFont;

@property(nonatomic, retain) UILabel *placeHolderLabel;
@property(nonatomic, retain) NSString *placeholder;
@property(nonatomic, retain) UIColor *placeholderColor;

@property(nonatomic, retain) NSString *tempText;

-(void)setMyAttrText:(NSString *)text;


/**
 * 获取格式化的内容
 */
-(NSString *)getUploadText;


-(BOOL)doDelete;

@end
