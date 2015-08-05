//
//  PhotoToVideoController.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "PhotoToVideoController.h"
#import "PhotoViewCell.h"
#import "PhotoEditCell.h"
#import "ImagesToVideo2.h"
#import "TEditMediaController.h"

#define kPhotoViewCellIdentifier @"PhotoViewCell"
#define kPhotoEditCellIdentifier @"PhotoEditCell"

#define kViewTag 100
#define kEditTag 200

#define kEditHeight 130
#define kInfoHeight 40

#define kViewBgColor   0xFFFFFF
#define kEditBgColor   0xEEEEEE
#define kInfoFontColor 0x999999

#define kMaxSize 30
#define kInfoText   @"当前选中了%i张(最多选择%i张)"
#define kAlertNull  @"亲，您还没有选择用于制作视频的照片！"
#define kAlertOver  @"图片数量已达到上限，不能再添加..."

#define kToVideoError  @"合成视频，失败！"

#define kCoverWidth 400

@interface PhotoToVideoController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,assign) CGRect gridFrame;
@property(nonatomic,strong) UICollectionView *colView;
@property(nonatomic,strong) UICollectionView *colEdit;
@property(nonatomic,strong) UILabel *labInfo;

@property(nonatomic,strong) ALAssetsLibrary *library;
@property(nonatomic,strong) NSMutableArray *arrayViewModel;

@property(nonatomic,assign) int total;
@property(nonatomic,copy) NSString *videoPath;
@property(nonatomic,strong) GetEditModelBlock block;

@end

@implementation PhotoToVideoController

- (instancetype)initWithBlock:(GetEditModelBlock)block
{
    self=[super init];
    if (self) {
        //初始化数据
        _block=block;
        _library=[[ALAssetsLibrary alloc] init];
        _arrayViewModel=[[NSMutableArray alloc] init];
        _arrayEditModel=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置背景颜色
    [self.view setBackgroundColor:UIColorFromRGB(kEditBgColor)];
    
    //设置界面
    [self setUI];
    
    //获取图片的URL
    [self getImageURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma -mark SetUI

/**
 *  设置界面
 */
- (void)setUI
{
    //导航栏
    [self setNavBar];
    
    //待选图片
    [self setColView];
    
    //已选图片
    [self setColEdit];
    
    //提示信息
    [self setLabInfo];
}

/**
 *  设置导航栏
 */
- (void)setNavBar
{
    [self createTitleMenu];
    [self.menuTitleButton setTitle:@"选择照片" forState:UIControlStateNormal];
    
    CGRect frame=self.menuRightButton.frame;
    [self.menuRightButton setFrame:CGRectMake(SCREEN_WIDTH-60, frame.origin.y, 55,45)];
    [self.menuRightButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.menuRightButton.titleLabel setFont:TitleFont];
    [self.menuRightButton setImage:nil forState:UIControlStateNormal];
    [self.menuRightButton setImage:nil forState:UIControlStateHighlighted];
}

/**
 *  设置待选区域
 */
- (void)setColView
{
    int rowGap=25;
    CGRect frame=self.view.bounds;
    frame.origin.y = NavBarHeight;
    frame.size.height=frame.size.height-frame.origin.y-kEditHeight-kInfoHeight-rowGap;
    
    int cellGap=2;
    double cellW=(frame.size.width-5*cellGap)/4,cellH=cellW;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(cellW, cellH);
    layout.minimumLineSpacing=cellGap;
    layout.minimumInteritemSpacing=cellGap;
    layout.sectionInset=UIEdgeInsetsMake(cellGap, cellGap, cellGap, cellGap);
    
    UICollectionView *colView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    colView.tag=kViewTag;
    colView.dataSource = self;
    colView.delegate = self;
    colView.backgroundColor=UIColorFromRGB(kViewBgColor);
    colView.showsVerticalScrollIndicator=NO;
    [colView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:kPhotoViewCellIdentifier];
    [self.view addSubview:colView];
    self.colView=colView;
}

/**
 *  设置提示信息
 */
- (void)setLabInfo
{
    _total=0;
    for (PhotoEditModel *model in _arrayEditModel) {
        _total+=model.size;
    }
    
    CGRect frame=CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    frame.origin.y=_colView.frame.size.height+_colView.frame.origin.y;
    frame.size.height=ScreenHeight-frame.origin.y-_colEdit.frame.size.height;
    
    UILabel *labInfo=[[UILabel alloc]init];
    labInfo.frame=frame;
    labInfo.text=[NSString stringWithFormat:kInfoText,_total,kMaxSize];
    labInfo.font=[UIFont systemFontOfSize:15.5];
    [labInfo setBackgroundColor:[UIColor whiteColor]];
    labInfo.textColor=UIColorFromRGB(kInfoFontColor);
    labInfo.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:labInfo];
    self.labInfo=labInfo;
}

/**
 *  设置编辑区域
 */
- (void)setColEdit
{
    CGRect frame=self.view.bounds;
    frame.origin.y=frame.size.height-kEditHeight;
    frame.size.height=kEditHeight;
    
    int cellGap=0;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake([PhotoEditCell width], [PhotoEditCell height]);
    layout.minimumLineSpacing=cellGap;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *colEdit = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    colEdit.tag=kEditTag;
    colEdit.dataSource = self;
    colEdit.delegate = self;
    colEdit.backgroundColor=UIColorFromRGB(kEditBgColor);
    colEdit.showsHorizontalScrollIndicator=NO;
    [colEdit registerClass:[PhotoEditCell class] forCellWithReuseIdentifier:kPhotoEditCellIdentifier];
    [self.view addSubview:colEdit];
    self.colEdit=colEdit;
}

#pragma -mark Event

/**
 *  [返回按钮]单击事件
 */
- (IBAction)buttonClick:(UIButton *)sender
{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
        _block(_arrayEditModel);
    }
    if(sender.tag==RIGHT_BUTTON){
        [self imagesToVideo];
    }
}

#pragma -mark Method

/**
 *  获取图片的URL
 */
- (void)getImageURL
{
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if (result!=nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                NSURL *url= (NSURL*)[[result defaultRepresentation]url];
                PhotoViewModel *model=[[PhotoViewModel alloc]init];
                model.asset=result;
                model.imageURL=url;
                [_arrayViewModel addObject:model];
                //遍历完成
                if ((int)[_group numberOfAssets]==_arrayViewModel.count){
                    //重新加载数据
                    [_colView reloadData];
                }
            }
        }
    };
    [_group enumerateAssetsUsingBlock:assetEnumerator];
}

