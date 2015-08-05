//
//  AuthorizationGuideController.h
//  Tutu
//
//  Created by gexing on 12/26/14.
//  Copyright (c) 2014 zxy. All rights reserved.
//

typedef NS_ENUM(NSInteger, AuthorizationType) {
    AuthorizationTypePhotoLibrary = 0,
    AuthorizationTypeCaptureDevice,
};

#import "BaseController.h"

@interface AuthorizationGuideController : BaseController
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property(nonatomic)AuthorizationType authorizatonType;
@end
