//
//  FilterViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15/6/25.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "FilterViewController.h"
#import "AppDelegate.h"

@interface FilterViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    AppDelegate *app;
    UITableView *_tableView;
    NSInteger    _selectSection;
    NSMutableArray *_sectionArray;      //section title array
    NSMutableDictionary *_mutDic;       //打开还是关闭的dic
    NSMutableDictionary *_mutDataDic;   //tableView data dic
    NSMutableDictionary *_mutHeightDic; //tableViewrow height
    NSMutableDictionary *_mutRedDic;    //存储红色or白色button的dic
}
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //标题
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    [self.view addSubview: [nav_View NavView_Title1:@"分类搜索"]];
    
    //init data
    _selectSection = 0;
    _mutDataDic   = [NSMutableDictionary dictionary];
    _mutRedDic    = [NSMutableDictionary dictionary];
    
    _sectionArray = [[NSMutableArray alloc] initWithObjects:@"品牌",@"类型",@"城市", nil];
    _mutDic       = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"0",@"1",@"1",@"1",@"2", nil];
    _mutHeightDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"0",@"0",@"0",@"1",@"0",@"2", nil];
    
    //set data
    [self setDic:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductBrandList] forKey:@"0"];
    [self setDic:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductTypeList]  forKey:@"1"];
    [self setDic:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductPooList]   forKey:@"2"];
    
    //将红色按钮的key value保存到字典
    NSArray *tempArray = @[@"0",@"1",@"2"];
    for (int i = 0; i < tempArray.count; i ++) {
        NSDictionary *tempDic = [_mutDataDic objectForKey:[tempArray objectAtIndex:i]];
        NSArray *tempArray = [NSArray array];
        if([app.str_Product_material isEqualToString:@"1"])//物料
        {
            tempArray=[tempDic objectForKey:@"1"];//数据表
        }else {
            tempArray=[tempDic objectForKey:@"0"];
        }
        for (NSString *tempStr in tempArray) {
            if (app.branchArray.count||app.typeArray.count||app.addressArray.count) {
                if ([app.branchArray containsObject:tempStr] ||
                    [app.typeArray containsObject:tempStr]  ||
                    [app.addressArray containsObject:tempStr]) {
                    [_mutRedDic setObject:@"1" forKey:tempStr];
                }else {
                    [_mutRedDic setObject:@"0" forKey:tempStr];
                }
            }else {
                [_mutRedDic setObject:@"0" forKey:tempStr];
            }
        }
    }
    
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag = 1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(320-44, 20, 44, 44)];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    searchBtn.tag = 2;
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    //tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, Phone_Height-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark ---- private method
- (void)btn_Action:(UIButton *)button {
    if (button.tag == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (button.tag == 2) {
        app.selectFlag = 1;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doButton:(UIButton *)button {
    NSString *sectionKey = [NSString stringWithFormat:@"%ld",(long)(button.tag - 100)];
    _selectSection = button.tag - 100;
    
    NSDictionary *tempDic = [_mutDataDic objectForKey:sectionKey];
    NSArray *tempArray = [NSArray array];
    if([app.str_Product_material isEqualToString:@"1"])//物料
    {
        tempArray=[tempDic objectForKey:@"1"];//数据表
    }else {
        tempArray=[tempDic objectForKey:@"0"];
    }
    
    if (tempArray.count) {
        if ([[_mutDic objectForKey:sectionKey] integerValue]) {
            [_mutDic setObject:@"0" forKey:sectionKey];
        }else {
            [_mutDic setObject:@"1" forKey:sectionKey];
        }
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:_selectSection];
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }else {
        [SGInfoAlert showInfo:@"此选项暂时无数据"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)setDic:(NSDictionary *)dic forKey:(NSString *)key {
    if (dic.count) {
        [_mutDataDic setObject:dic forKey:key];
    }else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [_mutDataDic setObject:dic forKey:key];
    }
}

- (void)selectItemButton:(UIButton *)button {
    if ([[_mutRedDic objectForKey:button.titleLabel.text] integerValue]) {
        [_mutRedDic setObject:@"0" forKey:button.titleLabel.text];
        [button setBackgroundImage:ImageName(@"btn_color1.png") forState:UIControlStateNormal];
        button.selected = NO;
        
        if (button.tag == 0) {
            if ([app.branchArray containsObject:button.titleLabel.text]) {
                [app.branchArray removeObject:button.titleLabel.text];
            }
        }else if (button.tag == 1) {
            if ([app.typeArray containsObject:button.titleLabel.text]) {
                [app.typeArray removeObject:button.titleLabel.text];
            }
        }else if (button.tag == 2) {
            if ([app.addressArray containsObject:button.titleLabel.text]) {
                [app.addressArray removeObject:button.titleLabel.text];
            }
        }
    }else {
        [_mutRedDic setObject:@"1" forKey:button.titleLabel.text];
        [button setBackgroundImage:ImageName(@"btn_color7.png") forState:UIControlStateNormal];
        button.selected = YES;
        
        if (button.tag == 0) {
            if (![app.branchArray containsObject:button.titleLabel.text]) {
                [app.branchArray addObject:button.titleLabel.text];
            }
        }else if (button.tag == 1) {
            if (![app.typeArray containsObject:button.titleLabel.text]) {
                [app.typeArray addObject:button.titleLabel.text];
            }
        }else if (button.tag == 2) {
            if (![app.addressArray containsObject:button.titleLabel.text]) {
                [app.addressArray addObject:button.titleLabel.text];
            }
        }
    }
}

#pragma mark ---- UITableView delegate and datasource
//设置表头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//Section Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor colorWithPatternImage:ImageName(@"back")];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, tableView.frame.size.width-20, 30)];
    titleLabel.text = [_sectionArray objectAtIndex:section];
    [view addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 12, 15, 15)];
    imageView.tag = 20000+section;
    
    //判断是不是选中状态
    NSString *string = [NSString stringWithFormat:@"%ld",(long)section];
    
    if ([[_mutDic objectForKey:string] integerValue]) {
        imageView.image = [UIImage imageNamed:@"buddy_header_arrow_down@2x.png"];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"buddy_header_arrow_right@2x.png"];
    }
    [view addSubview:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 320, 40);
    button.tag = 100+section;
    [button addTarget:self action:@selector(doButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, 320, 1)];
    lineImage.image = [UIImage imageNamed:@"line1.png"];
    [view addSubview:lineImage];
    
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *string = [NSString stringWithFormat:@"%ld",(long)section];
    if ([[_mutDic objectForKey:string] integerValue]) {
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    if ([[_mutDic objectForKey:string] integerValue]) {
        NSString *cellIdentifier = @"cellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSDictionary *tempDic = [_mutDataDic objectForKey:string];
        NSArray *tempArray = [NSArray array];
        if([app.str_Product_material isEqualToString:@"1"])//物料
        {
            tempArray=[tempDic objectForKey:@"1"];//数据表
        }else {
            tempArray=[tempDic objectForKey:@"0"];
        }
        
        if (tempArray.count) {
            NSInteger line = tempArray.count/3+1;
            NSInteger list = 0;
            if (line > 1) {
                list = 3;
            }else {
                list = tempArray.count%3;
            }
            
            for (UIView *viewObj in cell.contentView.subviews) {
                if ([viewObj isKindOfClass:[UIButton class]]) {
                    [viewObj removeFromSuperview];
                }
            }
            
            for (int i = 0; i < line; i ++) {
                for (int j = 0; j < list; j ++) {
                    if (j+i*3 < tempArray.count) {
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        [button.layer setCornerRadius:4.0];
                        button.layer.masksToBounds = YES;
                        button.tag = indexPath.section;
                        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
                        button.frame = CGRectMake(20*(j+1)+80*j, 10*(i+1)+40*i, 80, 40);
                        [button setTitle:[tempArray objectAtIndex:j+i*3] forState:UIControlStateNormal];
                        if ([[_mutRedDic objectForKey:[tempArray objectAtIndex:j+i*3]] integerValue]) {
                            [button setBackgroundImage:ImageName(@"btn_color7.png") forState:UIControlStateNormal];
                        }else {
                            [button setBackgroundImage:ImageName(@"btn_color1.png") forState:UIControlStateNormal];
                        }
                        [button addTarget:self action:@selector(selectItemButton:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:button];
                    }
                }
            }

            NSString *heightStr = [NSString stringWithFormat:@"%ld",(long)(10*(line+1)+40*line)];
            [_mutHeightDic setObject:heightStr forKey:string];
        }
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    if ([[_mutDic objectForKey:string] integerValue]) {
        return [[_mutHeightDic objectForKey:string] floatValue];
    }
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
