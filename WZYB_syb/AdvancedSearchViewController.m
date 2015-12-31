//
//  AdvancedSearchViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-23.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "AdvancedSearchViewController.h"
#import "NoteViewController.h"
#import "SearchListViewController.h"
#import "AppDelegate.h"
#import "TypeCustomerViewController.h"
#import "ADSignViewController.h"
@interface AdvancedSearchViewController () {
    AppDelegate* app;
    NSString* personFlag;
    NSMutableArray* mutDynArray;
    int oringinalY;
    int buttonNumber;
}
@property (nonatomic, strong) NSString* urlString;

//订单查询
@property (strong, nonatomic) IBOutlet UIScrollView* BossOrderScrollView;
@property (weak, nonatomic) IBOutlet UITextField* tex8_startDate;
@property (weak, nonatomic) IBOutlet UITextField* tex8_endDate;
@property (weak, nonatomic) IBOutlet UITextField* tex8_part;
@property (weak, nonatomic) IBOutlet UITextField* tex8_person;
@property (weak, nonatomic) IBOutlet UITextField* tex8_moneyMin;
@property (weak, nonatomic) IBOutlet UITextField* tex8_moneyMax;
@property (weak, nonatomic) IBOutlet UITextField* tex8_exeStatus;

//申请查询
@property (weak, nonatomic) IBOutlet UITextField* tex9_startDate;
@property (weak, nonatomic) IBOutlet UITextField* tex9_endDate;
@property (weak, nonatomic) IBOutlet UITextField* tex9_applyType;
@property (weak, nonatomic) IBOutlet UITextField* tex9_apart;
@property (weak, nonatomic) IBOutlet UITextField* tex9_person;
@property (weak, nonatomic) IBOutlet UITextField* tex9_state;
@property (weak, nonatomic) IBOutlet UITextField* tex9_minMoney;
@property (weak, nonatomic) IBOutlet UITextField* tex9_maxMoney;
@property (weak, nonatomic) IBOutlet UITextField* tex9_comPerson;
@property (strong, nonatomic) IBOutlet UIScrollView* BossApplyScrollView;
@property (strong, nonatomic) IBOutlet UIButton *tex9_apartmentBtn;

//客户查询
@property (weak, nonatomic) IBOutlet UITextField* tex10_startDate;
@property (weak, nonatomic) IBOutlet UITextField* tex10_endDate;
@property (weak, nonatomic) IBOutlet UITextField* tex10_terminal;
@property (weak, nonatomic) IBOutlet UITextField* tex10_apart;
@property (weak, nonatomic) IBOutlet UITextField* tex10_person;
@property (weak, nonatomic) IBOutlet UITextField* tex10_modeMin;
@property (weak, nonatomic) IBOutlet UITextField* tex10_modeMax;
@property (weak, nonatomic) IBOutlet UITextField* tex10_daysMin;
@property (weak, nonatomic) IBOutlet UITextField* tex10_daysMax;
@property (strong, nonatomic) IBOutlet UIScrollView* BossCustomerScrollView;

//考勤查询
@property (weak, nonatomic) IBOutlet UITextField* tex11_startDate;
@property (weak, nonatomic) IBOutlet UITextField* tex11_endDate;
@property (weak, nonatomic) IBOutlet UITextField* tex11_address;
@property (weak, nonatomic) IBOutlet UITextField* tex11_apart;
@property (weak, nonatomic) IBOutlet UITextField* tex11_person;
@property (weak, nonatomic) IBOutlet UITextField* tex11_signStatus;
@property (strong, nonatomic) IBOutlet UIScrollView* BossSignScrollView;
- (IBAction)signAddressAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel* tex7_label;
@property (strong, nonatomic) IBOutlet UIImageView* tex7_arrow;
@property (strong, nonatomic) IBOutlet UIButton* tex7_btn;
@property (strong, nonatomic) IBOutlet UIButton* tex6_btn;
@property (strong, nonatomic) IBOutlet UIButton *DayMaxBtn;

@end

