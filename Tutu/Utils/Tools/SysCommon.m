//
//  SysCommon.m
//  InversionClass
//
//  Created by 张 新耀 on 13-8-27.
//  Copyright (c) 2013年 张 新耀. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "RegexKitLite.h"
#import <Foundation/NSString.h>

#define DOCUMENTS_FOLDER_VEDIO @"Videos"


static NSString *regrexUrl = @"\\b((?:[\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|(?:[^\\p{Punct}\\s]|/))+|\\.com|\\.cn|\\.org|\\.net|\\.hk|\\.int|\\.edu|\\.gov|\\.mil|\\.arpa|\\.biz|\\info|\\.name|\\.pro|\\.coop|\\.aero|\\.museum|\\.cc|\\.tv)";

NSDate* parseDateFromNSNumber(NSNumber* number){
    
    if (nil == number || ![number isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[number longValue]];
}

BOOL parseBoolFromString(NSString* boolValue){
    
    if (nil == boolValue) {
        return NO;
    }
    
    static NSString* boolTrue = @"true";
    //static NSString* boolFalse = @"false";
    
    if (NSOrderedSame == [boolTrue caseInsensitiveCompare:boolValue]) {
        return YES;
    }
    
    return NO;
}


NSString* extractFileNameFromPath(NSString* path){
    return [path lastPathComponent];
}


NSString* getTmpDownloadFilePath(NSString* filePath){
    return [NSTemporaryDirectory() stringByAppendingPathComponent:extractFileNameFromPath(filePath)];
}

NSString* getCacheFilePath(NSString* cacheKey){
    return [NSTemporaryDirectory() stringByAppendingPathComponent:cacheKey];
}

NSString* md5(NSString* input)
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
   
    WSLog(@"%@",input);
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

NSString* trimString (NSString* input) {
    NSMutableString *mStr = [input mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mStr);
    NSString *result = [mStr copy];
    return result;
}

BOOL is_null(id object) {
    return (nil == object || [@"" isEqual:object] || [object isKindOfClass:[NSNull class]]);
}

id defaultNilObject(id object) {
    
    if (is_null(object)) {
        return nil;
    }
    
    return object;
}

BOOL isEmpty(NSString* str) {
    
    if (is_null(str)) {
        return YES;
    }
    
    if([str isKindOfClass:[NSString class]]){
        return [trimString(str) length] <= 0;
    }
    
    return NO;
}

NSString* defaultEmptyString(id object) {
    
    if (is_null(object)) {
        return @"";
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    
    if ([object respondsToSelector:@selector(stringValue)]) {
        return [object stringValue];
    }
    
    return @"";
}


BOOL validateEmail(NSString* email) {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:email];
}

//是否是真正的手机号
BOOL validateMobile(NSString* mobile) {
//    NSString *phoneRegex = @"^((13[0-9])|(14[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSString *phoneRegex = @"^((13[0-9])|(14[0-9])|(15[0,0-9])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

BOOL validateQQNumber(NSString *qqNumber)
{
    NSString *QQRegex = @"^[1-9]*[1-9][0-9]*$";
    NSPredicate *QQTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", QQRegex];
    return [QQTest evaluateWithObject:qqNumber];
}

BOOL validdatePinYin(NSString *pinYin){
    NSString *PYRegex = @"^[A-Za-z]*$";
    NSPredicate *PYTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PYRegex];
    return [PYTest evaluateWithObject:pinYin];
}

BOOL validateNickName(NSString *nickname){
    if(nickname==nil || [@"" isEqual:nickname]){
        return NO;
    }
    int len=0;
    for (int i=0 ;i<nickname.length;i++) {
        int s=[nickname characterAtIndex:i];
        if( s > 0x4e00 && s < 0x9fff){
            //中文算2个字符
            len=len+2;
        }else{
            len=len+1;
        }
    }
    if(len<4 || len>24){
        return NO;
    }
    return YES;
}

int getStringCharCount(NSString *text){
    int len=0;
    for (int i=0 ;i<text.length;i++) {
        int s=[text characterAtIndex:i];
        if( s > 0x4e00 && s < 0x9fff){
            //中文算2个字符
            len=len+2;
        }else{
            len=len+1;
        }
    }
    return len;
}

BOOL validatePassword(NSString *password){
    if(password==nil || [@"" isEqual:password] || password.length<6){
        return NO;
    }
    return YES;
}

int convertStingEncoding(const char* toEncoding, const char* fromEncoding,
                         const char* inBuffer, size_t* inBufferSize,
                         char* outBuffer, size_t* outBufferSize){
    
    //    iconv_t handle = iconv_open(toEncoding, fromEncoding);
    //
    //    // do not support the encoding
    //    if (((iconv_t) -1) == handle) {
    //        BeeCC(@"Do not Support Encoding  toEncoding[%s] fromEncoding[%s]", toEncoding, fromEncoding);
    //        return (size_t)handle;
    //    }
    //
    //    int convertSize = iconv(handle, (const char**)(&inBuffer), inBufferSize, &outBuffer, outBufferSize);
    //    iconv_close(handle);
    //
    //    return convertSize;
    return 0;
}

NSString* convertCharStrToUTF8(const char* inBuffer, size_t inBufferSize) {
    
    //    apiLogDebug(@"Dump Hex {%@}", convertToHexStr(inBuffer, inBufferSize));
    //
    //    NSData* data = [NSData dataWithBytes:inBuffer length:inBufferSize];
    //
    //    NSString* retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //
    //    if (nil != retStr) {
    //        apiLogDebug(@"recognize UTF-8 encoding [%@]", retStr);
    //        [retStr autorelease];
    //        return  retStr;
    //    }
    //
    //    NSStringEncoding gb2312Encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
    //    retStr = [[NSString alloc] initWithData:data encoding:gb2312Encoding];
    //
    //    if (nil != retStr) {
    //        apiLogDebug(@"recognize GB2312 encoding [%@]", retStr);
    //        [retStr autorelease];
    //        return  retStr;
    //    }
    //
    //    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //    retStr = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    //
    //    if (nil != retStr) {
    //        apiLogDebug(@"recognize GBK encoding [%@]", retStr);
    //        [retStr autorelease];
    //        return  retStr;
    //    }
    //
    //    return @"ERROR";
    
    static char* fromEncodingArray[] = {
        "GB18030",
        "ISO-8859-1",
        "UTF8",
        0
    };
    
    char** currentEncoding = fromEncodingArray;
    
    // make sure we would have enough space to containing all characters
    size_t outBufferSize = inBufferSize * 4 + 4;
    char* outBuffer = (char*)malloc(outBufferSize * sizeof(char));
    
    for (; *currentEncoding; currentEncoding++) {
        // clean the bufffer first
        memset(outBuffer, 0, outBufferSize);
        size_t tmpInBufferSize = inBufferSize;
        size_t tmpOutBufferSize = outBufferSize;
        
        int count = convertStingEncoding("utf-8", *currentEncoding, inBuffer, &tmpInBufferSize,
                                         outBuffer, &tmpOutBufferSize) ;
        if(count > 0){
            goto out_free;
        }
        
    }
    free(outBuffer);
    return [NSString stringWithUTF8String:inBuffer];
    
out_free:
    NSLog(@"ai");
    NSString* retString = [NSString stringWithUTF8String:outBuffer];
    free(outBuffer);
    return retString;
}

NSString * getLibraryVideoPath(){
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library"];
    NSString *path=[documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/Caches/%@", DOCUMENTS_FOLDER_VEDIO]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

NSString* getDocumentsFilePath(const NSString* fileName) {
    
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];

    return [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
}

NSString* getLibraryFilePath(const NSString* fileName){
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library"];
    return [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
}


NSString* getImageFilePath(const NSString* fileName) {
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
    return [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
}


NSString* getResourcePath(NSString* basePath, NSString* resName, NSString* resType) {
    NSString* path = [NSString pathWithComponents:[NSArray arrayWithObjects:basePath, resName, nil]];
    return [[NSBundle mainBundle] pathForResource:path ofType:resType];
}

NSURL* getResourceUrl(NSString* basePath, NSString* resName, NSString* resType) {
    NSString* path = [NSString pathWithComponents:[NSArray arrayWithObjects:basePath, resName, nil]];
    return [[NSBundle mainBundle] URLForResource:path withExtension:resType];
}

BOOL checkFileIsExsis(NSString *filePath){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        return YES;
    }else{
        return NO;
    }
}


NSString *getVideoPath(){
    NSString *path=getDocumentsFilePath(@"/Video/");
    if(![path hasSuffix:@"/"]){
        path=[path stringByAppendingString:@"/"];
    }
    checkPathAndCreate(path);
    return path;
}

NSString *getTempVideoPath(){
    NSString *path=getDocumentsFilePath(@"/VideoTemp/");
    if(![path hasSuffix:@"/"]){
        path=[path stringByAppendingString:@"/"];
    }
    checkPathAndCreate(path);
    return path;
}

NSString *getVideoNameByURL(NSString *videoUrl,BOOL istemp){
    if (videoUrl) {
        if(videoUrl==nil || ![videoUrl hasPrefix:@"http://"]){
            return videoUrl;
        }
       // WSLog(@"%@",videoUrl);
        
        if(istemp){
            return [NSString stringWithFormat:@"%@/%@.temp",getVideoPath(),md5(videoUrl)];
        }else{
            return [NSString stringWithFormat:@"%@/%@.mp4",getVideoPath(),md5(videoUrl)];
        }
    }
    return nil;
}

BOOL checkPathAndCreate(NSString *filePath){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        return YES;
    }else{
        return [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

BOOL checkFileAndCreate(NSString *filePath){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        return YES;
    }else{
        return [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
}

BOOL checkIsURL(NSString* str){
    
    if (isEmpty(str)) {
        return NO;
    }
    
    //str = [str lowercaseString];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",str];
    NSArray *blankSpace = [urlStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([urlStr isMatchedByRegex:regrexUrl] && [NSURL URLWithString:urlStr] && ([blankSpace count]==1)) {
        return YES;
    }
    return NO;
}

NSString* doParseURL(NSString *url){
    
    //url = [url lowercaseString];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *strURL = nil;
    
    if (!isEmpty(url)) {//判断url字符串不为空
        
        if ([url isMatchedByRegex:regrexUrl] && [NSURL URLWithString:url]) {//判断是否为url格式
            
            NSRange range_http1 = [url rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
            NSRange range_http2 = [url rangeOfString:@"http:/" options:NSCaseInsensitiveSearch];
            NSRange range_http3 = [url rangeOfString:@"http:" options:NSCaseInsensitiveSearch];
            NSRange range_https1 = [url rangeOfString:@"https://" options:NSCaseInsensitiveSearch];
            NSRange range_https2 = [url rangeOfString:@"https:/" options:NSCaseInsensitiveSearch];
            NSRange range_https3 = [url rangeOfString:@"https:" options:NSCaseInsensitiveSearch];
//            WSLog(@"range_http ===location===%d length===%d",range_http1.location,range_http1.length);
//            WSLog(@"range_https ===location===%d length===%d",range_https1.location,range_https1.length);
            if ((range_http1.location == 0) ||
                (range_http2.location == 0) ||
                (range_http3.location == 0) ||
                (range_https1.location == 0) ||
                (range_https2.location == 0) ||
                (range_https3.location == 0)) {
                strURL = url;
            }else{
                strURL = [NSString stringWithFormat:@"http://%@",url];
            }
        }
    }
    return strURL;
}
/**Author:窦静轩 Description:时间转换成字符串 年-月-日*/
NSString * dateTransformStringAsYMD(NSDate*date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [dateFormatter stringForObjectValue:date];
    return dateString;
}

NSString * dateTransformStringAsYMDByFormate(NSDate*date,NSString *formate)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formate];
    NSString * dateString = [dateFormatter stringForObjectValue:date];
    return dateString;
}
/**Author:窦静轩 Description:时间转换成字符串*/
NSString * dateTransformStringAsYMDHM(NSDate*date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //    NSString * dateString = [[NSString alloc] init];
    NSString * dateString = [dateFormatter stringForObjectValue:date];
    return dateString;
}
/**Author:窦静轩 Description:时间转换成字符串*/
NSString * dateTransformStringAsYMDHMS(NSDate*date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //    NSString * dateString = [[NSString alloc] init];
    NSString * dateString = [dateFormatter stringForObjectValue:date];
    return dateString;
}

NSString * dateTransformString(NSString* fromate,NSDate*date){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromate];
    //    NSString * dateString = [[NSString alloc] init];
    NSString * dateString = [dateFormatter stringForObjectValue:date];
    return dateString;
}
NSString * longdateTransformString(NSString* fromate,long long longdate){
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:longdate/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromate];
    //    NSString * dateString = [[NSString alloc] init];
    NSString * dateString = [dateFormatter stringForObjectValue:date];
    return dateString;
}

NSDate * stringFormateDate(NSString * stringDate){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:stringDate];
    return dateFromString;
}

NSDate * stringFormateDateWithFormate(NSString *formate,NSString * stringDate){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:formate];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:stringDate];
    return dateFromString;
}




NSString *intervalSinceNow(NSString *theDate){
    NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
    theDate=[timeArray objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        if([timeString isEqualToString:@"0"]){
            timeString=[NSString stringWithFormat:@"刚刚"];
        }else{
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
        
    }else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }else if (cha/86400>1 && cha/86400<=7)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }else if(dat.year-d.year==0){
        // 同一年
        timeString=dateTransformStringAsYMDByFormate(d,@"MM月dd日 HH:mm");
    }else{
        timeString=dateTransformStringAsYMDByFormate(d,@"yyyy-MM-dd");//[NSString stringWithFormat:@"%@",theDate];
    }
    return timeString;
}

NSString *intervalSinceNowFormat(NSString *theDate){
    NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
    theDate=[timeArray objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        if([timeString isEqualToString:@"0"]){
            timeString=[NSString stringWithFormat:@"刚刚"];
        }else{
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
    }else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }else if (cha/86400>1 && cha/86400<=7)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }else{
        timeString=dateTransformStringAsYMDByFormate(d,@"yyyy/MM/dd");//[NSString stringWithFormat:@"%@",theDate];
    }
    return timeString;
}

