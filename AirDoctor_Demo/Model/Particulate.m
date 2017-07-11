//
//  Particulate.m
//  AirDoctor_Demo
//
//  Created by kakaxi on 2016/11/10.
//  Copyright © 2016年 VSON. All rights reserved.
//

#import "Particulate.h"

@implementation Particulate

-(id)init
{
    self = [super init];
    if (self) {
        self.pm25 = 0;
        self.pm1  = 0;
        self.pm10 = 0;
        self.particle = 0;
        self.saveTime = @"";
        self.uid  = @"";
        self.mac  = @"";
        self.bleid= @"";

    }
    return self;
}


@end
