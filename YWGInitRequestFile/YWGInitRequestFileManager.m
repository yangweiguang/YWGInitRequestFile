//
//  YWGInitRequestFileManager.m
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import "YWGInitRequestFileManager.h"
#import "YWGClassInfo.h"
#import "YWGPbxprojInfo.h"

#define ESJsonFormatPluginPath [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Developer/Shared/Xcode/Plug-ins/ESJsonFormat.xcplugin"]

@implementation YWGInitRequestFileManager

+ (NSString *)parseClassHeaderContentWithClassInfo:(YWGClassInfo *)classInfo {
    NSMutableString *result;
    if (classInfo.isModel) {
        result = [NSMutableString stringWithFormat:@"@interface %@ : BaseGPModel\n",classInfo.modelClassName];
    } else {
        result = [NSMutableString stringWithFormat:@"@interface %@ : BaseGPRequest\n",classInfo.className];
    }
    [result appendString:@"\n@end"];
    
    //headerStr
    NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"h"]];
    //@class
    if (classInfo.isModel) {
        [headerString appendString:@"#import \"BaseGPModel.h\"\n\n"];
    } else {
        [headerString appendString:@"#import \"BaseGPRequest.h\"\n\n"];
    }
    [result insertString:headerString atIndex:0];
    return [result copy];
}

+ (NSString *)parseClassImpContentWithClassInfo:(YWGClassInfo *)classInfo {
    NSMutableString *result = [NSMutableString stringWithString:@""];
    if (classInfo.isModel) {
        [result appendFormat:@"@implementation %@\n\n@end\n",classInfo.modelClassName];
    } else {
        [result appendFormat:@"@implementation %@\n%@\n@end\n",classInfo.className, [self methodContentOfYTKRequestWithClassInfo:classInfo]];
    }
    
    //headerStr
    NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"m"]];
    //import
    if (classInfo.isModel) {
        [headerString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",classInfo.modelClassName]];
        [headerString appendString:@"\n"];
        [result insertString:headerString atIndex:0];
    } else {
        [headerString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",classInfo.className]];
        [headerString appendString:@"\n"];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}

+ (NSString *)methodContentOfYTKRequestWithClassInfo:(YWGClassInfo *)classInfo {
    if (classInfo.url.length <= 0) {
        return @"";
    } else {
        //append method content (objectClassInArray)
        NSString * methodStr = [NSString stringWithFormat:@"\n- (NSString *)requestUrl {\n    return %@Url;\n}\n", classInfo.className];
        return methodStr;
    }
}

+ (void)createFileWithFolderPath:(NSString *)folderPath classInfo:(YWGClassInfo *)classInfo {
    //创建.h文件
    NSString *fileName = classInfo.className;
    if (classInfo.isModel) {
        fileName = classInfo.modelClassName;
    }
    [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",fileName]] content:classInfo.classContentForH];
    //创建.m文件
    [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",fileName]] content:classInfo.classContentForM];
}

/**
 *  拼装模板信息
 *
 *  @param classInfo 类信息
 *  @param type      .h或者.m或者.swift
 *
 *  @return
 */
+ (NSString *)dealHeaderStrWithClassInfo:(YWGClassInfo *)classInfo type:(NSString *)type {
    //模板文字
    NSString *templateFile = [ESJsonFormatPluginPath stringByAppendingPathComponent:@"Contents/Resources/DataModelsTemplate.txt"];
    NSString *templateString = [NSString stringWithContentsOfFile:templateFile encoding:NSUTF8StringEncoding error:nil];
    //替换模型名字
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__MODELNAME__" withString:[NSString stringWithFormat:@"%@.%@",classInfo.className,type]];
    //替换用户名
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__NAME__" withString:NSFullUserName()];
    //产品名
    NSString *productName = [YWGPbxprojInfo shareInstance].productName;
    if (productName.length) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"__PRODUCTNAME__" withString:productName];
    }
    //组织名
    NSString *organizationName = [YWGPbxprojInfo shareInstance].organizationName;
    if (organizationName.length) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"__ORGANIZATIONNAME__" withString:organizationName];
    }
    //时间
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__DATE__" withString:[self dateStr]];
    
    return [templateString copy];
}

