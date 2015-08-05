//
//  MyTextView.m
//  Tutu
//
//  Created by zhangxinyao on 14-10-21.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "MyTextView.h"

@implementation MyTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    // If not dragging, send event to next responder
//    if (!self.dragging){
//        [self.nextResponder touchesBegan: touches withEvent:event];
//        WSLog(@"1111");
//    }else{
        [self.delegate touchesBegan: touches withEvent: event];
//    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    if(!self.dragging){
//        WSLog(@"2222 %d",self.dragging);
//        [self.nextResponder touchesMoved:touches withEvent:event];
//    }else{
        [self.delegate touchesMoved:touches withEvent:event];
//    }
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
    // If not dragging, send event to next responder
        [self.delegate touchesEnded: touches withEvent: event];

}

@end
