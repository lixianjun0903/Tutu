//
//  SelectionActionSheet.h
//  Tutu
//
//  Created by 刘大治 on 14-11-3.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectionActionSheetDelegate <NSObject>
-(void)selectAtIndex:(NSInteger)index;
@end


@interface SelectionActionSheet : UIView
-(id)init;
@property(assign,nonatomic)id<SelectionActionSheetDelegate> selectDelegate;
-(void)setWithButtons:(id)cancelButton, ...NS_REQUIRES_NIL_TERMINATION;
@end