/**
 *  返回模板信息里面日期字符串
 *
 *  @return
 */
+ (NSString *)dateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yy/MM/dd";
    return [formatter stringFromDate:[NSDate date]];
}

/**
 *  创建文件
 *
 *  @param FileName 文件名字
 *  @param content  文件内容
 */
+ (void)createFileWithFileName:(NSString *)FileName content:(NSString *)content{
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createFileAtPath:FileName contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}
//.h文件方法声明
+ (NSString *)methodRequestMethodWithClassInfo:(YWGClassInfo *)classInfo {
    return [NSString stringWithFormat:@"\n- (void)request%@WithParameter:(NSDictionary *)parameter completion:(void(^)(BOOL success))completion;\n", classInfo.subClassName];
}

+ (NSString *)methodRequestisPagelistMethodWithClassInfo:(YWGClassInfo *)classInfo {
    return [NSString stringWithFormat:@"\n- (void)request%@FirstPageWithParameter:(NSDictionary *)parameter completion:(void(^)(BOOL success, BOOL hasNext))completion;\n\n- (void)request%@NextPageWithParameter:(NSDictionary *)parameter completion:(void(^)(BOOL success, BOOL hasNext))completion;\n", classInfo.subClassName, classInfo.subClassName];
}

//.m 文件方法实现
+ (NSString *)methodRequestisPagelistMWithClassInfo:(YWGClassInfo *)classInfo {
    return [NSString stringWithFormat:@"\n- (void)request%@FirstPageWithParameter:(NSDictionary *)parameter completion:(void(^)(BOOL success, BOOL hasNext))completion {\n    _page = 1;\n    [self request%@WithParameter:parameter completion:completion];\n}\n\n- (void)request%@NextPageWithParameter:(NSDictionary *)parameter completion:(void(^)(BOOL success, BOOL hasNext))completion {\n    _page++;\n    [self request%@WithParameter:parameter completion:completion];\n}\n\n- (void)request%@WithParameter:(NSDictionary *)parameter completion:(void (^)(BOOL, BOOL))completion {\n    NSMutableDictionary * para = [[NSMutableDictionary alloc] initWithDictionary:parameter];\n    [para setObject:@(_page) forKey:@\"<#page#>\"];\n\n    %@ * request = [[%@ alloc] initWithParameters:para modelClass:[%@ class] isSaveToMemory:NO isSaveToDisk:NO];\n    [self startRequestWithRequest:request SuccessAction:^(id object, BaseRequest *request) {\n        %@ * model = object;\n        if (_page == 1) {\n            [self.%@ removeAllObjects];\n        }\n        [self.%@ addObjectsFromArray:<#dataList#>];\n        if (model.success) {\n            completion(YES, YES);\n        } else {\n            completion(NO, NO);\n        }\n    } failAction:^(NSError *error, BaseRequest *request) {\n        completion(NO, NO);\n    }];\n}\n\n", classInfo.subClassName, classInfo.subClassName, classInfo.subClassName, classInfo.subClassName, classInfo.subClassName, classInfo.className, classInfo.className, classInfo.modelClassName, classInfo.modelClassName, classInfo.dataProName, classInfo.dataProName];
}

+ (NSString *)methodRequestMethodMWithClassInfo:(YWGClassInfo *)classInfo {
    return [NSString stringWithFormat:@"- (void)request%@WithParameter:(NSDictionary *)parameter completion:(void (^)(BOOL))completion {\n    %@ * request = [[%@ alloc] initWithParameters:parameter modelClass:[%@ class] isSaveToMemory:NO isSaveToDisk:NO];\n    [self startRequestWithRequest:request SuccessAction:^(id object, BaseRequest *request) {\n        %@ * model = object;\n\n    } failAction:^(NSError *error, BaseRequest *request) {\n        completion(NO);\n    }];\n}\n\n", classInfo.subClassName, classInfo.className, classInfo.className, classInfo.modelClassName, classInfo.modelClassName];
}

@end
