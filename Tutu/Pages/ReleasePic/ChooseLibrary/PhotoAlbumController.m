//
//  PhotoAlbumController.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//  http://www.cnblogs.com/liangxing/archive/2013/01/05/2846136.html

#import "PhotoAlbumController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoAlbumCell.h"
#import "PhotoToVideoController.h"

@interface PhotoAlbumController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong) ALAssetsLibrary *library;
@property(nonatomic,strong) NSMutableArray *arrayGroup;
@property(nonatomic,strong) NSMutableArray *arrayImage;

@end

@implementation PhotoAlbumController

- (instancetype)init
{
    self=[super init];
    if (self) {
        //初始化数据
        _library=[[ALAssetsLibrary alloc] init];
        _arrayGroup=[[NSMutableArray alloc] init];
        _arrayImage=[[NSMutableArray alloc] init];
        
        _arrayEditModel=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //设置背景颜色
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    //设置导航栏
    [self createTitleMenu];
    [self.menuTitleButton setTitle:@"选择图片" forState:UIControlStateNormal];
    self.menuRightButton.hidden=YES;
    
    //设置界面
    [self setUI];
    
    //获取相册
    [self getPhotoAlbum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  设置界面
 */
- (void)setUI
{
    CGRect gridFrame=self.view.bounds;
    gridFrame.origin.y = NavBarHeight;
    gridFrame.size.height=gridFrame.size.height-gridFrame.origin.y;
    
    _tableView=[[UITableView alloc]init];
    _tableView.frame=gridFrame;
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

/**
 *  获取相册
 */
- (void)getPhotoAlbum
{
    //获取相册
    void (^ assetGroupEnumerator)(ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([group numberOfAssets]==0){
                return;
            }
            
            NSString *name=[group valueForProperty:ALAssetsGroupPropertyName];
            int size=(int)[group numberOfAssets];
            NSLog(@"name:%@ size:%i",name,size);
            
            [_arrayGroup addObject:group];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (index!=0) {
                    return;
                }
                if (result!=nil) {
                    if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                        NSURL *url= (NSURL*)[[result defaultRepresentation]url];
                        [_library assetForURL:url
                                  resultBlock:^(ALAsset *asset){
                                      //获取图片
                                      UIImage *image=[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                                      //图片为空
                                      if(image==nil){
                                          [_arrayGroup removeObject:group];
                                          [_tableView reloadData];
                                          return;
                                      }
                                      [_arrayImage addObject:image];
                                      //遍历完成
                                      if (_arrayGroup.count==_arrayImage.count){
                                          //重新加载数据
                                          [_tableView reloadData];
                                      }
                                  }
                                 failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!");
                        }];
                    }
                }
            }];
        }
    };
    
    //执行方法
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll
                            usingBlock:assetGroupEnumerator
                          failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

#pragma -mark Event

/**
 *  [返回按钮]单击事件
 */
-(IBAction)buttonClick:(UIButton *)sender
{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrayGroup count];
}

- (PhotoAlbumCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifer=@"identifer";
    PhotoAlbumCell *cell=[tableView dequeueReusableCellWithIdentifier:strIdentifer];
    if (cell==nil) {
        cell=[[PhotoAlbumCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifer];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
    ALAssetsGroup *group=_arrayGroup[indexPath.row];
    NSString *name=[group valueForProperty:ALAssetsGroupPropertyName];
    int size=(int)[group numberOfAssets];
    NSLog(@"name:%@ size:%i",name,size);

    cell.imgView.image=_arrayImage[indexPath.row];
    cell.labName.text=name;
    cell.labSize.text=[NSString stringWithFormat:@"%i",(int)[group numberOfAssets]];
    cell.width=self.view.bounds.size.width;
    
    return cell;
}

#pragma -mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPhotoAlbumCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoToVideoController *photoToVideo=[[PhotoToVideoController alloc]initWithBlock:^(NSMutableArray *arrayEditModel) {
        _arrayEditModel=arrayEditModel;
    }];
    photoToVideo.group=_arrayGroup[indexPath.row];
    photoToVideo.arrayEditModel=_arrayEditModel;
    [self.navigationController pushViewController:photoToVideo animated:YES];
}

@end
