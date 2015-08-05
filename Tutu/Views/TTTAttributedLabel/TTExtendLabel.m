//
//  TTExtendLabel.m
//  CustomView
//
//  Created by zhangxinyao on 15-4-9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TTExtendLabel.h"

#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression,regex,option) \
\
static inline NSRegularExpression * k##regularExpression() { \
static NSRegularExpression *_##regularExpression = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil];\
});\
\
return _##regularExpression;\
}\


#define REGULAREXPRESSION(regularExpression,regex) REGULAREXPRESSION_OPTION(regularExpression,regex,NSRegularExpressionCaseInsensitive)


REGULAREXPRESSION(URLRegularExpression,@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")

REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}")

REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")

//REGULAREXPRESSION(AtRegularExpressionStart, @"<atuser>")
//REGULAREXPRESSION(AtRegularExpressionEnd, @"</atuser>")
REGULAREXPRESSION(AtRegularExpression, @"<atuser>([^\\#|.]+)</atuser>")

//@"#([^\\#|.]+)#"
//REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)", NSRegularExpressionCaseInsensitive)
REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"#{1}(\\S*)\\s{1}", NSRegularExpressionCaseInsensitive)

const CGFloat kLineSpacing = 4.0;
const CGFloat kAscentDescentScale = 0.25; //在这里的话无意义，高度的结局都是和宽度一样

#define kEmojiReplaceCharacter @"\uFFFC"

#define kURLActionCount 5
NSString * const kURLActions[] = {@"url->",@"phoneNumber->",@"email->",@"at->",@"poundSign->"};

@interface TTExtendLabel()<TTTAttributedLabelDelegate>



@end

@implementation TTExtendLabel
#pragma mark - 初始化和TTT的一些修正
/**
 *  TTT很鸡巴。commonInit是被调用了两回。如果直接init的话，因为init其中会调用initWithFrame
 *  PS.已经在里面把init里的修改掉了
 */
