//
//  CoverListController.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-27.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "CoverListController.h"
#import "CoverHeaderView.h"
#import "CoverItemCell.h"

#define dentifierCoverItemCell @"CoverItemCell"
#define dentifierCoverHeaderView @"CoverHeaderView"
#import "UIImageView+WebCache.h"


@interface CoverListController (){
    CGFloat w;
    CGFloat h;
    
    UICollectionView *collectionView;
    CGFloat itemSizeWith;
    
    
    NSMutableArray *dataArr;
    NSIndexPath *lastIndex;
}

@end

@implementation CoverListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTitleMenu];
    [self.menuTitleButton setTitle:TTLocalString(@"TT_Select the cover page") forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickDefautl.png"] forState:UIControlStateNormal];
    [self.menuRightButton setImage:[UIImage imageNamed:@"changeNickHelight.png"] forState:UIControlStateHighlighted];
    [self.menuRightButton setImageEdgeInsets:UIEdgeInsetsMake(12,8,12,16)];
    self.menuRightButton.tag=RIGHT_BUTTON;
    
    [self.view setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    w=self.view.bounds.size.width;
    h=self.view.bounds.size.height;
    
    dataArr=[[NSMutableArray alloc] init];
    
    itemSizeWith=(w-20)/3;
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection              = UICollectionViewScrollDirectionVertical;
    
    layout.itemSize                     = CGSizeMake(itemSizeWith, itemSizeWith);
    layout.minimumInteritemSpacing      = 5;
    layout.minimumLineSpacing           = 5;
    layout.sectionInset                 = UIEdgeInsetsMake( 5, 5, 5, 5);
    
    collectionView                       = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NavBarHeight, w, h-NavBarHeight) collectionViewLayout:layout];
    collectionView.collectionViewLayout = layout;
    
    collectionView.alwaysBounceVertical  =YES;
    collectionView.backgroundColor       = [UIColor groupTableViewBackgroundColor];
    collectionView.dataSource            =self;
    collectionView.delegate              =self;
    
    
    UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([CoverHeaderView class])  bundle:[NSBundle mainBundle]];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([CoverItemCell class])  bundle:[NSBundle mainBundle]];
    [collectionView registerNib:headerNib forSupplementaryViewOfKind :UICollectionElementKindSectionHeader  withReuseIdentifier: dentifierCoverHeaderView ];  //注册加载头
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:dentifierCoverItemCell];
    
    [self.view addSubview:collectionView];
    
    
    // 查询数据
    [self queryData];
}


-(void)queryData{
    [[RequestTools getInstance] get:API_GET_COVER_LIST isCache:YES completion:^(NSDictionary *dict) {
        dataArr = dict[@"data"];
        [collectionView reloadData];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
    }];
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(w, 40);
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return dataArr.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arr =dataArr[section][@"list"];
    return arr.count;
}



-(UICollectionReusableView *)collectionView:(UICollectionView *)itemcollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    CoverHeaderView *view = [itemcollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:dentifierCoverHeaderView forIndexPath:indexPath];
    
    [view setTitle:[NSString stringWithFormat:@"·%@",dataArr[indexPath.section][@"typename"]]];
    return view;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)itemcollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CoverItemCell *cell = [itemcollectionView dequeueReusableCellWithReuseIdentifier:dentifierCoverItemCell forIndexPath:indexPath];
    
    NSDictionary *dict      = dataArr[indexPath.section];
    NSDictionary *item=[dict objectForKey:@"list"][indexPath.row];
    
    UIImage *img=[UIImage imageNamed:@"topic_default_samll"];
    [cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"smallpicurl"]] placeholderImage:img];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)ccollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    WSLog(@"选中%@",indexPath);
    if(lastIndex){
        [collectionView deselectItemAtIndexPath:lastIndex animated:YES];
    }
    lastIndex=indexPath;
}


-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    
    //提交
    if(sender.tag==RIGHT_BUTTON){
        NSDictionary *dict      = dataArr[lastIndex.section];
        NSDictionary *item=[dict objectForKey:@"list"][lastIndex.row];
        
        NSString *url=[item objectForKey:@"picurl"];
        NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
        [params setValue:@"syscover" forKey:@"covertype"];
        [params setValue:url forKey:@"syscoverurl"];
        
        WSLog(@"%@",API_POST_COVER);
        [[RequestTools getInstance] post:API_POST_COVER filePath:nil fileKey:nil params:params completion:^(NSDictionary *dict) {
            WSLog(@"%@",dict);
            
        } failure:^(ASIFormDataRequest *request, NSString *message) {
            
        } finished:^(ASIFormDataRequest *request) {
            WSLog(@"%@",request.responseString);
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_UPDATE_COVER object:url];
        [self goBack:nil];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