@implementation AdvancedSearchViewController
@synthesize dynamic_customer;
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    auth = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"]; //权限级别
    personFlag = [NSString string];
    [self All_Init];
    [self Set_SegmentView];

    app.isDateLegal = YES;
    if ([self.str_Num isEqualToString:@"1"]) {
        tex_startDate.textAlignment = NSTextAlignmentRight;
        tex_endDate.textAlignment = NSTextAlignmentRight;
        tex_gname.textAlignment = NSTextAlignmentRight;
        tex_max.textAlignment = NSTextAlignmentRight;
        tex_min.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:tex_startDate, tex_endDate, tex_gname, tex_max, tex_min, nil];

        scroll_clerk.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_clerk.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_clerk];
        moment_height = 300;
        scroll = scroll_clerk;

        [self Get_dynamic];
    }
    else if ([self.str_Num isEqualToString:@"2"]) {
        tex2_end.textAlignment = NSTextAlignmentRight;
        tex2_start.textAlignment = NSTextAlignmentRight;
        tex2_status.textAlignment = NSTextAlignmentRight;

        arr = [NSMutableArray arrayWithObjects:tex2_start, tex2_end, tex2_status, nil];
    }
    else if ([self.str_Num isEqualToString:@"3"]) {
        tex3_end.textAlignment = NSTextAlignmentRight;
        tex3_start.textAlignment = NSTextAlignmentRight;
        tex3_keyword.textAlignment = NSTextAlignmentRight;
        tex3_status.textAlignment = NSTextAlignmentRight;
        tex3_toWho.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:tex3_start, tex3_end, tex3_status, tex3_toWho, tex3_keyword, nil];
    }
    else if ([self.str_Num isEqualToString:@"4"]) {
        tex4_end.textAlignment = NSTextAlignmentRight;
        tex4_start.textAlignment = NSTextAlignmentRight;
        tex4_status.textAlignment = NSTextAlignmentRight;
        tex4_toWho.textAlignment = NSTextAlignmentRight;
        tex4_max.textAlignment = NSTextAlignmentRight;
        tex4_min.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:tex4_start, tex4_end, tex4_status, tex4_toWho, tex4_min, tex4_max, nil];
    }
    else if ([self.str_Num isEqualToString:@"5"]) {
        tex5_end.textAlignment = NSTextAlignmentRight;
        tex5_start.textAlignment = NSTextAlignmentRight;
        tex5_status.textAlignment = NSTextAlignmentRight;
        tex5_type.textAlignment = NSTextAlignmentRight;
        tex5_max.textAlignment = NSTextAlignmentRight;
        tex5_min.textAlignment = NSTextAlignmentRight;
        tex5_person.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:tex5_start, tex5_end, tex5_type, tex5_status, tex5_min, tex5_max, tex5_person, nil];

        tex5_type.text = self.applyType;
        if (!self.allTypeFlag) {
            if (self.dynamic_customer.count) {
                [attendButton setImage:ImageName(@"set_middle@2X.png") forState:UIControlStateNormal];
            }

            scroll_myApply.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
            scroll_myApply.backgroundColor = [UIColor clearColor];
            [self.view addSubview:scroll_myApply];
            moment_height = 320 + 70;
            scroll = scroll_myApply;
        }
    }
    else if ([self.str_Num isEqualToString:@"6"]) {
        tex6_end.textAlignment = NSTextAlignmentRight;
        tex6_start.textAlignment = NSTextAlignmentRight;
        tex6_status.textAlignment = NSTextAlignmentRight;
        tex6_type.textAlignment = NSTextAlignmentRight;
        tex6_max.textAlignment = NSTextAlignmentRight;
        tex6_min.textAlignment = NSTextAlignmentRight;
        tex6_peo.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:tex6_start, tex6_end, tex6_type, tex6_peo, tex6_status, tex6_min, tex6_max, nil];
    }
    else if ([self.str_Num isEqualToString:@"7"]) {
        tex7_end.textAlignment = NSTextAlignmentRight;
        tex7_start.textAlignment = NSTextAlignmentRight;
        tex7_status.textAlignment = NSTextAlignmentRight;
        tex7_isInstead.textAlignment = NSTextAlignmentRight;
        tex7_max.textAlignment = NSTextAlignmentRight;
        tex7_min.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:tex7_start, tex7_end, tex7_min, tex7_max, tex7_status, tex7_isInstead, nil];

        if (self.returnFlag) {
            self.tex7_arrow.hidden = YES;
            self.tex7_label.hidden = YES;
            tex7_isInstead.hidden = YES;
            self.tex7_btn.hidden = YES;
            [self.tex6_btn setImage:ImageName(@"set_bottom@2X.png") forState:UIControlStateNormal];
        }
    }
    else if ([self.str_Num isEqualToString:@"22"]) {
        self.tex8_startDate.textAlignment = NSTextAlignmentRight;
        self.tex8_endDate.textAlignment = NSTextAlignmentRight;
        self.tex8_part.textAlignment = NSTextAlignmentRight;
        self.tex8_person.textAlignment = NSTextAlignmentRight;
        self.tex8_moneyMin.textAlignment = NSTextAlignmentRight;
        self.tex8_moneyMax.textAlignment = NSTextAlignmentRight;
        self.tex8_exeStatus.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:self.tex8_startDate, self.tex8_endDate, self.tex8_part, self.tex8_person, self.tex8_moneyMin, self.tex8_moneyMax, self.tex8_exeStatus, nil];
    }
    else if ([self.str_Num isEqualToString:@"23"]) {
        self.tex9_startDate.textAlignment = NSTextAlignmentRight;
        self.tex9_endDate.textAlignment = NSTextAlignmentRight;
        self.tex9_applyType.textAlignment = NSTextAlignmentRight;
        self.tex9_apart.textAlignment = NSTextAlignmentRight;
        self.tex9_person.textAlignment = NSTextAlignmentRight;
        self.tex9_state.textAlignment = NSTextAlignmentRight;
        self.tex9_minMoney.textAlignment = NSTextAlignmentRight;
        self.tex9_maxMoney.textAlignment = NSTextAlignmentRight;
        self.tex9_comPerson.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:self.tex9_startDate, self.tex9_endDate, self.tex9_applyType, self.tex9_apart, self.tex9_person, self.tex9_state, self.tex9_minMoney, self.tex9_maxMoney, self.tex9_comPerson, nil];
        
        self.tex9_applyType.text = self.applyType;
        if (!self.allTypeFlag) {
            if (self.dynamic_customer.count) {
                [self.tex9_apartmentBtn setImage:ImageName(@"set_middle@2X.png") forState:UIControlStateNormal];
            }
            
            self.BossApplyScrollView.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
            self.BossApplyScrollView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:self.BossApplyScrollView];
            moment_height = 410 + 70;
            scroll = self.BossApplyScrollView;
        }
    }
    else if ([self.str_Num isEqualToString:@"24"]) {
        self.tex10_startDate.textAlignment = NSTextAlignmentRight;
        self.tex10_endDate.textAlignment = NSTextAlignmentRight;
        self.tex10_terminal.textAlignment = NSTextAlignmentRight;
        self.tex10_apart.textAlignment = NSTextAlignmentRight;
        self.tex10_person.textAlignment = NSTextAlignmentRight;
        self.tex10_modeMin.textAlignment = NSTextAlignmentRight;
        self.tex10_modeMax.textAlignment = NSTextAlignmentRight;
        self.tex10_daysMin.textAlignment = NSTextAlignmentRight;
        self.tex10_daysMax.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:self.tex10_startDate, self.tex10_endDate, self.tex10_terminal, self.tex10_apart, self.tex10_person, self.tex10_modeMin, self.tex10_modeMax, self.tex10_daysMin, self.tex10_daysMax, nil];
        
        self.BossCustomerScrollView.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        self.BossCustomerScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.BossCustomerScrollView];
        moment_height = 455 + 20;
        scroll = self.BossCustomerScrollView;
        [self Get_dynamic];
    }
    else if ([self.str_Num isEqualToString:@"25"]) {
        self.tex11_startDate.textAlignment = NSTextAlignmentRight;
        self.tex11_endDate.textAlignment = NSTextAlignmentRight;
        self.tex11_address.textAlignment = NSTextAlignmentRight;
        self.tex11_apart.textAlignment = NSTextAlignmentRight;
        self.tex11_person.textAlignment = NSTextAlignmentRight;
        self.tex11_signStatus.textAlignment = NSTextAlignmentRight;
        arr = [NSMutableArray arrayWithObjects:self.tex11_startDate, self.tex11_endDate, self.tex11_address, self.tex11_apart, self.tex11_person, self.tex11_signStatus, nil];
    }

    if (![Advance_Search sharedInstance].arr_search.count > 0) {
        UITextField* tex = [arr objectAtIndex:0];
        tex.text = [Function getYearMonthDay_Now];

        UITextField* tex1 = [arr objectAtIndex:1];
        tex1.text = tex.text;
    }
    else {
        for (NSInteger i = 0; i < arr.count; i++) {
            UITextField* tex = [arr objectAtIndex:i];
            tex.text = [[Advance_Search sharedInstance].arr_search objectAtIndex:i];
        }
    }

    if (![self.str_Num isEqualToString:@"1"] && ![self.str_Num isEqualToString:@"24"]) {
        [self CreatScrollView];
    }
    isFirst = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (isFirst) {
        isFirst = NO;
    }
    else {
        for (UITextField* obj in arr) {
            if (Index == obj.tag) {
                if ([self.str_Num isEqualToString:@"5"] && Index == 7) {
                    obj.text = app.str_workerName;
                }
                else {
                    obj.text = app.str_temporary;
                }
                break;
            }
        }
    }

    if ([self.str_Num isEqualToString:@"22"]) {
        if (Index == 0) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* firstTempStr = [defaults objectForKey:@"LIST"];
            if (firstTempStr.integerValue) {
                app.str_temporary = @"";
                app.exeString = @"";
                app.str_workerName = @"";
                [defaults setObject:@"0" forKey:@"LIST"];
                [defaults synchronize];
            }

            if (self.firstFlag) {
                self.firstFlag = 0;
                self.tex8_part.text = app.exeString;
            }
            else {
                self.tex8_part.text = app.str_temporary;
                app.exeString = [NSString stringWithFormat:@"%@", app.str_temporary];
            }
        }
        self.tex8_person.text = app.str_workerName;
    }

    if ([self.str_Num isEqualToString:@"23"] && (Index == 0)) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* firstTempStr = [defaults objectForKey:@"ALIST"];
        if (firstTempStr.integerValue) {
            app.str_temporary = @"";
            app.exeString = @"";
            app.str_workerName = @"";
            [defaults setObject:@"0" forKey:@"ALIST"];
            [defaults synchronize];
        }

        if (self.firstFlag) {
            self.firstFlag = 0;
            self.tex9_apart.text = app.exeString;
        }
        else {
            self.tex9_apart.text = app.str_temporary;
            app.exeString = [NSString stringWithFormat:@"%@", app.str_temporary];
        }
        if (personFlag.integerValue == 5) {
            self.tex9_person.text = app.str_workerName;
            app.personIndex1 = [NSString stringWithFormat:@"%@", app.str_index_no];
        }
        else if (personFlag.integerValue == 9) {
            self.tex9_comPerson.text = app.str_workerName;
            app.personIndex2 = [NSString stringWithFormat:@"%@", app.str_index_no];
        }
    }

    if ([self.str_Num isEqualToString:@"24"]) {
        if (Index == 0) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* firstTempStr = [defaults objectForKey:@"CLIST"];
            if (firstTempStr.integerValue) {
                app.customerStr = @"";
                app.str_temporary = @"";
                app.exeString = @"";
                app.str_workerName = @"";
                app.customerNumber = 0;
                [defaults setObject:@"0" forKey:@"CLIST"];
                [defaults synchronize];
            }

            if (self.firstFlag) {
                self.firstFlag = 0;
                self.tex10_apart.text = app.exeString;
            }
            else {
                if (app.exeString.length) {
                    self.tex10_apart.text = app.exeString;
                }
                else {
                    self.tex10_apart.text = app.str_temporary;
                    app.exeString = [NSString stringWithFormat:@"%@", app.str_temporary];
                }
            }
        }
        self.tex10_person.text = app.str_workerName;
        self.tex10_terminal.text = app.customerStr;
    }

    if ([self.str_Num isEqualToString:@"25"]) {
        if (Index == 0) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* firstTempStr = [defaults objectForKey:@"SLIST"];
            if (firstTempStr.integerValue) {
                app.str_temporary = @"";
                app.exeString = @"";
                app.str_workerName = @"";
                app.BSAddressStr = @"";
                app.BSAddress = @"";
                [defaults setObject:@"0" forKey:@"SLIST"];
                [defaults synchronize];
            }

            if (self.firstFlag) {
                self.firstFlag = 0;
                self.tex11_apart.text = app.exeString;
            }
            else {
                if (app.exeString.length) {
                    self.tex11_apart.text = app.exeString;
                }
                else {
                    self.tex11_apart.text = app.str_temporary;
                    app.exeString = [NSString stringWithFormat:@"%@", app.str_temporary];
                }
            }
        }
        self.tex11_person.text = app.str_workerName;
        self.tex11_address.text = app.BSAddressStr;
    }

    Index = 0;
}
- (void)CreatScrollView
{
    if ([self.str_Num isEqualToString:@"1"] ||
        ([self.str_Num isEqualToString:@"5"] && !self.allTypeFlag) ||
        ([self.str_Num isEqualToString:@"23"] && !self.allTypeFlag) ||
        [self.str_Num isEqualToString:@"24"]) {
        NSArray* dataTypeArray = @[@"0", @"2", @"3", @"6"];

        for (NSDictionary* tempDic in dynamic_customer) {
            if ([dataTypeArray containsObject:[tempDic objectForKey:@"data_type"]]) {
                NSArray* tempkeys = [tempDic allKeys];
                NSArray* tempvalue = [tempDic allValues];
                NSMutableDictionary* tempMutDic = [NSMutableDictionary dictionary];
                for (int i = 0; i < tempkeys.count; i++) {
                    [tempMutDic setObject:[tempvalue objectAtIndex:i] forKey:[tempkeys objectAtIndex:i]];
                }

                NSString* string1 = [NSString stringWithFormat:@"%@ (最小)", [tempDic objectForKey:@"tname"]];
                NSString* string2 = [NSString stringWithFormat:@"%@ (最大)", [tempDic objectForKey:@"tname"]];

                [tempMutDic setObject:string1 forKey:@"tname"];
                [tempMutDic setObject:@"1" forKey:@"rcontent"];
                NSDictionary* tempConvertDic = [NSDictionary dictionaryWithDictionary:tempMutDic];
                [mutDynArray addObject:tempConvertDic];

                [tempMutDic setObject:string2 forKey:@"tname"];
                [tempMutDic setObject:@"0" forKey:@"rcontent"];
                NSDictionary* tempConvertDic1 = [NSDictionary dictionaryWithDictionary:tempMutDic];
                [mutDynArray addObject:tempConvertDic1];
            }
            else {
                [mutDynArray addObject:tempDic];
            }
        }

        app.mutDynDic = mutDynArray;

        if ([self.str_Num isEqualToString:@"5"]) {
            buttonNumber = 7;
            oringinalY = 363;
        }
        else  if ([self.str_Num isEqualToString:@"24"] || [self.str_Num isEqualToString:@"23"]){
            buttonNumber = 9;
            oringinalY = 452;
        }else {
            buttonNumber = 5;
            oringinalY = 276;
        }
        for (int i = 0; i < mutDynArray.count; i++) {
            NSDictionary* tempDic = [mutDynArray objectAtIndex:i];
            if ([[tempDic objectForKey:@"condition_flg"] isEqualToString:@"1"]) {
                if ([Advance_Search sharedInstance].arr_search.count > 0) {
                    if (i == mutDynArray.count - 1) {
                        [self customButton:oringinalY + 44 * i image:@"set_bottom@2X.png" tag:i frontText:[tempDic objectForKey:@"tname"] behindText:[[Advance_Search sharedInstance].arr_search objectAtIndex:i + buttonNumber] hehindArray:arr];
                    }
                    else {
                        [self customButton:oringinalY + 44 * i image:@"set_middle@2X.png" tag:i frontText:[tempDic objectForKey:@"tname"] behindText:[[Advance_Search sharedInstance].arr_search objectAtIndex:i + buttonNumber] hehindArray:arr];
                    }
                }
                else {
                    if (i == mutDynArray.count - 1) {
                        [self customButton:oringinalY + 44 * i image:@"set_bottom@2X.png" tag:i frontText:[tempDic objectForKey:@"tname"] behindText:@"" hehindArray:arr];
                    }
                    else {
                        [self customButton:oringinalY + 44 * i image:@"set_middle@2X.png" tag:i frontText:[tempDic objectForKey:@"tname"] behindText:@"" hehindArray:arr];
                    }
                }
            }
        }
    }
    else if ([self.str_Num isEqualToString:@"2"]) {
        scroll_visit.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_visit.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_visit];
        moment_height = 190 + 20;
        scroll = scroll_visit;
    }
    else if ([self.str_Num isEqualToString:@"3"]) {
        scroll_myTask.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_myTask.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_myTask];
        moment_height = 280 + 20;
        scroll = scroll_myTask;
    }
    else if ([self.str_Num isEqualToString:@"4"]) {
        scroll_assign.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_assign.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_assign];
        moment_height = 320 + 20;
        scroll = scroll_assign;
    }
    else if ([self.str_Num isEqualToString:@"5"]) {
        scroll_myApply.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_myApply.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_myApply];
        moment_height = 320 + 70;
        scroll = scroll_myApply;
    }
    else if ([self.str_Num isEqualToString:@"6"]) {
        scroll_assess.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_assess.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_assess];
        moment_height = 360 + 20;
        scroll = scroll_assess;
    }
    else if ([self.str_Num isEqualToString:@"7"]) {
        scroll_order.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        scroll_order.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll_order];
        moment_height = 320 + 20;
        scroll = scroll_order;
    }
    else if ([self.str_Num isEqualToString:@"22"]) {
        self.BossOrderScrollView.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        self.BossOrderScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.BossOrderScrollView];
        moment_height = 365 + 20;
        scroll = self.BossOrderScrollView;
    }
    else if ([self.str_Num isEqualToString:@"23"]) {
        self.BossApplyScrollView.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        self.BossApplyScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.BossApplyScrollView];
        moment_height = 410 + 70;
        scroll = self.BossApplyScrollView;
    }
    else if ([self.str_Num isEqualToString:@"24"]) {
        self.BossCustomerScrollView.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        self.BossCustomerScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.BossCustomerScrollView];
        moment_height = 455 + 20;
        scroll = self.BossCustomerScrollView;
    }
    else if ([self.str_Num isEqualToString:@"25"]) {
        self.BossSignScrollView.frame = CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44);
        self.BossSignScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.BossSignScrollView];
        moment_height = 320 + 20;
        scroll = self.BossSignScrollView;
    }

    for (NSInteger i = 0; i < 3; i++) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, moment_height, (Phone_Weight - 20), 44);
        [scroll addSubview:btn];
        moment_height += 54;
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
        if (i == 0) {
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"搜索" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(Action_Submit:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (i == 1) {
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color7.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color8.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"清空条件" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(Action_Clear:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (i == 2) {
            if (([self.str_Num intValue] == 1) || ([self.str_Num intValue] == 2) || ([self.str_Num intValue] == 7) || ([self.str_Num intValue] == 22) || ([self.str_Num intValue] == 23) || ([self.str_Num intValue] == 24) || ([self.str_Num intValue] == 25)) {
                break;
            }
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color8.png"] forState:UIControlStateHighlighted];
            if ([self.str_Num isEqualToString:@"6"]) {
                [btn setTitle:@"查询待审批" forState:UIControlStateNormal];
            }
            else {
                switch ([self.str_Num intValue]) {
                case 3:
                    [btn setTitle:@"查询未完成任务" forState:UIControlStateNormal];
                    break;
                case 4:
                    [btn setTitle:@"查询未完成指派" forState:UIControlStateNormal];
                    break;
                case 5:
                    [btn setTitle:@"查询未完成申请" forState:UIControlStateNormal];
                    break;
                case 6:
                    [btn setTitle:@"查询待审批" forState:UIControlStateNormal];
                    break;
                default:
                    break;
                }
            }
            [btn addTarget:self action:@selector(Action_AllAssess:) forControlEvents:UIControlEventTouchUpInside];
        }
        btn.titleLabel.textColor = [UIColor whiteColor];
    }

    if (moment_height >= scroll.frame.size.height) {
        scroll.contentSize = CGSizeMake(0, moment_height + 44);
    }
    else {
        scroll.contentSize = CGSizeMake(0, scroll.frame.size.height);
    }
}
- (void)All_Init
{
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (StatusBar_System > 0)
        moment_status = 20;
    else
        moment_status = 0;
    NavView* nav_View = [[NavView alloc] init];
    [self.view addSubview:[nav_View NavView_Title1:@"高级搜索"]];

    if (![self.str_Num isEqualToString:@"5"] && ![self.str_Num isEqualToString:@"23"]) {
        dynamic_customer = [NSArray array];
    }
    mutDynArray = [NSMutableArray array];
    oringinalY = 0;
    buttonNumber = 0;
}
- (void)Set_SegmentView
{
    for (NSInteger i = 0; i < 2; i++) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        if (i == 0) //返回
        {
            btn.frame = CGRectMake(0, moment_status, 60, 44);
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        else {
            btn.frame = CGRectMake(Phone_Weight - 44, moment_status, 44, 44);
            [btn setTitle:@"搜索" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        btn.tag = buttonTag + i;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}
- (void)btn_Action:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == buttonTag) //返回
    {
        app.isOnlyGoBack = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (btn.tag == buttonTag + 1) {
        [self submit];
    }
    else if (btn.tag == buttonTag * 2 + 2) {
        isOpenDate = NO;
        [view_back removeFromSuperview];
    }
    else if (btn.tag == buttonTag * 2 + 3) {
        isOpenDate = NO;
        [view_back removeFromSuperview];

        if (app.isDateLegal) {
            if (Index != 0 && Index != 1) {
                for (UITextField* obj in arr) {
                    if (Index == obj.tag) {
                        obj.text = app.str_Date;
                        break;
                    }
                }
            }
            else {
                UITextField* tex = [arr objectAtIndex:0];
                if (Index == tex.tag) {
                    tex.text = app.str_Date;
                }
                else {
                    UITextField* tex1 = [arr objectAtIndex:1];
                    tex1.text = app.str_Date;
                }
            }
        }
        Index = 0;
    }
}
- (void)select_Date
{
    view_back = [[UIView alloc] initWithFrame:CGRectMake(0, moment_status + 44, Phone_Weight, Phone_Height - moment_status - 44)];
    view_back.backgroundColor = [UIColor colorWithRed:193 / 255.0 green:193 / 255.0 blue:193 / 255.0 alpha:0.6];
    [self.view addSubview:view_back];
    RBCustomDatePickerView* pickerView = [[RBCustomDatePickerView alloc] initWithFrame:CGRectMake((Phone_Weight - 278.5) / 2, (view_back.frame.size.height - (190 + 54 * 2) - 49) / 2, 278.5, 54 + 190.0)];
    pickerView.backgroundColor = [UIColor clearColor];
    pickerView.layer.cornerRadius = 8; //设置视图圆角
    pickerView.layer.masksToBounds = YES;
    [view_back addSubview:pickerView];
    for (NSInteger i = 2; i < 4; i++) { //
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UILabel* label_btn = [[UILabel alloc] init];
        label_btn.backgroundColor = [UIColor whiteColor];
        label_btn.layer.cornerRadius = 8;
        label_btn.layer.masksToBounds = YES;
        label_btn.textColor = [UIColor blackColor];
        label_btn.textAlignment = NSTextAlignmentCenter;
        if (i == 2) {
            btn.frame = CGRectMake((Phone_Weight - 278.5) / 2, pickerView.frame.origin.y + pickerView.frame.size.height + 10, 278.5 / 2 - 5, 44);
            label_btn.text = @"取消";
        }
        else {
            btn.frame = CGRectMake((Phone_Weight - 278.5) / 2 + 5 + 278.5 / 2, pickerView.frame.origin.y + pickerView.frame.size.height + 10, 278.5 / 2 - 5, 44);
            label_btn.text = @"确定";
        }
        [btn addSubview:label_btn];
        btn.backgroundColor = [UIColor clearColor];
        label_btn.frame = CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height);
        btn.tag = buttonTag * 2 + i;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [view_back addSubview:btn];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Action_Submit:(id)sender
{
    [self submit];
}
- (void)submit
{
    if ([Advance_Search sharedInstance].arr_search != nil || [Advance_Search sharedInstance].arr_search.count > 0) {
        [[Advance_Search sharedInstance].arr_search removeAllObjects];
    }
    for (UITextField* obj in arr) {
        if ([Function isBlankString:obj.text]) {
            obj.text = @"";
        }
        //Dlog(@"ZZZ %@",obj.text);
    }
    for (NSInteger i = 0; i < arr.count; i++) {
        UITextField* tex = [arr objectAtIndex:i];
        [[Advance_Search sharedInstance].arr_search addObject:tex.text];
    }

    if ([self.str_Num isEqualToString:@"2"]) {
        self.delegate = (id)app.VC_Visit; //vc
        //指定代理对象为，second
        [self.delegate Notify_AdvancedSearch]; //这里获得代理方法的返回
    }
    else if ([self.str_Num isEqualToString:@"3"]) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults]; //1.0.4 区分action事件
        [defaults setObject:@"1" forKey:@"userFlag"];
        [defaults synchronize];
    }
    else if ([self.str_Num isEqualToString:@"7"]) {
        if (self.returnFlag) {
            self.delegate = (id)app.VC_SubmitROrder;
        }
        else {
            self.delegate = (id)app.VC_SubmitOrder;
        }
        [self.delegate Notify_AdvancedSearch]; //这里获得代理方法的返回
    }
    else if ([self.str_Num isEqualToString:@"5"]) { //我的申请
        app.applySearch = 1;
    }
    else if ([self.str_Num isEqualToString:@"6"]) { //我的审批  boss
        app.assessSearch = @"1"; //1.0.4
        if ([auth isEqualToString:@"4"]) {
            self.delegate = (id)app.VC_Assessment; //vc
            //指定代理对象为，second
            [self.delegate Notify_AdvancedSearch]; //这里获得代理方法的返回
        }
    }
    else if ([self.str_Num isEqualToString:@"4"]) { //我的指派 boss
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults]; //1.0.4 区分action事件
        [defaults setObject:@"1" forKey:@"userFlag"];
        [defaults synchronize];

        if ([auth isEqualToString:@"4"]) {
            self.delegate = (id)app.VC_Task; //vc
            //指定代理对象为，second
            [self.delegate Notify_AdvancedSearch]; //这里获得代理方法的返回
        }
    }
    else if ([self.str_Num isEqualToString:@"22"]) {
        //订单查询
        self.delegate = (id)app.VC_searchList;
        [self.delegate Notify_AdvancedSearch];
    }
    else if ([self.str_Num isEqualToString:@"23"]) {
        //订单查询
        self.delegate = (id)app.VC_searchApply;
        [self.delegate Notify_AdvancedSearch];
    }
    else if ([self.str_Num isEqualToString:@"24"]) {
        //订单查询
        self.delegate = (id)app.VC_searchCustomer;
        [self.delegate Notify_AdvancedSearch];
    }
    else if ([self.str_Num isEqualToString:@"25"]) {
        //考勤查询
        self.delegate = (id)app.VC_searchSign;
        [self.delegate Notify_AdvancedSearch];
    }

    if ([self.str_Assess isEqualToString:@"1"]) {
        app.isOnlyGoBack = NO;
    }
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)Action_AllAssess:(id)sender //1.0.4 action事件的修改
{
    switch (self.str_Num.intValue) {
    case 3:
        break;
    case 4: {
        if ([auth isEqualToString:@"4"]) {
            self.delegate = (id)app.VC_Task; //vc
            [self.delegate Notify_AdvancedSearch];
        }
    } break;
    case 5:
        break;
    case 6: {
        app.assessSearch = @"0"; //1.0.4
        self.delegate = (id)app.VC_Assessment;
        [self.delegate Notify_AdvancedSearch];
    } break;
    default:
        break;
    }

    [self.navigationController popViewControllerAnimated:NO];
}
- (void)Action_Clear:(id)sender
{
    tex_gname.text = @"";
    tex_max.text = @"";
    tex_min.text = @"";
    tex2_status.text = @"";
    tex3_keyword.text = @"";
    tex3_status.text = @"";
    tex3_toWho.text = @"";
    tex4_max.text = @"";
    tex4_min.text = @"";
    tex4_status.text = @"";
    tex4_toWho.text = @"";
    tex5_type.text = @"";
    tex5_min.text = @"";
    tex5_max.text = @"";
    tex5_status.text = @"";
    tex6_max.text = @"";
    tex6_min.text = @"";
    tex6_peo.text = @"";
    tex6_status.text = @"";
    tex6_type.text = @"";
    tex7_isInstead.text = @"";
    tex7_max.text = @"";
    tex7_min.text = @"";
    tex7_status.text = @"";
    //订单
    self.tex8_part.text = @"";
    self.tex8_person.text = @"";
    self.tex8_moneyMin.text = @"";
    self.tex8_moneyMax.text = @"";
    self.tex8_exeStatus.text = @"";
    //申请
    self.tex9_applyType.text = @"";
    self.tex9_apart.text = @"";
    self.tex9_person.text = @"";
    self.tex9_state.text = @"";
    self.tex9_minMoney.text = @"";
    self.tex9_maxMoney.text = @"";
    //客户
    self.tex10_terminal.text = @"";
    self.tex10_apart.text = @"";
    self.tex10_person.text = @"";
    self.tex10_modeMin.text = @"";
    self.tex10_modeMax.text = @"";
    self.tex10_daysMin.text = @"";
    self.tex10_daysMax.text = @"";
    //考勤
    self.tex11_address.text = @"";
    self.tex11_apart.text = @"";
    self.tex11_person.text = @"";
    self.tex11_signStatus.text = @"";

    [[Advance_Search sharedInstance].arr_search removeAllObjects];
}
- (IBAction)Action_StartDate:(id)sender
{
    UITextField* tex = [arr objectAtIndex:0];
    if (![Function isBlankString:app.str_startDate])
        tex.text = app.str_startDate;
    UIButton* btn = (UIButton*)sender;
    Index = btn.tag;
    if (!isOpenDate) {
        isOpenDate = YES;
        [self select_Date];
    }
}
- (IBAction)Action_EndDate:(id)sender
{
    UITextField* tex = [arr objectAtIndex:1];
    if (![Function isBlankString:app.str_startDate])
        tex.text = app.str_startDate;
    UIButton* btn = (UIButton*)sender;
    Index = btn.tag;
    if (!isOpenDate) {
        isOpenDate = YES;
        [self select_Date];
    }
}
- (IBAction)Action_chooseGname:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    Index = btn.tag;
    NoteViewController* noteVC = [[NoteViewController alloc] init];
    noteVC.str_title = @"终端名称";
    noteVC.str_content = tex_gname.text;
    noteVC.isDetail = NO;
    [self.navigationController pushViewController:noteVC animated:YES];
}
- (IBAction)Action_chooseMax:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    Index = btn.tag;
    [self NoteVC_Title:@"最大规模" Content:tex_max.text KeybordType:@"2"];
}
- (IBAction)Action_chooseMin:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    Index = btn.tag;
    [self NoteVC_Title:@"最小规模" Content:tex_min.text KeybordType:@"2"];
}
- (IBAction)Action_status:(UIButton*)sender
{
    Index = sender.tag;
    [self Action_Sheet_Title:@"签到状态" Tdefault:@"疑似地址不匹配,到达已签到,到达未签退,签到成功,终端无坐标"];
}
- (void)NoteVC_Title:(NSString*)Title Content:(NSString*)content KeybordType:(NSString*)type
{
    NoteViewController* noteVC = [[NoteViewController alloc] init];
    noteVC.str_title = Title;
    noteVC.str_content = content;
    noteVC.str_keybordType = type;
    noteVC.isDetail = NO;
    [self.navigationController pushViewController:noteVC animated:YES];
}
- (void)Action_Sheet_Title:(NSString*)title Tdefault:(NSString*)tdefault
{
    UIActionSheetViewController* actionVC = [[UIActionSheetViewController alloc] init];
    actionVC.str_title = title;
    actionVC.str_tdefault = tdefault;
    actionVC.isOnlyLabel = YES;
    [self.navigationController pushViewController:actionVC animated:YES];
    actionVC = nil;
}
- (IBAction)Action3_status:(UIButton*)sender
{ //（H8数据 -1：未确认、0：已确认、1：接受、2：拒绝、3：完成）
    Index = sender.tag;
    UIActionSheetViewController* actionVC = [[UIActionSheetViewController alloc] init];
    actionVC.str_title = @"执行状态";
    actionVC.str_H = @"H8";
    actionVC.isOnlyLabel = NO;
    [self.navigationController pushViewController:actionVC animated:YES];
    actionVC = nil;
}

