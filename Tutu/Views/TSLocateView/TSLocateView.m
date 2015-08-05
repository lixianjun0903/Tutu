//
//  UICityPicker.m
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

#import "TSLocateView.h"
#import "UIView+Border.h"

#define kDuration 0.3

@implementation TSLocateView

@synthesize titleLabel;
@synthesize locatePicker;
@synthesize locate;

- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TSLocateView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.titleLabel.text = title;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        AreaDBHelper *db=[[AreaDBHelper alloc] init];
        
        //加载数据
        provinces = [db findProvince];
        PlaceNameModel *pm=[provinces objectAtIndex:0];
        
        cities = [db findCitysWithProId:pm];
        
        //初始化默认数据
        self.locate = (CityModel *)[cities objectAtIndex:0];
        
        
        UITapGestureRecognizer * tap  =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)setDefaultValue:(int)showNull{
    self.showNull=showNull;
    if(self.showNull==1){
        CityModel *cmodel=[[CityModel alloc] init];
        cmodel.cityname=@"不限";
        cmodel.citysort=@"0";
        cmodel.proid=@"";
        cmodel.pname=locate.pname;
        [cities insertObject:cmodel atIndex:0];
        self.locate=cmodel;
    }
}


- (void)drawRect:(CGRect)rect
{
    [_titleView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    
    
    [_titleView addTopBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    [_titleView addBottomBorderWithColor:UIColorFromRGB(TextGrayColor) andWidth:0.5];
    
//    for (UIView *view in self.subviews) {
//        WSLog(@"%@",view);
        //        if ([view isKindOfClass:[UIControl class]]) {
        //            [self bringSubviewToFront:view];
        //            [buttons addObject:view];
        //            [view removeFromSuperview];
        //        }
        //        if ([view isKindOfClass:[UILabel class]]) {
        //            titleLabel = (UILabel *)view;
        //        }
//    }
}

- (void)showInView:(UIView *) view
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"DDLocateView"];
//    view.frame.size.height - self.frame.size.height
    
    self.frame = CGRectMake(0,0, ScreenWidth, ScreenHeight);
    
    [view addSubview:self];
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            WSLog(@"%d",[cities count]);
            return [cities count];
            break;
        default:
            return 0;
            break;
    }
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    float width;
//    if (component == 0) {
//        width = 100;
//    }
//    else
//    {
//        width = 200;
//    }
//    return width;
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PlaceNameModel *pm=(PlaceNameModel *)[provinces objectAtIndex:row];
    switch (component) {
        case 0:
            return pm.proname;
            break;
        case 1:
            return ((CityModel *)[cities objectAtIndex:row]).cityname;
            break;
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    AreaDBHelper *db=[[AreaDBHelper alloc] init];
    PlaceNameModel *pnm;
    if (component==0) {
        pnm=(PlaceNameModel *)[provinces objectAtIndex:row];
    }
    
    switch (component) {
        case 0:
            cities = [db findCitysWithProId:pnm];
            if(self.showNull==1){
                CityModel *cmodel=[[CityModel alloc] init];
                cmodel.cityname=@"不限";
                cmodel.citysort=@"0";
                cmodel.proid=pnm.prosort;
                cmodel.pname=pnm.proname;
                [cities insertObject:cmodel atIndex:0];
            }
            [self.locatePicker selectRow:0 inComponent:1 animated:NO];
            [self.locatePicker reloadComponent:1];
            
            self.locate=[cities objectAtIndex:0];
            WSLog(@"%@",cities);
            
            break;
        case 1:
            NSLog(@"%d==row=%d",cities.count,row);
           
            self.locate = [cities objectAtIndex:row];
            break;
        default:
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component

{
    
    return 40.0;
    
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    UILabel * label = (UILabel*)[[UILabel alloc]init];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:ListDetailFont];
    label.textAlignment = NSTextAlignmentCenter;
    if (component==0) {
        label.text = [[provinces objectAtIndex:row] proname];
    }
    else
    {
        label.text = [[cities objectAtIndex:row] cityname];
    }
    label.frame = CGRectMake(0, 0, self.mj_size.width/2, 40);
    return label;
}


- (IBAction)hidden
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];

}




#pragma mark - Button lifecycle

- (IBAction)cancel:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
}

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
    
}

@end
