//
//  PrivacyViewController.m
//  fun_beta
//
//  Created by 刘大治 on 14-10-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()
{
    float edgSize;
    float width;
    float height;
    CGSize labelSize;
    NSTimer *myTimer;
    int a;
}
@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    edgSize = 8;
    width = self.view.frame.size.width;
    height = self.view.frame.size.height;
    
    [self createLeftButtonSelect:@selector(goBack:) imageName:@"common_back@2x" heightImageName:@"common_backSelected@2x"];
    [self setTitle:@"隐私申明"];
    
    
     NSString * string = @"曾经看到过一篇文章，描写的是一个女子和他丈夫，她丈夫很贪吃，有个情节是在冬天，家里买了个西瓜，她丈夫把西瓜一破为二，自己吃了一半有拿起另外一半吃了点，然后出去了，女子在家看着吃剩下的西瓜，于是把剩下的西瓜吃了，她丈夫回来要西瓜吃质问她，她觉得很不好意思。\n最后的结局是因为她在厨房打了8个鸡蛋，做了一份葱花炒蛋，结果出去的时候她丈夫留给她一个干净的盘底，最后离婚谁能提供整篇文章曾经看到过一篇文章，描写的是一个女子和他丈夫，她丈夫很贪吃，有个情节是在冬天，家里买了个西瓜，她丈夫把西瓜一破为二，自己吃了一半有拿起另外一半吃了点，然后出去了，女子在家看着吃剩下的西瓜，于是把剩下的西瓜吃了，她丈夫回来要西瓜吃质问她，她觉得很不好意思。\n最后的结局是因为她在厨房打了8个鸡蛋，做了一份葱花炒蛋，结果出去的时候她丈夫留给她一个干净的盘底，最后离婚谁能提供整篇文章曾经看到过一篇文章，描写的是一个女子和他丈夫，她丈夫很贪吃，有个情节是在冬天，家里买了个西瓜，她丈夫把西瓜一破为二，自己吃了一半有拿起另外一半吃了点，然后出去了，女子在家看着吃剩下的西瓜，于是把剩下的西瓜吃了，她丈夫回来要西瓜吃质问她，她觉得很不好意思。\n最后的结局是因为她在厨房打了8个鸡蛋，做了一份葱花炒蛋，结果出去的时候她丈夫留给她一个干净的盘底，最后离婚谁能提供整篇文章出去的时候她丈夫留给她一个干净的盘底，最后离婚谁能提供整篇文章曾经看到过一篇文章，描写的是一个女子和他丈夫，她丈夫很贪吃，有个情节是在冬天，家里买了个西瓜，她丈夫把西瓜一破为二，自己吃了一半有拿起另外一半吃了点，然后出去了，女子在家看着吃剩下的西瓜，于是把剩下的西瓜吃了，她丈夫回来要西瓜吃质问她，她觉得很不好意思。\n最后的结局是因为她在厨房打了8个鸡蛋，做了一份葱花炒蛋，结果出去的时候她丈夫留给她一个干净的盘底，最后离婚谁能提供整篇文章曾经看到过一篇文章，描写的是一个女子和他丈夫，她丈夫很贪吃，有个情节是在冬天，家里买了个西瓜，她丈夫把西瓜一破为二，自己吃了一半有拿起另外一半吃了点，然后出去了，女子在家看着吃剩下的西瓜，于是把剩下的西瓜";
    
    CGRect labelRect = [SysTools rectWidth:string FontSize:17 size:CGSizeMake(width- edgSize*2, CGFLOAT_MAX)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(edgSize, edgSize, width-edgSize*2, labelRect.size.height)];
    label.text = string;
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [_backScroll addSubview:label];
    
    _backScroll.contentSize = CGSizeMake(width- edgSize*2, labelRect.size.height+edgSize*2);

    
    NSString * ssstttrrr = @"       我想有个好的开始和好的结局你胸胸伯钦遥角傀你你仍脆瓜我胸        ";
    labelSize = [SysTools rectWidth:ssstttrrr FontSize:17 size:CGSizeMake(CGFLOAT_MAX, _runLabel.frame.size.height)].size;
    
    NSLog(@"%@",NSStringFromCGSize(labelSize));
    NSString * ssstttrrr2 = @"我想有个好的开始和好的结局你胸胸伯钦遥角傀你你仍脆瓜我胸       我想有个好的开始和好的结局你胸胸伯钦遥角傀你你仍脆瓜我胸";

    _runLabel.text = ssstttrrr2;
    _runLabel.frame = CGRectMake(0, 0, labelSize.width, _runLabel.frame.size.height);
    _runScroll.contentSize = CGSizeMake(labelSize.width, _runLabel.frame.size.height);
    
    [self scrollRunning];
    // Do any additional setup after loading the view from its nib.
}

-(void)selfaddRunScroll:(CGRect)frame andText:(NSString*)text
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self viewWillDisappear:animated];
    if (myTimer) {
        [myTimer invalidate];
    }
}
-(void)scrollRunning
{
    [self performSelector:@selector(goRun) withObject:nil afterDelay:2];
}
-(void)goRun
{
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFlys) userInfo:nil repeats:YES];
}
-(void)timerFlys
{
    NSLog(@"%d",a);
    a+=1;
    _runScroll.contentOffset = CGPointMake(a, 0);
    if (a>= labelSize.width - width) {
        [myTimer invalidate];
        [self performSelector:@selector(goRun) withObject:nil afterDelay:1];
        _runScroll.contentOffset = CGPointMake(0, 0);
        a=0;
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    if ([touch.view isEqual:_runScroll]) {
        [myTimer invalidate];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    if ([touch.view isEqual:_runScroll]) {
        [self goRun];
    }
}


-(void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
