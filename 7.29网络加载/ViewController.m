//
//  ViewController.m
//  7.29网络加载
//
//  Created by 刘家强 on 16/7/29.
//  Copyright © 2016年 刘家强. All rights reserved.
//

#import "AFNetworking.h"
#import "AppInfo.h"
#import "HMTableViewCell.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<AppInfo *> *appInfo;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *imagesDict;
@property (nonatomic, strong) NSMutableDictionary *opDict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // 创建manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    // 获取url
    NSString *urlStr = @"https://raw.githubusercontent.com/zzzzly/HMdemo/master/appserr.json";

    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

        // 获取临时数组
        NSArray *tempArr = responseObject;

        // 遍历数组
        for (NSDictionary *dict in tempArr) {
            // 创建模型对象
            AppInfo *info = [[AppInfo alloc] init];

            // 字典转模型
            [info setValuesForKeysWithDictionary:dict];

            // 添加到可变数组
            [self.appInfo addObject:info];
        }

        [self.tableView reloadData];
    }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {

            // 失败的回调
            NSLog(@"%@", error);

        }];
}

#pragma mark - tabView的道理方式

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 上缓存池找cell
    HMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    // 获取模型数据
    AppInfo *info = self.appInfo[indexPath.row];

    // 问题1. 网络加载闪动问题 - cell的复用 原封不动的放入缓存池
    cell.imageView.image = nil;

    // 问题2. cell加载数据 网络繁忙的时候 cell地址 会被之前加在的线程的图片给覆盖掉 引起图片混论
    // 间接跟新 只更新某一行的cell 把其保存起来(模型中) 在加载完成的时候 去更新

    // 设置属性
    cell.nameLable.text = info.name;
    //
    cell.downloadLable.text = info.download;
    
    // 获取key
//    NSString *key = [info.icon stringByExpandingTildeInPath];

    if (self.imagesDict[info.icon]) {
        
        NSLog(@"从内存中读取");
        
        // 不为空就赋值
        cell.imageView.image = self.imagesDict[info.icon];
        return cell;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self sanboxPatchWithStr:info.icon]];
    
    if (image) {
        
        NSLog(@"从沙盒中读取");
        
        cell.imageView.image = image;
        
        // 写入到内存
        [self.imagesDict setObject:image forKey:info.icon];
        return cell;
    }
    
    if (self.opDict[info.icon]) {
        return cell;
    }
    
    
    // 获取url
    NSURL *url = [NSURL URLWithString:info.icon];

    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        [NSThread sleepForTimeInterval:arc4random_uniform(4)];

        // 获取data
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        [data writeToFile:[self sanboxPatchWithStr:info.icon] atomically:true];

        UIImage *image = [UIImage imageWithData:data];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            
            NSLog(@"创建%@", info.name);
            
            
            // 防止因为图片返回为空 程序崩溃
            if (image) {
                 [self.imagesDict setObject:image forKey:info.icon];
            
            [self.opDict removeObjectForKey:info.icon];

            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
            }

        }];

    }];
    
    // 3.重复创建操作"op"
    [self.opDict setObject:op forKey:info.icon];

    [self.queue addOperation:op];

    // 返回cell
    return cell;
}

#pragma mark - 懒加载

- (NSMutableArray<AppInfo *> *)appInfo {
    // 判断
    if (_appInfo == nil) {
        _appInfo = [NSMutableArray array];
    }
    return _appInfo;
}

- (NSOperationQueue *)queue {
    // 判断
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSMutableDictionary *)imagesDict {
    // 判断
    if (_imagesDict == nil) {
        _imagesDict = [NSMutableDictionary dictionary];
    }
    return _imagesDict;
}

- (NSMutableDictionary *)opDict {
    
    if (_opDict == nil) {
        _opDict = [NSMutableDictionary dictionary];
    }
    return _opDict;
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
//    // 这样遍历很麻烦 可以考虑去 通过字典来存储
//    for (int i = 0; i < self.appInfo.count; i++) {
//        self.appInfo[i].image = nil;
//    }
    
    [self.imagesDict removeAllObjects];
    
    [self.opDict removeAllObjects];
    
    // 取消队列的任务
    [self.queue cancelAllOperations];
}

- (NSString *)sanboxPatchWithStr:(NSString *)str{
    
    // 获取"/"后面的字符串
    NSString *lastPath = [str lastPathComponent];
    
    // 获取系统的临时储存路径
    NSString *fristPath =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
    
    // 拼接
    NSString *path = [fristPath stringByAppendingPathComponent:lastPath];
    
    return path;
}

@end
