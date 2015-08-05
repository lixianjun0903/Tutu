//
//  TTLinkedTextView.m
//  CustomView
//
//  Created by zhangxinyao on 15-4-8.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TTLinkedTextView.h"

@interface TTLinkedTextView(){
    NSMutableDictionary *nickDict;
    UIColor *curTextColor;
}

@property(strong,nonatomic) LinkedStringTapHandler linkedblock;


@end

@implementation TTLinkedTextView
@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;

#pragma mark - Public Methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}



- (void)textChanged:(NSNotification *)notification
{
    [self lengthWithInRangeWithreplacementText:self.text];
    
    if([[self placeholder] length] == 0)
    {
        return;
    }
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

-(void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    curTextColor=textColor;
}

-(void)setFont:(UIFont *)font{
    [super setFont:font];
    
    self.fixedFont=font;
}


- (void)setText:(NSString *)text{
    NSString *textString=text;
    
    NSAttributedString *attributedString = [textString stringToAttributedString:nickDict textColor:curTextColor];
    [self setAttributedText:attributedString];
    
    if(self.fixedFont!=nil){
        [self setFont:self.fixedFont];
    }else{
        [self setFont:self.font];
    }
    
    if([[self placeholder] length] == 0)
    {
        return;
    }
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}


- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( placeHolderLabel == nil )
        {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = ListDetailFont;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
        
        placeHolderLabel.text = self.placeholder;
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

-(void)setMyAttrText:(NSString *)text{
    [self setText:text];
}

-(NSString *)getUploadText{
    NSString *str=self.text;
    
    for (NSString *item in nickDict.allKeys) {
        NSString *value=[nickDict objectForKey:item];
        if([@"1" isEqual:value]){
            str=[str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",item] withString:[NSString stringWithFormat:@"<atuser>%@</atuser>",[item stringByReplacingOccurrencesOfString:@"@" withString:@""]]];
        }
    }
    return str;
}
-(BOOL)doDelete{
    NSUInteger len=0;
    for (NSString *item in nickDict.allKeys) {
        NSString *itemString=[NSString stringWithFormat:@"@%@",item];
        if([self.text hasSuffix:itemString]){
            len=itemString.length+1;
            if(![itemString hasSuffix:@" "]){
                len=itemString.length;
            }
            break;
        }
    }
    if(len>0){
        self.text=[self.text substringWithRange:NSMakeRange(0, self.text.length-len)];
        return NO;
    }
    return YES;
}


- (void)commonInit
{
    nickDict=[[NSMutableDictionary alloc] init];
    
//    self.scrollEnabled = NO;
//    self.allowsEditingTextAttributes = NO;
//    self.selectable = NO;
//    self.editable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
}

- (void)reset
{
    self.attributedText = nil;
    [self commonInit];
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    placeHolderLabel = nil;
    placeholderColor = nil;
    placeholder = nil;
}


- (NSInteger) lengthWithInRangeWithreplacementText:(NSString *)string {
    NSInteger textLength = 0;
    UITextRange *selectedRange = [self markedTextRange];
    //获取高亮部分
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        textLength = [self.text length];
    }
    
    if (string.length > 0) {
        //输入状态
        NSString * newText = [self textInRange:selectedRange];
        if (newText && [newText length] > 0) {       //候选词替换高亮拼音时
            
            if (newText != nil) {
                NSInteger tvLength = [self.text length];
                textLength += (tvLength-[newText length]);
            }
            
            textLength += [string length];
        }else {
            
            NSRange sRange=self.selectedRange;
            [self setText:string];
            
            //重新设置光标位置，否则定位到末尾
            [self setSelectedRange:sRange];
            
            if (newText != nil) {
                NSInteger tvLength = [self.text length];
                textLength += (tvLength-[newText length]);
            }
            
            textLength += 1;
        }
    }else {
        //删除状态
        if (self.text.length > 0) {
            NSString * newText = [self textInRange:selectedRange];
            if (newText != nil) {
                NSInteger newLength = [newText length];
                NSInteger tvLength = [self.text length];
                textLength += (tvLength-newLength);
                if (newLength > 1) {
                    textLength += 1;
                }
            }
            else {
//                textLength = [[self.text substringToIndex:range.location] length];
            }
        }
    }
    
    return textLength;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
