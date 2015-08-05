//
//  LinkManModel.h
//  Tutu
//
//  Created by 刘大治 on 14/12/9.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkManModel : NSObject
@property (retain,nonatomic)NSString * local_id;
@property (retain,nonatomic)NSString * phonenumber;
@property (nonatomic)NSInteger relation;
@property (retain,nonatomic)NSString * tutuid;
@property (retain,nonatomic)NSString * mytutuid;
@property (retain,nonatomic)NSString * status;
@property (retain,nonatomic)NSString * createtime;
@property (retain,nonatomic)NSString * modifytime;
@property (retain,nonatomic)NSString *nickName;
@property(retain,nonatomic)UIImage *avatar;
@property(nonatomic,strong)NSString *fristLetter;
@property(nonatomic,strong)NSString *pinyin;
-(id)initWithDictionary:(NSDictionary *)dictionary;
@end
