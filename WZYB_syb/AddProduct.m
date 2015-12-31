//
//  AddProduct.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-7.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "AddProduct.h"

@implementation AddProduct
@synthesize arr_AddToList=arr_AddToList;
static AddProduct * sharedSingleton = nil;
+ (AddProduct *) sharedInstance
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
        arr_AddToList=[[NSMutableArray alloc]init];
        return self;
    }
}

@end
