//
//  VPImageCropperViewController.h
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeController.h"

@interface VPImageCropperViewController : UIViewController

@property (nonatomic, retain) HomeController *pcontroller;

- (id)initWithImage:(UIImage *)originalImage;

@end
