//
//  LeftViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "LeftViewController.h"
#import "leftCell.h"
#import "SecretViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "UserInfoViewController.h"
#import "LocationViewController.h"

@interface LeftViewController ()<SDWebImageDownloaderDelegate>
{
    NSArray *_tableData;
    NSArray *_imageData;
    AppDelegate *app;
}
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    _tableData = @[@"企业通讯录",@"个人资料",@"修改密码",@"安全退出"];
    _imageData = @[@"tel.png",@"userInfo.png",@"xiaoxi.png",@"shezhi.png"];
    [self _initView];
}

- (void)_initView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [self.view addSubview:headerView];
    
    //用户icon图标
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 38, 50, 50)];
    imageView.image = ImageName(@"80.png");
    imageView.layer.cornerRadius = 8;
    imageView.layer.masksToBounds = YES;
    [headerView addSubview:imageView];
    
    //用户名称
    UILabel *nameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+10, 43, 100, 30)];
    nameLabel.text          = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"];
    nameLabel.textColor     = [UIColor whiteColor];
    if (isIOS6) {
        nameLabel.backgroundColor = [UIColor clearColor];
    }
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font          = [UIFont systemFontOfSize:14.0];
    [headerView addSubview:nameLabel];
    
    //公司名称
    UILabel *companyLabel       = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+10, 65, 200, 30)];
    companyLabel.text           = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"coname"];
    companyLabel.textColor      = [UIColor whiteColor];
    if (isIOS6) {
        companyLabel.backgroundColor = [UIColor clearColor];
    }
    companyLabel.textAlignment  = NSTextAlignmentLeft;
    companyLabel.font           = [UIFont systemFontOfSize:11.0];
    [headerView addSubview:companyLabel];
    
    //下方表格
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240, Phone_Height)
                                              style:UITableViewStylePlain];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.tableHeaderView = headerView;
    _tableView.bounces = NO;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //tableView顶端的横条
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 200, 0.5)];
    imageView1.image = ImageName(@"xian.png");
    [_tableView addSubview:imageView1];
     
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *leftString = [defaults objectForKey:LEFT];
    NSString *backViewUrl = [[defaults objectForKey:APPBGIG] objectForKey:@"SidePullImage"];
    NSString *filepath=[Function achieveThe_filepath:[NSString stringWithFormat:@"%@/%@",MyFolder,SlideView]
                                                Kind:Library_Cache];
    if ([Function StringIsNotEmpty:filepath] && [leftString isEqualToString:@"1"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:filepath]];
        imageView.backgroundColor = [UIColor blackColor];
        [self.tableView setBackgroundView:imageView];
    }else {
        //开始下载
        [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:backViewUrl]
                                       delegate:self
                                       userInfo:@"slideView"];
    }
    [defaults setObject:@"1" forKey:LEFT];
    [defaults synchronize];
}

#pragma mark ---- UITableViewDataSource,UITableViewDelegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    leftCell *cell = (leftCell*)[tableView dequeueReusableCellWithIdentifier:@"leftCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"leftCell" owner:[leftCell class] options:nil];
        cell = (leftCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.leftimageView.frame = CGRectMake(26, 9, 26, 26);
    cell.leftimageView.image = ImageName([_imageData objectAtIndex:indexPath.row]);
    cell.leftTextLabel.text = [_tableData objectAtIndex:indexPath.row];
    cell.leftTextLabel.textColor = [UIColor whiteColor];
    cell.bottomImageView.height = 0.5;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            //企业通讯录
            LocationViewController *lVC=[[LocationViewController alloc]init];
            lVC.str_from=@"3";
            lVC.fromLeftStr = @"1";
            lVC.titleString = @"企业通讯录";
            [self.navigationController pushViewController:lVC animated:YES];
        }
            break;
        case 1:
        {
            //个人资料
            UserInfoViewController *userInfoVC = [UserInfoViewController new];
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
            break;
        case 2:
        {
            //修改密码
            SecretViewController *secretVC=[[SecretViewController alloc]init];
            [self.navigationController pushViewController:secretVC animated:YES];
        }
            break;
        case 3:
        {
            //安全退出
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

// 接收结果
- (void)imageDownloader:(SDWebImageDownloader *)downloader
     didFinishWithImage:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image , 1.0);
    [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,SlideView] Kind:Library_Cache];
    [Function creatTheFile:SlideView Kind:Library_Cache];
    [Function WriteToFile:SlideView File:imageData Kind:Library_Cache];
    
    NSString *filepath=[Function achieveThe_filepath:[NSString stringWithFormat:@"%@/%@",MyFolder,SlideView]
                                                Kind:Library_Cache];     //即使为空也没事
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:filepath]];
    imageView.backgroundColor = [UIColor blackColor];
    [self.tableView setBackgroundView:imageView];
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundView = imageView;
    NSLog(@"tableView background failed");
}

@end