NSString *intervalSinceNowByDate(NSDate *theDate){
    NSTimeInterval late=[theDate timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        if([timeString isEqualToString:@"0"]){
            timeString=[NSString stringWithFormat:@"刚刚"];
        }else{
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
        
    }else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }else if (cha/86400>1 && cha/86400<=7)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }else{
        timeString=dateTransformString(@"MM-dd yyyy",theDate);
    }
    
    return timeString;
}

NSString * intervalFromLastDate(NSString * dateString1,NSString * dateString2){
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    
    
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    
    //    NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    
    
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    
    
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    NSString *min=@"";
    NSString *sen=@"";
    
    sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    // min = [min substringToIndex:min.length-7];
    // 秒
    sen=[NSString stringWithFormat:@"%@", sen];
    
    
    
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    // min = [min substringToIndex:min.length-7];
    // 分
    min=[NSString stringWithFormat:@"%@", min];
    
    
    // 小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    // house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    
    
    timeString=[NSString stringWithFormat:@"%@:%@:%@",house,min,sen];
    
    
    return timeString;
}

int calculateMinutesFromDate(NSDate *date1 ,NSDate *date2){
    NSTimeInterval late=[date1 timeIntervalSince1970]*1;
    
    
    NSTimeInterval now=[date2 timeIntervalSince1970]*1;

    NSTimeInterval cha=now-late;
    
    return (int)cha/60;
}


