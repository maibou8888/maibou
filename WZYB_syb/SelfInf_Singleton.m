//
//  SelfInf_Singleton.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "SelfInf_Singleton.h"

@implementation SelfInf_Singleton
@synthesize dic_SelfInform=dic_SelfInform;
static SelfInf_Singleton * sharedSingleton = nil;
+ (SelfInf_Singleton *) sharedInstance
{
    if (sharedSingleton == nil) {
        sharedSingleton = [[super allocWithZone:NULL] init];
    }
    return sharedSingleton;
}
+ (id) allocWithZone:(struct _NSZone *)zone//第三步：重写allocWithZone方法
{
    return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone *) zone//第四步
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}


- (oneway void) release
{
   
}

- (id) autorelease
{
    return self;
}
-(id)init
{
    @synchronized(self) {
       
        dic_SelfInform= [[NSMutableDictionary alloc]init];
        return self;
    }
}

@end
