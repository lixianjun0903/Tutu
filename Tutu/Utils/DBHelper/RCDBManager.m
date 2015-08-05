//
//  RCDBManager.m
//  Tutu
//
//  Created by zhangxinyao on 14-12-19.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "RCDBManager.h"

#import "FMDatabase.h"

@interface RCDBManager ()

@end

@implementation RCDBManager


static RCDBManager * _sharedDBManager;

static NSString *kDefaultDBName=@"storage";

+(RCDBManager *)defaultDBManager{
    if (!_sharedDBManager) {
        _sharedDBManager = [[RCDBManager alloc] init];
    }
    return _sharedDBManager;
}

- (void) dealloc {
    [self close];
}

- (id) init {
    self = [super init];
    if (self) {
        int state = [self initializeDBWithName:kDefaultDBName];
        if (state == -1) {
            //            NSLog(@"数据库初始化失败");
        } else {
            //            NSLog(@"数据库初始化成功");
        }
    }
    return self;
}

/**
 * @brief 初始化数据库操作
 * @param name 数据库名称
 * @return 返回数据库初始化状态， 0 为 已经存在，1 为创建成功，-1 为创建失败
 */
- (int) initializeDBWithName : (NSString *) name {
    if (!name) {
        return -1;  // 返回数据库创建失败
    }
    NSString *_name = getDocumentsFilePath([NSString stringWithFormat:@"/%@/%@/%@",RCKey,[[LoginManager getInstance] getUid],name]);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:_name];
    [self connect];
    if (!exist) {
        return 0;
    } else {
        return 1;          // 返回 数据库已经存在
        
    }
    
}

/// 连接数据库
- (void) connect {
    if (!_dataBase) {
        _dataBase = [[FMDatabase alloc] initWithPath:getDocumentsFilePath([NSString stringWithFormat:@"/%@/%@/%@",RCKey,[[LoginManager getInstance] getUid],kDefaultDBName])];
    }
    if (![_dataBase open]) {
        NSLog(@"不能打开数据库");
    }else{
        WSLog(@"打开数据库成功!");
    }
}
/// 关闭连接
- (void) close {
    [_dataBase close];
    _sharedDBManager = nil;
}
@end
