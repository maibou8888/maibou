//
//  BasicData.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "BasicData.h"

@implementation BasicData
@synthesize dic_BasicData=dic_BasicData;
static BasicData * sharedSingleton = nil;
+ (BasicData *) sharedInstance
{
    if (sharedSingleton == nil) {
        sharedSingleton = [[super allocWithZone:NULL] init];
    }
    return sharedSingleton;
}
+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone *) zone
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
        dic_BasicData=[[NSMutableDictionary alloc]init];
        return self;
    }
}

@end
