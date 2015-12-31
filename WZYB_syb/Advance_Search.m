//
//  Advance_Search.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-24.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "Advance_Search.h"

@implementation Advance_Search
@synthesize arr_search=arr_search;
static Advance_Search * sharedSingleton = nil;
+ (Advance_Search *) sharedInstance
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
    @synchronized(self)
    {
        arr_search=[[NSMutableArray alloc]init];
        return self;
    }
}

@end
