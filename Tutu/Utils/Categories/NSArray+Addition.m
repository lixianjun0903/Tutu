//
//  NSArray+Addition.m
//  GeXingWang
//
//  Created by feng on 14-10-15.
//  Copyright (c) 2014年 GeXing. All rights reserved.
//
#import  <objc/runtime.h>
#import "NSArray+Addition.h"


@implementation NSArray (Addition)

+ (void)load {
    Method objectAtIndex = class_getInstanceMethod([[NSArray array] class], @selector(objectAtIndex:));
    Method objectAtIndexNew = class_getInstanceMethod([[NSArray array] class], @selector(objectAtIndexNew:));
    method_exchangeImplementations(objectAtIndex, objectAtIndexNew);
}
- (id)objectAtIndexNew:(NSUInteger)index{
    if (self.count > index) {
        id objc = [self objectAtIndexNew:index];
        return objc;
    }
    return nil;
}
@end
