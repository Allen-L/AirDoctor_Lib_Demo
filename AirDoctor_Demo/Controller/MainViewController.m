//
//  MainViewController.m
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import "MainViewController.h"
#import "VsonBleProcess.h"
#import "Particulate.h"
#import "MainView.h"
#import "MBProgressHUD.h"

#define RGBCOLOR(r,g,b)         [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height


@interface MainViewController ()<VsonBLEDelegate>
{
    UIButton *m_button_connectState;
    
    VsonBleProcess *m_VsonBle;
    MainView *m_view_data;
    NSTimer *m_timer_connect;
    NSMutableString *m_string_historyData;
}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation MainViewController
@synthesize m_device;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavigationBarView];
    
    
    m_VsonBle = [VsonBleProcess sharedInstance];
    m_VsonBle.delegate = self;
    
    m_view_data = [[MainView alloc]initWithFrame:CGRectMake(0, 64+20, SCREEN_WIDTH, SCREEN_HEIGHT-84)];
    [self.view addSubview:m_view_data];
    
    
    m_string_historyData = [NSMutableString new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!m_device) {
            NSLog(@"not selectd device!!!!");
        }else{
            [self starConnectDevice];
        }
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    m_VsonBle.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([m_VsonBle checkPeripheralConnectStatus]) {
        [m_VsonBle disConnectPeripheral];
    }
}

-(void)setupNavigationBarView
{
    UIView *view_navigationBar = [[UIView alloc]initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    view_navigationBar.backgroundColor = RGBCOLOR(0, 71, 102);
    [self.view addSubview:view_navigationBar];
    
    
    UILabel *lable_title = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, 20, SCREEN_WIDTH/2, 44)];
    lable_title.textAlignment = NSTextAlignmentCenter;
    lable_title.text = NSLocalizedString(@"Data", nil);
    [lable_title setTextColor:[UIColor whiteColor]];
    lable_title.font = [UIFont boldSystemFontOfSize:20.0];
    [view_navigationBar addSubview:lable_title];
    
    
    m_button_connectState = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-50, 20, 40, 40)];
    [m_button_connectState setImage:[UIImage imageNamed:@"blueToothNotConnected.png"] forState:0];
    [m_button_connectState addTarget:self action:@selector(starConnectDevice) forControlEvents:UIControlEventTouchUpInside];
    [view_navigationBar addSubview:m_button_connectState];
    
    
    UIImageView *imageView_line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 63, SCREEN_WIDTH, 0.7)];
    imageView_line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView_line];
}

