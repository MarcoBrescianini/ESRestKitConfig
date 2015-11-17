//
//  ESMappingFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@protocol ESMappingFactory <NSObject>

-(NSDictionary<NSString*, RKMapping*>*)createMappings;

@end
