//
//  RBCustomDatePickerView.m
//  RBCustomDateTimePicker
//  e-mail:rbyyy924805@163.com
//  Created by renbing on 3/17/14.
//  Copyright (c) 2014 renbing. All rights reserved.
//

#import "RBCustomDatePickerView.h"
#import "AppDelegate.h"
@interface RBCustomDatePickerView()
{
    UIView                      *timeBroadcastView;//定时播放显示视图
    MXSCycleScrollView          *yearScrollView;//年份滚动视图
    MXSCycleScrollView          *monthScrollView;//月份滚动视图
    MXSCycleScrollView          *dayScrollView;//日滚动视图
    MXSCycleScrollView          *hourScrollView;//时滚动视图
    MXSCycleScrollView          *minuteScrollView;//分滚动视图
    MXSCycleScrollView          *secondScrollView;//秒滚动视图
    UILabel                     *nowPickerShowTimeLabel;//当前picker显示的时间
    UILabel                     *selectTimeIsNotLegalLabel;//所选时间是否合法
    UIButton                    *OkBtn;//自定义picker上的确认按钮
    AppDelegate *app;
}
@end

@implementation RBCustomDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTimeBroadcastView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -custompicker
//设置自定义datepicker界面
- (void)setTimeBroadcastView
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    nowPickerShowTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 278.5, 44)];
    [nowPickerShowTimeLabel setBackgroundColor:[UIColor whiteColor]];
    [nowPickerShowTimeLabel setFont:[UIFont systemFontOfSize:18.0]];
    [nowPickerShowTimeLabel setTextColor:RGBA(51, 51, 51, 1)];
    [nowPickerShowTimeLabel setTextAlignment:NSTextAlignmentCenter];
    nowPickerShowTimeLabel.layer.cornerRadius = 8;
    nowPickerShowTimeLabel.layer.masksToBounds=YES;
    nowPickerShowTimeLabel.text = [NSString stringWithFormat:@"请选择日期" ];
    [self addSubview:nowPickerShowTimeLabel];
    
    
    timeBroadcastView = [[UIView alloc] initWithFrame:CGRectMake(0, 44+10, 278.5, 190.0)];
    timeBroadcastView.layer.cornerRadius = 8;//设置视图圆角
    timeBroadcastView.layer.masksToBounds = YES;
    CGColorRef cgColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    timeBroadcastView.layer.borderColor = cgColor;
    timeBroadcastView.layer.borderWidth = 2.0;
    [self addSubview:timeBroadcastView];
    timeBroadcastView.backgroundColor=[UIColor whiteColor];
    UIView *beforeSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 278.5, 1.5)];
    [beforeSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [timeBroadcastView addSubview:beforeSepLine];
    UIView *middleSepView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 278.5, 38)];
    [middleSepView setBackgroundColor:RGBA(249.0, 138.0, 20.0, 1.0)];
    [timeBroadcastView addSubview:middleSepView];
    UIView *bottomSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 150.5, 278.5, 1.5)];
    [bottomSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [timeBroadcastView addSubview:bottomSepLine];
    [self setYearScrollView];
    [self setMonthScrollView];
    [self setDayScrollView];
    /*
    [self setHourScrollView];
    [self setMinuteScrollView];
    [self setSecondScrollView];
    */
    selectTimeIsNotLegalLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 339.5, 278.5, 15)];
    [selectTimeIsNotLegalLabel setBackgroundColor:[UIColor clearColor]];
    [selectTimeIsNotLegalLabel setFont:[UIFont systemFontOfSize:15.0]];
    [selectTimeIsNotLegalLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:selectTimeIsNotLegalLabel];
}
//设置年月日时分的滚动视图
- (void)setYearScrollView
{
    yearScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 278.5/3, 190.0)];
    NSInteger yearint = [self setNowTimeShow:0];
    [yearScrollView setCurrentSelectPage:(yearint-2002)];
    yearScrollView.delegate = self;
    yearScrollView.datasource = self;
    [self setAfterScrollShowView:yearScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:yearScrollView];
}
//设置年月日时分的滚动视图
- (void)setMonthScrollView
{
    monthScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(278.5/3, 0, 278.5/3, 190.0)];
    NSInteger monthint = [self setNowTimeShow:1];
    [monthScrollView setCurrentSelectPage:(monthint-3)];
    monthScrollView.delegate = self;
    monthScrollView.datasource = self;
    [self setAfterScrollShowView:monthScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:monthScrollView];
}
//设置年月日时分的滚动视图
- (void)setDayScrollView
{
    dayScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(278.5/3*2, 0, 278.5/3, 190.0)];
    NSInteger dayint = [self setNowTimeShow:2];
    [dayScrollView setCurrentSelectPage:(dayint-3)];
    dayScrollView.delegate = self;
    dayScrollView.datasource = self;
    [self setAfterScrollShowView:dayScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:dayScrollView];
}
//设置年月日时分的滚动视图
- (void)setHourScrollView
{
    hourScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(159.5, 0, 39.0, 190.0)];
    NSInteger hourint = [self setNowTimeShow:3];
    [hourScrollView setCurrentSelectPage:(hourint-2)];
    hourScrollView.delegate = self;
    hourScrollView.datasource = self;
    [self setAfterScrollShowView:hourScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:hourScrollView];
}
//设置年月日时分的滚动视图
- (void)setMinuteScrollView
{
    minuteScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(198.5, 0, 37.0, 190.0)];
    NSInteger minuteint = [self setNowTimeShow:4];
    [minuteScrollView setCurrentSelectPage:(minuteint-2)];
    minuteScrollView.delegate = self;
    minuteScrollView.datasource = self;
    [self setAfterScrollShowView:minuteScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:minuteScrollView];
}
//设置年月日时分的滚动视图
- (void)setSecondScrollView
{
    secondScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(235.5, 0, 43.0, 190.0)];
    NSInteger secondint = [self setNowTimeShow:5];
    [secondScrollView setCurrentSelectPage:(secondint-2)];
    secondScrollView.delegate = self;
    secondScrollView.datasource = self;
    [self setAfterScrollShowView:secondScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:secondScrollView];
}
- (void)setAfterScrollShowView:(MXSCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    [currentLabel setTextColor:[UIColor whiteColor]];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}
#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView
{
    if (scrollView == yearScrollView) {
        return 99;
    }
    else if (scrollView == monthScrollView)
    {
        return 12;
    }
    else if (scrollView == dayScrollView)
    {
        return 31;
    }
    else if (scrollView == hourScrollView)
    {
        return 24;
    }
    else if (scrollView == minuteScrollView)
    {
        return 60;
    }
    return 60;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView *)scrollView
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height/5)];
    l.tag = index+1;
    if (scrollView == yearScrollView) {
        l.text = [NSString stringWithFormat:@"%ld年",2000+index];
    }
    else if (scrollView == monthScrollView)
    {
        l.text = [NSString stringWithFormat:@"%ld月",1+index];
    }
    else if (scrollView == dayScrollView)
    {
        l.text = [NSString stringWithFormat:@"%ld日",1+index];
    }
    else if (scrollView == hourScrollView)
    {
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%ld",(long)index];
        }
        else
            l.text = [NSString stringWithFormat:@"%ld",(long)index];
    }
    else if (scrollView == minuteScrollView)
    {
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%ld",(long)index];
        }
        else
            l.text = [NSString stringWithFormat:@"%ld",(long)index];
    }
    else
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%ld",(long)index];
        }
        else
            l.text = [NSString stringWithFormat:@"%ld",(long)index];
    
    l.font = [UIFont systemFontOfSize:12];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    return l;
}
-(NSString *)To_FixDate:(NSString *)date
{
    NSArray *array = [date componentsSeparatedByString:@"-"];
    //Dlog(@"date:%@",array);
    NSInteger month=[[array objectAtIndex:1]integerValue];
    NSInteger day=[[array objectAtIndex:2]integerValue];
    if(month<10&&day<10)
    {
        return [NSString stringWithFormat:@"%@-0%ld-0%ld",[array objectAtIndex:0],(long)month,(long)day];
    }
    else if(month<10&&day>=10)
    {
        return [NSString stringWithFormat:@"%@-0%ld-%ld",[array objectAtIndex:0],(long)month,(long)day];
    }
    else if(month>=10&&day<10)
    {
        return [NSString stringWithFormat:@"%@-%ld-0%ld",[array objectAtIndex:0],(long)month,(long)day];
    }
    else
    {
        return [NSString stringWithFormat:@"%@-%ld-%ld",[array objectAtIndex:0],(long)month,(long)day];
    }
}
//设置现在时间
- (NSInteger)setNowTimeShow:(NSInteger)timeType
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    
    if(![Function isBlankString:app.str_Date])
    {
        dateString=app.str_Date;
    }
    dateString=[self To_FixDate:dateString];
    switch (timeType) {
        case 0:
        {
            NSRange range = NSMakeRange(0, 4);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 1:
        {
            NSRange range = NSMakeRange(5, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 2:
        {
            NSRange range = NSMakeRange(8, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 3:
        {
            NSRange range = NSMakeRange(11, 2);
            NSString *yearString = [dateString substringWithRange:range];
            //Dlog(@"%@",dateString);
            //Dlog(@"%@",yearString);
            return yearString.integerValue;
        }
            break;
        case 4:
        {
            NSRange range = NSMakeRange(14, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 5:
        {
            NSRange range = NSMakeRange(17, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        default:
            break;
    }
    return 0;
}
//选择设置的播报时间
- (void)selectSetBroadcastTime
{
//    UILabel *yearLabel = [[(UILabel*)[[yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
//    UILabel *monthLabel = [[(UILabel*)[[monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
//    UILabel *dayLabel = [[(UILabel*)[[dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
}
//滚动时上下标签显示(当前时间和是否为有效时间)
- (void)scrollviewDidChangeNumber
{
    UILabel *yearLabel = [[(UILabel*)[[yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *monthLabel = [[(UILabel*)[[monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *dayLabel = [[(UILabel*)[[dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    NSInteger yearInt = yearLabel.tag + 1999;
    NSInteger monthInt = monthLabel.tag;
    NSInteger dayInt = dayLabel.tag;
    NSString *str_date=[NSString stringWithFormat:@"%ld-%ld-%ld",(long)yearInt,(long)monthInt,(long)dayInt];
    NSString *str_2014_0X_0X=str_date;
    if(monthInt<10&&dayInt<10)
    {
        str_2014_0X_0X=[NSString stringWithFormat:@"%ld-0%ld-0%ld",(long)yearInt,(long)monthInt,(long)dayInt];
    }
    if(monthInt<10&&dayInt>=10)
    {
        str_2014_0X_0X=[NSString stringWithFormat:@"%ld-0%ld-%ld",(long)yearInt,(long)monthInt,(long)dayInt];
    }
    if(dayInt<10&&monthInt>=10)
    {
        str_2014_0X_0X=[NSString stringWithFormat:@"%ld-%ld-0%ld",(long)yearInt,(long)monthInt,(long)dayInt];
    }
  
    
    app.isDateLegal=[Function isOKDate :str_date];
    if(app.isDateLegal)
    {
        self.str_Date=str_2014_0X_0X;
        app.str_Date=str_2014_0X_0X;//把选中日期传给app.str_Date
        nowPickerShowTimeLabel.text = [NSString stringWithFormat:@"您选择了日期:%@",str_2014_0X_0X];
    }
    else
    {
        nowPickerShowTimeLabel.text = [NSString stringWithFormat:@"当前日期不合法无法"];
    }
}
//通过日期求星期
- (NSString*)fromDateToWeek:(NSString*)selectDate
{
    NSInteger yearInt = [selectDate substringWithRange:NSMakeRange(0, 4)].integerValue;
    NSInteger monthInt = [selectDate substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt = [selectDate substringWithRange:NSMakeRange(6, 2)].integerValue;
    int c = 20;//世纪
    long y = yearInt -1;//年
    long d = dayInt;
    long m = monthInt;
    long w =(y+(y/4)+(c/4)-2*c+(26*(m+1)/10)+d-1)%7;
    NSString *weekDay = @"";
    switch (w) {
        case 0:
            weekDay = @"周日";
            break;
        case 1:
            weekDay = @"周一";
            break;
        case 2:
            weekDay = @"周二";
            break;
        case 3:
            weekDay = @"周三";
            break;
        case 4:
            weekDay = @"周四";
            break;
        case 5:
            weekDay = @"周五";
            break;
        case 6:
            weekDay = @"周六";
            break;
        default:
            break;
    }
    return weekDay;
}

@end
