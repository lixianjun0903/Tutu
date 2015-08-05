//
//  AddressBookModel.m
//  Tutu
//
//  Created by 刘大治 on 14/12/3.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AddressBookDictionary.h"
#import "AppDelegate.h"

@implementation AddressBookDictionary


-(NSString*)ifNull:(NSString*)string
{
    NSString * newString = nil;
    if (string==nil) {
        newString=@"";
    }
    else
    {
        newString = string;
    }
    return newString;
}


//获取所有通讯录
-(NSArray * )getAllRecord
{
    NSMutableArray * bookArray = [NSMutableArray array];
    [self createAddressBook];
    if(_addressBookRef==nil){
        return bookArray;
    }
    CFArrayRef result = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    
    for (NSInteger i=0; i<CFArrayGetCount(result); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(result,i);
        AddressBookDictionary * dict = [[AddressBookDictionary alloc]init];
        NSDictionary * newDict = [dict getAddressBook:person];
        [bookArray addObject:newDict];
    }
    
    CFRelease(result);//new
    CFRelease(_addressBookRef);//new

    return bookArray;
}

//增量获取
-(NSArray *)getContactsWithTime{
    
    NSString *sysTime=[SysTools getValueFromNSUserDefaultsByKey:SYSContactsTime_KEY];
    int time=0;
    if(sysTime!=nil && ![@"" isEqual:sysTime]){
        time=[stringFormateDate(sysTime) timeIntervalSince1970];
    }
    
    NSMutableArray * bookArray = [NSMutableArray array];
    [self createAddressBook];
    if(_addressBookRef==nil){
        return bookArray;
    }
    CFArrayRef result = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    for (NSInteger i=0; i<CFArrayGetCount(result); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(result,i);
        AddressBookDictionary * dict = [[AddressBookDictionary alloc]init];
        NSDictionary * newDict = [dict getAddressBook:person];
        
        //去掉头像，否则无法转换为json
//        [newDict setValue:@"" forKey:@"headerImage"];
        
        //增量判断，当前时间是否大于系统记录时间
        NSString *lastTime=[newDict objectForKey:@"last"];
        if(lastTime==nil || [@"" isEqual:lastTime]){
            lastTime=[newDict objectForKey:@"first"];
        }
        int newTime=[stringFormateDateWithFormate(@"yyyy-MM-dd HH:mm:ss +0000",lastTime) timeIntervalSince1970];
        if(newTime>time){
            [bookArray addObject:newDict];
        }
        
    }
    
    CFRelease(result);//new
    CFRelease(_addressBookRef);//new

    return bookArray;
}


//获取电话薄
-(void)createAddressBook{
    _addressBookRef=nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)//判断ios版本
    {
        
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        //等待同意后向下执行
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef error) {
            
            dispatch_semaphore_signal(sema);
            
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}



