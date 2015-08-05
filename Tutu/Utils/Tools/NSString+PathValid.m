//
//  NSString+PathValid.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-20.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NSString+PathValid.h"
#define imageVALIDMINUTES 20
#define videoVALIDMINUTES 10

@implementation NSString(PathValid)

- (int)Interval
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil];
    //NSLog(@"create date:%@",[attributes fileModificationDate]);
    NSString *dateString = [NSString stringWithFormat:@"%@",[attributes fileModificationDate]];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:dateString];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *d = [cal components:unitFlags fromDate:formatterDate toDate:[NSDate date] options:0];
    
    //NSLog(@"%d,%d,%d,%d",[d year],[d day],[d hour],[d minute]);
    
    int result = (int)d.minute;
    
    //	return 0;
    return result;
}


-(BOOL)imageIsValid{
    if ([self Interval] < imageVALIDMINUTES) { //VALIDDAYS = 有效时间天数
        return YES;
    }
    return NO;
}

-(BOOL)videoIsValid{
    if ([self Interval] < videoVALIDMINUTES) { //VALIDDAYS = 有效时间天数
        return YES;
    }
    return NO;
}

@end
