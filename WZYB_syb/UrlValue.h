//
//  UrlValue.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#ifndef WZYB_syb_UrlValue_h
#define WZYB_syb_UrlValue_h

static NSString* const kAppUpgradeUrl = @"https://itunes.apple.com/us/app/shang-ying-bao/id917492278?l=zh&ls=1&mt=8";

#define kBASEURL @"http://115.28.188.245/syb/" //远程
//#define kBASEURL    @"http://192.168.0.8:8080/wzyb/"
#define webImageURL @"http://www.maystall.com/"

#define KPORTAL_URL [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"portal_url"]

/*
用户登录POST ACTION:【portal.do?app=0&action=chk_login】
用户名--[user.uid]
密  码--[user.password]
 收到令牌确认
 POST ACTION:【App_Login.do?app=0&action=receive_token】
 保存个推clientId或百度云推送channel_id
 POST ACTION:【App_Login.do?app=0&action=save_client_id】
*/
#define KCHK_LOGIN @"App_Login.do?app=0&action=login"
#define KUSER_UID @"user.uid"
#define KUSER_PASSWORD @"user.password"
#define KReceive_token @"App_Login.do?app=0&action=receive_token"
#define KSave_client_id @"App_Login.do?app=0&action=save_client_id"
/*
消息通知POST ACTION:【App_Notice.do?app=0&action=get_notice】
用户名--[user.uid]
密  码--[user.password]
 */
#define KGET_NOTICE @"App_Notice.do?app=0&action=get_notice"
/*
通知已读POST ACTION:【App_Notice.do?app=0&action=read_notice】
用户名--[user.uid]
密  码--[user.password]
推送消息索引--[index_no]
 */
#define KREAD_NOTICE @"App_Notice.do?app=0&action=read_notice"
#define KINDEX_NO @"index_no"
/*
寻访列表POST ACTION:【App_Access.do?app=0&action=get_access】
用户名--[user.uid]--
密  码--[user.password]--
寻访日期--[access_start_date]
*/
#define KGET_ACCESS @"App_Access.do?app=0&action=get_access"
/*
通过二维码取得终端信息
POST ACTION:【App_Access.do?app=0&action=get_customer】
用户名--[user.uid]--
密  码--[user.password]--
二维码--[atu]
*/
#define KGET_CUSTOMER @"App_Access.do?app=0&action=get_customer"
#define KATU @"atu"
/*
 通过终端名取得终端信息
 
 POST ACTION:【App_Access.do?app=0&action=get_customer_list】
 */
#define KGET_CUSTOMER_List @"App_Access.do?app=0&action=get_customer_list"
#define KNear_List @"App_Access.do?app=0&action=get_customer_near"
/*
 签到 POST ACTION:【App_Access.do?app=0&action=checkin&sign_type=0】
 */
#define KSIGN_TYPE0 @"App_Access.do?app=0&action=checkin&sign_type=0"
/*
 签退 POST ACTION:【App_Access.do?app=0&action=checkin&sign_type=1】
*/
#define KSIGN_TYPE1 @"App_Access.do?app=0&action=checkin&sign_type=1"
/*
 订单下单         POST ACTION:【App_Order.do?app=0&action=new_order】
 取得订单动态项目  POST ACTION:【App_Order.do?app=0&action=get_dynamic】
 */
#define KNew_Order @"App_Order.do?app=0&action=new_order"
#define KRet_Order @"App_Return.do?app=0&action=new_return"
#define KUpdate_Sign @"App_Access.do?app=0&action=update_dynamic"
#define KGetOrder_Dynamic @"App_Order.do?app=0&action=get_dynamic"
#define KGetROrder_Dynamic @"App_Return.do?app=0&action=get_dynamic"
/*
 订单列表  POST ACTION:【App_Order.do?app=0&action=get_order】
 取得订单详细 POST ACTION:【App_Order.do?app=0&action=get_detail】
*/
#define KGet_Order @"App_Order.do?app=0&action=get_order"
#define KGet_ROrder @"App_Return.do?app=0&action=get_return"
#define KGet_Order_Boss @"App_Order.do?app=0&action=search_order"
#define KGet_DetailList @"App_Order.do?app=0&action=get_detail"
/*
 取得商品价格和库存
 POST ACTION:【App_Order.do?app=0&action=get_price】
 */
