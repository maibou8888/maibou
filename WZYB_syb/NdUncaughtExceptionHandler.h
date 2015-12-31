//
//  NdUncaughtExceptionHandler.h
//  WZYB_syb
//
//  Created by wzyb on 14-9-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NdUncaughtExceptionHandler : NSObject
{
    BOOL dd;
}
+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;
+(void)Post_url:(NSString *)url_msg;
@end