/**
 *  合成视频
 */
- (void)imagesToVideo
{
    if (_arrayEditModel.count==0) {
        [self showNoticeWithMessage:kAlertNull message:nil bgColor:TopNotice_Block_Color];
        return;
    }
    
    
    _videoPath=[NSString stringWithFormat:@"%@%@",getTempVideoPath(),@"temp.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:_videoPath error:NULL];
    
    NSMutableArray *arrayImageURL=[[NSMutableArray alloc]init];
    for (PhotoEditModel *model in _arrayEditModel) {
        int size=model.size;
        while (size--) {
            [arrayImageURL addObject:model.asset];
        }
    }
    
    [SVProgressHUD showWithStatus:Video_Message];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ImagesToVideo2 videoFromImage:arrayImageURL toPath:_videoPath withCallbackBlock:^(BOOL success) {
            if (success) {
                //获取封面URL
                NSMutableArray *arrayImageURL=[[NSMutableArray alloc]init];
                if (_arrayEditModel.count<10) {
                    for (PhotoEditModel *model in _arrayEditModel) {
                        [arrayImageURL addObject:model.imageURL];
                    }
                }
                else {
                    int step=(int)_arrayEditModel.count/10;
                    for (int i=0; i<_arrayEditModel.count; i+=step) {
                        PhotoEditModel *model=_arrayEditModel[i];
                        [arrayImageURL addObject:model.imageURL];
                    }
                }
                //获取封面图片
                [self pushEditMedia:arrayImageURL];
            } else {
                NSLog(@"Failed!");
            }
        }];
    });
}

/**
 *  根据URL获取图片
 */
- (void)getImageByURL:(NSArray *)arrayImageURL
{
    NSMutableArray *arrayImage =[[NSMutableArray alloc]init];
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc] init];
    for (NSURL *url in arrayImageURL) {
        NSLog(@"%@",url);
        [library assetForURL:url
                 resultBlock:^(ALAsset *asset){
                     UIImage *image=[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                     UIImage *scaleImage=[UIImage clipImageToSquare:image byWidth:kCoverWidth];
                     [arrayImage addObject:scaleImage];
                     if (arrayImage.count==arrayImageURL.count) {
                         [self pushEditMedia:arrayImage];
                     }
                 }
                failureBlock:^(NSError *error){
                    NSLog(@"operation was not successfull!");
                }
         ];
    }
}

/**
 *  调到视频编辑页面
 */
- (void)pushEditMedia:(NSMutableArray *)arrayImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    TEditMediaController *media=[[TEditMediaController alloc] init];
    media.filePath=_videoPath;
    media.arrayImage=arrayImage;
    media.isPhotoToVideo=1;
    [self.navigationController pushViewController:media animated:YES];
    });
}

