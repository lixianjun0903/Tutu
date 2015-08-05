//
//  TTExtendLabel.h
//  CustomView
//
//  Created by zhangxinyao on 15-4-9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TTTAttributedLabel.h"

typedef NS_OPTIONS(NSUInteger, TTExtendLabelLinkType) {
    TTExtendLabelLinkTypeURL = 0,
    TTExtendLabelLinkTypePhoneNumber,
    TTExtendLabelLinkTypeEmail,
    TTExtendLabelLinkTypeAt,
    TTExtendLabelLinkTypePoundSign,
};

typedef void (^TTExtendLabelSelectedBlock)(NSString *linkedString,TTExtendLabelLinkType type);

@class TTExtendLabel;
@protocol TTExtendLabelDelegate <NSObject>

-(void)ttExtendLabel:(TTExtendLabel *) extendLabel didSelectLink:(NSString *)link withType:(TTExtendLabelLinkType) type;

@end

@interface TTExtendLabel : TTTAttributedLabel

@property (nonatomic, assign) BOOL disableThreeCommon; //禁用电话，邮箱，连接三者

@property (nonatomic, assign) BOOL isNeedAtAndPoundSign; //是否需要话题和@功能，默认为需要

@property (nonatomic, strong) id<TTExtendLabelDelegate> extendDelegate; //点击连接的代理方法
@property (nonatomic, strong) TTExtendLabelSelectedBlock exntedBlock;
@property (nonatomic, assign) float contentHeight;

//设置文字处理，必须使用此属性，否则不会添加时间
@property (nonatomic, strong) NSString *extendText;

@end
