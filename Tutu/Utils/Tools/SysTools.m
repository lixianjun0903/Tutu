//
//  SysTools.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SysTools.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "MobClick.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation SysTools

+(NSString *)covertToString:(id)object{
    if ([object isKindOfClass:[NSNull class]]) {
        return @"";
    }else if(!object){
        return @"";
    }else if([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }else{
        return [NSString stringWithFormat:@"%@",object];
    }
}
/**Author:Ronaldo Description:从本地NSUserDefaults取出值*/
+(id)getValueFromNSUserDefaultsByKey:(NSString*)key
{
    if (key) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        id obj = [defaults objectForKey:key];
        return obj;
    }
    return nil;
}

/**Author:Ronaldo Description:同步NSUserDefaults数据*/
+(void)syncNSUserDeafaultsByKey:(NSString*)key withValue:(id)value
{
    if (key && value) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:value forKey:key];
        [defaults  synchronize];
    }
}

+(void)removeNSUserDeafaultsByKey:(NSString*)key{
    if (key) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:key];
        [defaults  synchronize];
    }
}


+(UIImage *)getImageWithName:(NSString *)imagePathName{
    NSString *pathimg=getDocumentsFilePath([NSString stringWithFormat:@"images/%@",imagePathName]);
    //判断是否在沙盒中
    if(checkFileIsExsis(pathimg)){
        //因为拿到的是个路径 把它加载成一个data对象
        NSData*data=[NSData dataWithContentsOfFile:pathimg];
        //直接把该图片读出来
        UIImage*img=[UIImage imageWithData:data];
        return img;
    }
    return [UIImage imageNamed:imagePathName];
}