- (IBAction)Action3_toWho:(UIButton*)sender
{
    Index = sender.tag;
    if ([self.str_Num isEqualToString:@"4"]) {
        [self NoteVC_Title:@"执行人" Content:tex4_toWho.text KeybordType:@"1"];
    }
    else if ([self.str_Num isEqualToString:@"3"]) {
        [self NoteVC_Title:@"指派人" Content:tex3_toWho.text KeybordType:@"1"];
    }
    else if ([self.str_Num isEqualToString:@"22"]) {
        LocationViewController* loVC = [[LocationViewController alloc] init];
        loVC.str_from = @"2"; //指派
        [self.navigationController pushViewController:loVC animated:NO];
    }
    else if ([self.str_Num isEqualToString:@"23"]) {
        Index = 0;
        personFlag = [NSString stringWithFormat:@"%ld", sender.tag];
        LocationViewController* loVC = [[LocationViewController alloc] init];
        loVC.str_from = @"2"; //申请
        [self.navigationController pushViewController:loVC animated:NO];
    }
    else if ([self.str_Num isEqualToString:@"24"]) {
        Index = 0;
        LocationViewController* loVC = [[LocationViewController alloc] init];
        loVC.str_from = @"2"; //申请
        [self.navigationController pushViewController:loVC animated:NO];
    }
    else if ([self.str_Num isEqualToString:@"25"]) {
        Index = 0;
        LocationViewController* loVC = [[LocationViewController alloc] init];
        loVC.str_from = @"2"; //申请
        [self.navigationController pushViewController:loVC animated:NO];
    }
    else if ([self.str_Num isEqualToString:@"5"]) {
        LocationViewController* loVC = [[LocationViewController alloc] init];
        loVC.str_from = @"2"; //申请
        [self.navigationController pushViewController:loVC animated:NO];
    }
}
- (IBAction)Action3_Keyword:(UIButton*)sender
{
    Index = sender.tag;
    [self NoteVC_Title:@"关键字" Content:tex3_keyword.text KeybordType:@"1"];
}
- (IBAction)Action4_min:(UIButton*)sender
{
    Index = sender.tag;
    if ([self.str_Num isEqualToString:@"4"]) {
        [self NoteVC_Title:@"最小耗时" Content:tex4_min.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"5"]) {
        [self NoteVC_Title:@"最小申请金额" Content:tex5_min.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"6"]) {
        [self NoteVC_Title:@"最小申请金额" Content:tex6_min.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"7"]) {
        [self NoteVC_Title:@"最小金额" Content:tex7_min.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"22"]) {
        [self NoteVC_Title:@"最小金额" Content:self.tex8_moneyMin.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"23"]) {
        [self NoteVC_Title:@"最小金额" Content:self.tex9_minMoney.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"24"]) {
        [self NoteVC_Title:@"最小未巡天数" Content:self.tex10_daysMin.text KeybordType:@"2"];
    }
}
- (IBAction)Action4_max:(UIButton*)sender
{
    Index = sender.tag;
    if ([self.str_Num isEqualToString:@"4"]) {
        [self NoteVC_Title:@"最大耗时" Content:tex4_max.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"5"]) {
        [self NoteVC_Title:@"最大申请金额" Content:tex5_max.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"6"]) {
        [self NoteVC_Title:@"最大申请金额" Content:tex6_max.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"7"]) {
        [self NoteVC_Title:@"最大金额" Content:tex7_max.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"22"]) {
        [self NoteVC_Title:@"最大金额" Content:self.tex8_moneyMax.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"23"]) {
        [self NoteVC_Title:@"最大金额" Content:self.tex9_maxMoney.text KeybordType:@"2"];
    }
    else if ([self.str_Num isEqualToString:@"24"]) {
        [self NoteVC_Title:@"最大未巡天数" Content:self.tex10_daysMax.text KeybordType:@"2"];
    }
}
- (IBAction)Action5_type:(UIButton*)sender
{ //H9数据
    Index = sender.tag;
    UIActionSheetViewController* actionVC = [[UIActionSheetViewController alloc] init];
    actionVC.str_title = @"审批类型";
    actionVC.str_H = @"H9";
    actionVC.isOnlyLabel = NO;
    actionVC.isSuper = YES;
    [self.navigationController pushViewController:actionVC animated:YES];
    actionVC = nil;
}
- (IBAction)Action5_status:(UIButton*)sender
{ //（H10数据 0：审批中、1：拒绝、2：同意、3：终结）
    Index = sender.tag;
    UIActionSheetViewController* actionVC = [[UIActionSheetViewController alloc] init];
    actionVC.str_title = @"审批状态";
    actionVC.str_H = @"H10";
    actionVC.isOnlyLabel = NO;
    [self.navigationController pushViewController:actionVC animated:YES];
    actionVC = nil;
}
- (IBAction)Action6_Peo:(UIButton*)sender
{
    Index = sender.tag;
    [self NoteVC_Title:@"申请人" Content:tex6_peo.text KeybordType:@"1"];
}
- (IBAction)Action7_statusOrInstead:(UIButton*)sender
{
    Index = sender.tag;
    if ([self.str_Num isEqualToString:@"22"]) {
        if (Index == 7) {
            [self Action_Sheet_Title:@"执行状态" Tdefault:@"未执行,已执行"];
        }
        else {
            [self Action_Sheet_Title:@"代收款状态" Tdefault:@"不代收,代收"];
        }
    }
    else {
        if (Index == 5) {
            [self Action_Sheet_Title:@"执行状态" Tdefault:@"未执行,已执行"];
        }
        else {
            [self Action_Sheet_Title:@"代收款状态" Tdefault:@"不代收,代收"];
        }
    }
}

