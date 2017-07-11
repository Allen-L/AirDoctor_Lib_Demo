//
//  Device.h
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

@interface Device : NSObject
@property(nonatomic,retain)CBPeripheral *peripheral;
@property(nonatomic,copy)NSString *name;    //name
@property(nonatomic,copy)NSString *lc;      //大客户代码
@property(nonatomic,copy)NSString *md;      //型号
@property(nonatomic,copy)NSString *pid;     //设备ID(当前为蓝牙名称)
@property(nonatomic,copy)NSString *mac;     //设备MAC地址
@property(nonatomic,copy)NSString *uuid;    //设备的UUID


@end
