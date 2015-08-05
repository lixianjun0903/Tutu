//
//  AuthorizationGuideController.m
//  Tutu
//
//  Created by gexing on 12/26/14.
//  Copyright (c) 2014 zxy. All rights reserved.
//

#import "AuthorizationGuideController.h"
#import "UILabel+Additions.h"
@interface AuthorizationGuideController ()

@end

@implementation AuthorizationGuideController
- (IBAction)buttonClick:(id)sender{
    [self goBack:sender];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTitleMenu];
    [self.menuRightButton setHidden:YES];
   
    self.view.backgroundColor = HEXCOLOR(SystemGrayColor);
    if (_authorizatonType == AuthorizationTypeCaptureDevice) {
        _descLabel.text = TTLocalString(@"TT_set_camera_permission");
        self.title = TTLocalString(@"TT_camera");
        self.bgImageView.image =[UIImage imageNamed:@"camera_bg"] ;
        self.bgImageView.frame = CGRectMake((ScreenWidth - 130)/2.0, _bgImageView.mj_y, 130, 112);
    }else if (_authorizatonType == AuthorizationTypePhotoLibrary){
        _descLabel.text = TTLocalString(@"TT_set_album_permission");
        self.title = TTLocalString(@"TT_album");
        self.bgImageView.image = [UIImage imageNamed:@"album_bg"];
    }else{
        
    }
    self.descLabel.textColor = HEXCOLOR(TextGrayColor);
    CGSize size = [_descLabel getLabelSize];
    _descLabel.frame = CGRectMake(_descLabel.mj_x, _descLabel.mj_y,size.width, size.height);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)dismissController:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
