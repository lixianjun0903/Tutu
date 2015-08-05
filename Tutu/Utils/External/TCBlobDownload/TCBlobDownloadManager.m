//
//  TCBlobDownloadManager.m
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownloadManager.h"
#import "TCBlobDownloader.h"

@interface TCBlobDownloadManager ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong)NSMutableArray *downloadUrls;
@end

@implementation TCBlobDownloadManager
@dynamic downloadCount;
@dynamic currentDownloadsCount;


#pragma mark - Init


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.defaultDownloadPath = [NSString stringWithString:NSTemporaryDirectory()];
        self.downloadUrls = [[NSMutableArray alloc]initWithCapacity:5];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
        [sharedManager setOperationQueueName:@"TCBlobDownloadManager_SharedInstance_Queue"];
    });
    return sharedManager;
}


#pragma mark - TCBlobDownloader Management


- (TCBlobDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                                  delegate:(id<TCBlobDownloaderDelegate>)delegateOrNil
{
    if ([self.downloadUrls containsObject:url]) {
        return nil;
    }else{
        [self.downloadUrls addObject:url];
        NSString *downloadPath = customPathOrNil ? customPathOrNil : self.defaultDownloadPath;
        
        TCBlobDownloader *downloader = [[TCBlobDownloader alloc] initWithURL:url
                                                                downloadPath:downloadPath
                                                                    delegate:delegateOrNil];
        [self.operationQueue addOperation:downloader];
        
        return downloader;
    }
}

- (TCBlobDownloader *)startDownloadWithURL:(NSURL *)url identification:(NSString *)identification
                                customPath:(NSString *)customPathOrNil
                             firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                                  progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress,NSString *identification))progressBlock
                                     error:(void (^)(NSError *error))errorBlock
                                  complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock
{
    
    if ([self.downloadUrls containsObject:url]) {
        return nil;
    }else{
        NSString *downloadPath = customPathOrNil ? customPathOrNil : self.defaultDownloadPath;
        TCBlobDownloader *downloader = [[TCBlobDownloader alloc] initWithURL:url identification:identification downloadPath:downloadPath firstResponse:firstResponseBlock progress:progressBlock error:^(NSError *error) {
            if ([self.downloadUrls containsObject:url]) {
                [self.downloadUrls removeObject:url];
            }
            errorBlock(error);
        } complete:^(BOOL downloadFinished, NSString *pathToFile) {
            if ([self.downloadUrls containsObject:url]) {
                [self.downloadUrls removeObject:url];
            }
            completeBlock(downloadFinished,pathToFile);
        }];
        
        [self.operationQueue addOperation:downloader];
        [self.downloadUrls addObject:url];
        return downloader;
    }
}

- (void)startDownload:(TCBlobDownloader *)download
{
    [self.operationQueue addOperation:download];
}

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove
{
    for (TCBlobDownloader *blob in [self.operationQueue operations]) {
        [blob cancelDownloadAndRemoveFile:remove];
    }
    [self.downloadUrls removeAllObjects];
}


#pragma mark - Custom Setters


- (void)setOperationQueueName:(NSString *)name
{
    [self.operationQueue setName:name];
}

- (BOOL)setDefaultDownloadPath:(NSString *)pathToDL error:(NSError *__autoreleasing *)error
{
    if ([[NSFileManager defaultManager] createDirectoryAtPath:pathToDL
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:error]) {
        _defaultDownloadPath = pathToDL;
        return YES;
    } else {
        return NO;
    }
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrent
{
    [self.operationQueue setMaxConcurrentOperationCount:maxConcurrent];
}


#pragma mark - Custom Getters


- (NSUInteger)downloadCount
{
    return [self.operationQueue operationCount];
}

- (NSUInteger)currentDownloadsCount
{
    NSUInteger count = 0;
    for (TCBlobDownloader *blob in [self.operationQueue operations]) {
        if (blob.state == TCBlobDownloadStateDownloading) {
            count++;
        }
    }

    return count;
}

@end
