//
//  selectPhotoView.h
//  tttttest
//
//  Created by gexing on 15/1/12.
//  Copyright (c) 2015年 gexing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^blockImage)(UIImage *image);
typedef void(^originalImage)(UIImage *orImage);

@interface SelectPhotoView : UIView<UIScrollViewDelegate>

@property(nonatomic,strong)NSArray *array;

@property(nonatomic,copy)blockImage tempBlock;
@property(nonatomic,copy)originalImage tempOrBlock;



//初始化方法 ,数组里为图片对象
-(id)initWithFrame:(CGRect)rect ImageArray:(NSArray *)imageArray  originalImage:(originalImage)originalImageBlock selectImageBlock:(blockImage )imageBlock;



@end
