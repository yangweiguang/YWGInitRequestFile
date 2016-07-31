//
//  YWGInputRequestController.h
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define YWGResultNotification @"YWGResultNotification"

@protocol YWGInputRequestControllerDelegate <NSObject>

@optional
-(void)windowWillClose;
@end

@interface YWGInputRequestController : NSWindowController

@property (nonatomic, weak) __weak id<YWGInputRequestControllerDelegate> delegate;

@end
