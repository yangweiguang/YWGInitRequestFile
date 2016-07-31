//
//  YWGInitRequestFile.h
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface YWGInitRequestFile : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end