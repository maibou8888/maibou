//
//  LocationViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "LocationViewController.h"
#import "SearchCell.h"
#import "AppDelegate.h"
#import "SearchCoreManager.h"
#import "ContactPeople.h"
#define  searchHeight 44
#define  Edge     35
#define CheckDateNull(date)   (![date isKindOfClass:[NSDate class]]||(date == nil)) ? ([NSDate date]) : date
@interface LocationViewController ()

@end

@implementation LocationViewController
{
    AppDelegate *app;
    BOOL allFlag;
}
@synthesize searchBar;
@synthesize contactDic;
@synthesize searchByName;
@synthesize searchByPhone;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    dic_add=[NSMutableDictionary dictionaryWithCapacity:10];
    arr_Inform=[[NSMutableArray alloc]init];
    array_Data_back=[[NSMutableArray alloc]init];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    //处理导航start
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.titleString]];
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    
    for(NSInteger i=0;i<2;i++)
    {//左边返回键 右边扫描二维码 添加新订单
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
            btn.backgroundColor=[UIColor clearColor];
        }
        else
        {
            if([self.str_from isEqualToString:@"1"]||[self.str_from isEqualToString:@"3"])
                continue;
            //只有任务交办有确定按键
            btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"确定" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
            btn.backgroundColor=[UIColor clearColor];
        }
        btn.tag=buttonTag+i;
        
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
    }
    
    if ([self.str_from isEqualToString:@"2"]) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(Phone_Weight-88, moment_status, 44, 44);
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(selectALLPeople) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"全选" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        btn.backgroundColor=[UIColor clearColor];
        [nav_View.view_Nav  addSubview:btn];
    }
    
    [self searchBarInit];
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
}

- (void) selectALLPeople {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择全部人员" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 222;
    [alertView show];
}

