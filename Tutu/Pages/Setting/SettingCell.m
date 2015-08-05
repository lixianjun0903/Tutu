//
//  SettingCell.m
//  Tutu
//
//  Created by gexing on 12/19/14.
//  Copyright (c) 2014 zxy. All rights reserved.
//

#import "SettingCell.h"
#import "SDImageCache.h"
@implementation SettingCell

- (void)awakeFromNib {
    // Initialization code
    _titleLab.textColor = HEXCOLOR(TextBlackColor);
    _infoLab.textColor = HEXCOLOR(TextGrayColor);
    _infoLab.textAlignment = NSTextAlignmentRight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchValueChange:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(switchValueChanged:index:)]) {
        [_delegate switchValueChanged:sender index:_cellIndexPath];
    }
}
- (void)loadCellWithTitle:(NSString *)title info:(NSString *)info indexPaht:(NSIndexPath *)indexpath{

    _titleLab.text = title;
    _infoLab.text = info;
    _cellIndexPath = indexpath;
    
    [_swithBtn setHidden:YES];
    [_arrow setHidden:NO];
    if (indexpath.section ==1 && (indexpath.row == 0 || indexpath.row == 2 || indexpath.row == 3) ) {
        [_arrow setHidden:YES];
        [_swithBtn setHidden:NO];
        if (indexpath.row == 0) {
            if ([SysTools isCloseSoundEffect]) {
                [_swithBtn setOn:NO animated:NO];
            }
            else
            {
                [_swithBtn setOn:YES animated:NO];
            }
        }else if (indexpath.row == 2){
            NSString *isAllowStranger=[SysTools getValueFromNSUserDefaultsByKey:AllowStrangerMessage_KEY];
            if([@"0" isEqual:isAllowStranger]){
                [_swithBtn setOn:NO];
            }else{
                [_swithBtn setOn:YES];
            }
        
        }else if (indexpath.row == 3){
        
            BOOL isOpen = [UserDefaults boolForKey:UserDefaults_is_Close_AutoPlay_Under_Wifi];
            if (isOpen) {
                [_swithBtn setOn:NO];
            }else{
                [_swithBtn setOn:YES];
            }
        }
    }
    _infoLab.text = @"";
    _infoLab.hidden = YES;
    if (indexpath.section == 3 && indexpath.row == 5) {
        _infoLab.text = [SysTools getAppVersion];
        _infoLab.hidden = NO;
    }
    [_activityView removeFromSuperview];
    _activityView = nil;
    if (indexpath.section == 3 && indexpath.row == 4) {
        [self setimageCache];
        _infoLab.hidden = NO;
    }
}
- (void)setimageCache{
    _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake(ScreenWidth - 40, self.mj_height / 2.0f);
    _activityView.hidesWhenStopped = YES;
    [self.contentView addSubview:_activityView];
    [_activityView startAnimating];
    
    [self bk_performBlockInBackground:^(id obj) {
        long size = [[SDImageCache sharedImageCache] getSize];
        long size2 =  [SysTools fileSizeForDir:getVideoPath()];
        size = size + size2;
        NSString *string = @"";
        if (size <= 1024) {
            string = @"0KB";
        }else if(size > 1024 && size < 1024 * 1024){
            string = [NSString stringWithFormat:@"%.1fKB",size / 1024.0];
        }else{
            string = [NSString stringWithFormat:@"%.1fMB",size / 1024.0/1024.0];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityView stopAnimating];
           _infoLab.text = string;
        });
        
    } afterDelay:0.0f];
    
}

@end
