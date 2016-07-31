//
//  HMTableViewCell.h
//  7.29网络加载
//
//  Created by 刘家强 on 16/7/30.
//  Copyright © 2016年 刘家强. All rights reserved.
//

#import <UIKit/UIKit.h>

// 自定义cell 解决(void)layoutSubviews 无法显示图片的问题

@interface HMTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *downloadLable;

@end

