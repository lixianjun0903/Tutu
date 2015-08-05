//
//  ManagerUserModel.h
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {

//  空内容
    ManagerCellTypeEmpty = 0,

//  头像
    ManagerCellTypeImage = 1,
//  详情
    ManagerCellTypeDetail =2,
    
    ManagerCellTypeTuTuNum = 3,

} ManagerCellType;
@interface ManagerUserModel : NSObject
@property(copy,nonatomic)NSString * title;
@property(assign,nonatomic)ManagerCellType type ;
@property(copy,nonatomic)NSString * detail;
@property(copy,nonatomic)NSString * avatarUrl;
-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
