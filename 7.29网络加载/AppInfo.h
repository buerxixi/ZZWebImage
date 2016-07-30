//
//  AppInfo.h
//  7.29网络加载
//
//  Created by 刘家强 on 16/7/29.
//  Copyright © 2016年 刘家强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject

/**
 *  应用的名称
 */
@property (nonatomic, copy) NSString *name;
/**
 *  图片的下载地址
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  下载量
 */
@property (nonatomic, copy) NSString *download;

@end
