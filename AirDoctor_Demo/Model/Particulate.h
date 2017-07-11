//
//  Particulate.h
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Particulate : NSObject

/**
 *@brief type :  1:data_now  2:data_history
 */
@property(nonatomic,assign)int type;        
@property(nonatomic,assign)int pm25;
@property(nonatomic,assign)int pm1;
@property(nonatomic,assign)int pm10;
@property(nonatomic,assign)int particle;


@property(nonatomic,retain) NSString *saveTime;         //need save    format：201601081018

@property(nonatomic,retain) NSString *timeFormat;       //not need    for web
@property(nonatomic,retain) NSString *uid;              //not need
@property(nonatomic,retain) NSString *mac;              //not need
@property(nonatomic,retain) NSString *bleid;            //not need


@end
