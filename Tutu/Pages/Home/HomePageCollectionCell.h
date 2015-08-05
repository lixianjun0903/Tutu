//
//  HomePageCollectionCell.h
//  Tutu
//
//  Created by gexing on 4/8/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomePageCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@property(nonatomic,strong)NSMutableArray *dataArray;

@end
