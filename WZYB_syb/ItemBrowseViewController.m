//
//  ItemBrowseViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15/6/24.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ItemBrowseViewController.h"
#import "AppDelegate.h"
#import "ChooseView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationSpring.h"

#define NUMBERS @"0123456789\n"

@interface ItemBrowseViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>
{
    AppDelegate *app;
    UITableView *itemTableView;
    NSInteger   btnTag;
    UITextField *myTextfield;
    NSString    *urlString;
    ChooseView* chooseView;
    
    NSString *chooseTFStr;
    NSString *chooseTWStr;
    BOOL switchFlag;
}
@end

@implementation ItemBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initView];      //页面初始化
    [self _initTableView]; //初始化tableView
}

#pragma mark ---- private method
- (void)_initView
{
    //title
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    [self.view addSubview: [nav_View NavView_Title1:@"产品列表"]];

    btnTag = 0;
    
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:14];
    
    //右边订购按钮
    UIButton *refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(320-70, 20, 70, 44)];
    [refreshBtn setTitle:@"确认项目" forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    refreshBtn.tag = 2;
    [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshBtn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [refreshBtn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshBtn];
    
    urlString  = [NSString string];
    chooseView = [ChooseView defaultPopupView];
    
    switchFlag = 0;
    chooseTFStr = [NSString string];
    chooseTWStr = [NSString string];
}

- (void)_initTableView {
    itemTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, Phone_Height-64) style:UITableViewStylePlain];
    itemTableView.delegate = self;
    itemTableView.dataSource = self;
    [self.view addSubview:itemTableView];
}

- (void)btn_Action:(UIButton *)button {
    if (button.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if(button.tag == 2){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"确定项目"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)showOkayCancelAlert:(UIButton *)button {
    NSDictionary *dic=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:btnTag];
    
    if (app.GiftFlagStr.integerValue) {
        [self whenFlagTrueShowAlert:dic];
    }else {
        btnTag = button.tag;
        if (isIOS8) {
            NSString *message = NSLocalizedString(@"请输入订购数量", nil);
            NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
            NSString *otherButtonTitle = NSLocalizedString(@"修改", nil);
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            // Create the actions.
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                NSLog(@"取消");
            }];
            
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (myTextfield.text.integerValue) {
                    [self setItem];
                }
            }];
            
            // Add the actions.
            [alertController addAction:cancelAction];
            [alertController addAction:otherAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                myTextfield = textField;
                myTextfield.text = [dic objectForKey:@"cnt"];
                // 可以在这里对textfield进行定制，例如改变背景色
                myTextfield.backgroundColor = [UIColor orangeColor];
                myTextfield.textColor = [UIColor whiteColor];
                myTextfield.font = [UIFont systemFontOfSize:17.0];
                myTextfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                myTextfield.delegate = self;
            }];
        }else {
            [self showAlert_IOS7];
        }
    }
}

- (void)whenFlagTrueShowAlert:(NSDictionary *)dic
{
    chooseView.switchBtn.on = [[dic objectForKey:@"switch"] boolValue];
    chooseView.numberTextField.text = [dic objectForKey:@"cnt"];
    chooseView.remarkTextView.text = [dic objectForKey:@"remark"];
    chooseView.numberTextField.delegate = self;
    chooseView.remarkTextView.delegate = self;
    chooseView.parentVC = self;
    [chooseView.sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [self lew_presentPopupView:chooseView
                     animation:[LewPopupViewAnimationSpring new]
                     dismissed:^{
                     }];
}

- (void)sureAction
{
    switchFlag  = chooseView.switchBtn.on;
    chooseTFStr = chooseView.numberTextField.text;
    chooseTWStr = chooseView.remarkTextView.text;
    
    [self lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
    
    if (chooseTFStr.integerValue) {
        [self setItem];
    }
}

- (void)showAlert_IOS7 {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入订购数量" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改",nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    NSDictionary *dic=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:btnTag];
    myTextfield = [alert textFieldAtIndex:0];
    myTextfield.placeholder = [dic objectForKey:@"cnt"];
    myTextfield.delegate = self;
    [alert show];
}

- (void)setItem {
    NSDictionary *tempDic = [[AddProduct sharedInstance].arr_AddToList objectAtIndex:btnTag];
    if (!self.returnFlag) {
        if (([[tempDic objectForKey:@"stock_cnt"] integerValue] < myTextfield.text.integerValue) || ([[tempDic objectForKey:@"stock_cnt"] integerValue] < chooseTFStr.integerValue)) {
            [SGInfoAlert showInfo:@"您的订购数量超过了库存数量,请重新选择订购数量"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return;
        }
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *keyArray = [tempDic allKeys];
    NSArray *valueArray = [tempDic allValues];
    for (int i = 0; i < keyArray.count; i ++) {
        [dic setObject:[valueArray objectAtIndex:i] forKey:[keyArray objectAtIndex:i]];
    }
    
    NSString *totalPrice_s = nil;
    NSString *totalPrice_r = nil;
    if (app.GiftFlagStr.integerValue) {
        [dic setObject:chooseTFStr forKey:@"cnt"];
        [dic setObject:chooseTWStr forKey:@"remark"];
        NSString *switchString = [NSString stringWithFormat:@"%d",switchFlag];
        [dic setObject:switchString forKey:@"switch"];
        totalPrice_s = [NSString stringWithFormat:@"%ld",
                        (long)chooseTFStr.integerValue*([[tempDic objectForKey:@"price"] integerValue])];
        if (switchFlag) {
            totalPrice_r = @"0";
        }else {
            totalPrice_r = [NSString stringWithFormat:@"%ld",
                            (long)chooseTFStr.integerValue*([[tempDic objectForKey:@"selling_price"] integerValue])];
        }
    }else {
        [dic setObject:myTextfield.text forKey:@"cnt"];
        totalPrice_s = [NSString stringWithFormat:@"%ld",
                        (long)myTextfield.text.integerValue*([[tempDic objectForKey:@"price"] integerValue])];
        totalPrice_r = [NSString stringWithFormat:@"%ld",
                        (long)myTextfield.text.integerValue*([[tempDic objectForKey:@"selling_price"] integerValue])];
    }
    [dic setObject:totalPrice_s forKey:@"should"];
    [dic setObject:totalPrice_r forKey:@"real_rsum"];
    [[AddProduct sharedInstance].arr_AddToList replaceObjectAtIndex:btnTag withObject:dic];
    [itemTableView reloadData];
}

//批量取得商品价格和库存
- (void)getBatchPriceAndInventoryForGoods {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal) {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,BatchGoods];
        }
        else {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,BatchGoods];
        }
        NSURL *url = [NSURL URLWithString:urlString];
        
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.cIndexNumber forKey:@"cindex_no"];
        if (self.meterialFlag) {
            NSString *meterialStr = [NSString stringWithFormat:@"%ld",(long)self.meterialFlag];
            [request setPostValue:meterialStr forKey:@"mptype"];
        }
        
        for (int i = 0; i < [AddProduct sharedInstance].arr_AddToList.count; i ++) {
            NSString *tempKey = [NSString stringWithFormat:@"postList[%d].pindex_no",i];
            NSDictionary *tempDic = [[AddProduct sharedInstance].arr_AddToList objectAtIndex:i];
            
            if ([Function StringIsNotEmpty:[tempDic objectForKey:@"pindex_no"]]) {
                [request setPostValue:[tempDic objectForKey:@"pindex_no"] forKey:tempKey];
            }
        }
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

