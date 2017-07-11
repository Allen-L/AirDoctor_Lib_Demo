//
//  ScanViewController.m
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import "ScanViewController.h"
#import "VsonBleProcess.h"
#import "Device.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"

#define RGBCOLOR(r,g,b)         [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

@interface ScanViewController ()<UITableViewDelegate,UITableViewDataSource,VsonBLEDelegate>
{
    UITableView *m_tableView_Items;
    Device *m_device;
    VsonBleProcess *m_VSONBLE;
    
    NSTimer *m_timer_search; //扫描计时器
    NSMutableArray *m_array_device;    //扫描到的设备
}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"SCAN";
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor redColor];
    [self setupNavigationBarView];
    
    
    m_VSONBLE = [VsonBleProcess sharedInstance];
    m_VSONBLE.delegate = self;
    
    
    m_tableView_Items            =[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    m_tableView_Items.dataSource = self;
    m_tableView_Items.delegate   = self;
    m_tableView_Items.exclusiveTouch = YES;
    [self.view addSubview:m_tableView_Items];
    
}


-(void)setupNavigationBarView
{
    UIView *view_navigationBar = [[UIView alloc]initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    view_navigationBar.backgroundColor = RGBCOLOR(0, 71, 102);
    [self.view addSubview:view_navigationBar];
    
    
    UILabel *lable_title = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, 20, SCREEN_WIDTH/2, 44)];
    lable_title.textAlignment = NSTextAlignmentCenter;
    lable_title.text = NSLocalizedString(@"Device", nil);
    [lable_title setTextColor:[UIColor whiteColor]];
    lable_title.font = [UIFont boldSystemFontOfSize:20.0];
    [view_navigationBar addSubview:lable_title];
    
    
    UIButton *barButton_right = [UIButton buttonWithType:UIButtonTypeSystem];
    barButton_right.frame = CGRectMake(SCREEN_WIDTH-70, 20, 60, 44);
    [barButton_right setTitle:@"Scan" forState:0];
    [barButton_right setTitleColor:[UIColor whiteColor] forState:0];
    [barButton_right addTarget:self action:@selector(startScanDevice:) forControlEvents:UIControlEventTouchUpInside];
    [view_navigationBar addSubview:barButton_right];
    
    UIImageView *imageView_line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 63, SCREEN_WIDTH, 0.7)];
    imageView_line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView_line];
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


-(void)viewWillDisappear:(BOOL)animated
{
    [m_tableView_Items deselectRowAtIndexPath:m_tableView_Items.indexPathForSelectedRow animated:NO];
}

/**
 *@brief Scan Our device
 */
-(void)startScanDevice:(id)sender
{
    
    [m_VSONBLE disConnectPeripheral];
    m_VSONBLE.peripherals = nil;
    m_VSONBLE.peripherals_name = nil;
    [m_VSONBLE scanPeripheralsWithTimer:5 connectedPeripheralUUID:nil];
    [self showHudWithText:@"scan..."];
    
    if (m_timer_search) {
        [m_timer_search invalidate];
        m_timer_search = nil;
    }
    m_timer_search = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(stopSearch) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:m_timer_search forMode:NSDefaultRunLoopMode];
    
}
/**
 *@brief Forced off the scanning interface
 */
-(void)stopSearch
{
    [self hideHUD];
    if (m_timer_search) {
        [m_timer_search invalidate];
        m_timer_search = nil;
    }
}

#pragma mark-VsonBle Delegate
-(void) peripheralDidUpdateValue:(NSData *)receiveData DataLength:(UInt16)length DataType:(Const_receive_data_type)dataType;
{
}

-(void) scanResult:(NSMutableArray *)peripherals_name;
{
    if (peripherals_name.count == 0) {
        NSLog(@"No devices found");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"alert" message:@"No devices found,please scan again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
         return;
    }
    
    m_array_device = peripherals_name;
    [m_tableView_Items reloadData];
}
/**
 *@brief This method is when peripheral bluetooth state change callback methods, such as have connected/disconnection
 *@param inStatuCode Current state of the peripheral
 */
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;
{
    if (inStatuCode == const_ble_status_powerOff) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"alert" message:@"must open system bluetooth" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}
/**
 *@brief  This Method is used to show that has been connected to the peripherals
 */
-(void)afterConnectedPeripheral;
{
}
/**
 *@brief This method is when phone set peripheral, set up the success will callback method, you need to determine type of success, to perform the corresponding operation
 *@param SuccessType Set the type of success
 */
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;
{
    switch (SuccessType) {
        case SuccessType_SetName:
        {
        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_array_device.count;
}

#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const iden = @"iden";
    UITableViewCell *mycell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!mycell) {
        mycell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    }
    Device *_device = [m_array_device objectAtIndex:indexPath.row];
    
    mycell.textLabel.font = [UIFont systemFontOfSize:18.0];
    mycell.textLabel.text = _device.name;
    mycell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    mycell.exclusiveTouch = YES;
    
    return mycell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 26;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 6;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device *device_selected = [m_array_device objectAtIndex:indexPath.row];
    m_VSONBLE.delegate = nil;  //This is very important
    m_VSONBLE = nil;
    MainViewController *mainVC = [[MainViewController alloc]init];
    mainVC.m_device = device_selected;
    [self.navigationController pushViewController:mainVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