- (IBAction)personApartment:(id)sender
{
    UIActionSheetViewController* sheetVC = [UIActionSheetViewController new];
    sheetVC.str_H = @"H1";
    sheetVC.str_title = @"所属部门";
    [self.navigationController pushViewController:sheetVC animated:YES];
    if ([self.str_Num isEqualToString:@"24"]) {
        app.exeString = @"";
    }
}
- (IBAction)terminalAction:(id)sender
{
    TypeCustomerViewController* tcVC = [TypeCustomerViewController new];
    [self.navigationController pushViewController:tcVC animated:YES];
}
- (IBAction)signAddressAction:(id)sender
{
    ADSignViewController* signVC = [ADSignViewController new];
    [self.navigationController pushViewController:signVC animated:YES];
}

#pragma mark---- dynamic data
//获取新客户动态信息
- (void)Get_dynamic
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            self.urlString = [self Setting_URL_Get_dynamic:KPORTAL_URL];
        }
        else {
            self.urlString = [self Setting_URL_Get_dynamic:kBASEURL];
        }
        NSURL* url = [NSURL URLWithString:self.urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (NSString*)Setting_URL_Get_dynamic:(NSString*)basic_url
{
    NSString* str;
    if (self.customerFlag) {
        str = [NSString stringWithFormat:@"%@%@", basic_url, KNewCustomer_Dynamic0];
    }
    else {
        str = [NSString stringWithFormat:@"%@%@", basic_url, KNewCustomer_Dynamic1];
    }
    return str;
}

- (void)customButton:(CGFloat)height
               image:(NSString*)imageName
                 tag:(NSInteger)tag
           frontText:(NSString*)text
          behindText:(NSString*)text1
         hehindArray:(NSMutableArray*)array
{
    //点击button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:ImageName(imageName) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dynamicButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(10, height, 300, 44);
    if ([self.str_Num isEqualToString:@"5"]) {
        button.tag = tag + 8;
    }else if([self.str_Num isEqualToString:@"24"] || [self.str_Num isEqualToString:@"23"]){
        button.tag = tag + 10;
    }else {
        button.tag = tag + 6;
    }
    [scroll addSubview:button];

    //titleLabel
    UILabel* frontLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 11, 140, 21)];
    frontLabel.font = [UIFont systemFontOfSize:13.0];
    frontLabel.text = text;
    [button addSubview:frontLabel];

    //dataLabel
    UITextField* behindTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 158, 44)];
    behindTextField.textColor = [UIColor colorWithRed:0 green:122 / 255.0 blue:211 / 255.0 alpha:1];
    behindTextField.textAlignment = NSTextAlignmentRight;
    behindTextField.placeholder = @"选填";
    behindTextField.enabled = NO;
    if ([self.str_Num isEqualToString:@"5"]) {
        behindTextField.tag = tag + 8;
    }else if([self.str_Num isEqualToString:@"24"] || [self.str_Num isEqualToString:@"23"]){
        behindTextField.tag = tag + 10;
    }else {
        behindTextField.tag = tag + 6;
    }
    behindTextField.text = text1;
    [array addObject:behindTextField];
    [button addSubview:behindTextField];

    //箭头
    UIImageView* imageView = [[UIImageView alloc] initWithImage:ImageName(@"icon_everyline_arrow.png")];
    imageView.frame = CGRectMake(270, 17, 5, 10);
    [button addSubview:imageView];

    moment_height += 45;
    scroll.contentSize = CGSizeMake(0, moment_height);
}

