//
//  Config.h
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define kNotiPhoneticListLoadCompleted @"phonetic_list"
#define kNotiPhoneticClassLoadCompleted @"phonetic_class"

#define SERVER_DEBUG NO

#define APPID @"?app_id=5"
#define BASE_URL (SERVER_DEBUG ? @"" : @"http://tic.upkao.com/api/")
#define INIT_URL [NSString stringWithFormat:@"%@index/init%@", BASE_URL, APPID]
#define PHONOGRAM_LIST_URL [NSString stringWithFormat:@"%@index/phonetic_list%@", BASE_URL, APPID]
#define MCLASS_LIST_URL [NSString stringWithFormat:@"%@index/phonetic_class%@", BASE_URL, APPID]
#define VIP_LIST_URL [NSString stringWithFormat:@"%@index/vip_list%@", BASE_URL, APPID]

#define ORDER_URL [NSString stringWithFormat:@"%@index/pay%@", BASE_URL, APPID]
#define CHECK_URL [NSString stringWithFormat:@"%@index/orders_check%@", BASE_URL, APPID]
#define QUERY_URL [NSString stringWithFormat:@"%@index/orders_query%@", BASE_URL, APPID]

#define PAY_WAY_LIST_URL [NSString stringWithFormat:@"%@index/payway_list%@", BASE_URL, APPID]


#endif /* Config_h */
