//
//  AddressBookModel.h
//  Tutu
//
//  Created by 刘大治 on 14/12/3.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
@interface AddressBookDictionary : NSDictionary

//通讯录
@property (nonatomic, assign) ABAddressBookRef addressBookRef;

-(NSString*)ifNull:(NSString*)string;

//获取通讯录使用
-(NSArray * )getAllRecord;

//增量上传使用
-(NSArray *)getContactsWithTime;

@end
