//
//  VsonBleProcess.h
//  libVsonBle
//
//  Created by vson on 15/7/6.
//  Copyright (c) 2015年 vson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Particulate.h"

//SINGLETON
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
    + (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
    + (__class *)sharedInstance \
    { \
        static dispatch_once_t once; \
        static __class * __singleton__; \
        dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
        return __singleton__; \
    }


typedef NS_ENUM(NSInteger, Const_ble_status) {
    const_ble_status_scan = 0,
    const_ble_status_scaning = 1,
    const_ble_status_connecting = 2,
    const_ble_status_connceted = 3,
    const_ble_status_disconnected = 4,
    const_ble_status_powerOff = 5
};

typedef NS_ENUM(NSInteger, Const_receive_data_type) {
    const_invalid_data      = -1, //Invalid data
    const_one_more          = 0,  //PM data
    const_charge_status     = 1,  //current peripheral battery
    const_device_setSuccess = 2,  //setSuccess
    const_generor_comm_data = 3   //General data
};

typedef NS_ENUM(NSInteger, SetPeripheralSuccessType) {
    SuccessType_CallBrate = 0,      //Deprecated
    SuccessType_SetName   = 1,      //Set Name Success
    SuccessType_Bind      = 2,      //Deprecated
    SuccessType_UnBind    = 3,      //Deprecated
    SuccessType_Init      = 4,      //init Success
    SuccessType_Normal    = 5,      //General Settings peripherals, such as modified water plan, switch peripherals buzzer Success
    SuccessType_HistoryRecord  = 6  //peripheral Device HistoryRecord  send over Success
};


#pragma mark
#pragma mark-All of the protocol, please implement in your program

@protocol VsonBLEDelegate

@optional
/**
 *@brief    This method is active when peripherals to mobile phones to send data by the method called, all of the peripherals sent to mobile phone Numbers are callback this method
 *@param receiveData  phone receive data
 *@param length       data length
 *@param dataType     data type
 */
-(void) peripheralDidUpdateValue:(NSData *)receiveData DataLength:(UInt16)length DataType:(Const_receive_data_type)dataType;

@optional
/**
 *@brief This method is that when you call a method  -(int) scanPeripheralsWithTimer:(int) timeout  connectedPeripheralUUID:(NSString *)PeripheralUUID; ，Timer stopScan, is returned to you scan to the total number of peripherals
 *@param peripherals_name  the array name of peripherals
 */

@optional
-(void) scanResult:(NSMutableArray *)peripherals_name;

/**
 *@brief This method is when peripheral bluetooth state change callback methods, such as have connected/disconnection
 *@param inStatuCode Current state of the peripheral
 */
@optional
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;

@optional
/**
 *@brief  This Method is used to show that has been connected to the peripherals
 */
-(void)afterConnectedPeripheral;

@optional
/**
 *@brief This method is when phone set peripheral, set up the success will callback method, you need to determine type of success, to perform the corresponding operation
 *@param SuccessType Set the type of success
 */
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;


@end

@interface VsonBleProcess : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
}

AS_SINGLETON(VsonBleProcess)

@property (nonatomic,assign) id <VsonBLEDelegate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic)  NSMutableArray *peripherals_name;

/**
 *@brief This method is used for active scan peripherals,
 *@param timeout           Scan time for timer
 *@param PeripheralUUID    last time had connected peripherals UUID
 */
-(int) scanPeripheralsWithTimer:(int) timeout  connectedPeripheralUUID:(NSString *)PeripheralUUID;


/**
 *@brief  This method is used to stop manager scan peripheral
 */
-(void) stopScan;

/**
 *@brief  This method is used to check whether the current connection of peripheral you is still in the connection status  ture: show already connected  false:not connect
 */
-(BOOL) checkPeripheralConnectStatus;

/**
 *@brief Method is used to connect you to specify an array subscript peripherals, when you call after scanning methods, will give you a scan to peripheral array, by specifying the array subscript to connect to the peripherals, the return value for the current want to link the peripheral UUID
 *@param inindex        Want to connect a peripheral array index
 */
-(NSString*) connectPeripheralWithIndex:(int)inindex;

/**
 *@brief Through uuid connection hardware
 *@param  identifier uuid
 */
-(void) connectPeripheralWithPeripheralIdentifier:(NSString *)identifier;

/**
 *@brief This method is applied to disconnect peripherals
 */
-(void) disConnectPeripheral;


/**
 *@brief This method is read peripherals current battery
 */
-(void) readBattery;

/**
 *@brief Response to hardware, has received a historical data package
 */
-(void) SendReceiveHistoryOneDataToDevice;


/**
 *@brief According to the time request to historical PM records to hardware
 *@param data      data of query time
 */
-(void) sendRequestQueryHistoryTemperatureRecordToDeviceWithTime:(NSData * )data;

/**
 *@brief Method is used to set the type of data to the peripherals
 *@param indata  Need to send the set of the data
 */
-(void) sendSetTypeDataToDevice:(NSData * )indata;

/**
 *@brief Parsing get PM data
 */
-(Particulate *)parseParticulateData:(NSData *)receiveData;

@end
