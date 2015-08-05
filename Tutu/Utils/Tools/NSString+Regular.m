//
//  NSString+Regular.m
//  CustomView
//
//  Created by zhangxinyao on 15-4-8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NSString+Regular.h"


@implementation NSString(Regular)

-(NSMutableAttributedString *) stringToAttributedString{
    return [self stringToAttributedString:nil textColor:nil];
}
-(NSMutableAttributedString *) stringToAttributedString:(NSMutableDictionary *)dict textColor:(UIColor *)color{
    NSString *replace=[self stringByReplacingOccurrencesOfString:@"<atuser>" withString:@"@"];
    replace=[replace stringByReplacingOccurrencesOfString:@"</atuser>" withString:@""];
    
    NSMutableDictionary *defaultAttributes = [self defaultAttributes];
    
    NSMutableAttributedString *attr=[[NSMutableAttributedString alloc] initWithString:replace];
    if(color!=nil){
        [attr beginEditing];
        [attr addAttributes:[self defaultAttributesWithColor:color] range:NSMakeRange(0, replace.length)];
        [attr endEditing];
    }
    
    if(dict!=nil){
        [attr beginEditing];
        for (NSString *item in dict.allKeys) {
            NSString *value=[NSString stringWithFormat:@"@%@",item];
            NSRange range=[replace rangeOfString:value];
            if(range.location!=NSNotFound){
                [attr addAttributes:defaultAttributes range:range];
            }
        }
        [attr endEditing];
    }
    
    
    [attr beginEditing];
    [self getSpecialRangeText:self arr:attr paramDict:dict];
    [attr endEditing];
    
    
    NSError *err = nil;
    // 替换掉atuser后的text
    NSRegularExpression *regex = [self getRegexWithTopic:err];
     NSArray *matches = [regex matchesInString:replace options:0 range:NSMakeRange(0, replace.length)];
    [attr beginEditing];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[replace substringWithRange:wordRange];
        
        if(dict!=nil){
            [dict setObject:@"2" forKey:key];
        }
        [attr addAttributes:defaultAttributes range:wordRange];
    }
    [attr endEditing];
    
    // 替换掉atuser后的text
    // 修改的@xxxx
//    err=nil;
//    regex = [self getRegexWithAtUser:err];
//    matches = [regex matchesInString:replace options:0 range:NSMakeRange(0, replace.length)];
//    [attr beginEditing];
//    for (NSTextCheckingResult *match in matches) {
//        NSRange wordRange = match.range;
//        
//        if(dict!=nil){
//            [dict setObject:@"1" forKey:[[replace substringWithRange:wordRange] stringByReplacingOccurrencesOfString:@"@" withString:@""]];
//        }
//        [attr addAttributes:defaultAttributes range:wordRange];
//    }
//    [attr endEditing];
    
    
    //替换atuser之前的text,需要减位置
//    regex = [self getRegexWithNickName:err];
//    matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
//    [attr beginEditing];
//    int len=0;
//    int startRange=0;
//    for (NSTextCheckingResult *match in matches) {
//        NSRange range=match.range;
//        startRange=startRange+14;
//        len=14;
//        
//        NSString* atString = [self substringWithRange:range];
//        atString=[atString stringByReplacingOccurrencesOfString:@"<atuser>" withString:@"@"];
//        atString=[atString stringByReplacingOccurrencesOfString:@"</atuser>" withString:@""];
//        //匹配一次正则，减少15个字符
//        if(startRange==14){
//            range=NSMakeRange(range.location, range.length-len);
//        }else{
//            range=NSMakeRange(range.location-startRange, range.length-len);
//        }
//        //        NSLog(@"%@",atString);
//        // 保存名称
//        if(dict!=nil){
//            [dict setObject:@"1" forKey:[atString stringByReplacingOccurrencesOfString:@"@" withString:@""]];
//        }
//        [attr addAttributes:defaultAttributes range:range];
//    }
//    
//    [attr endEditing];
    
    return attr;
}



-(void)getSpecialRangeText:(NSString*)message arr:(NSMutableAttributedString *)attr paramDict:(NSMutableDictionary *) dict
{
    NSRange range=[message rangeOfString:@"<atuser>"];
    NSRange range1=[message rangeOfString:@"</atuser>"];
    
    NSUInteger len=0;
    //判断当前字符串是否还有表情的标志。
    if (range.length&&range1.length) {
        len=range1.location-(range.location+8);
        NSString *subString=[message substringWithRange:NSMakeRange(range.location+8, len)];
        
        if(dict!=nil){
            [dict setObject:@"1" forKey:subString];
        }
        
        //替换进行下一次查询
        message=[message stringByReplacingCharactersInRange:range1 withString:@""];
        message=[message stringByReplacingCharactersInRange:range withString:@"@"];
        
        //匹配一次正则，因为多了一个@字符
        range=NSMakeRange(range.location, len+1);
        [attr addAttributes:[self defaultAttributes] range:range];
        
        [self getSpecialRangeText:message arr:attr paramDict:dict];
    }
}


- (NSMutableDictionary *)defaultAttributes
{
    return [@{NSForegroundColorAttributeName:UIColorFromRGB(DrakGreenNickNameColor)}mutableCopy];
}
- (NSMutableDictionary *)defaultAttributesWithColor:(UIColor *) color
{
    if(color==nil){
        return [@{NSForegroundColorAttributeName:UIColorFromRGB(TextBlackColor)}mutableCopy];
    }
    return [@{NSForegroundColorAttributeName:color}mutableCopy];
}


- (NSMutableDictionary *)highlightedAttributes
{
    return [@{NSForegroundColorAttributeName:[UIColor grayColor]}mutableCopy];
}

-(NSRegularExpression *)getRegexWithNickName:(NSError *)error{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<atuser>([^\\#|.]+)</atuser>" options:0 error:&error];
    return regex;
}

-(NSRegularExpression *)getRegexWithTopic:(NSError *)error{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#([^\\s]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    return regex;
}



-(NSRegularExpression *)getRegexWithAtUser:(NSError *)error{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@([\\u4e00-\\u9fa5\\w\\-]+)" options:0 error:&error];
    return regex;
}

@end