#pragma -mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (collectionView.tag) {
        case kViewTag:
            return _arrayViewModel.count;
            break;
        case kEditTag:
            return _arrayEditModel.count;
            break;
        default:
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (collectionView.tag) {
        case kViewTag:
        {
            PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoViewCellIdentifier forIndexPath:indexPath];
            PhotoViewModel *model=_arrayViewModel[indexPath.row];
            for (int i=0;i<_arrayEditModel.count;i++) {
                PhotoEditModel *editModel=_arrayEditModel[i];
                if ([editModel.imageURL isEqual:model.imageURL]) {
                    model.checked=YES;
                    editModel.targetRow=indexPath.row;
                    _arrayViewModel[indexPath.row]=model;
                    _arrayEditModel[i]=editModel;
                }
            }
            [cell setModel:model];
            return cell;
        }
            break;
        case kEditTag:
        {
            PhotoEditCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoEditCellIdentifier forIndexPath:indexPath];
            PhotoEditModel *model=_arrayEditModel[indexPath.row];
            [cell setModel:model];
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma -mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (collectionView.tag) {
        case kViewTag:
        {
            if (_total>=kMaxSize) {
                [self showNoticeWithMessage:kAlertOver message:nil bgColor:TopNotice_Block_Color];
                return;
            }
            _total++;
            _labInfo.text=[NSString stringWithFormat:kInfoText,_total,kMaxSize];
            
            PhotoViewCell *viewCell=(PhotoViewCell*) [_colView cellForItemAtIndexPath:indexPath];
            [viewCell setChecked:YES];
            PhotoViewModel *viewModel=_arrayViewModel[indexPath.row];
            viewModel.checked=YES;
            _arrayViewModel[indexPath.row]=viewModel;
            //修改
            if (_arrayEditModel.count>0) {
                PhotoEditModel *editModel=_arrayEditModel[_arrayEditModel.count-1];
                if ([editModel.imageURL isEqual:viewModel.imageURL]) {
                    editModel.size++;
                    _arrayEditModel[_arrayEditModel.count-1]=editModel;
                    //局部刷新
                    NSIndexPath *index=[self getIndexPath];
                    if (index==nil) {
                        [_colEdit reloadData];
                    }
                    [_colEdit reloadItemsAtIndexPaths:[NSArray arrayWithObjects:index, nil]];
                    return;
                }
            }
            //添加
            PhotoEditModel *editModel=[[PhotoEditModel alloc]init];
            editModel.targetRow=indexPath.row;
            editModel.asset=viewModel.asset;
            editModel.imageURL=viewModel.imageURL;
            editModel.size=1;
            [_arrayEditModel addObject:editModel];
            //局部刷新
            NSIndexPath *index=[self getIndexPath];
            if (index==nil) {
                [_colEdit reloadData];
            }
            [_colEdit insertItemsAtIndexPaths:[NSArray arrayWithObjects:index, nil]];
            
            //设置ContentOffset
            if ([PhotoEditCell width]*(_arrayEditModel.count)>_colEdit.frame.size.width) {
                CGPoint point=CGPointMake([PhotoEditCell width]*_arrayEditModel.count-_colEdit.frame.size.width, 0);
                [_colEdit setContentOffset:point animated:YES];
            }
        }
            break;
        case kEditTag:
        {
            PhotoEditModel *editModel=_arrayEditModel[indexPath.row];
            [_arrayEditModel removeObjectAtIndex:indexPath.row];
            BOOL isExist=false;
            for (PhotoEditModel *model in _arrayEditModel) {
                if ([model.imageURL isEqual:editModel.imageURL]) {
                    isExist=true;
                }
            }
            if (!isExist) {
                for (int i=0; i<_arrayViewModel.count; i++) {
                    PhotoViewModel *model=_arrayViewModel[i];
                    if ([model.imageURL isEqual:editModel.imageURL]) {
                        model.checked=false;
                        _arrayViewModel[i]=model;
                        NSIndexPath *index = [NSIndexPath indexPathForRow:editModel.targetRow inSection:0];
                        [_colView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:index, nil]];
                    }
                }
            }
            //局部刷新
            [_colEdit deleteItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
            
            _total-=editModel.size;
            _labInfo.text=[NSString stringWithFormat:kInfoText,_total,kMaxSize];
        }
            break;
        default:
            break;
    }
}

/**
 *  获取IndexPath
 */
-(NSIndexPath *)getIndexPath
{
    double w=[PhotoEditCell width];
    double x=w*_arrayEditModel.count-w/2;
    double y=_colEdit.frame.size.height/2;
    NSIndexPath *index=[_colEdit indexPathForItemAtPoint:CGPointMake(x, y)];
    return index;
}

@end
