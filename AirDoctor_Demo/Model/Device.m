//
//  Device.m
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import "Device.h"

@implementation Device
-(id)init
{
    self = [super init];
    if (self) {
        self.peripheral = nil;
        self.name = @"";
        self.lc = @"";
        self.md = @"";
        self.pid = @"";
        self.mac = @"";
        self.uuid = @"";
    }
    return self;
}
@end
