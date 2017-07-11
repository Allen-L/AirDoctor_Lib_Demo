//
//  MainView.m
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import "MainView.h"

@implementation MainView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *lable_battery = [[UILabel alloc]initWithFrame:CGRectMake(10,10,80,40)];
        lable_battery.text = NSLocalizedString(@"Battery:", nil);
        [self addSubview:lable_battery];
        _m_view_battery = [[UITextView alloc]initWithFrame:CGRectMake(90, 10, frame.size.width-100, 40)];
        _m_view_battery.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
        _m_view_battery.editable = false;
        [self addSubview:_m_view_battery];
        
        
        UILabel *lable_dataNow = [[UILabel alloc]initWithFrame:CGRectMake(10,60,80,40)];
        lable_dataNow.text = NSLocalizedString(@"dataNow:", nil);
        [self addSubview:lable_dataNow];
        _m_view_dataNow = [[UITextView alloc]initWithFrame:CGRectMake(90, 60, frame.size.width-100, 70)];
        _m_view_dataNow.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
        _m_view_dataNow.editable = false;
        [self addSubview:_m_view_dataNow];
        
        
        UILabel *lable_dataHistory= [[UILabel alloc]initWithFrame:CGRectMake(10,140,180,30)];
        lable_dataHistory.text = NSLocalizedString(@"dataHistory:", nil);
        [self addSubview:lable_dataHistory];
        _m_view_dataHistory = [[UITextView alloc]initWithFrame:CGRectMake(90, 170, frame.size.width-100, 240)];
        _m_view_dataHistory.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
        _m_view_dataHistory.editable = false;
        [self addSubview:_m_view_dataHistory];
        
    
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
