//
//  DocumentViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-6-9.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"
@interface DocumentViewController : UIViewController<UIWebViewDelegate,NSURLConnectionDataDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate, UIBarPositioningDelegate>
{
    NavView *nav_View1;
    NavView * nav_View2 ;
    NavView * nav_View3;
    NSInteger moment_status;
    UIWebView *webView;
    UIButton *btn;
    UIButton *btn1;
    BOOL isLoading;
    
    NSInteger currentScale;
    NSInteger scaleFlag;
    NSInteger enablePan;
}
@property(nonatomic,strong)NSMutableData *connectionData;
//
@property(nonatomic,strong)NSString *string_Title;//文档标题
@property(nonatomic,assign)BOOL isCache;//是否要求缓存 YES是
@property(nonatomic,strong)NSString *str_Url;//文档地址
@property(nonatomic,strong)NSString *str_isGraph; //是数据图表 1
@property(nonatomic,strong)NSString *str_index_no;
@property(nonatomic,strong)NSString *str_Index;//唯一标识
@property(nonatomic,strong)NSString *str_only_Online;//@"1"  在线浏览
@property(nonatomic,assign)BOOL exist;
@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,assign)NSInteger modalFlag;
@property(nonatomic,assign)NSInteger webViewHeight;
@property(nonatomic,assign)NSInteger mutiSelect;
@end
