//
//  HolidayViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-11-13.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "WZYB_TwoSectionViewController.h"

@interface HolidayViewController : WZYB_TwoSectionViewController<UIAlertViewDelegate>
{
    BOOL isHoliday;//是否正在休假中 YES 是 holiday=1
}
@property (strong, nonatomic) IBOutlet UIView *View_Back;
@property (weak, nonatomic) IBOutlet UILabel *lab_title;
@property (weak, nonatomic) IBOutlet UILabel *lab_UpTitle;
@property (weak, nonatomic) IBOutlet UILabel *lab_DownTitle;
@property (weak, nonatomic) IBOutlet UIImageView *img_Up;
@property (weak, nonatomic) IBOutlet UIImageView *img_Down;
@property (weak, nonatomic) IBOutlet UIButton *btn_up;
@property (weak, nonatomic) IBOutlet UIButton *btn_down;
@property (nonatomic,assign) NSInteger modeFlag;

- (IBAction)Action_Choose:(id)sender;
@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *urlString;
@end
