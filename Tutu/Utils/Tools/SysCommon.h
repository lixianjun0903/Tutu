//
//  SysCommon.h
//  InversionClass
//
//  Created by 张 新耀 on 13-8-27.
//  Copyright (c) 2013年 张 新耀. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSDate* parseDateFromNSNumber(NSNumber* number);

extern BOOL parseBoolFromString(NSString* boolValue);

/**
 * extract the file name from path
 *
 **/
NSString* extractFileNameFromPath(NSString* path);


/**
 *  get the Tmp path of download file
 *
 ***/
NSString* getTmpDownloadFilePath(NSString* filePath);

/**
 *  get cache file path
 ***/
NSString* getCacheFilePath(NSString* cacheKey);

/**
 * do md5 hash
 ***/
NSString* md5(NSString* input);

NSString* trimString (NSString* input);

BOOL is_null(id object);

BOOL isEmpty(NSString* str);

id defaultNilObject(id object);

NSString* defaultEmptyString(id object);

BOOL validateEmail(NSString* email);
BOOL validateMobile(NSString* mobile);
BOOL validateQQNumber(NSString *qqNumber);
BOOL validateNickName(NSString *nickname);
BOOL validatePassword(NSString *password);
BOOL validdatePinYin(NSString *pinYin);

//计算text的长度，英文算1个，汉字算2个
int getStringCharCount(NSString *text);


NSString* convertToHexStr(const char* buffer, int length);

int convertStingEncoding(const char* toEncoding, const char* fromEncoding,
                         const char* inBuffer, size_t* inBufferSize,
                         char* outBuffer, size_t* outBufferSize);


NSString* convertCharStrToUTF8(const char* inBuffer, size_t inBufferSize);


NSString * getLibraryVideoPath();

NSString* getDocumentsFilePath(const NSString* fileName);

//获取Library路径
NSString* getLibraryFilePath(const NSString* fileName);

NSString* getImageFilePath(const NSString* fileName);

NSString* getResourcePath(NSString* basePath, NSString* resName, NSString* resType);

NSURL* getResourceUrl(NSString* basePath, NSString* resName, NSString* resType);

BOOL checkFileIsExsis(NSString *filePath);

//获取系统视频路径
NSString * getVideoPath();
NSString * getTempVideoPath();

NSString *getVideoNameByURL(NSString *videoUrl,BOOL istemp);

//检查路径，没有就创建路径
BOOL checkPathAndCreate(NSString *path);

//检查路径文件，没有就创建路径和文件
BOOL checkFileAndCreate(NSString *filePath);

/**
 * parse URL www.baidu.com to http://www.baidu.com
 ***/

BOOL checkIsURL(NSString* str);
NSString* doParseURL(NSString *url);


NSString * dateTransformStringAsYMD(NSDate*date);
NSString * dateTransformStringAsYMDByFormate(NSDate*date,NSString *formate);
NSString * dateTransformStringAsYMDHM(NSDate*date);
NSString * dateTransformStringAsYMDHMS(NSDate*date);
NSString * dateTransformString(NSString* fromate,NSDate*date);
NSString * longdateTransformString(NSString* fromate,long long date);

NSDate * stringFormateDate(NSString * stringDate);
NSDate * stringFormateDateWithFormate(NSString *formate,NSString * stringDate);

/**
 *计算时间差
 */
NSString * intervalSinceNow(NSString *theDate);
NSString *intervalSinceNowFormat(NSString *theDate);
NSString * intervalSinceNowByDate(NSDate *theDate);
NSString * intervalFromLastDate(NSString * dateString1,NSString * dateString2);


NSString * getDateTimeFromLongMilliSeconds(long long miliSeconds,NSString *formate);

int calculateMinutesFromDate(NSDate *date1 ,NSDate *date2);


NSString * filterHTML(NSString *html);

//去掉加密文件
NSString * writeDataToFile(NSData *data,NSString *path,int length);

//删除未加密文件
BOOL deleteFileByPath(NSString *path);


// 获取空间大小 1/总大小 2/使用大小   其它，剩余空间
// 转M，/1024.0/1024.0
float getTotalDiskspace(int type);

