//
//  IsRead.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-4.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "IsRead.h"

@implementation IsRead
@synthesize arr_isRead=arr_isRead;
static IsRead * sharedSingleton = nil;
+ (IsRead *) sharedInstance
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
        arr_isRead=[[NSMutableArray alloc]init];
        return self;
    }
}

@end
