//
//  CustomOverlayView.h
//  BaiduMapSdkSrc
//
//  Created by baidu on 13-5-21.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMKBaseComponent.h>
#import <BaiduMapAPI/BMKMapComponent.h>
#import "CustomOverlay.h"
@interface CustomOverlayView : BMKOverlayPathView
- (id)initWithCustomOverlay:(CustomOverlay *)customOverlay;

@property (nonatomic, readonly) CustomOverlay *customOverlay;
@end