#pragma mark-important
#pragma mark-Vson_Delegate
-(void) peripheralDidUpdateValue:(NSData *)receiveData DataLength:(UInt16)length DataType:(Const_receive_data_type)dataType ;
{
    unsigned char array_data[receiveData.length];
    [receiveData getBytes:&array_data length:receiveData.length];
    switch (dataType) {
        case 0:
        {
            Particulate *_particulate = [m_VsonBle parseParticulateData:receiveData];
            if (_particulate) {
                if (_particulate.type == 1) {
                    //1:data_now
                    //2:Please according to their own need to save the real time data, our hardware will send a real-time data every 3 s,Please according to your need to save the data
                    //3: saveTime  :You need to save the value, each time it needs to be connected to the hardware into a new data of the time, is come from here
                    //4: save data to you database
                    //5: _particulate.particle  unit is k (1000)
                    
                    m_view_data.m_view_dataNow.font = [UIFont systemFontOfSize:15.0];
                    m_view_data.m_view_dataNow.text = [NSString stringWithFormat:@" pm2.5 = %d    pm10 = %d  \n pm1 =%d  particle = %d k   \n savetime = %@",_particulate.pm25,_particulate.pm10,_particulate.pm1,_particulate.particle,_particulate.saveTime];
                    
                    NSLog(@" pm25 = %d pm10 = %d  pm1 =%d particle = %d k savetime = %@",_particulate.pm25,_particulate.pm10,_particulate.pm1,_particulate.particle,_particulate.saveTime);
                    
                    [[NSUserDefaults standardUserDefaults]setObject:_particulate.saveTime forKey:@"SAVETIMELAST"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                }else if (_particulate.type == 2){
                    
                    //data_history ：Please preserve the historical data received, when history all the upload is complete, there will be a callback method：setPeripheralSuccessResponse:   ,history data only have pm25 data and time
                    NSString *data = [NSString stringWithFormat:@"pm2.5 = %d  saveTime = %@ \n",_particulate.pm25,_particulate.saveTime];
                    [m_string_historyData appendString:data];
                    
                    m_view_data.m_view_dataHistory.text = m_string_historyData;
                    // save to you database
                }
            }else{
                NSLog(@"something wrong ,please check again!!");
            }
        }
            break;
        case 1:
        {
            
            int battery  = array_data[0];
            NSLog(@"current battery = %d",battery);
            m_view_data.m_view_battery.text = [NSString stringWithFormat:@"%d",battery];
        }
            break;
        case 2:
        {
        }
            break;
        case 3:
        {
            if (array_data[0] == 1) {
                if ((array_data[6]*256 + array_data[7]) == 0) {
                    //Hardware does not have the historical data, return
                    NSLog(@"Hardware does not have the historical data, return");
                    return;
                }
                //step1：Query the database inside a PM latest data
                //step2：Please pass into the database inside the time of the latest data，Must be asked format @“yyyyMMddHHmm”
                NSString *str_time = [[NSUserDefaults standardUserDefaults]stringForKey:@"SAVETIMELAST"];
                if (str_time.length == 14) {
                    str_time = [str_time substringToIndex:11];
                }else{
                    str_time = @"201707100815";
                }
                NSLog(@"str_time = %@",str_time);
                
                [self queryDeviceParticulateRecordWithLastTime:str_time];
            }
        }
            break;
        default:
            break;
    }
}

-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;
{
    NSLog(@"peripheralConnectStateChanged");
    switch (inStatuCode) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
        {
            NSLog(@"blueToothConnected");
            [m_button_connectState setImage:[UIImage imageNamed:@"blueToothConnected.png"] forState:0];
        }
            break;
        case 4:
        {
            NSLog(@"blueToothNotConnected");
            
            [m_button_connectState setImage:[UIImage imageNamed:@"blueToothNotConnected.png"] forState:0];
        }
            break;
        case 5:
        {
            NSLog(@"system bluetooth closed");
        }
        default:
            break;
    }
}
-(void)afterConnectedPeripheral;
{
    NSLog(@"afterConnectedPeripheral");
    [self hideHUD];
    if ([m_timer_connect isValid]) {
        [m_timer_connect invalidate];
        m_timer_connect = nil;
    }
}
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;
{
    NSLog(@"setPeripheralSuccessResponse");
    
    if (SuccessType == SuccessType_HistoryRecord) {
        NSLog(@"All history data upload is complete, can refresh the view");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"alert" message:@"All history data upload is complete, can refresh the view" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark-fun - Parse the received data

/**
 *@brief connect
 */
-(void)starConnectDevice
{
    if (!m_timer_connect) {
        m_timer_connect = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(stopConnectDevice) userInfo:nil repeats:NO];
    }
    if (![m_VsonBle checkPeripheralConnectStatus]) {
        [m_VsonBle connectPeripheralWithPeripheralIdentifier:m_device.uuid];
        [self showHudWithText:@"In the connection"];
    }
}
/**
 *@brief Connection failed
 */
-(void)stopConnectDevice
{
    [self hideHUD];
    [m_VsonBle disConnectPeripheral];
    
    if ([m_timer_connect isValid]) {
        [m_timer_connect invalidate];
        m_timer_connect = nil;
    }
    
}
/**
 *@brief According to the time the hardware to upload, and query the hardware for the last time saving data, comparing the time request the history data of hardware
 */
-(void)queryDeviceParticulateRecordWithLastTime:(NSString *)lastTime
{
    if ([lastTime longLongValue] < 1  || lastTime.length != 12) {
        //Don't have the time, direct assignment for the current time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
        lastTime = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    Byte query_time[6] = {0};
    query_time[0] = 1;
    query_time[1] = [[lastTime substringWithRange:NSMakeRange(2, 2)] intValue];
    query_time[2] = [[lastTime substringWithRange:NSMakeRange(4, 2)] intValue];
    query_time[3] = [[lastTime substringWithRange:NSMakeRange(6, 2)] intValue];
    query_time[4] = [[lastTime substringWithRange:NSMakeRange(8, 2)] intValue];
    query_time[5] = [[lastTime substringWithRange:NSMakeRange(10, 2)] intValue];
    
    NSData *data_time = [NSData dataWithBytes:query_time length:6];
    [m_VsonBle sendRequestQueryHistoryTemperatureRecordToDeviceWithTime:data_time];
}

#pragma mark-HUD
- (MBProgressHUD*)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}

/*!
 *  @method HideHUD
 */
-(void)hideHUD
{
    [self.hud hide:YES];
}

/*!
 *  @method showHudWithText:
 */
-(void)showHudWithText:(NSString *)msg
{
    self.hud.mode  = MBProgressHUDModeIndeterminate;
    self.hud.labelText  = msg;
    [self.hud show:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