+(NSString *)writeImageToDocument:(UIImage *)image fileName:(NSString *)name{
    NSString *docDir = getDocumentsFilePath(@"/images/");
    if(!checkFileIsExsis(docDir)){
        [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
//    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir,name];
//    NSData *data1 = [NSDatadataWithData:UIImagePNGRepresentation(image)];
//    [data1 writeToFile:pngFilePath atomically:YES];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@",docDir,name];
    
    
    NSData *data2 = nil;
    
    
    //图片缩放系数，缩放到最小边为640
    
    if(image.size.width!=image.size.height){
        CGFloat scale=1.0f;
        CGFloat minSize=image.size.width<image.size.height?image.size.width:image.size.height;
        scale=640/minSize;
        UIImage *scaleImage=[self scaleToSize:image size:CGSizeMake(image.size.width*scale, image.size.height*scale)];
        data2 = [NSData dataWithData:UIImageJPEGRepresentation(scaleImage, 1.0f)];
    }else{
        
        //1.0f = 100%quality
        data2=[NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:jpegFilePath contents:data2 attributes:nil];
    return jpegFilePath;
}

+(void)checkUserInfo:(UserInfo *) user{
//    UserDBHelper *db=[[UserDBHelper alloc] init];
//    UserInfo *usermodel=[db findWithToken:user.token];
//    if(usermodel!=nil && [usermodel.uid intValue]>0){
//        [[UserModel shareUserModel] syncModel:usermodel];
//    }else{
//        [db saveUser:user];
//        usermodel=[db findWithToken:user.token];
//        [[UserModel shareUserModel] syncModel:usermodel];
//    }
}

+(UIColor *)getCommentColor:(NSString *)bgName{
    if(bgName){
        if([@"input_22_16_1" isEqual:bgName]){
            return [UIColor blackColor];
        }
        NSString *intPart=[[[bgName stringByReplacingOccurrencesOfString:@"input_0" withString:@""] stringByReplacingOccurrencesOfString:@".png" withString:@""] stringByReplacingOccurrencesOfString:@"input_" withString:@""];
        
        NSArray *strArr=[intPart componentsSeparatedByString:@"_"];
        if(strArr!=nil && strArr.count>=3){
            if([[strArr objectAtIndex:2] intValue]==1){
                return [UIColor whiteColor];
            }else{
                return [UIColor blackColor];
            }
        }
        
        int intValue=[intPart intValue];
        if((intValue>=5 && intValue <=8) || (intValue>=17 && intValue<=20) || (intValue>=25&&intValue<=28)|| (intValue>=33&&intValue<=36)){
            return [UIColor whiteColor];
        }
    }
    return [UIColor blackColor];
}

+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}


+(NSString *) getDeviceId{
    //获取设备id号
    UIDevice *device = [UIDevice currentDevice];//创建设备对象
    NSString *deviceUID = [[device identifierForVendor] UUIDString];
    return  deviceUID;
    
}

+(NSString *) getDeviceVersion{
    return [[UIDevice currentDevice] systemVersion];
}
+(NSString *) getAppVersion{
    //WSLog(@"%@",[[NSBundle mainBundle] infoDictionary]);
    //kCFBundleVersionKey 获取build的值
    //CFBundleShortVersionString 获取version的值
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+(NSString *) getAppBuildVersion{
    //WSLog(@"%@",[[NSBundle mainBundle] infoDictionary]);
    //kCFBundleVersionKey 获取build的值
    //CFBundleShortVersionString 获取version的值
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return version;
}

+(int)getSystemVerson
{
    int strin=[[[UIDevice currentDevice] systemVersion] intValue];
    return strin;
}

+(NSString*)getDeviceName
{
    NSString * device=[[NSString alloc]init];
    if ([[[UIDevice currentDevice] model]isEqualToString:@"iPad Simulator"]||[[[UIDevice currentDevice] model]isEqualToString:@"iPad"]) {
        device=@"iPad";
    }
    else
    {
        device=@"iPhone";
    }
    return device;
}


#pragma 表情方法
+(UIImage *)getFaceImage:(NSString *)faceName{
    if(isEmpty(faceName)){
        return nil;
    }
    NSDictionary *_faceMap = [NSDictionary dictionaryWithContentsOfFile:
                 [[NSBundle mainBundle] pathForResource:@"_expression_cn"
                                                 ofType:@"plist"]];
    UIImage *img=nil;
    for (NSString *key in _faceMap.allKeys) {
        if([faceName isEqual:[_faceMap objectForKey:key]]){
            img = [UIImage imageNamed:key];
            break;
        }
    }
    return img;
}




//解析输入的文本，根据文本信息分析出那些是表情，那些是文字。
+(NSMutableArray *)getImageRange:(NSString*)message
{
    NSMutableArray *array=[NSMutableArray array];
    NSRange range=[message rangeOfString:@"["];
    NSRange range1=[message rangeOfString:@"]"];
    //判断当前字符串是否还有表情的标志。
    if (range.length&&range1.length) {
        if (range.location>0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return array;
            }
        }
    }else if(message!=nil){
        [array addObject:message];
    }
    return array;
}

+(UIView *)assembleMessageAtIndex:(NSArray *)arr maxWidth:(CGFloat)width color:(UIColor *)textColor
{
#define KFacialSizeWidth 25
#define KFacialSizeHeight 25
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    [returnView setBackgroundColor:[UIColor clearColor]];
    NSArray *data = arr;
    //  UIFont *fon=[UIFont systemFontOfSize:14.0f];
    
    CGFloat upX=0;
    CGFloat upY=0;
    if (data) {
        for (int i=0;i<[data count];i++) {
            NSString *str=[data objectAtIndex:i];
            if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"])
            {
                if (upX > (width - KFacialSizeWidth))
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                }
                UIImage *image=[self getFaceImage:str];
                UIImageView *img=[[UIImageView alloc] initWithImage:image];
                [img setBackgroundColor:[UIColor clearColor]];
                [img setContentMode:UIViewContentModeScaleAspectFit];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth-1, KFacialSizeHeight-1);
                [returnView addSubview:img];
                
                upX=KFacialSizeWidth+upX;
            }else
            {
                for (int j = 0; j<[str length]; j++)
                {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if([str length]-j>1){
                        NSString *temp2 = [str substringWithRange:NSMakeRange(j, 2)];
                        if([self stringContainsEmoji:temp2]){
                            temp=temp2;
                            j=j+1;
                        }
                    }
                    
                    CGSize size=[temp sizeWithFont:FONT_CHAT constrainedToSize:CGSizeMake(width, 40)];
                    if (upX > (width-size.width))
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                    }
                    
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX, upY,size.width,KFacialSizeHeight)];
                    la.font = FONT_CHAT;
                    la.text = temp;
                    if(textColor!=nil){
                        [la setTextColor:textColor];
                    }
                    [la setBackgroundColor:[UIColor clearColor]];
                    [returnView addSubview:la];
                    upX=upX+size.width;
                }
            }
        }
        
        if(upX>0){
            upY=upY+KFacialSizeHeight;
            if(upY==KFacialSizeHeight){
                width=upX;
            }
        }
    }
    if(upX==0 && upY==0){
        width=0;
    }
    
    [returnView setFrame:CGRectMake(0, 0, width, upY)];
    return returnView;
}

