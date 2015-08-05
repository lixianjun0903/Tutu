//
//  AreaDBManager.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AreaDBManager.h"
#import "FMDatabase.h"


@interface AreaDBManager ()

@end

@implementation AreaDBManager


static AreaDBManager * _sharedDBManager;

static NSString *kDefaultDBName=@"china_Province_city_zone.db";

+(AreaDBManager *)defaultDBManager{
    
    if (!_sharedDBManager) {
        _sharedDBManager = [[AreaDBManager alloc] init];
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
    
    [self checkMarkFile:name];
    
    NSString *_name = getDocumentsFilePath([NSString stringWithFormat:@"/DB/%@",name]);
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
        _dataBase = [[FMDatabase alloc] initWithPath:getDocumentsFilePath([NSString stringWithFormat:@"/DB/%@",kDefaultDBName])];
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


//复制文件到Document沙盒
-(void)checkMarkFile:(NSString *) fileName{
    NSFileManager*fileManager =[NSFileManager defaultManager];
    NSError *error;
    NSString *txtPath =getDocumentsFilePath([NSString stringWithFormat:@"/DB/%@",fileName]);
    if(!checkFileIsExsis(getDocumentsFilePath(@"/DB"))){
        [fileManager createDirectoryAtPath:getDocumentsFilePath(@"/DB") withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(!checkFileIsExsis(txtPath)){
        NSString *resourcePath =[[NSBundle mainBundle] pathForResource:@"china_Province_city_zone" ofType:@"db"];
        BOOL isCopy=[fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
        WSLog(@"复制结果：%d",isCopy);
    }
}

@end
