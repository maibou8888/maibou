//
//  Logistic_LocationViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-11-12.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "WZYB_TwoSectionViewController.h"


@protocol MyDelegate_Logistic <NSObject>
@optional
-(void)Notify_MyLogistic;
@end

@interface Logistic_LocationViewController : WZYB_TwoSectionViewController<UIAlertViewDelegate>
{
    NSTimer *timer;
    UIButton *btn_GPS;
}
@property(weak,nonatomic)id<MyDelegate_Logistic> delegate;

@property (strong, nonatomic) IBOutlet UIView *View_Back;
@property (weak, nonatomic) IBOutlet UILabel *lab_title;//面条标题
 
@property (weak, nonatomic) IBOutlet UILabel *lab_alat_alng;//经纬度
@property (weak, nonatomic) IBOutlet UILabel *lab_address;//地址
@property (weak, nonatomic) IBOutlet UILabel *lab_day;
@property (weak, nonatomic) IBOutlet UILabel *lab_hour;
@property (weak, nonatomic) IBOutlet UILabel *lab_min;

@property (weak, nonatomic) IBOutlet UIProgressView *progressive;
@property (weak, nonatomic) IBOutlet UIImageView *prgViewBack;

@property (weak, nonatomic) IBOutlet UITextView *tex_mention;
@property(nonatomic,retain)NSString *titleString;
@end