- (void)commonInit {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    
    self.delegate = self;
    self.numberOfLines = 0;
    self.font = [UIFont systemFontOfSize:14.0];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    
    /**
     *  PS:这里需要注意，TTT里默认把numberOfLines不为1的情况下实际绘制的lineBreakMode是以word方式。
     *  而默认UILabel似乎也是这样处理的。我不知道为何。已经做修改。
     */
    self.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.textInsets = UIEdgeInsetsZero;
    self.lineHeightMultiple = 1.0f;
    self.lineSpacing = kLineSpacing; //默认行间距
    self.isNeedAtAndPoundSign = YES;
    self.disableThreeCommon =YES; //默认不匹配连接
    
    [self setValue:[NSArray array] forKey:@"links"];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableInactiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableInactiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    // 连接的颜色
    UIColor *commonLinkColor = UIColorFromRGB(DrakGreenNickNameColor);
    UIColor *activeLinkColor = UIColorFromRGB(TextBlackColor);
    
    //点击时候的背景色
//    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor colorWithWhite:0.631 alpha:1.000] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[UIColorFromRGB(SystemGrayColor) CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    
    
    if ([NSMutableParagraphStyle class]) {
        [mutableLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:activeLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:activeLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        
        
        //把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
    } else {
        [mutableLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:(__bridge id)[activeLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:(__bridge id)[activeLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        
        
        //把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
    }
    
    self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    self.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    self.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableInactiveLinkAttributes];
}

/**
 *  如果是有attributedText的情况下，有可能会返回少那么点的，这里矫正下
 *
 */
- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.attributedText) {
        return [super sizeThatFits:size];
    }
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}

#pragma mark - main

-(void)getSpecialRangeText:(NSString*)message arr:(NSMutableArray *)array
{
//    WSLog(@"开始查询：\n%@",message);
    NSRange range=[message rangeOfString:@"<atuser>"];
    NSRange range1=[message rangeOfString:@"</atuser>"];
    
    NSUInteger len=0;
    //判断当前字符串是否还有表情的标志。
    if (range.length&&range1.length) {
        len=range1.location-(range.location+8);
        NSString *subString=[message substringWithRange:NSMakeRange(range.location+8, len)];
//        WSLog(@"查询到的数据：%@",subString);
        
        //添加链接
        NSString *actionString = [NSString stringWithFormat:@"at->%@",subString];
        
        //替换进行下一次查询
        message=[message stringByReplacingCharactersInRange:range1 withString:@"@"];
        message=[message stringByReplacingCharactersInRange:range withString:@""];
        
        //匹配一次正则，因为多了一个@字符
//        if(range.location>1){
            range=NSMakeRange(range.location, len+1);
            //这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
            //因为有自定义的类型出现，所以这样方便点。
            NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:range replacementString:actionString];
            [array addObject:aResult];
//        }
        
        [self getSpecialRangeText:message arr:array];
    }
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (void)setExtendText:(NSString *)extendText
{
    extendText=[extendText stringByReplacingOccurrencesOfString:@"<atuser >" withString:@"<atuser>"];
    _extendText = extendText;
    if (!extendText||extendText.length<=0) {
        [super setText:nil];
        return;
    }
    
    // 设置页面显示
    NSString *replaceString=extendText;
    replaceString=[replaceString stringByReplacingOccurrencesOfString:@"<atuser>" withString:@"@"];
    replaceString=[replaceString stringByReplacingOccurrencesOfString:@"</atuser>" withString:@""];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:replaceString];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [paragraphStyle setLineSpacing:kLineSpacing];
    NSDictionary *attributes = @{NSFontAttributeName:self.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    _contentHeight = [replaceString boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size.height ;
    
    
    [self setText:mutableAttributedString afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
    
    
    
    //////////////
    // start
    //////////////
    NSString *replaceStringStart=extendText;
    NSMutableArray *results = [NSMutableArray array];
    NSMutableAttributedString *exAttributedString = [[NSMutableAttributedString alloc] initWithString:replaceStringStart];
    NSRange stringRange = NSMakeRange(0, exAttributedString.length);
    
    [self getSpecialRangeText:replaceStringStart arr:results];
    
    
    /////////////////////////////////////////////////////////////////////////////////////
    // 替换<atuser>和</atuser>之前
    // 匹配<atuser>xxxxx</atuser>为@xxxx空格
//    exAttributedString = [[NSMutableAttributedString alloc] initWithString:extendText];
//    stringRange = NSMakeRange(0, exAttributedString.length);
//    
//    __block int startRange=0;
//    __block int startlocation=0;
//    [kAtRegularExpression() enumerateMatchesInString:[exAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
//        
//        //检查是否和之前记录的有交集，有的话则忽略
//        for (NSTextCheckingResult *record in results){
//            if (NSMaxRange(NSIntersectionRange(record.range, result.range))>0){
//                return;
//            }
//        }
//        
//        NSRange range=result.range;
//        int len=0;
//        NSString *atString=[_extendText substringWithRange:result.range];
//        atString=[atString stringByReplacingOccurrencesOfString:@"<atuser>" withString:@"@"];
//        atString=[atString stringByReplacingOccurrencesOfString:@"</atuser>" withString:@" "];
//        if(startlocation==0){
//            startlocation=(int)range.location;
//        }else{
//            if(startlocation>range.location){
//                startlocation=(int)range.location;
//            }
//        }
//        
//        startRange=startRange+15;
//        len=15;
//        
//        //匹配一次正则，减少15个字符
//        if(startRange==15){
//            range=NSMakeRange(range.location, range.length-len);
//        }else{
//            range=NSMakeRange(range.location-startRange, range.length-len);
//        }
//        
//        //添加链接
//        NSString *actionString = [NSString stringWithFormat:@"at->%@",atString];
//        
//        //这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
//        //因为有自定义的类型出现，所以这样方便点。
//        NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:range replacementString:actionString];
//        
//        [results addObject:aResult];
//    }];
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////
    // 匹配#
    stringRange = NSMakeRange(0, mutableAttributedString.length);
    NSRegularExpression * const regexps[] = {kURLRegularExpression(),kPhoneNumerRegularExpression(),kEmailRegularExpression(),kAtRegularExpression(),kPoundSignRegularExpression()};
    
    NSUInteger maxIndex = self.isNeedAtAndPoundSign?kURLActionCount:kURLActionCount-1;
    for (NSUInteger i=0; i<maxIndex; i++) {
        //连接允许点击
        if (self.disableThreeCommon&& i<kURLActionCount-1 && i>0) {
            continue;
        }
        
        
        //已经单独匹配过了
        if(i==3){
            continue;
        }
        
        NSString *urlAction = kURLActions[i];
        
        //使用替换后的mutableAttributedString，不用再移动位置
        [regexps[i] enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
            
            //检查是否和之前记录的有交集，有的话则忽略
            for (NSTextCheckingResult *record in results){
                if (NSMaxRange(NSIntersectionRange(record.range, result.range))>0){
                    return;
                }
            }
            NSRange range=result.range;
//            WSLog(@"%@",NSStringFromRange(range));
            NSString *atString=[replaceString substringWithRange:range];
            //添加链接
            NSString *actionString = [NSString stringWithFormat:@"%@%@",urlAction,atString];
            
            //这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
            //因为有自定义的类型出现，所以这样方便点。
            NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:range replacementString:actionString];
            
            [results addObject:aResult];
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //这里直接调用父类私有方法，好处能内部只会setNeedDisplay一次。一次更新所有添加的链接
    [super performSelector:@selector(addLinksWithTextCheckingResults:attributes:) withObject:results withObject:self.linkAttributes];
#pragma clang diagnostic pop
    
}

#pragma mark - setter
- (void)setIsNeedAtAndPoundSign:(BOOL)isNeedAtAndPoundSign
{
    _isNeedAtAndPoundSign = isNeedAtAndPoundSign;
    self.extendText = self.extendText; //简单重新绘制处理下
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    self.extendText = self.extendText; //简单重新绘制处理下
}

- (void)setDisableEmoji:(BOOL)disableEmoji
{
    self.extendText = self.extendText; //简单重新绘制处理下
}

- (void)setDisableThreeCommon:(BOOL)disableThreeCommon
{
    _disableThreeCommon = disableThreeCommon;
    self.extendText = self.extendText; //简单重新绘制处理下
}



#pragma mark - delegate
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;
{
    if (result.resultType == NSTextCheckingTypeCorrection) {
        //判断消息类型
        for (NSUInteger i=0; i<kURLActionCount; i++) {
            if ([result.replacementString hasPrefix:kURLActions[i]]) {
                NSString *content = [result.replacementString substringFromIndex:kURLActions[i].length];
                if(self.extendDelegate&&[self.extendDelegate respondsToSelector:@selector(ttExtendLabel:didSelectLink:withType:)]){
                    //type的数组和i刚好对应
                    [self.extendDelegate ttExtendLabel:self didSelectLink:content withType:i];
                }
                
                if(self.exntedBlock){
                    self.exntedBlock(content,i);
                }
            }
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
