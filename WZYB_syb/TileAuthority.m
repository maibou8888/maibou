//
//  TileAuthority.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-10.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "TileAuthority.h"

@implementation TileAuthority
@synthesize dic_TileAuthority=dic_TileAuthority;
static TileAuthority *sharedSingleton = nil;
+ (TileAuthority*) sharedInstance
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
        dic_TileAuthority=[[NSDictionary alloc]init];
        return self;
    }
}
@end
