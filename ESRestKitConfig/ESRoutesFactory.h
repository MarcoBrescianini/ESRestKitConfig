//
//  ESRoutesFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol ESRoutesFactory <NSObject>

-(NSDictionary<NSString*, RKRoute*>*)createRoutes;

@end
