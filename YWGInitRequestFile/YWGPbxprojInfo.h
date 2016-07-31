//
//  YWGPbxprojInfo.h
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YWGPbxprojInfo : NSObject

@property (nonatomic, copy, readonly) NSString *classPrefix;
@property (nonatomic, copy, readonly) NSString *organizationName;
@property (nonatomic, copy, readonly) NSString *productName;

+(instancetype)shareInstance;
-(void)setParamsWithPath:(NSString *)path;

@end
