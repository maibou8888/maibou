//
//  Document_Read.h
//  WZYB_syb
//
//  Created by wzyb on 14-6-30.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Document_Read : UIView
//用webView读取GIF图片
-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView;
@end