/**
 * 检测是否有emoji字符
 * @param source
 * @return 一旦含有就抛出
 */

+(BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

+(UIView *)assembleMessageWithMessage:(NSString *)message maxWidth:(CGFloat)width color:(UIColor *)textColor{
    
    NSMutableArray *array = [self getImageRange:message];
    return [self assembleMessageAtIndex:array maxWidth:width color:textColor];
}

//解析输入的文本，根据文本信息分析出那些是表情，那些是文字。
+(void)getImageRange:(NSString*)message :(NSMutableArray*)array
{
    NSRange range=[message rangeOfString:@"["];
    NSRange range1=[message rangeOfString:@"]"];
    //判断当前字符串是否还有表情的标志。
    if (range.length&&range1.length) {
        if (range.location>0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
    }else {
        [array addObject:message];
    }
}
+(void)playerSoundWith:(NSString *)soundName{
    if ([SysTools isCloseSoundEffect]) {
        return;
    }
    SystemSoundID soundID;
    NSURL *filePath   = [[NSBundle mainBundle] URLForResource:soundName withExtension: @"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    
    AudioServicesPlaySystemSound(soundID);
}
//计算文件夹下文件的总大小
+(long)fileSizeForDir:(NSString*)path
{
    long size = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            [self fileSizeForDir:fullPath];
        }
    }
    return size;
}

+(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font}];
    CGSize contansize=CGSizeMake(width, CGFLOAT_MAX);
    if([self getSystemVerson]>=7){
        CGRect rec = [astr boundingRectWithSize:contansize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        return rec.size.height;
    }else{
        CGSize s=[string sizeWithFont:font constrainedToSize:contansize lineBreakMode:NSLineBreakByCharWrapping];
        return s.height;
    }
}

+(CGFloat)getWidthContain:(NSString *)string font:(UIFont *)font Height:(CGFloat) height
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName: font}];
    
    CGSize cs=CGSizeMake(CGFLOAT_MAX,height);
    if([SysTools getSystemVerson]<7){
        CGSize s=[string sizeWithFont:font constrainedToSize:cs lineBreakMode:NSLineBreakByCharWrapping];
        return s.width;
    }else{
        CGRect rec = [astr boundingRectWithSize:cs options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        CGSize size = rec.size;
        
        return size.width;
    }
}

+(CGRect)rectWidth:(NSString*)string FontSize:(CGFloat)font size:(CGSize)size
{
    CGRect labelRect ;
    labelRect = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil] context:nil];
    return labelRect;
}


+(int)getAgeByBirthday:(NSString *)birthday{
    if(birthday==nil || [@"" isEqual:birthday]){
        return 0;
    }
    NSDate *date = stringFormateDateWithFormate(@"yyyy-MM-dd",birthday);
    int age=trunc([date timeIntervalSinceNow]/(60*60*24))/365;
    if(age<=0){
        age=1;
    }
    return age;
}

+(NSString *)getHeaderImageURL:(NSString *)uid time:(NSString *)avatartime{
    return [NSString stringWithFormat:@"%@%@/%@/100",AVATARURL,uid,avatartime];
}

+(NSString *)getBigHeaderImageURL:(NSString *)uid time:(NSString *)avatartime{
    return [NSString stringWithFormat:@"%@%@/%@",AVATARURL,uid,avatartime];
}


//unicode的数据，转换为utf8
+(NSString*) replaceUnicode:(NSString*)aUnicodeString
{
    
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                           
                                                           mutabilityOption:NSPropertyListImmutable
                           
                                                                     format:NULL
                           
                                                           errorDescription:NULL];
    
    
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
}

+(void)transferView:(UIView *)imageView scaleNum:(CGFloat)scale {
    
//    if (degreen) {
//            float radian=(degreen*M_PI)/180;
////            imageView.transform=CGAffineTransformRotate(imageView.transform,radian);
//            imageView.transform=CGAffineTransformMake(1.0f, sin(radian), -sin(radian),1.0f, 0, 0);
//            imageView.transform=CGAffineTransformScale(imageView.transform, scale, scale);
//
//    }else
//    {
        imageView.transform=CGAffineTransformScale(imageView.transform, scale, scale);
//    }

    
    
}

