//
//  ChooseVideoManager.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-30.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ChooseVideoManager.h"

static ChooseVideoManager *_instance=nil;

@implementation ChooseVideoManager{
    NSMutableArray *videoArray;
    NSMutableArray *photosArray;
    int filterType;
}

+(ChooseVideoManager *)getInstance{
    if(_instance==nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[ChooseVideoManager alloc] init];
        });
    }
    return _instance;
}



+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}

-(void)getAllVideosAndPhots:(ReadFinish)block{
    videoArray=[[NSMutableArray alloc] init];
    photosArray=[[NSMutableArray alloc] init];
    
    [self setFilter:FilterAll];
    [self setupGroup:block withSetupAsset:YES];
}

-(void)getVideos:(ReadFinish) block{
    videoArray=[[NSMutableArray alloc] init];
    photosArray=[[NSMutableArray alloc] init];
    
    [self setFilter:FilterVideo];
    [self setupGroup:block withSetupAsset:YES];
}

-(void)getPhotos:(ReadFinish)block{
    videoArray=[[NSMutableArray alloc] init];
    photosArray=[[NSMutableArray alloc] init];
    
    [self setFilter:FilterPhoto];
    [self setupGroup:block withSetupAsset:YES];
}

-(void)getLastImage:(ReadLastImage)block filterType:(FilterType)type{
    videoArray=[[NSMutableArray alloc] init];
    photosArray=[[NSMutableArray alloc] init];
    filterType=type;
    [self setFilter:type];
    [self setupGroup:^(NSMutableArray *arr) {
        if(arr!=nil && arr.count>0){
            NSDictionary *dict=[arr objectAtIndex:0];
            if(block){
                block([dict objectForKey:AssetPropertyImage]);
            }
        }
    } withSetupAsset:YES];
}

- (void)setFilter:(FilterType) type{
    filterType=type;
    if(type==FilterVideo){
        self.assetsFilter = [ALAssetsFilter allVideos];
    }else if(type==FilterPhoto){
        self.assetsFilter = [ALAssetsFilter allPhotos];
    }else{
        self.assetsFilter=[ALAssetsFilter allAssets];
    }
    
}
- (void)setupGroup:(ReadFinish)endblock withSetupAsset:(BOOL)doSetupAsset
{
    if (!self.assetsLibrary)
    {
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    
    __weak typeof(self) weakSelf = self;
    
    ALAssetsFilter *assetsFilter = [ALAssetsFilter allAssets]; // number of Asset
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if(groupType == ALAssetsGroupSavedPhotos)
            {
                [weakSelf.groups insertObject:group atIndex:0];
                if(doSetupAsset)
                {
                    weakSelf.assetsGroup = group;
                    [weakSelf setupAssets:nil];
                }
            }
            else
            {
                if (group.numberOfAssets > 0)
                    [weakSelf.groups addObject:group];
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(endblock)
                    if(filterType==FilterVideo){
                        endblock(videoArray);
                    }
                    if(filterType==FilterPhoto){
                        endblock(photosArray);
                    }
                    if(filterType==FilterAll){
                        [photosArray addObjectsFromArray:videoArray];
                        endblock(photosArray);
                    }
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        //不允许访问
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}

- (void)setupAssets:(ReadFinish)successBlock
{
//    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    if(!self.assetsGroup)
    {
        self.assetsGroup = self.groups[0];
    }
    [self.assetsGroup setAssetsFilter:self.assetsFilter];
    NSInteger assetCount = [self.assetsGroup numberOfAssets];
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset)
        {
            NSDate *date= [asset valueForProperty:ALAssetPropertyDate];
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            NSString *fileName = [[asset defaultRepresentation] filename];
            NSURL *url = [[asset defaultRepresentation] url];
            int64_t fileSize = [[asset defaultRepresentation] size];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setObject:date forKey:AssetPropertyDate];
            [dict setObject:image forKey:AssetPropertyImage];
            [dict setObject:fileName forKey:AssetPropertyFileName];
            [dict setObject:url forKey:AssetPropertyURL];
            [dict setObject:[NSString stringWithFormat:@"%lld",fileSize] forKey:AssetPropertyFileSize];
            
            [self.assets addObject:asset];
            
            NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
            
            if ([assetType isEqual:ALAssetTypePhoto]){
                [photosArray addObject:dict];
            }
            if ([assetType isEqual:ALAssetTypeVideo]){
                [videoArray addObject:dict];
            }
        }
        
        else if (self.assets.count >= assetCount)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock){
                    WSLog(@"%d",filterType);
                    if(filterType==FilterVideo){
                        successBlock(videoArray);
                    }else if(filterType==FilterPhoto){
                        successBlock(photosArray);
                    }else{
                        [photosArray addObjectsFromArray:videoArray];
                        successBlock(photosArray);
                    }
                }
            });
            
        }
    };
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
}


- (void)getGroupsArray:(ReadFinish) block{
    __weak ChooseVideoManager *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [weakSelf.groups addObject:group];
            } else {
                [weakSelf.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result && [result thumbnail] != nil) {
                            NSDate *date= [result valueForProperty:ALAssetPropertyDate];
                            UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                            NSString *fileName = [[result defaultRepresentation] filename];
                            NSURL *url = [[result defaultRepresentation] url];
                            int64_t fileSize = [[result defaultRepresentation] size];
                            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
                            [dict setObject:date forKey:@"date"];
                            [dict setObject:image forKey:@"image"];
                            [dict setObject:fileName forKey:@"fileName"];
                            [dict setObject:url forKey:@"url"];
                            [dict setObject:[NSString stringWithFormat:@"%lld",fileSize] forKey:@"fileSize"];
                            
                            WSLog(@"获取到的属性：%@",[result valueForProperty:ALAssetPropertyType]);
                            
                            // 照片
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [photosArray addObject:dict];
                                });
                            }
                            // 视频
                            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ){
                                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [videoArray addObject:dict];
                                });
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
//                                if(block){
//                                    block();
//                                }
                                
                            });
                            
                        }

                    }];
                }];
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
        {
            
            NSString *errorMessage = nil;
            
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                    break;
                    
                default:
                    errorMessage = @"Reason unknown.";
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误,无法访问!"
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            });
        };
        
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}

@end
