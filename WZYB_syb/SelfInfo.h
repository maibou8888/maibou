//
//  SelfInfo.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelfInfo : NSObject
@property(nonatomic,retain)NSString *str_uname;
@property(nonatomic,retain)NSString *str_uid;
@property(nonatomic,retain)NSString *str_password;
@property(nonatomic,retain)NSString *str_umtel;
@property(nonatomic,retain)NSString *str_utype;//用户的层级 0和1是管理者 2 是普通员工
@property(nonatomic,retain)NSString *str_index_no;
@property(nonatomic,retain)NSString *str_user_token;//令牌
@end
