//
//  Document_Read.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-30.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "Document_Read.h"

@implementation Document_Read

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
/*//调用
 UIWebView *webView;
 webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 100, 300, 265)];
 Document_Read *document=[[Document_Read alloc]init];
 [document loadDocument:@"run.gif" inView:webView];
 [self.view addSubview:webView];
 //webView.scalesPageToFit=YES;//点击伸缩效果的
 webView.userInteractionEnabled=NO;
 */
-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView
{
    webView.backgroundColor=[UIColor clearColor];
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}
@end
