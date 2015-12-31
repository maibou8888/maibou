//
//  ContactPeople.h
//  SearchCoreTest
//
//  Created by Apple on 28/01/13.
//  Copyright (c) 2013 kewenya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactPeople : NSObject {
    
}
@property (nonatomic,retain) NSNumber *localID;//index
@property (nonatomic,retain) NSString *name;//姓名  电话
@property (nonatomic,retain) NSMutableArray *phoneArray;

@end
