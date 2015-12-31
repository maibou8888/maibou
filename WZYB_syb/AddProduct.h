//
//  AddProduct.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-7.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddProduct : NSObject
{
    NSMutableArray *arr_AddToList;//添加订单产品 
}
+ (AddProduct *) sharedInstance;
@property(nonatomic,copy) NSMutableArray *arr_AddToList;
@end