//utf8的数据，转换为unicode
+(NSString *) utf8ToUnicode:(NSString *)string
{
    
    NSUInteger length = [string length];
    
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    
    for (int i = 0;i < length; i++)
        
    {
        
        unichar _char = [string characterAtIndex:i];
        
        //判断是否为英文和数字
        
        if (_char <= '9' && _char >= '0')
            
        {
            
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
            
        }
        
        else if(_char >= 'a' && _char <= 'z')
            
        {
            
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
            
            
            
        }
        
        else if(_char >= 'A' && _char <= 'Z')
            
        {
            
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
            
            
            
        }
        
        else
            
        {
            
            [s appendFormat:@"\\u%x",[string characterAtIndex:i]];
            
        }
        
    }
    
    return s;
    
}

+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSURL *)getEmotionURL:(NSString *)path{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png",EMOTIONURL,path]];
}
+ (void)getEmotionImage:(NSString *)path imageView:(UIImageView *)imageView{
    UIImage *image = [UIImage imageNamed:path];
    if (image) {
        imageView.image = image;
    }else{
        [imageView sd_setImageWithURL:[self getEmotionURL:path]];
    }
}
+ (void)getEmotionImage:(NSString *)path button:(UIButton *)button{
    UIImage *image = [UIImage imageNamed:path];
    if (image) {
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }else{
        [button sd_setBackgroundImageWithURL:[self getEmotionURL:path] forState:UIControlStateNormal];
    }
}

+(BOOL) APCheckIfAppInstalled2:(NSString *)urlSchemes
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchemes]])
    {
        //        NSLog(@" installed");
        
        return YES;
    }
    else
    {
        return NO;
    }
}


+(BOOL)isCloseSoundEffect
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SoundEffect"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"SoundEffect"] boolValue];
    }
    else
    {
        return FALSE;
    }
}
+(void)setSoundEffectClose:(BOOL)open
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",open] forKey:@"SoundEffect"];
}

+(void)setNotificationShakeing:(BOOL)shake
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",shake] forKey:@"notShakeing"];
}
+(BOOL)isNotificationShakeing
{
    BOOL notShaking;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"notShakeing"]) {
        notShaking = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notShakeing"] boolValue];
    }
    else
    {
        notShaking = FALSE;
    }
    return notShaking;
}


+(void)setNotificationSoundOpen:(BOOL)shake
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",shake] forKey:@"notificationSound"];
}

+(BOOL)isNotificationSoundOpen
{
    BOOL notSound;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"notificationSound"]) {
        notSound = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationSound"] boolValue];
    }
    else
    {
        notSound = TRUE;
    }
    return notSound;
}
+(void)clearAvatar
{
    UserInfo *info=[[LoginManager getInstance] getLoginInfo];
    [[SDImageCache sharedImageCache] removeImageForKey:[SysTools getHeaderImageURL:info.uid time:info.avatartime] fromDisk:YES];
}

+(AppDelegate *)getApp{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


+(BOOL)isLocatonServicesAvailable{
    CLAuthorizationStatus status =   [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorized || (status == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled])){
        return YES;
    }else
        return NO;
}
    