NSString * getDateTimeFromLongMilliSeconds(long long miliSeconds,NSString *formate){
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli;///1000.0;
    
    NSDate *d=[NSDate dateWithTimeIntervalSince1970:seconds];
    return dateTransformString(formate, d);
}


NSString * filterHTML(NSString *html){
    html=[html stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    html=[html stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    html=[html stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    html=[html stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];
    html=[html stringByReplacingOccurrencesOfRegex:@"<([^>]*)br([^>]*)>" withString:@"\n"];
    html=[html stringByReplacingOccurrencesOfRegex:@"<([^>]*)BR([^>]*)>" withString:@"\n"];
    
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    
    return html;
}


NSString * writeDataToFile(NSData *data,NSString *path,int length){
    if(is_null(path)){
        path=getTmpDownloadFilePath(@"temp.mp4");
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *fileData=data;
    if(length>0){
        long datasize=data.length;
        fileData=[data subdataWithRange:NSMakeRange(length, datasize-length)];
    }
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
        
    }
    [fileData writeToFile:path atomically:YES];
    
    return path;
}

BOOL deleteFileByPath(NSString *path){
    if(is_null(path)){
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        return [fileManager removeItemAtPath:path error:nil];
    }
    return NO;
}


float getTotalDiskspace(int type){
    float totalSpace=0.0;
    float totalFreeSpace = 0.0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];//共使用的容量
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];//剩余容量
    }
    if(type==1){
        return totalSpace;
    }else if(type==2){//使用大小
        return totalSpace-totalFreeSpace;
    }else{ //剩余空间
        return totalFreeSpace;
    }
}


