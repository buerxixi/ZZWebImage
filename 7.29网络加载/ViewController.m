//
//  ViewController.m
//  7.29网络加载
//
//  Created by 刘家强 on 16/7/29.
//  Copyright © 2016年 刘家强. All rights reserved.
//

#import "AFNetworking.h"
#import "AppInfo.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, copy) NSMutableArray<AppInfo *> *appInfo;
@property (nonatomic, copy) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // 创建manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    // 获取url
    NSString *urlStr = @"https://raw.githubusercontent.com/zzzzly/HMdemo/master/apps.json";

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    // 获取模型数据
    AppInfo *info = self.appInfo[indexPath.row];

    // 获取url
    NSURL *url = [NSURL URLWithString:info.icon];

    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{

        // 获取data
        NSData *data = [NSData dataWithContentsOfURL:url];

        UIImage *image = [UIImage imageWithData:data];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.imageView.image = image;
            [self.tableView reloadData];
        }];

    }];

    [self.queue addOperation:op];

    // 设置属性
    cell.textLabel.text = info.name;

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

@end
