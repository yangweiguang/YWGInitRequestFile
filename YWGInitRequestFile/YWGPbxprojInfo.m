//
//  YWGPbxprojInfo.m
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import "YWGPbxprojInfo.h"

static YWGPbxprojInfo *instance;

@implementation YWGPbxprojInfo

+(instancetype)shareInstance{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[YWGPbxprojInfo alloc] init];
    });
    return instance;
}

-(void)setParamsWithPath:(NSString *)path{
    NSData *pbxprojData = [NSData dataWithContentsOfFile:path];
    NSString *pbxprojStr = [[NSString alloc] initWithData:pbxprojData encoding:NSUTF8StringEncoding];
    _classPrefix = [self matchStringWithKeyWord:@"CLASSPREFIX" matchInString:pbxprojStr];
    _organizationName = [self matchStringWithKeyWord:@"ORGANIZATIONNAME" matchInString:pbxprojStr];
    _productName = [self matchStringWithKeyWord:@"productName" matchInString:pbxprojStr];
}

-(NSString *)matchStringWithKeyWord:(NSString *)keyWord matchInString:(NSString *)matchString{
    NSString *resultStr = @"";
    NSError *error;
    // 创建NSRegularExpression对象并指定正则表达式
    NSString *prefixStr = [NSString stringWithFormat:@"%@ = ",keyWord];
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:[NSString stringWithFormat:@"%@[a-zA-Z0-9\u4e00-\u9fa5]+;",prefixStr]
                                  options:0
                                  error:&error];
    if (!error) {
        // 获取特特定字符串的范围
        NSTextCheckingResult *match = [regex firstMatchInString:matchString
                                                        options:0
                                                          range:NSMakeRange(0, [matchString length])];
        if (match) {
            // 截获特定的字符串
            NSString *result = [matchString substringWithRange:match.range];
            resultStr = [result substringWithRange:NSMakeRange(prefixStr.length, result.length-prefixStr.length-1)];
        }
    };
    return resultStr;
}

@end
