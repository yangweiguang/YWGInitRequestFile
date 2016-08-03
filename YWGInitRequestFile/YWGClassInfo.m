//
//  YWGClassInfo.m
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import "YWGClassInfo.h"
#import "YWGInitRequestFileManager.h"
#import "NSString+Uplower.h"
#import "NSString+UrlEncode.h"

@implementation YWGClassInfo

- (instancetype)initWithClassName:(NSString *)className url:(NSString *)url isPageList:(BOOL)isPageList {
    self = [super init];
    if (self) {
        self.className = className;
        self.url = url;
        self.isPageList = isPageList;
    }
    return self;
}

- (NSString *)subClassName {
    if (self.className.length > 3) {
        _subClassName = [self.className substringFromIndex:3];
        NSRange range = [_subClassName rangeOfString:@"Request"];
        if (range.location != NSNotFound) {
            _subClassName = [_subClassName substringToIndex:range.location];
        }
    } else {
        _subClassName = self.className;
    }
    return _subClassName;
}

- (NSString *)modelClassName {
    NSRange range = [self.className rangeOfString:@"Request"];
    if (range.location != NSNotFound) {
        _modelClassName = [self.className substringToIndex:range.location];
    }
    _modelClassName = [NSString stringWithFormat:@"%@ResponseModel", _modelClassName];
    return _modelClassName;
}

- (NSString *)dataProName {
    _dataProName = [self.subClassName firstToLower];
    _dataProName = [NSString stringWithFormat:@"%@DataArray", _dataProName];
    return _dataProName;
}

- (NSString *)classContentForH {
    return [YWGInitRequestFileManager parseClassHeaderContentWithClassInfo:self];
}

- (NSString *)classContentForM {
    return [YWGInitRequestFileManager parseClassImpContentWithClassInfo:self];
}

- (NSString *)methordContentForH {
    if (self.isPageList) {
        return [YWGInitRequestFileManager methodRequestisPagelistMethodWithClassInfo:self];
    } else {
        return [YWGInitRequestFileManager methodRequestMethodWithClassInfo:self];
    }
}

- (NSString *)methordContentForM {
    if (self.isPageList) {
        return [YWGInitRequestFileManager methodRequestisPagelistMWithClassInfo:self];
    } else {
        return [YWGInitRequestFileManager methodRequestMethodMWithClassInfo:self];
    }
}

- (void)createFileWithFolderPath:(NSString *)folderPath {
    [YWGInitRequestFileManager createFileWithFolderPath:folderPath classInfo:self];
    YWGClassInfo * modelInfo = [[YWGClassInfo alloc] initWithClassName:self.className url:self.url isPageList:NO];
    modelInfo.isModel = YES;
    [YWGInitRequestFileManager createFileWithFolderPath:folderPath classInfo:modelInfo];
}

- (void)addUrlToFileWithFileName:(NSString *)fileName currentProPath:(NSString *)proPath currentFilePath:(NSString *)filePath {
    NSString * path = proPath;
    NSString * fPath = filePath;
    NSRange range = [path rangeOfString:@"Pods"];
    if (range.location != NSNotFound) {
        path = [path substringToIndex:range.location];
        NSRange namRange = [filePath rangeOfString:path.lastPathComponent options:NSBackwardsSearch];
        fPath = [fPath substringToIndex:namRange.location + namRange.length];
        fPath = [fPath stringByAppendingString:@"/Expand/Network/"];
    } else {
        range = [path rangeOfString:@"/" options:NSBackwardsSearch];
        path = [path substringToIndex:range.location];
        NSRange namRange = [filePath rangeOfString:path.lastPathComponent options:NSBackwardsSearch];
        fPath = [fPath substringToIndex:namRange.location + namRange.length];
        fPath = [fPath stringByAppendingString:@"/Expand/Network/"];
    }
    NSString * hPath = [NSString stringWithFormat:@"%@%@.h", fPath, fileName];
    NSURL * writeUrl = [NSURL URLWithString:hPath];
    NSString * originalContent = [NSString stringWithContentsOfURL:writeUrl encoding:NSUTF8StringEncoding error:nil];
    originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(originalContent.length, 0) withString:[NSString stringWithFormat:@"\nextern NSString * %@Url;\n", self.className]];
    [originalContent writeToURL:writeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSString * mpath = [NSString stringWithFormat:@"%@%@.m", fPath, fileName];
    NSURL * mwriteUrl = [NSURL URLWithString:mpath];
    NSString * moriginalContent = [NSString stringWithContentsOfURL:mwriteUrl encoding:NSUTF8StringEncoding error:nil];
    moriginalContent = [moriginalContent stringByReplacingCharactersInRange:NSMakeRange(moriginalContent.length, 0) withString:[NSString stringWithFormat:@"\nNSString * %@Url = @\"%@\";\n", self.className, self.url]];
    [moriginalContent writeToURL:mwriteUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