#define KGetSellingPrice_Stock @"App_Order.do?app=0&action=get_price"
/*
 新客户列表    POST ACTION:【App_Customer.do?app=0&action=get_customer&gtype=0】
 竞争对手列表   POST ACTION【App_Customer.do?app=0&action=get_customer&gtype=1】
 */
#define KGet_Customer0 @"App_Customer.do?app=0&action=get_customer&gtype=0"
#define KGet_Customer1 @"App_Customer.do?app=0&action=get_customer&gtype=1"
/*
 新客户详细  POST ACTION:【App_Customer.do?app=0&action=get_detail&gtype=0】
 竞争对手详细 POST ACTION:【App_Customer.do?app=0&action=get_detail&gtype=1】
 签约客户2
 */
#define KGet_Detail0 @"App_Customer.do?app=0&action=get_detail&gtype=0"
#define KGet_Detail1 @"App_Customer.do?app=0&action=get_detail&gtype=1"
#define KGet_Detail2 @"App_Customer.do?app=0&action=get_detail&gtype=2"
#define KGet_matter @"App_Access.do?app=0&action=get_dynamic"

/*
 取得新客户动态项目 POST ACTION:【App_Customer.do?app=0&action=get_dynamic&gtype=0】
 取得竞争对手动态项目POST ACTION:【App_Customer.do?app=0&action=get_dynamic&gtype=1】
 新客户登记  POST ACTION:【App_Customer.do?app=0&action=new_customer&gtype=0】
 竞争对手登记  POST ACTION:【App_Customer.do?app=0&action=new_customer&gtype=1】 
 */
#define KNewCustomer_Dynamic0 @"App_Customer.do?app=0&action=get_dynamic&gtype=0"
#define KNewCustomer_Dynamic1 @"App_Customer.do?app=0&action=get_dynamic&gtype=1"
#define KNewCustomer0 @"App_Customer.do?app=0&action=new_customer&gtype=0"
#define KNewCustomer1 @"App_Customer.do?app=0&action=new_customer&gtype=1"

#define KAllApplyDynamic @"App_Workflow.do?app=0&action=get_all_dynamic"
/*
新客户更新POST ACTION:【App_Customer.do?app=0&action=update_customer&gtype=0】
竞争对手更新POST ACTION:【App_Customer.do?app=0&action=update_customer&gtype=1】
签约客户 2
*/
#define KUpdate0 @"App_Customer.do?app=0&action=update_customer&gtype=0"
#define KUpdate1 @"App_Customer.do?app=0&action=update_customer&gtype=1"
#define KUpdate2 @"App_Customer.do?app=0&action=update_customer&gtype=2"
/*回放路径
 POST ACTION:【App_History.do?app=0&action=history】
 POST ACTION:【App_History.do?app=0&action=history_list】
 */

#define KHistory @"App_History.do?app=0&action=history"
#define KHistoryList @"App_History.do?app=0&action=history_list"

/*企业文档列表
 POST ACTION:【App_Document.do?app=0&action=list_document】
 */
#define KList_Document @"App_Document.do?app=0&action=get_document"

/*
 我的申请列表POST ACTION:【App_Workflow.do?app=0&action=get_apply】
 待审批列表  POST ACTION:【App_Workflow.do?app=0&action=get_approve】
 待审批高级搜索  POST ACTION:【App_Workflow.do?app=0&action=search_approve】
*/
#define KGet_SerApply @"App_Workflow.do?app=0&action=get_apply"
#define KGet_apply @"App_Workflow.do?app=0&action=unfinished_apply" //1.0.4 服务器接口修改
#define Boss_apply @"App_Workflow.do?app=0&action=search_apply"
#define Boss_customer @"App_Customer.do?app=0&action=search_customer"
#define Boss_sign @"App_Access.do?app=0&action=search_attendance"
#define Boss_getSign @"App_Access.do?app=0&action=search_corp"
#define KGet_approve @"App_Workflow.do?app=0&action=get_approve"
#define KSearch_approve @"App_Workflow.do?app=0&action=search_approve"

