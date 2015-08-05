//
//  ChoosePickerController.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ChoosePickerController.h"
#import "UzysAssetsViewCell.h"
#import "VideoCutController.h"
#import "VPImageCropperViewController.h"

@class ChoosePickerController;
typedef void(^CopyImageBlock) (NSString *imagePath);

@interface ChoosePickerController (){
    NSIndexPath *lastIndexPath;
    
    NSMutableArray *chooseArr;
    BOOL isPhoto;
}

@end

@implementation ChoosePickerController



#pragma mark - ALAssetsLibrary

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

- (id)init
{
    self = [super init];
    if(self)
    {
        //系统相册更改
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryUpdated:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}
- (void)dealloc
{
    //    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    self.assetsLibrary = nil;
    self.assets = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createTitleMenu];
    
    
    
//    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake((44-17)/2,(44-24)/2,(44-17)/2,(44-24)/2)];
//    [self.menuRightButton setImage:[UIImage imageNamed:@"crop_comfirm_nor"] forState:UIControlStateNormal];
//    [self.menuRightButton setImage:[UIImage imageNamed:@"crop_comfirm"] forState:UIControlStateHighlighted];
//    [self.menuRightButton setTitle:@"继续" forState:UIControlStateNormal];
//    [self.menuRightButton setTitle:@"继续" forState:UIControlStateNormal];
//    self.menuRightButton.titleLabel.font=[UIFont systemFontOfSize:17];
    [self.menuRightButton setHidden:YES];
    UIButton *lightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [lightButton setBackgroundColor:[UIColor clearColor]];
    lightButton.tag=RIGHT_BUTTON;
    [lightButton setFrame:CGRectMake(SCREEN_WIDTH-60,20, 55, 45)];

    [lightButton setTitle:@"下一步" forState:UIControlStateNormal];
//    lightButton.titleLabel.font=[UIFont systemFontOfSize:17];
    [lightButton.titleLabel setFont:TitleFont];

    //    [lightButton setTitleEdgeInsets:UIEdgeInsetsMake((45-35)/2,(45-35)/2,(45-35)/2,(45-35)/2)];
    //    [lightButton setImageEdgeInsets:UIEdgeInsetsMake((45-17)/2,(45-24)/2,(45-17)/2,(45-24)/2)];
    //    [lightButton setImage:[UIImage imageNamed:@"crop_comfirm_nor"] forState:UIControlStateNormal];
    //    [lightButton setImage:[UIImage imageNamed:@"crop_comfirm"] forState:UIControlStateHighlighted];
    [lightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightButton];
    if (self.maximumNumberOfSelectionVideo) {
        [self.menuTitleButton setTitle:@"选择视频" forState:UIControlStateNormal];

    }else
    {
        [self.menuTitleButton setTitle:@"选择图片" forState:UIControlStateNormal];

    }
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    [self setupCollectionView];
    
    [self setupOneMediaTypeSelection];
    
}

-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    if(sender.tag==RIGHT_BUTTON){
        [self finishPickingAssets];
    }
    
    if(sender.tag == OTHER_BUTTON){
        [self.groupPicker toggle];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
    
}


- (void)setupOneMediaTypeSelection
{
    if(_maximumNumberOfSelectionVideo > 0)
    {
        self.assetsFilter = [ALAssetsFilter allVideos];
        self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
        //        self.segmentedControl.hidden = YES;
        
        // To do 选择视频
        isPhoto=NO;
    }
    else
    {
        if(_maximumNumberOfSelectionPhoto ==0)
        {
            self.assetsFilter = [ALAssetsFilter allVideos];
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionVideo;
            //            self.segmentedControl.hidden = YES;
            
            //选择视频
            isPhoto=NO;
        }
        else if(_maximumNumberOfSelectionVideo ==0)
        {
            self.assetsFilter = [ALAssetsFilter allPhotos];
            self.maximumNumberOfSelection = self.maximumNumberOfSelectionPhoto;
            //选择图片
            isPhoto=YES;
        }
        else
        {
            self.assetsFilter = [ALAssetsFilter allAssets];
            self.maximumNumberOfSelection = 0;
            //切换、视频或图片
            isPhoto=YES;
        }
    }
    
    [self setupGroup:nil withSetupAsset:YES];
    
    
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = kThumbnailSize;
    layout.sectionInset                 = UIEdgeInsetsMake(1.0, 0, 0, 0);
    layout.minimumInteritemSpacing      = 1.0;
    layout.minimumLineSpacing           = 1.0;
    
    
    CGRect gridFrame=self.view.bounds;
    gridFrame.origin.y = NavBarHeight;
    gridFrame.size.height=gridFrame.size.height-gridFrame.origin.y;
    self.collectionView = [[UICollectionView alloc] initWithFrame:gridFrame collectionViewLayout:layout];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[UzysAssetsViewCell class]
            forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    
    UzysAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell applyData:[self.assets objectAtIndex:indexPath.row]];
    
    
    return cell;
}

