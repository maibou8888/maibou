//
//   TileAuthority.h
//  WZYB_syb
//
//  Created by wzyb on 14-9-10.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TileAuthority : NSObject
{
    NSDictionary *dic_TileAuthority;    //贴片权限字典
}
+ (TileAuthority *) sharedInstance;
@property(nonatomic,copy) NSDictionary *dic_TileAuthority;
@end