#define UserInfo @"App_User.do?app=0&action=get_user"
#define UserUpdate @"App_User.do?app=0&action=update_user"
/*
 申请POST      ACTION:【App_Workflow.do?app=0&action=apply】
 物料申请  POST ACTION:【App_Workflow.do?app=0&action=apply】
 取得申请动态项目 POST ACTION:【App_Workflow.do?app=0&action=get_dynamic】
 */
#define KAdd_apply @"App_Workflow.do?app=0&action=apply"
#define KGet_dynamic @"App_Workflow.do?app=0&action=get_dynamic"
/*
 取得审批流程记录 POST ACTION:【App_Workflow.do?app=0&action=approve_log】
 审批  POST ACTION:【App_Workflow.do?app=0&action=approve】
 取得物料详细 POST ACTION:【App_Workflow.do?app=0&action=get_material】
 
 申请者确认
 POST ACTION:【App_Workflow.do?app=0&action=confirm】
 */
#define KApprove_log @"App_Workflow.do?app=0&action=approve_log"
#define KUpdate_dynamic @"App_Workflow.do?app=0&action=update_dynamic"
#define KAction_approve @"App_Workflow.do?app=0&action=approve"

#define KROrder_detail @"App_Return.do?app=0&action=get_detail"
#define KGet_material @"App_Workflow.do?app=0&action=get_material"
#define KConfirm @"App_Workflow.do?app=0&action=confirm"
#define KLog_record @"App_Workflow.do?app=0&action=get_log_record"
/*
 我的指派列表  POST ACTION:【App_Task.do?app=0&action=get_assign】
 我的任务列表  POST ACTION:【App_Task.do?app=0&action=get_task】
 
 更新任务状态   POST ACTION:【App_Task.do?app=0&action=update_status】
 任务交办    POST ACTION:【App_Task.do?app=0&action=new_task】
 */
#define KGetAssign @"App_Task.do?app=0&action=unfinished_assign" //1.0.4 服务器接口修改
#define KGetTask @"App_Task.do?app=0&action=unfinished_task" //1.0.4 服务器接口修改

#define KGETTASK @"App_Task.do?app=0&action=get_task" //1.0.4 高级搜索之后的接口
#define KGETASSIGN @"App_Task.do?app=0&action=get_assign" //1.0.4 高级搜索之后的接口

#define KUpdate_status @"App_Task.do?app=0&action=update_status"
#define KNew_task @"App_Task.do?app=0&action=new_task"
/*
 问题反馈  POST ACTION:【App_Reply.do?app=0&action=new_reply】
 我的反馈列表  POST ACTION:【App_Reply.do?app=0&action=get_reply】
 关于我们  POST ACTION:【about.html】
 分析      POST ACTION:【x.do?app=0&actionId=an_term】
 
 
 终端客户分析
 
 POST ACTION:【x.do?app=0&actionId=an_term&x.do?app=0&actionId=an_term&user.uid=liqun&user.password=321&user.token=c3a0a2a1b36f20419385afa4cf956487@c3a0a2a1b36f20419385afa4cf956487@ac25c74e9d2abaf935b147f5357b78b4@24d1a7b72d793e0ceac1170a7ddc228f
 
 */
#define KNew_Reply @"App_Reply.do?app=0&action=new_reply"
#define KGet_Reply @"App_Reply.do?app=0&action=get_reply"
#define KAboutUs @"about.html"
#define KTerm @"term.html"