- (void)searchBarInit
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,moment_status+44 , Phone_Weight, searchHeight)];
    
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.backgroundColor=[UIColor clearColor];//修改搜索框背景
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.translucent=YES;
    self.searchBar.placeholder=@"搜索";
    //self.searchBar.tintColor=Orange;
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton=YES;
    self.searchBar.barStyle=UIBarStyleDefault;
    // [[self.searchBar.subviews objectAtIndex:2] setHidden:YES ];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_searchbar.png"]];
    imageView.frame=CGRectMake(20, 10, searchBar.frame.size.width-40, searchBar.frame.size.height-20);
    // [self.searchBar insertSubview:imageView atIndex:0];
    
    [self.view addSubview:self.searchBar];
    //   self.tableView.tableHeaderView=self.searchBar;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self All_Init];
    [self Get_Data];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    dic=nil;
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    nameIDArray=nil;
    NSMutableArray *phoneIDArray = [[NSMutableArray alloc] init];
    
    self.searchByPhone = phoneIDArray;
    phoneIDArray=nil;
    
    //添加到搜索库
    for (NSInteger i = 0; i < arr_Inform.count; i ++) {
        NSDictionary *dic=[arr_Inform objectAtIndex:i];
        ContactPeople *contact = [[ContactPeople alloc] init];
        contact.localID = [NSNumber numberWithInteger:i];
        contact.name = [dic objectForKey:@"uname"];
        NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
        [phoneArray addObject:[dic objectForKey:@"indexRow"]];
        [phoneArray addObject:[dic objectForKey:@"index_no"]];
        [phoneArray addObject:[dic objectForKey:@"umtel"]];
        [phoneArray addObject:[dic objectForKey:@"section"]];
        [phoneArray addObject:[dic objectForKey:@"utype"]];
        
        contact.phoneArray = phoneArray;
        // //Dlog(@"%@",phoneArray);
        
        [[SearchCoreManager share] AddContact:contact.localID name:contact.name phone:contact.phoneArray];
        [self.contactDic setObject:contact forKey:contact.localID];
        phoneArray=nil;
        contact=nil;
    }
    isSearching=NO;
    self.searchBar.text=@"";
}
-(void)viewWillDisappear:(BOOL)animated
{
    for (id obj in self.view.subviews) {
        if ([obj isKindOfClass:[UIView class]] ) {
            [obj removeFromSuperview];
        }
    }
    [self.searchBar resignFirstResponder];
    [[SearchCoreManager share]Reset];
    arr_H1=nil;
    dic_UserList=nil;
    arr_Key=nil;
    arr_Inform=nil;
    dic_add=nil;
}
-(void)Get_Data
{
    /*
     self.str_from;// 1---从轨迹进入 2----任务交办 3---后续审批人
     if(boss4)
     {
     一直都是所有人  单选
     }
     else if(部门经理2)
     {
     if(1)
     {
     本部门 单选
     }
     else if(2)
     {
     本部门  多选
     }
     else if(3)
     {
     所有人 单选
     }
     }
     else  if(普通员工1)
     {
     不可见此功能
     }
     */
    /*
     if(auth==4&&gbelongto为空 )全都显示
     else 只展示 gbelongto 一组的
     */
    // //Dlog(@"%@",[BasicData sharedInstance].dic_BasicData);
    arr_Key=[[NSMutableArray alloc]init];
    dic_UserList=[[BasicData sharedInstance].dic_BasicData objectForKey:@"UserList"];
    NSDictionary *dic_H=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H1=[dic_H objectForKey:@"H1"];//所有的head
    ////Dlog(@"%@",dic_UserList);
    section=0;
    gbelongto=[[SelfInf_Singleton sharedInstance].dic_SelfInform  objectForKey:@"gbelongto"];
    auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform  objectForKey:@"auth"];
    
    if(([ auth isEqualToString:@"4"]&&[ gbelongto isEqualToString:@"-1"])||[self.str_from isEqualToString:@"3"])
    {//是boss 或者是 审批想 gbelongto为-1是不隶属于任何部门 e.g. boss
        [self All_People];
        isSelectOne=YES;
    }
    else if([ auth isEqualToString:@"2"])
    {//部门经理
        if([self.str_from isEqualToString:@"1"])
        {
            isSelectOne=YES;
            [self My_Mention];
        }
        else if([self.str_from isEqualToString:@"2"])
        {
            [self My_Mention];
        }
        /*
         else if([self.str_from isEqualToString:@"3"])
         {
         isSelectOne=YES;
         [self All_People];
         }
         */
    }
    [self TableView];
}
-(void)All_People//所有人
{
    for (NSInteger i=0; i<arr_H1.count; i++) {
        NSDictionary *dic_arr_every=[arr_H1 objectAtIndex:i];
        NSArray *arr=[dic_UserList objectForKey:[dic_arr_every objectForKey:@"cvalue"]];
        
        if(arr.count!=0)
        {
            NSMutableDictionary *dic_Key=[NSMutableDictionary dictionaryWithCapacity:2];
            [dic_Key setObject:[dic_arr_every objectForKey:@"clabel"] forKey:@"clabel"];
            [dic_Key setObject:[dic_arr_every objectForKey:@"cvalue"] forKey:@"cvalue"];
            [arr_Key addObject:dic_Key];
            dic_Key=nil;
            ////Dlog(@"%@",arr);
            for (NSInteger i=0;i<arr.count; i++)
            {
                NSDictionary *dict=[arr objectAtIndex:i];
                NSMutableDictionary *dic1=[NSMutableDictionary dictionaryWithCapacity:4];
                [dic1 setObject:[dict objectForKey:@"index_no"] forKey:@"index_no"];
                [dic1 setObject:[dict objectForKey:@"uname"] forKey:@"uname"];
                [dic1 setObject:[NSString stringWithFormat:@"%ld",(long)section]forKey:@"section"];//第几组
                [dic1 setObject:[NSString stringWithFormat:@"%ld",(long)i] forKey:@"indexRow"];
                [dic1 setObject:[dict objectForKey:@"umtel"] forKey:@"umtel"];
                [dic1 setObject:[dic_arr_every objectForKey:@"clabel"] forKey:@"section"];
                if([Function isBlankString:[dict objectForKey:@"utype"]])
                {
                    [dic1 setObject:@"-1" forKey:@"utype"];
                }
                else
                {
                    [dic1 setObject:[dict objectForKey:@"utype"] forKey:@"utype"];
                }
                [arr_Inform addObject:dic1];
                dic1=nil;
                dict=nil;
            }
            section++;
        }
        dic_arr_every=nil;
    }
    
}
-(void)My_Mention//本部门
{
    section=0;
    for(NSInteger i=0;i<arr_H1.count;i++)
    {
        NSDictionary *dic_arr=[arr_H1 objectAtIndex:i];
        if([[dic_arr objectForKey:@"cvalue"] isEqualToString:gbelongto])
        {
            NSMutableDictionary *dic_Key=[NSMutableDictionary dictionaryWithCapacity:2];
            [dic_Key setObject:[dic_arr objectForKey:@"clabel"] forKey:@"clabel"];
            [dic_Key setObject:[dic_arr  objectForKey:@"cvalue"] forKey:@"cvalue"];
            [arr_Key addObject:dic_Key];
            
            NSArray *arr=[dic_UserList objectForKey:[dic_arr objectForKey:@"cvalue"]];
            for (NSInteger i=0;i<arr.count; i++)
            {
                NSDictionary *dict=[arr objectAtIndex:i];
                NSMutableDictionary *dic1=[NSMutableDictionary dictionaryWithCapacity:4];
                [dic1 setObject:[dict objectForKey:@"index_no"] forKey:@"index_no"];
                [dic1 setObject:[dict objectForKey:@"uname"] forKey:@"uname"];
                [dic1 setObject:[NSString stringWithFormat:@"%ld",(long)section]forKey:@"section"];//第几组
                [dic1 setObject:[NSString stringWithFormat:@"%ld",(long)i] forKey:@"indexRow"];
                [dic1 setObject:[dict objectForKey:@"umtel"] forKey:@"umtel"];
                [dic1 setObject:[dic_arr objectForKey:@"clabel"] forKey:@"section"];
                if([Function isBlankString:[dict objectForKey:@"utype"]])
                {
                    [dic1 setObject:@"-1" forKey:@"utype"];
                }
                else
                {
                    [dic1 setObject:[dict objectForKey:@"utype"] forKey:@"utype"];
                }
                [arr_Inform addObject:dic1];
                dic1=nil;
                dict=nil;
            }
            dic_Key=nil;
            break;
        }
    }
    
}
-(void)TableView
{
    tableView_Inform=[[UITableView alloc]initWithFrame:CGRectMake(0, 44+moment_status+searchHeight, Phone_Weight,Phone_Height-44-moment_status-searchHeight)];
    
    tableView_Inform.backgroundColor=[UIColor clearColor];
    [self.view addSubview:tableView_Inform];
    tableView_Inform.separatorStyle = UITableViewCellSeparatorStyleNone;//隐藏tableViewCell的分割线
    tableView_Inform.dataSource=self;
    tableView_Inform.delegate=self;
}
#pragma tableView  Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section1
{
    if (!section1 == 0) {
        
        return 46.0;
    } else {
        return 46.0;
    }
}
//cell  高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 120;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section1
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor clearColor];
    
    UIImageView *viewCell;
    UILabel *titleLabel = [[UILabel alloc] init];
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 46)];
    titleLabel.frame= CGRectMake(30, 0, Phone_Weight-30, 46);
    viewCell.image=[UIImage imageNamed:@"cell_select_sectionBackground.png"];
    [myView addSubview:viewCell];
    titleLabel.font=[UIFont systemFontOfSize:20];
    
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    if(isSearching)
    {
        titleLabel.text=@"检索结果如下:";
    }
    else
    {
        NSDictionary *dic=[arr_Key objectAtIndex:section1];
        titleLabel.text=[dic objectForKey:@"clabel"];
        dic=nil;
    }
    [myView addSubview:titleLabel];
    return myView;
}
//一共有几组 返回有几个 section 块
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(isSearching)
        return 1;
    return  arr_Key.count ;
}
//每组有几行  返回 每个块 有几行cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section1 {
    if(isSearching)
    {
        if ([self.searchBar.text length] <= 0) {
            if([self.contactDic count]==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
            return [self.contactDic count];
        } else {
            if([self.searchByName count] + [self.searchByPhone count]==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
            return [self.searchByName count] + [self.searchByPhone count];
        }
    }
    else
    {
        NSDictionary *dic_key=[arr_Key objectAtIndex: section1];
        if(([ auth isEqualToString:@"4"]&&[gbelongto isEqualToString:@"-1"])||[self.str_from isEqualToString:@"3"])
        {
            NSArray *arr=[dic_UserList objectForKey:[dic_key objectForKey:@"cvalue"] ];
            if(arr.count==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
            return arr.count;
        }
        else
        {
            if(arr_Inform.count==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
            //Dlog(@" Test1  %d",arr_Inform.count);
            return arr_Inform.count;
        }
        
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *cell=(SearchCell*)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:[SearchCell class] options:nil];
        cell = (SearchCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"];
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;
    
    cell.backgroundColor=[UIColor clearColor];
    //cell.lab_uname.textAlignment=NSTextAlignmentCenter;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    cell.userInteractionEnabled=YES;
    UIButton *button_cell_select=[UIButton buttonWithType:UIButtonTypeCustom];
    if (![self fromLeft]) {
        [button_cell_select addTarget:self action:@selector(add_Action:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [cell addSubview:button_cell_select];
    //添加打电话或发信息功能start
    UIButton *btn_tel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_tel setImage:[UIImage imageNamed:@"icon_select_call.png"] forState:UIControlStateNormal];
    btn_tel.backgroundColor=[UIColor clearColor];
    [btn_tel addTarget:self action:@selector(Action_Tel:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn_tel];
    
    UIButton *btn_msg=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_msg setImage:[UIImage imageNamed:@"icon_select_send.png"] forState:UIControlStateNormal];
    btn_msg.backgroundColor=[UIColor clearColor];
    [btn_msg addTarget:self action:@selector(Action_Msg:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn_msg];
    //添加打电话或发信息功能end
    button_cell_select.frame=CGRectMake(0,0, 229, 119);
    btn_tel.frame=CGRectMake(229, 0, 45, 119);
    btn_msg.frame=CGRectMake(275, 0, 45, 119);
    if(isSearching)
    {
        NSNumber *localID = nil;
        NSMutableString *matchString = [NSMutableString string];
        NSMutableArray *matchPos = [NSMutableArray arrayWithCapacity:0];
        if (indexPath.row < [searchByName count]) {
            localID = [self.searchByName objectAtIndex:indexPath.row];
            
            //姓名匹配 获取对应匹配的拼音串 及高亮位置
            if ([self.searchBar.text length]) {
                [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
            }
        } else {
            localID = [self.searchByPhone objectAtIndex:indexPath.row-[searchByName count]];
            NSMutableArray *matchPhones = [NSMutableArray arrayWithCapacity:0];
            
            //号码匹配 获取对应匹配的号码串 及高亮位置
            if ([self.searchBar.text length]) {
                [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
                [matchString appendString:[matchPhones objectAtIndex:0]];
            }
        }
        ContactPeople *contact = [self.contactDic objectForKey:localID];
        
        cell.lab_uname.text = contact.name;
        cell.lab_section.text=[contact.phoneArray objectAtIndex:3];
        cell.lab_tel.text=[contact.phoneArray objectAtIndex:2];
        cell.imgView_head.backgroundColor=[UIColor clearColor];
        if([[contact.phoneArray objectAtIndex:4]isEqualToString:@"0"])
        {
            cell.imgView_head.image=[UIImage imageNamed:@"icon_select_1"];
        }
        else if([[contact.phoneArray objectAtIndex:4]isEqualToString:@"1"])
        {
            cell.imgView_head.image=[UIImage imageNamed:@"icon_select_0"];
        }
        
        cell.detailTextLabel.text = matchString;
        button_cell_select.tag=[contact.localID integerValue];
        btn_tel.tag=[contact.localID integerValue];
        btn_msg.tag=[contact.localID integerValue];
    }
    else
    {
        if(([ auth isEqualToString:@"4"]&&[gbelongto isEqualToString:@"-1"])||[self.str_from isEqualToString:@"3"])
        {//能看所有人
            NSDictionary *dic_key=[arr_Key objectAtIndex: indexPath.section];
            NSArray *arr=[dic_UserList objectForKey:[dic_key objectForKey:@"cvalue"] ];
            NSDictionary *dic=[arr objectAtIndex:indexPath.row];
            cell.lab_uname.text=[dic objectForKey:@"uname"];
            cell.lab_section.text=[dic_key objectForKey:@"clabel"];
            cell.lab_tel.text=[dic objectForKey:@"umtel"];
            cell.imgView_head.backgroundColor=[UIColor clearColor];
            if([[dic objectForKey:@"utype"]isEqualToString:@"0"])
            {
                cell.imgView_head.image=[UIImage imageNamed:@"icon_select_1"];
            }
            else if([[dic objectForKey:@"utype"]isEqualToString:@"1"])
            {
                cell.imgView_head.image=[UIImage imageNamed:@"icon_select_0"];
            }
            arr=nil;
            Index=0;
            for (NSInteger i=0;i<indexPath.section;i++) {
                NSDictionary *dic_key1=[arr_Key objectAtIndex: i];
                
                
                NSArray *arr1=[dic_UserList objectForKey:[dic_key1 objectForKey:@"cvalue"] ];
                Index+=arr1.count;
                arr1=nil;
            }
            Index+=(indexPath.row);
            button_cell_select.tag=Index;
            btn_tel.tag=Index;
            btn_msg.tag=Index;
        }
        else
        {
            button_cell_select.tag=indexPath.row;
            btn_msg.tag=indexPath.row;
            btn_tel.tag=indexPath.row;
            NSDictionary *dic=[arr_Inform objectAtIndex:indexPath.row];
            cell.lab_uname.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"uname"]];
            cell.lab_tel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"umtel"]];
            cell.lab_section.text=[dic objectForKey:@"section"];
            cell.imgView_head.backgroundColor=[UIColor clearColor];
            if([[dic objectForKey:@"utype"]isEqualToString:@"0"])
            {
                cell.imgView_head.image=[UIImage imageNamed:@"icon_select_1"];
            }
            else if([[dic objectForKey:@"utype"]isEqualToString:@"1"])
            {
                cell.imgView_head.image=[UIImage imageNamed:@"icon_select_0"];
            }
        }
    }
    if([[dic_add objectForKey:[NSString stringWithFormat:@"%ld",(long)button_cell_select.tag]] isEqualToString:@"1"])
    {
        cell.imgView_isSeleted.image=[UIImage imageNamed:@"cell_selcted_btn"];
    }
    else
    {
        cell.imgView_isSeleted.image=[UIImage imageNamed:@"cell_unselcted_btn"];
    }
    
    if ([self fromLeft]) {
        cell.imgView_isSeleted.hidden = YES;
        cell.imgView_head.left = 20;
        cell.sectionImg.left = 20;
        cell.telImg.left = 20;
        
        cell.lab_uname.left = 68;
        cell.lab_tel.left = 68;
        cell.lab_section.left = 68;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)Action_Tel:(UIButton*)btn
{//电话 5
    //Dlog(@"电话");
    NSDictionary *dic=[arr_Inform objectAtIndex:btn.tag];
    //Dlog(@"%@",[dic objectForKey:@"umtel"]);
    str_tel=[dic objectForKey:@"umtel"];
    [self Alert_Title:@"提示" msg:[NSString stringWithFormat:@"现在要给%@打电话",[dic objectForKey:@"uname"]] Tag:13];
}
-(void)Action_Msg:(UIButton *)btn
{//短信 6
    //Dlog(@"短信");
    NSDictionary *dic=[arr_Inform objectAtIndex:btn.tag];
    //Dlog(@"%@",[dic objectForKey:@"umtel"]);
    str_tel=[dic objectForKey:@"umtel"];
    [self Alert_Title:@"提示" msg:[NSString stringWithFormat:@"现在要给%@发信息",[dic objectForKey:@"uname"]] Tag:12];
}
- (void)Alert_Title:(NSString *)title msg:(NSString *)msg Tag:(NSInteger)tag{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];
    alert.tag=tag;
    alert=nil;
}
- (void)showMessageView:(NSString *)tel
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:tel];
        //controller.body = @"测试发短信";
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"短信"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}
//MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];//关键的一句   不能为YES
}
- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10||alertView.tag==11)//danxuan
    {
        if(buttonIndex==1)
        {
            if([self.str_from isEqualToString:@"1"])//从轨迹来
            {
                LocationPersonViewController *locVC=[[LocationPersonViewController alloc]init];
                [self.navigationController pushViewController:locVC animated:YES];
                return;
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
    }
    if(alertView.tag==12)//短信
    {
        if(buttonIndex==1)
        {
            [self showMessageView:str_tel];
            str_tel=@"";
        }
    }
    else if(alertView.tag==13)
    {//电话
        if(buttonIndex==1)
        {
            if (![Function isBlankString:str_tel])
            {
                UIWebView*callWebview =[[UIWebView alloc] init];
                NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",str_tel]];// 貌似tel:// 或者 tel: 都行
                [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
                //记得添加到view上
                [self.view addSubview:callWebview];
            }
            else
            {
                [SGInfoAlert showInfo:@"号码不合法"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
        }
    }else if (alertView.tag == 222) {
        if (buttonIndex == 1) {
            allFlag = YES;
            [self AccountWho];
        }
    }
}
-(void)add_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    //Dlog(@"%d",btn.tag);
    if([self.str_from isEqualToString:@"1"]||[self.str_from isEqualToString:@"3"])
    {
        [dic_add removeAllObjects];
        [self Account_Select:btn];
        NSDictionary *dic=[arr_Inform objectAtIndex:btn.tag];
        app.str_index_no=[dic objectForKey:@"index_no"];
        app.str_workerName=[dic objectForKey:@"uname"];
        [self ShowAlertView:app.str_workerName Tag:11];
    }
    else
    {
        [self Account_Select:btn];
    }
}
-(void)Account_Select:(UIButton *)btn//计算给谁打了对勾 或者取消了打对勾
{
    if([[dic_add objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]] isEqualToString:@"1"])
    {
        [dic_add setObject:@"0" forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    }
    else
    {
        [dic_add setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    }
    [tableView_Inform reloadData];
    
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag)//返回
    {
        if([self.str_from isEqualToString:@"3"])
        {
            
        }
        else
        {
            app.str_index_no=@"";
            app.str_workerName=@"";
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self AccountWho];  //任务交办的确定button点击事件
        
    }
}
-(void)AccountWho//计算 选择了 谁
{
    if (allFlag) {
        allFlag = 0;
        for (int i = 0; i < arr_Inform.count; i ++) {
            [dic_add setObject:@"1" forKey:[NSString stringWithFormat:@"%d",i]];
            [tableView_Inform reloadData];
        }
    }
    
    if(dic_add.count==0)
    {
        [SGInfoAlert showInfo:@"您还没选择人员"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return;
    }
    NSMutableString *str=[NSMutableString stringWithCapacity:1];
    NSMutableString *str_index=[NSMutableString stringWithCapacity:app.arr_uname_indexno.count];
    BOOL isOK=NO;
    for (NSInteger i=0; i<arr_Inform.count; i++)
    {
        if ([[dic_add objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] isEqualToString:@"1"])
        {
            NSDictionary *dic=[arr_Inform objectAtIndex:i];
            [str appendString:[dic objectForKey:@"uname"]];
            [str_index appendString:[dic objectForKey:@"index_no"]];
            [str_index appendString:@","];  //多选的时候分隔开
            [str appendString:@" "];
            isOK=YES;
        }
    }
    if(!isOK)
    {
        [SGInfoAlert showInfo:@"您还没选择人员"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return;
    }
    app.str_workerName=str;
    app.str_index_no=[str_index substringWithRange:NSMakeRange(0, str_index.length-1)];
    [self ShowAlertView:str Tag:10];
    str=nil;
    str_index=nil;
}

-(void)ShowAlertView :(NSString *)message Tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您选择的人员是:"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles: @"确定",nil];
    [alert show];
    alert.tag=tag;
    alert=nil;
}

#pragma mark -
#pragma mark search bar delegate methods
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    isSearching=YES;
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:self.searchByPhone];
    
    [tableView_Inform reloadData];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching=NO;
    [self.searchBar resignFirstResponder];
    [tableView_Inform reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (BOOL)fromLeft {
    if ([self.fromLeftStr isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