#pragma mark ---- ASIHTTPRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString * jsonString  =  [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    NSArray *dataArray = [dict objectForKey:@"ProductList"];
    
    for (int i = 0; i < [AddProduct sharedInstance].arr_AddToList.count; i ++) {
        NSDictionary *dic = [[AddProduct sharedInstance].arr_AddToList objectAtIndex:i];
        NSDictionary *dic1 = [dataArray objectAtIndex:i];
        NSMutableDictionary *tempMutDic = [NSMutableDictionary dictionary];
        NSArray *tempKeyArrays = [dic allKeys];
        NSArray *tempValueArrays = [dic allValues];
        
        for (int j = 0; j < tempKeyArrays.count; j ++) {
            //将服务器传过来的实收单价保存到单例里面
            if ([[tempKeyArrays objectAtIndex:j] isEqualToString:@"selling_price"]) {
                [tempMutDic setObject:[dic1 objectForKey:@"selling_price"] forKey:[tempKeyArrays objectAtIndex:j]];
            }else {
                [tempMutDic setObject:[tempValueArrays objectAtIndex:j] forKey:[tempKeyArrays objectAtIndex:j]];
            }
        }
        [[AddProduct sharedInstance].arr_AddToList replaceObjectAtIndex:i withObject:tempMutDic];
    }
    
    if (self.meterialFlag) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:6]
                                              animated:YES];
    }else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:4]
                                              animated:YES];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}


#pragma mark ---- UITextField delegate method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if(!basicTest)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入数字"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
        return NO;
    }
    return YES;
}

#pragma mark ---- UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (NotIOS8) {
            [self setItem];
        }
        
        [self getBatchPriceAndInventoryForGoods];
    }
}

#pragma mark ---- UITableView delegate and datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [AddProduct sharedInstance].arr_AddToList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseCell *cell=(ChooseCell*)[tableView1 dequeueReusableCellWithIdentifier:@"ChooseCell"];
    if(cell==nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChooseCell" owner:[ChooseCell class] options:nil];
        cell = (ChooseCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    NSDictionary *dic=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:indexPath.row];
    cell.lab_pname.text=[dic objectForKey:@"name"];
    cell.lab_pcode.text=[dic objectForKey:@"pcode"];//pcode是条码编号
    cell.lab_poo.text=[dic objectForKey:@"address"];//产地
    cell.lab_price.text=[dic objectForKey:@"price"];
    cell.lab_ptype.text=[dic objectForKey:@"type"];//型号
    cell.lab_branded.text=[dic objectForKey:@"ext1"];//品牌
    cell.unitLabel.text = [dic objectForKey:@"unit"];
    
    cell.itemNumbtn.hidden = NO;
    cell.itemNumbtn.tag = indexPath.row;
    [cell.itemNumbtn setTitle:[dic objectForKey:@"cnt"] forState:UIControlStateNormal];
    [cell.itemNumbtn addTarget:self action:@selector(showOkayCancelAlert:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 205;
}

//要求委托方的编辑风格在表视图的一个特定的位置。
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    if ([tableView isEqual:itemTableView]) {
        result = UITableViewCellEditingStyleDelete;//设置编辑风格为删除风格
    }
    return result;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[AddProduct sharedInstance].arr_AddToList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationLeft];
}

@end