#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ([collectionView indexPathsForSelectedItems].count < self.maximumNumberOfSelection);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //取消上一个
    if(lastIndexPath!=nil){
        [collectionView deselectItemAtIndexPath:lastIndexPath animated:YES];
    }
    lastIndexPath=indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    WSLog(@"取消选择：%@",indexPath);
    lastIndexPath=nil;
}

#pragma mark - Notification
//系统相册更改
- (void)assetsLibraryUpdated:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //recheck here
        if([notification.name isEqualToString:ALAssetsLibraryChangedNotification])
        {
            NSDictionary* info = [notification userInfo];
            NSSet *updatedAssets = [info objectForKey:ALAssetLibraryUpdatedAssetsKey];
            NSSet *updatedAssetGroup = [info objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
            NSSet *deletedAssetGroup = [info objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
            NSSet *insertedAssetGroup = [info objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
            
            
            if(notification.userInfo == nil)
            {
                //AllClear
                [self setupGroup:nil withSetupAsset:YES];
                return;
            }
            if(insertedAssetGroup.count >0 || deletedAssetGroup.count > 0)
            {
                [self setupGroup:nil withSetupAsset:NO];
                return;
            }
            if(notification.userInfo.count == 0) {
                return;
            }
            
            if(updatedAssets.count  <2 && updatedAssetGroup.count ==0 && deletedAssetGroup.count == 0 && insertedAssetGroup.count == 0)
            {
                [self.assetsLibrary assetForURL:[updatedAssets allObjects][0] resultBlock:^(ALAsset *asset) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([[[self.assets[0] valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString]])
                        {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            [self.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        }
                        
                    });
                    
                } failureBlock:nil];
                return;
            }
            NSMutableArray *selectedItems = [NSMutableArray array];
            NSArray *selectedPath = self.collectionView.indexPathsForSelectedItems;
            
            for (NSIndexPath *idxPath in selectedPath)
            {
                [selectedItems addObject:[self.assets objectAtIndex:idxPath.row]];
            }
            NSInteger beforeAssets = self.assets.count;
            [self setupAssets:^{
                for (ALAsset *item in selectedItems)
                {
                    for(ALAsset *asset in self.assets)
                    {
                        if([[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:[[item valueForProperty:ALAssetPropertyAssetURL] absoluteString]])
                        {
                            NSUInteger idx = [self.assets indexOfObject:asset];
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:idx inSection:0];
                            [self.collectionView selectItemAtIndexPath:newPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    }
                }
                if(self.assets.count > beforeAssets)
                {
                    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
                }
            }];
        }
        
    });
}

- (void)changeGroup:(NSInteger)item filter:(ALAssetsFilter *)filter
{
    self.assetsFilter = filter;
    self.assetsGroup = self.groups[item];
    [self setupAssets:nil];
    [self.groupPicker.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:item inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.groupPicker dismiss:YES];
}

- (void)setupGroup:(voidBlock)endblock withSetupAsset:(BOOL)doSetupAsset
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
    
    ALAssetsFilter *childassetsFilter = [ALAssetsFilter allAssets]; // number of Asset
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group)
        {
            [group setAssetsFilter:childassetsFilter];
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
                [weakSelf.groupPicker reloadData];
                if(endblock)
                    endblock();
                
                [self checkDataNull];
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        self.menuRightButton.enabled = NO;
        
        //不允许访问
        
        [self.menuTitleButton setTitle:NSLocalizedStringFromTable(@"Not Allowed", @"UzysAssetsPickerController",nil) forState:UIControlStateNormal];
        [self.menuTitleButton setImage:nil forState:UIControlStateNormal];
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}

- (void)setupAssets:(voidBlock)successBlock
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
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
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }
        
        else if (self.assets.count >= assetCount)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadCollectionData];
                if(successBlock)
                    successBlock();
                
            });
            
        }
    };
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
}

- (void)reloadCollectionData
{
    [self.collectionView reloadData];
//    [self.menuRightButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.collectionView.indexPathsForSelectedItems
//                                    .count] forState:UIControlStateNormal];
    
    //判断显示情况
//    [self showNoAssetsIfNeeded];
}


