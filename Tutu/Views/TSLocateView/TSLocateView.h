//
//  UICityPicker.h
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "AreaDBHelper.h"

@interface TSLocateView : UIActionSheet<UIPickerViewDelegate, UIPickerViewDataSource> {
@private
    NSArray *provinces;
    NSMutableArray	*cities;
}

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (strong, nonatomic) CityModel *locate;
@property (assign, nonatomic) int showNull;

- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate;

- (void) setDefaultValue:(int) showNul;

- (void)showInView:(UIView *)view;
- (IBAction)hidden;
@end
