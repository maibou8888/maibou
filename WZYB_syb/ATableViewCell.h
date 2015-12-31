//
//  ATableViewCell.h
//  IphoneMapSdkDemo
//
//  Created by 石梦星 on 15/5/13.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

@interface ATableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) IBOutlet UILabel *lblPropress;

@property (nonatomic, strong) BMKOLUpdateElement* item;


@end