#pragma mark 提交处理
//完成提交
- (void)finishPickingAssets
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [assets addObject:[self.assets objectAtIndex:indexPath.item]];
    }
    
    
    if(assets.count==0){
        if(isPhoto){
            [self showNoticeWithMessage:@"请至少选择一个图片" message:@"" bgColor:TopNotice_Red_Color];
        }else{
            [self showNoticeWithMessage:@"请至少选择一个视频" message:@"" bgColor:TopNotice_Red_Color];
        }
        return;
    }
    
    chooseArr=[[NSMutableArray alloc] init];
    if([assets count]>0)
    {
        for(ALAsset *asset in assets)
        {
            NSURL *videoURL=[asset valueForProperty:ALAssetPropertyAssetURL];
            double duration=[[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setValue:videoURL forKey:@"videoURL"];
            [dict setValue:[NSString stringWithFormat:@"%f",duration] forKey:@"duration"];
            [chooseArr addObject:dict];
        }
    }
    if(!isPhoto){
        VideoCutController *cutVideo=[[VideoCutController alloc] init];
        [cutVideo setVideoArr:chooseArr];
        [self.navigationController pushViewController:cutVideo animated:YES];
    }else{
        NSDictionary *dict=[chooseArr objectAtIndex:0];
        [self imageWithUrl:[dict objectForKey:@"videoURL"] withFileName:[self getVideoTempPath:@"temp.jpg"] blcok:^(NSString *imagePath) {
            UIImage *img=[UIImage imageWithContentsOfFile:imagePath];
            VPImageCropperViewController *controller=[[VPImageCropperViewController alloc] initWithImage:img];
            [self.navigationController pushViewController:controller animated:YES];
        }];
    }
}

// 将原始图片的URL转化为NSData数据,写入沙盒
- (void)imageWithUrl:(NSURL *)url withFileName:(NSString *)dirPath blcok:(CopyImageBlock) fblock
{
    // 进这个方法的时候也应该加判断,如果已经转化了的就不要调用这个方法了
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dirPath]) {
        [fileManager removeItemAtPath:dirPath error:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            // 主要方法
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
//                NSString * imagePath = dirPath;
//                [data writeToFile:imagePath atomically:YES];
                
                [fileManager createFileAtPath:dirPath contents:data attributes:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(fblock){
                        fblock(dirPath);
                    }
                });
            } failureBlock:nil];
        }
    });
}



-(NSString *)getVideoTempPath:(NSString *)fileName{
    return [NSString stringWithFormat:@"%@%@",getTempVideoPath(),fileName];
}



#pragma mark 空数据UI展示
-(void)checkDataNull{
    if(self.assets==nil || self.assets.count==0){
        
        [self removePlaceholderView];
        self.placeholderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 100)];
        self.placeholderView.center = CGPointMake(self.view.center.x, self.view.center.y-40);
        [self.collectionView addSubview:self.placeholderView];
        
        UILabel *placeTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 195, 20)];
        if(isPhoto){
            [placeTitleLabel setText:@"你本地还没有照片啊！"];
        }else{
            [placeTitleLabel setText:@"你本地还没有视频啊！"];
        }
        [placeTitleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [placeTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.placeholderView addSubview:placeTitleLabel];
        
        UILabel *placeDescLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 195, 30)];
        [placeDescLabel setText:@"快去添加吧！"];
        [placeDescLabel setFont:ListDetailFont];
        [placeDescLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [placeDescLabel setTextAlignment:NSTextAlignmentCenter];
        [self.placeholderView addSubview:placeDescLabel];
        
        //        UIButton *placeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        //        [placeButton setFrame:CGRectMake(195/2-125/2, 50, 125, 36)];
        //        placeButton.layer.cornerRadius=18;
        //        placeButton.layer.borderColor=UIColorFromRGB(SystemColor).CGColor;
        //        placeButton.layer.borderWidth=1.0f;
        //        [placeButton setTitle:@"话题广场" forState:UIControlStateNormal];
        //        [placeButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        //        [placeButton setTitleColor:UIColorFromRGB(SystemColorHigh) forState:UIControlStateHighlighted];
        //        placeButton.tag=5;
        //        [placeButton.titleLabel setFont:ListDetailFont];
        //        [placeButton addTarget:self action:@selector(changePageClick:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.placeholderView addSubview:placeButton];
    }else{
        [self removePlaceholderView];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
