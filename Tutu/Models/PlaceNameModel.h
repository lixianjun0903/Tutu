//
//  PlaceNameModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlaceNameModel : NSObject

@property (nonatomic , retain) NSString *prosort;
@property (nonatomic , retain) NSString *proname;
@property (nonatomic , retain) NSString *proremark;

@end


@interface CityModel : NSObject

@property (nonatomic , retain) NSString *citysort;
@property (nonatomic , retain) NSString *proid;
@property (nonatomic , retain) NSString *cityname;

//pname，不要删除，展示使用
@property (nonatomic , retain) NSString *pname;

@end

@interface AreaModel : NSObject

@property (nonatomic , retain) NSString *cityid;
@property (nonatomic , retain) NSString *zoneid;
@property (nonatomic , retain) NSString *zonename;

@end