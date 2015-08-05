//
//  CacheManager.m
//  Tutu
//
//  Created by gexing on 4/9/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "CacheManager.h"
#import "SDImageCache.h"

@interface  CacheManager()
@property(nonatomic,strong)dispatch_queue_t ioQueue;
@property(nonatomic,strong)NSString *imagePath;
@property(nonatomic,strong)NSString *videoPath;
@property(nonatomic,strong)NSFileManager *fileManager;
@end
@implementation CacheManager
+ (CacheManager *)sharedCacheManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initWithName:@"com.tutuim.cache"];
    }
    return self;
}
- (void)initWithName:(NSString *)name{

    _ioQueue = dispatch_queue_create("com.tutuim.cache", DISPATCH_QUEUE_SERIAL);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _imagePath = [paths[0] stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    _videoPath = getVideoPath();
    dispatch_sync(_ioQueue, ^{
        _fileManager = [NSFileManager new];
    });
}
- (NSUInteger)getImageSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        size = [[SDImageCache sharedImageCache] getSize];
    });
    return size;
}

- (NSUInteger)getVideoSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.videoPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.videoPath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}
- (NSUInteger)getImageAndVideoSize{
            NSUInteger imageSize;
            NSUInteger videoSize;
        imageSize = [self getImageSize];
        videoSize = [self getVideoSize];
    return imageSize + videoSize;
}

- (void)clearImageDisk
{
    [[SDImageCache sharedImageCache] clearDisk];
}

- (void)clearImageAndVideo{
    //清理个人信息缓存
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    if(dictionary.allKeys.count>100){
        for(NSString* key in [dictionary allKeys]){
            if([key hasPrefix:@"UserInfoCacheKey"]){
                [userDefatluts removeObjectForKey:key];
                [userDefatluts synchronize];
            }
        }
    }
    
   dispatch_async(self.ioQueue, ^{
       // 清理过期视频
       NSMutableArray *videoMArr = [@[]mutableCopy];
       NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.videoPath];
       for (NSString *fileName in fileEnumerator) {
           NSString *filePath = [self.videoPath stringByAppendingPathComponent:fileName];
           // 未过期，添加到排序列表
           if([filePath videoIsValid]){
               [videoMArr addObject:filePath];
           }else{
               // 过期，直接删除
               [_fileManager removeItemAtPath:filePath error:nil];
           }
       }
      
       
       // 清理过期图片
       NSMutableArray *imageMArr = [@[]mutableCopy];
       NSDirectoryEnumerator *imagefileEnumerator = [_fileManager enumeratorAtPath:self.imagePath];
       for (NSString *fileName in imagefileEnumerator) {
           NSString *filePath = [self.imagePath stringByAppendingPathComponent:fileName];
           // 未过期，添加到排序列表
           if([filePath imageIsValid]){
               [imageMArr addObject:filePath];
           }else{
               // 过期，直接删除
               [_fileManager removeItemAtPath:filePath error:nil];
           }
       }
       
       int freeDisk=getTotalDiskspace(3)/1024.f/1024.f;
       NSUInteger imageVideoSize = [self getImageAndVideoSize] / 1024.F / 1024.F;
       
       //
       // 缓存总文件大于100M，大于剩余空间的一半，剩余空间小于500M
       // 缓存图片、视频各删除一半
       //
       if (imageVideoSize > 100 || imageVideoSize>freeDisk/2 || freeDisk<500) {
           if(videoMArr.count>1){
               NSArray *sortArray = [videoMArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                   NSDictionary *attrs1 = [_fileManager attributesOfItemAtPath:(NSString *)obj1 error:nil];
                   NSDictionary *attrs2 = [_fileManager attributesOfItemAtPath:(NSString *)obj2 error:nil];
                   return [attrs1.fileCreationDate  compare:attrs2.fileCreationDate];
               }];
               for (int i = 0; i < sortArray.count / 2; i ++) {
                   NSString *filePath = sortArray[i];
                   [_fileManager removeItemAtPath:filePath error:nil];
               }
           }
           
           if(imageMArr.count>1){
               NSArray *imageSortArray = [imageMArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                   NSDictionary *attrs1 = [_fileManager attributesOfItemAtPath:(NSString *)obj1 error:nil];
                   NSDictionary *attrs2 = [_fileManager attributesOfItemAtPath:(NSString *)obj2 error:nil];
                   return [attrs1.fileCreationDate  compare:attrs2.fileCreationDate];
               }];
               for (int i = 0; i < imageSortArray.count / 2; i ++) {
                   NSString *filePath = imageSortArray[i];
                   [_fileManager removeItemAtPath:filePath error:nil];
               }
           }
       }
   });
}


-(void)clearUnValidVieo{
    dispatch_async(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.videoPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.videoPath stringByAppendingPathComponent:fileName];
            // 文件过期，直接删除
            if(![filePath videoIsValid]){
                [_fileManager removeItemAtPath:filePath error:nil];
            }
        }
    });
}


-(void)clearUnValidImage{
    dispatch_async(self.ioQueue, ^{
        // kDefaultCacheMaxCacheAge ,默认缓存7天，修改为1小时
        [[SDImageCache sharedImageCache] cleanDisk];
    });
}


-(void)cleanAllCache{
    [[SDImageCache sharedImageCache] cleanDisk];
    //清理个人信息缓存
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    if(dictionary.allKeys.count>100){
        for(NSString* key in [dictionary allKeys]){
            if([key hasPrefix:@"UserInfoCacheKey"]){
                [userDefatluts removeObjectForKey:key];
                [userDefatluts synchronize];
            }
        }
    }
    
    // 清理过期视频
    NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.videoPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [self.videoPath stringByAppendingPathComponent:fileName];
        // 过期，直接删除
        [_fileManager removeItemAtPath:filePath error:nil];
    }
}

@end