//获取联系人信息
-(NSDictionary*)getAddressBook:(ABRecordRef)person{
    NSInteger lookupforkey =(NSInteger)ABRecordGetRecordID(person);//读取通讯录中联系人
    NSMutableDictionary * inforDictionary =[[NSMutableDictionary alloc]init];
    [inforDictionary setObject:[NSString stringWithFormat:@"%ld",(long)lookupforkey] forKey:@"local_id"];
//    WSLog(@"%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *personName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    personName = [self ifNull:personName];
    
    //读取lastname
    NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    lastname = [self ifNull:lastname];
    
    NSString * name = [NSString stringWithFormat:@"%@%@",lastname,personName];
    [inforDictionary setValue:[self ifNull:name] forKey:@"name"];
    //读取prefix前缀
    NSString *prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
    //读取suffix后缀
    NSString *suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
    [inforDictionary setObject:[self ifNull:prefix] forKey:@"pre"];
    [inforDictionary setObject:[self ifNull:suffix] forKey:@"suf"];
    
    
    //读取nickname呢称
    NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
    [inforDictionary setObject:[self ifNull:nickname] forKey:@"nick"];
    //读取firstname拼音音标
    NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
    
    //读取lastname拼音音标
    NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
    
    //读取middlename拼音音标
//    NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);

    //读取organization公司
    NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);

    [inforDictionary setObject:[self ifNull:firstnamePhonetic] forKey:@"fstVoc"];
    [inforDictionary setObject:[self ifNull:lastnamePhonetic] forKey:@"lstVoc"];
    [inforDictionary setObject:[self ifNull:organization] forKey:@"cpy"];
    


    //读取jobtitle工作
    NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
    [inforDictionary setObject:[self ifNull:jobtitle] forKey:@"job"];
    
    //读取department部门
    NSString *department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
    [inforDictionary setObject:[self ifNull:department] forKey:@"depart"];
    
    //读取birthday生日
    NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
    NSString * newSt =@"";
    if (birthday != NULL) {
        newSt = [NSString stringWithFormat:@"%@",birthday];
    }
    
    [inforDictionary setObject:newSt forKey:@"birth"];
    //读取note备忘录
    
    NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
    [inforDictionary setObject:[self ifNull:note] forKey:@"note"];
    
    
    
    //第一次添加该条记录的时间
    NSDate *firstknow = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
    newSt = @"";
    if (firstknow !=NULL) {
        newSt = [NSString stringWithFormat:@"%@",firstknow];
    }
    [inforDictionary setObject:newSt forKey:@"first"];
    
    
    //最后一次修改該条记录的时间
    NSDate *lastknow = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
    newSt = @"";
    if (lastknow !=NULL) {
        newSt = [NSString stringWithFormat:@"%@",lastknow];
    }
//    NSLog(@"最后一次修改联系人的的时间%@\n",lastknow);
    [inforDictionary setObject:newSt forKey:@"last"];
    
    //获取email多值
    ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
    int emailcount = ABMultiValueGetCount(email);
    NSMutableArray * emailArray =[NSMutableArray array];
    for (int x = 0; x < emailcount; x++)
    {
        //获取email Label
        NSString* emailKind = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
        //获取email值
        NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
        NSDictionary * emailDic= @{@"kind":[self ifNull:emailKind],@"detail":[self ifNull:emailContent]};
        [emailArray addObject:emailDic];
    }
    [inforDictionary setObject:emailArray forKey:@"email"];
    
    
    //读取地址多值
    ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
    int count = ABMultiValueGetCount(address);
    NSMutableArray * addressArray = [NSMutableArray array];
    for(int j = 0; j < count; j++)
    {
        //获取地址Label
//        NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
        //获取該label下的地址6属性
        NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
        NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
        
        NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
        
        NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];

        NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
        
        city=[NSString stringWithFormat:@"%@ %@",city,street];

        
        //            邮编
        NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];

        NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
        NSDictionary * addressInfo = @{@"cy": [self ifNull:country],@"pro":[self ifNull:state],@"city":[self ifNull:city],@"pc":[self ifNull:zip],@"cycode":[self ifNull:coutntrycode]};
        [addressArray addObject:addressInfo];
    }
    
    [inforDictionary setObject:addressArray forKey:@"add"];
