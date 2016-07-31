//
//  YWGInitRequestFileManager.h
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YWGClassInfo;
@interface YWGInitRequestFileManager : NSObject

/**
 *  解析一个类实现文件内容 (仅对OC有效)
 *
 *  @param classInfo 类信息
 *
 *  @return 实现文件里面的内容
 */
+ (NSString *)parseClassImpContentWithClassInfo:(YWGClassInfo *)classInfo;

/**
 *  解析一个类头文件的内容(会根据是否创建文件返回的内容有所不同)
 *
 *  @param classInfo 类信息
 *
 *  @return 类头文件里面的内容
 */
+ (NSString *)parseClassHeaderContentWithClassInfo:(YWGClassInfo *)classInfo;

/**
 *  生成 dataArray get 方法
 *
 *  @param classInfo 指定类信息
 *
 *  @return
 */
+ (NSString *)methodContentOfYTKRequestWithClassInfo:(YWGClassInfo *)classInfo;

+ (NSString *)methodRequestisPagelistMethodWithClassInfo:(YWGClassInfo *)classInfo;
+ (NSString *)methodRequestMethodWithClassInfo:(YWGClassInfo *)classInfo;

+ (NSString *)methodRequestisPagelistMWithClassInfo:(YWGClassInfo *)classInfo;
+ (NSString *)methodRequestMethodMWithClassInfo:(YWGClassInfo *)classInfo;

/**
 *  创建文件
 *
 *  @param folderPath 输出的文件夹路径
 *  @param classInfo  类信息
 */
+ (void)createFileWithFolderPath:(NSString *)folderPath classInfo:(YWGClassInfo *)classInfo;

@end
