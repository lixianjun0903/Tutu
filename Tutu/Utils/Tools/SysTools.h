//
//  SysTools.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "RCIMClientHeader.h"

@interface SysTools : NSObject

//空对象转行成@""

+(NSString *)covertToString:(id)object;
/**Author:Ronaldo Description:从本地NSUserDefaults取出值*/
+(id)getValueFromNSUserDefaultsByKey:(NSString*)key;

/**Author:Ronaldo Description:同步NSUserDefaults数据*/
+(void)syncNSUserDeafaultsByKey:(NSString*)key withValue:(id)value;

+(void)removeNSUserDeafaultsByKey:(NSString*)key;

//显示图片
+(UIImage *) getImageWithName:(NSString *)imagePathName;

//写图片到沙盒中，返回图片路径
+(NSString *)writeImageToDocument:(UIImage *) img fileName:(NSString *) name;

+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;


+(UIColor *)getCommentColor:(NSString *) bgName;


+(NSString *) getDeviceId;
+(NSString *) getDeviceVersion;
+(NSString *) getAppVersion;
+(NSString *) getAppBuildVersion;
+(int)getSystemVerson;
+(NSString *)getDeviceName;


+(UIImage *)getFaceImage:(NSString *) faceName;
+(NSMutableArray *)getImageRange:(NSString*)message;
+(UIView *)assembleMessageAtIndex:(NSArray *)arr maxWidth:(CGFloat ) width color:(UIColor *)textColor;
+(UIView *)assembleMessageWithMessage:(NSString *)message maxWidth:(CGFloat ) width color:(UIColor *) textColor;


+(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width;

+(CGFloat)getWidthContain:(NSString *)string font:(UIFont *)font Height:(CGFloat) height;

+(CGRect)rectWidth:(NSString*)string FontSize:(CGFloat)font size:(CGSize)size;


+(int)getAgeByBirthday:(NSString *) birthday;

+(NSString *)getHeaderImageURL:(NSString *)uid time:(NSString *)avatartime;
+(NSString *)getBigHeaderImageURL:(NSString *)uid time:(NSString *)avatartime;

+(NSString*) replaceUnicode:(NSString*)aUnicodeString;

+(NSString *) utf8ToUnicode:(NSString *)string;
+ (UIImage *) createImageWithColor: (UIColor *) color;


+ (NSURL *)getEmotionURL:(NSString *)path;
+ (void)getEmotionImage:(NSString *)path imageView:(UIImageView *)imageView;
+ (void)getEmotionImage:(NSString *)path button:(UIButton *)button;
+(BOOL) APCheckIfAppInstalled2:(NSString *)urlSchemes;

//计算文件夹下文件的总大小
+(long)fileSizeForDir:(NSString*)path;
//音效开/关
+(BOOL)isCloseSoundEffect;
//设置音效开/关
+(void)setSoundEffectClose:(BOOL)open;
//播放声音
+(void)playerSoundWith:(NSString *)soundName;

//推送通知振动/
+(BOOL)isNotificationShakeing;
//推送通知振动设置开/关
+(void)setNotificationShakeing:(BOOL)shake;

//设置推送通知音效开/关
+(void)setNotificationSoundOpen:(BOOL)shake;
//推送通知音效
+(BOOL)isNotificationSoundOpen;
+(void)clearAvatar;


+(AppDelegate *) getApp;
//检测定位服务是否可用
+(BOOL)isLocatonServicesAvailable;

//检测是否有相机的权限
+(BOOL)isHasCaptureDeviceAuthorization;

//检查是否有相册的权限
+(BOOL)isHasPhotoLibraryAuthorization;

//获取wav格式的设置
+ (NSDictionary*)getAudioRecorderSettingDict;

+(NSDictionary *)getRecorderSettingDict;


//获取消息中的昵称
+(NSString *)getNicknameByExtra:(RCConversation *) item objectName:(NSString *)objName;

//判断当前消息，是否显示
+(BOOL)checkItemIsBlock:(RCMessage *) item;

// 当前消息不能发送，如果不是我自己，就不显示
+(BOOL)getMessageBeSendValue:(RCMessage *) item;

//图形转换
+(void)transferView:(UIView *)imageView scaleNum:(CGFloat)scale;

//获得手机的全部存储空间,单位兆
+(CGFloat)getTotalSpace;
//获得手机的剩余空间，单位兆
+(CGFloat)getFreeSpace;
//获得手机的已使用的空间，单位兆
+ (CGFloat)getUsedSpace;

@end