/**
 war获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}

+(NSDictionary *)getRecorderSettingDict{
    //wav格式
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 44100.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数默认 16
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端是内存的组织方式
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];//采样信号是整数还是浮点数
    return recordSetting;
}


+(NSString *)getExtraWith:(RCMessageContent *)content objectName:(NSString *) objectName{
    NSString *extra=@"";
    
    if(content==nil){
        return extra;
    }
    if([RCTextMessageTypeIdentifier isEqual:objectName]){
        RCTextMessage *msg=(RCTextMessage*)content;
        extra=msg.extra;
    }
    if([RCRichContentMessageTypeIdentifier isEqual:objectName]){
        RCRichContentMessage *msg=(RCRichContentMessage*)content;
        extra=[msg.extra JSONString];
    }
    if([RCVoiceMessageTypeIdentifier isEqual:objectName]){
        RCVoiceMessage *msg=(RCVoiceMessage*)content;
        extra=msg.extra;
    }
    if([RCImageMessageTypeIdentifier isEqual:objectName]){
        RCImageMessage *msg=(RCImageMessage*)content;
        extra=msg.extra;
    }
    return extra;
}

+(NSString *)getNicknameByExtra:(RCConversation *) item objectName:(NSString *)objName{
    NSString *nickName=@"";
    NSString *extra=[self getExtraWith:item.lastestMessage objectName:objName];
    
    if(extra!=nil && ![@"" isEqual:extra]){
        @try {
            NSDictionary *msgDict=nil;
            if([extra isKindOfClass:[NSDictionary class]]){
                msgDict=[[extra JSONString] objectFromJSONString];
            }else{
                msgDict=[extra objectFromJSONString];
            }
            if([[[LoginManager getInstance] getUid] isEqual:item.senderUserId]){
                nickName=[msgDict objectForKey:@"nickname"];
            }else{
                nickName=CheckNilValue([msgDict objectForKey:@"sendername"]);
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return nickName;
}

//验证当前item是否被屏蔽后发送
+(BOOL)checkItemIsBlock:(RCMessage *) item{
    NSString *extra=[self getExtraWith:item.content objectName:item.objectName];
    
    if(extra!=nil && ![@"" isEqual:extra]){
        @try {
            NSDictionary *msgDict=nil;
            if([extra isKindOfClass:[NSDictionary class]]){
                msgDict=[[extra JSONString] objectFromJSONString];
            }else{
                msgDict=[extra objectFromJSONString];
            }
            NSString *canchat=[msgDict objectForKey:@"canchat"];
            // 当前消息不能发送，如果不是我自己，就不显示
            if(canchat!=nil && [@"0" isEqual:canchat] && ![item.senderUserId isEqual:[[LoginManager getInstance] getUid]]){
                return YES;
            }
            
            // 这条消息不应该在新版本显示
            NSString *dodelete=[msgDict objectForKey:@"dodelete"];
            if(dodelete!=nil && [@"1" isEqual:dodelete]){
                return YES;
            }
            
            // 当前消息被屏蔽了，如果发送者不是我自己，就不显示
            NSString *block=[msgDict objectForKey:@"isblock"];
            if([@"1" isEqual:block] && ![item.senderUserId isEqual:[[LoginManager getInstance] getUid]]){
                return YES;
            }else{
                return NO;
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return NO;
}
+(BOOL)getMessageBeSendValue:(RCMessage *)item{
    if(item==nil){
        return NO;
    }
    NSString *extra=@"";
    if([RCTextMessageTypeIdentifier isEqual: item.objectName]){
        RCTextMessage *msg=(RCTextMessage*)item.content;
        extra=msg.extra;
    }
    if([RCRichContentMessageTypeIdentifier isEqual: item.objectName]){
        RCRichContentMessage *msg=(RCRichContentMessage*)item.content;
        extra=[msg.extra JSONString];
    }
    if([RCVoiceMessageTypeIdentifier isEqual: item.objectName]){
        RCVoiceMessage *msg=(RCVoiceMessage*)item.content;
        extra=msg.extra;
    }
    if([RCImageMessageTypeIdentifier isEqual: item.objectName]){
        RCImageMessage *msg=(RCImageMessage*)item.content;
        extra=msg.extra;
    }
    if(extra!=nil && ![@"" isEqual:extra]){
        NSDictionary *msgDict=nil;
        if([extra isKindOfClass:[NSDictionary class]]){
            msgDict=[[extra JSONString] objectFromJSONString];
        }else{
            msgDict=[extra objectFromJSONString];
        }
        NSString *canchat=[msgDict objectForKey:@"canchat"];
        // 当前消息不能发送，如果不是我自己，就不显示
        if(canchat!=nil && [@"0" isEqual:canchat]){
            return YES;
        }
    }
    return NO;
}

//检查是否有相册的权限
+(BOOL)isHasPhotoLibraryAuthorization{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}
//检测是否有相机的权限
+(BOOL)isHasCaptureDeviceAuthorization{
    if (iOS7) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            return NO;
        }
        return YES;
    }else{
        return YES;
    }
    
}
//获得手机的全部存储空间,单位兆
+(CGFloat)getTotalSpace{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    return [totalSpace longLongValue] / 1024.f / 1024.f;
}
//获得手机的剩余空间，单位兆
+(CGFloat)getFreeSpace{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    return [freeSpace longLongValue] / 1024.f / 1024.f;
}
//获得手机的已使用的空间，单位兆
+ (CGFloat)getUsedSpace{
    CGFloat tottal = [SysTools getTotalSpace];
    CGFloat free = [SysTools getFreeSpace];
    return tottal - free;
}


@end
