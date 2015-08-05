//
//  CacheManager.h
//  Tutu
//
//  Created by gexing on 4/9/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+PathValid.h"

@interface CacheManager : NSObject
+ (CacheManager *)sharedCacheManager;

//
// 视频大于10分钟 清理
// 图片大于20分钟 清理
//
// 缓存总文件大于100M，大于剩余空间的一半，剩余空间小于500M
// 缓存图片、视频各删除一半
//
- (void)clearImageAndVideo;

- (void)clearUnValidVieo;

-(void)clearUnValidImage;

- (NSUInteger)getImageAndVideoSize;


-(void)cleanAllCache;

@end
