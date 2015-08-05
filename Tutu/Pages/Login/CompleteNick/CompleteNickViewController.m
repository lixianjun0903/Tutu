//
//  CompleteNickViewController.m
//  Tutu
//
//  Created by 刘大治 on 14/11/11.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "CompleteNickViewController.h"

@interface CompleteNickViewController ()

@end

@implementation CompleteNickViewController

-(id)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTitleMenu];
    [self.menuTitleButton setTitle:@"完善昵称" forState:UIControlStateNormal];
   // [self.menuLeftButton setImageEdgeInsets:UIEdgeInsetsMake(22-19/2,16,22-19/2,16)];
    

    // Do any additional setup after loading the view from its nib.
}

-(void)buttonClick:(UIButton*)sender
{
    if (sender.tag == BACK_BUTTON) {
        [self goBack:nil];
    }
    else
    {
        
    }
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
