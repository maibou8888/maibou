//
//  QR_GetCustomer.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QR_GetCustomer : NSObject
@property (nonatomic,retain)NSString *str_gname;//终端名称
@property (nonatomic,retain)NSString *str_address;//终端地址
@property (nonatomic,retain)NSString *str_index_no;//终端索引
@property (nonatomic,retain)NSString *str_last_sign_date;//上次签到日期
@property (nonatomic,retain)NSString *str_glng;//终端经度
@property (nonatomic,retain)NSString *str_glat;//终端纬度
@property (nonatomic,retain)NSString *str_belongto;//所属办事处
@property (nonatomic,retain)NSString *str_dist;//终端到手机距离
@property (nonatomic,retain)NSString *str_gmemo;//签退测试备注
@property (nonatomic,retain)NSString *str_atu;//二维码信息
@property (nonatomic,retain)NSString *str_new_lng;//新经度
@property (nonatomic,retain)NSString *str_new_lat;//新纬度
@property (nonatomic,retain)NSString *str_gbelongto;//隶属什么部门 上级 到时候要和自己判断是否是一个部门的
@property (nonatomic,retain)NSString *str_gtype;//是考勤1 还是巡访2//暂时搁置
@property (nonatomic,retain)NSString *str_sign_type;//0将要签到 1将要签退
@property (nonatomic,retain)NSString *URLFlag;
@property (nonatomic,retain)NSString *DynamicCount;
@property (nonatomic,retain)NSString *RequiredCount;
@property (nonatomic,retain)NSString *DynamicSaved;
@property (nonatomic,retain)NSString *InfoNumberStr;
@end