- (void)dynamicButtonMethod:(UIButton*)button
{
    Index = button.tag;
    NSDictionary* tempDic = nil;
    if ([self.str_Num isEqualToString:@"5"]) {
        tempDic = [mutDynArray objectAtIndex:button.tag - 8];
    }
    else if([self.str_Num isEqualToString:@"24"] || [self.str_Num isEqualToString:@"23"]){
        tempDic = [mutDynArray objectAtIndex:button.tag - 10];
    }else {
        tempDic = [mutDynArray objectAtIndex:button.tag - 6];
    }

    if ([[tempDic objectForKey:@"data_type"] isEqualToString:@"3"]) {
        [self select_Date];
    }
    else if ([[tempDic objectForKey:@"data_type"] isEqualToString:@"4"]) {
        UIActionSheetViewController* actionVC = [[UIActionSheetViewController alloc] init];
        actionVC.str_title = [tempDic objectForKey:@"tname"];
        actionVC.str_tdefault = [tempDic objectForKey:@"tdefault"];
        [self.navigationController pushViewController:actionVC animated:YES];
    }
    else {
        NoteViewController* noteVC = [[NoteViewController alloc] init];
        noteVC.str_title = [tempDic objectForKey:@"tname"];
        noteVC.placeHolderString = [tempDic objectForKey:@"tdefault"];

        UITextField* tex = [arr objectAtIndex:button.tag - 1];
        noteVC.str_content = tex.text;
        noteVC.str_keybordType = [tempDic objectForKey:@"data_type"];
        [self.navigationController pushViewController:noteVC animated:YES];
    }
}

#pragma mark---- ASIHTTPRequest delegate method
- (void)requestFinished:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if ([request responseStatusCode] == 200) {
        NSString* jsonString = [request responseString];
        SBJsonParser* parser = [[SBJsonParser alloc] init];
        NSDictionary* dict = [parser objectWithString:jsonString];
        if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
            if (request.tag == 100) {
                dynamic_customer = [dict objectForKey:@"DynamicList"];
                if (dynamic_customer.count) {
                    [modeMax setImage:ImageName(@"set_middle@2X.png") forState:UIControlStateNormal];
                    [self.DayMaxBtn setImage:ImageName(@"set_middle@2X.png") forState:UIControlStateNormal];
                    [self CreatScrollView];
                }
            }
        }
    }
    else {
        [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,%d", self.urlString, [request responseStatusCode]]];
    }
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}

@end
