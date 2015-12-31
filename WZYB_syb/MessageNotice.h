//
//  MessageNotice.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>
//消息通知
@interface MessageNotice : NSObject
@property(nonatomic,retain)NSString *str_content;
@property(nonatomic,retain)NSString *str_Date;
@property(nonatomic,retain)NSString *str_index_no;
@property(nonatomic,assign)BOOL isRead;//是否阅读过 NO 没读过 YES 读过
@property(nonatomic,assign)NSString *str_uname;//谁发送的
@end