//    WSLog(@"%@",[inforDictionary JSONString]);
    
    
    //获取dates多值
    ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
    int datescount = ABMultiValueGetCount(dates);
    NSMutableArray * dateArray = [NSMutableArray array];
    for (int y = 0; y < datescount; y++)
    {
        //获取dates Label
        
        NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
        //获取dates值
        NSDate* datesContent = (__bridge NSDate*)ABMultiValueCopyValueAtIndex(dates, y);
        NSDictionary * dateDict = @{@"kind":[self ifNull:datesLabel],@"detail":[self ifNull:[NSString stringWithFormat:@"%@",datesContent]]};
        [dateArray addObject:dateDict];
    }
    [inforDictionary setObject:dateArray forKey:@"date"];
    
    
    
    //获取kind值
    CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
    if (recordType == kABPersonKindOrganization) {
        // it's a company
    } else {
        // it's a person, resource, or room
    }
    
    //        ABMultiValueRef email = ABRecordCopyValue(person,i);
    
    //获取即时通信信息
    ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
    NSMutableArray * imArray= [NSMutableArray array];
    for (int l = 0; l < ABMultiValueGetCount(instantMessage); l++)
    {
        
        //获取IM Label
//        NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
        
        //获取該label下的2属性
        NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
        NSString* username = CheckNilValue([instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey]);
        NSString* service = CheckNilValue( [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey]);
        NSDictionary * imDict = @{@"kind":service,@"detail":username};
        [imArray addObject:imDict];
    }
    
    if ([imArray count]==0)
    {
        NSArray * emptyArray = [NSArray array];
        [inforDictionary setObject:emptyArray forKey:@"im"];
    }
    else
    {
        [inforDictionary setObject:imArray forKey:@"im"];
    }
    
    
    
    
    ABMultiValueRef socCommit = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
    
    NSArray * socArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(socCommit));
    NSMutableArray * socalArray = [[NSMutableArray alloc]init];
    if ([socArray count]!=0) {
        for (int k=0; k<ABMultiValueGetCount(socCommit);k++)
        {
            NSDictionary * emptyDictionary = [NSDictionary dictionary];
            NSDictionary * detail = nil;
            if ([socArray objectAtIndex:k] != nil) {
                detail = [socArray objectAtIndex:k];
            }
            else
            {
                detail = emptyDictionary;
            }
            
            [socalArray addObject:[socArray objectAtIndex:k]];
            //将多值属性的多个值转化为数组
            
        }
        [inforDictionary setObject:socArray forKey:@"socal"];
    }
    else
    {
        NSArray * emptyArray = [NSArray array];
        [inforDictionary setObject:emptyArray forKey:@"socal"];
    }
    
    
    
    //读取电话多值
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSMutableArray * phoneArray  =[NSMutableArray array];
    for (int k = 0; k<ABMultiValueGetCount(phone); k++)
    {
        //获取电话Label
        NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
        //获取該Label下的电话值
        NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
        NSDictionary * phoneDict =@{@"kind":personPhoneLabel,@"detail":personPhone};
        [phoneArray addObject:phoneDict];
    }
    [inforDictionary setObject:phoneArray forKey:@"phone"];
    
    
    
    //获取URL多值
    ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
    NSMutableArray * urlArray =[NSMutableArray array];
    for (int m = 0; m < ABMultiValueGetCount(url); m++)
    {
        //获取电话Label
        NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
        //获取該Label下的电话值
        NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
        NSDictionary * urlDict =[NSDictionary dictionaryWithObjectsAndKeys:urlLabel,@"kind",urlContent,@"detail", nil];
        //            @"type":urlLabel,@"detal":urlContent
        [urlArray addObject:urlDict];
    }
    [inforDictionary setObject:urlArray forKey:@"url"];
    
//    if(!isSend)
//    {
        //判断联系人是否有照片
//        if (ABPersonHasImageData(person)) {
//            //获取照片数据
//            NSData *photoData = CFBridgingRelease(ABPersonCopyImageData(person));
//            [inforDictionary setObject:[UIImage imageWithData:photoData] forKey:@"headerImage"];
//        }
//        else{
//               [inforDictionary setObject:[UIImage imageNamed:@"avatar_default"] forKey:@"headerImage"];
//        }
//    }

    
    return inforDictionary;
}


//获取联系人的图片
- (UIImage *)getImage:(int) personIDASNumber book:(ABAddressBookRef) addressBook
{
    ABRecordRef cecordRef = ABAddressBookGetPersonWithRecordID(addressBook,personIDASNumber);
    //判断联系人是否有照片
    if (ABPersonHasImageData(cecordRef)) {
        //获取照片数据
        NSData *photoData = CFBridgingRelease(ABPersonCopyImageData(cecordRef));
        return [UIImage imageWithData:photoData];
    }
    return nil;
}

@end