/*
 终端客户分析   POST ACTION:【x.do?app=0&actionId=an_term&x.do?app=0&actionId=an_term】
 终端分析(维护) POST ACTION:【x.do?app=0&actionId=an_term_man】
 订单分析       POST ACTION:【x.do?app=0&actionId=an_ord】
 财务分析(支出) POST ACTION:【x.do?app=0&actionId=an_fin】
 人员分析       POST ACTION:【x.do?app=0&actionId=an_emp】
 产品分析(结构)  POST ACTION:【x.do?app=0&actionId=an_prod】
 产品分析(人员)  POST ACTION:【x.do?app=0&actionId=an_prod_emp】
 产品分析(终端)   POST ACTION:【x.do?app=0&actionId=an_prod_t】
 营销活动分析    POST ACTION:【ma.do?app=0】
 运营分析      POST ACTION:【x.do?app=0&actionId=an_ope】
 */
#define KAn_term @"x.do?app=0&actionId=an_term"
#define KAn_term_man @"x.do?app=0&actionId=an_term_man"
#define KAn_ord @"x.do?app=0&actionId=an_ord"
#define KAn_fin @"x.do?app=0&actionId=an_fin"
#define KAn_emp @"x.do?app=0&actionId=an_emp"
#define KAn_prod @"x.do?app=0&actionId=an_prod"
#define KAn_prod_emp @"x.do?app=0&actionId=an_prod_emp"
#define KAn_prod_t @"x.do?app=0&actionId=an_prod_t"
#define KMa_Do @"ma.do?app=0"
#define KAn_ope @"x.do?app=0&actionId=an_ope"
#define KMap @"x.do?app=0&actionId=an_bmap"
#define KGps @"x.do?app=0&actionId=an_gps_map"
#define SaleRank @"x.do?app=0&actionId=an_sales_ranking"
#define SaleHistory @"x.do?app=0&actionId=an_sales_history"

/*
 我要休假  POST ACTION:【App_Holiday.do?app=0&action=apply_holiday】
 结束休假  POST ACTION:【App_Holiday.do?app=0&action=end_holiday】
 */
#define Kapply_holiday @"App_Holiday.do?app=0&action=apply_holiday"
#define Kend_holiday @"App_Holiday.do?app=0&action=end_holiday"
/*
 修改密码      POST ACTION:【App_Password.do?app=0&action=new_password】
 忘记密码      POST ACTION:【App_Password.do?app=0&action=forget_password】
 */
#define Knew_password @"App_Password.do?app=0&action=new_password"
#define Kforget_password @"App_Password.do?app=0&action=forget_password"

/*
 系统自动更新确认地址
 */

#define GetLastVersion @"http://www.yunlingyilian.com/version/ver_ios.txt" // @"http://www.yunlingyilian.com/version/ver_ios.txt"
#define SecondServer @"http://www.amonsoft.com/syb.txt"
#define GetLastVersionFromNet @"ver_itmsServices.txt" // @"http://115.28.188.245/syb/ver_itmsServices.txt"
/*
 异常记录
 POST ACTION:【App_Reply.do?app=0&action=error】
 */
#define KError @"App_Reply.do?app=0&action=error"

/*
 推送消息
 POST ACTION:【App_Notice.do?app=0&action=push_notice】
*/
#define KPush_Notice @"App_Notice.do?app=0&action=push_notice"
/*
 取得定位
 POST ACTION:【App_Reply.do?app=0&action=gps】
 */
#define KReply_myGPS @"App_Reply.do?app=0&action=gps"
/*
即时定位
POST ACTION:【App_Reply.do?app=0&action=gprs】
*/
#define KReply_myMoment_GPRS @"App_Reply.do?app=0&action=gprs"
/*
 产品检索  POST ACTION:【App_Product.do?app=0&action=get_product】
 */
#define KStore_get_product @"App_Product.do?app=0&action=get_product"
/*
 取得产品详细   POST ACTION:【App_Product.do?app=0&action=get_detail】
*/

#define BatchGoods @"App_Order.do?app=0&action=get_price_list"

#define UpdateItem @"App_Product.do?app=0&action=refresh_product"

#define UpdateProduct @"App_Product.do?app=0&action=update_product"
#define KStore_get_deatail @"App_Product.do?app=0&action=get_detail"

#define Ksign_num @"App_Workflow.do?app=0&action=num_sign"

#define KGet_UnRead @"App_Notice.do?app=0&action=get_not_read"
#endif
