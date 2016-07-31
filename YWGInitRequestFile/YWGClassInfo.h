//
//  YWGClassInfo.h
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YWGClassInfo : NSObject
/**
 *  request实体类的类名
 */
@property (nonatomic, copy) NSString *className;
/**
 *  request实体类的类名 去除前三个字符的前缀
 */
@property (nonatomic, copy) NSString *subClassName;
/**
 *  request实体类的类名 去除前三个字符的前缀
 */
@property (nonatomic, copy) NSString *modelClassName;
/**
 *  request list data arr 属性名
 */
@property (nonatomic, copy) NSString * dataProName;
/**
 *  request url
 */
@property (nonatomic, copy) NSString *url;
/**
 *  是否是model类
 */
@property (nonatomic, assign) BOOL isModel;
/**
 *  是否是model类
 */
@property (nonatomic, assign) BOOL isPageList;
/**
 *  整个类头文件的内容，包含头与尾 -- 会根据是否创建文件添加模板文字
 */
@property (nonatomic, copy) NSString *classContentForH;

/**
 *  整个类实现文件里面的内容，在Swift情况下此参数无效
 */
@property (nonatomic, copy) NSString *classContentForM;

/**
 *  所有request方法的格式化的内容
 */
@property (nonatomic, copy) NSString *methordContentForH;

@property (nonatomic, copy) NSString *methordContentForM;

/**
 *  创建文件
 *
 *  @param folderPath 文件路径
 */
- (void)createFileWithFolderPath:(NSString *)folderPath;

/**
 *  添加url 到指定文件
 *
 */
- (void)addUrlToFileWithFileName:(NSString *)fileName currentProPath:(NSString *)proPath currentFilePath:(NSString *)filePath;

- (instancetype)initWithClassName:(NSString *)className url:(NSString *)url isPageList:(BOOL)isPageList;

@end
