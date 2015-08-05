//
//  TutuDBManager.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-4.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
#import "TutuDBManager.h"
#import "FMDatabase.h"


@interface TutuDBManager ()

@end

@implementation TutuDBManager


static TutuDBManager * _sharedDBManager;

static NSString *kDefaultDBName=@"Tutu.db";

+(TutuDBManager *)defaultDBManager{
    
    if (!_sharedDBManager) {
        _sharedDBManager = [[TutuDBManager alloc] init];
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
    
    if(![[LoginManager getInstance] isLogin]){
        return -1;
    }
    
    [self checkMarkFile:name];
    
    NSString *_name = getDocumentsFilePath([NSString stringWithFormat:@"/DB/%@/%@",[[LoginManager getInstance] getUid],name]);
    
    WSLog(@"重新打开数据库：%@",_name);
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
        _dataBase = [[FMDatabase alloc] initWithPath:getDocumentsFilePath([NSString stringWithFormat:@"/DB/%@/%@",[[LoginManager getInstance] getUid],kDefaultDBName])];
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
    NSString *path=[NSString stringWithFormat:@"/DB/%@/",[[LoginManager getInstance] getUid]];
    NSString *txtPath =getDocumentsFilePath([NSString stringWithFormat:@"%@%@",path,fileName]);
    if(!checkFileIsExsis(getDocumentsFilePath(path))){
        [fileManager createDirectoryAtPath:getDocumentsFilePath(path) withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if(!checkFileIsExsis(txtPath)){
        [fileManager createFileAtPath:txtPath contents:nil attributes:nil];
        
//        NSString *resourcePath =[[NSBundle mainBundle] pathForResource:@"Tutu" ofType:@"db"];
//        BOOL isCopy=[fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
//        WSLog(@"复制结果：%d",isCopy);
    }
}

@end
