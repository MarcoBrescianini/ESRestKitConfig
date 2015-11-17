//
//  ESPlistResponseDescriptorFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

#import "ESResponseDescriptionFactory.h"


NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString*, RKRoute*> * TYRouteMap;
typedef NSDictionary<NSString*, RKMapping*> * TYMappingMap;

@interface ESPlistResponseDescriptorFactory : NSObject<ESResponseDescriptionFactory>

@property (nonatomic, strong, readonly, nonnull) TYRouteMap routes; //TODO: SHOULD BE READWRITE AND MOVED IN INTERFACE
@property (nonatomic, strong, readonly, nonnull) TYMappingMap mappings; //TODO: SHOULD BE READWRITE AND MOVED IN INTERFACE
@property (nonatomic, strong, readonly, nonnull) NSDictionary * config;

-(instancetype)initWithRoutes:(TYRouteMap)routes mappings:(TYMappingMap)mappings config:(NSDictionary*)config;
-(instancetype)initWithRoutes:(TYRouteMap)routes mappings:(TYMappingMap)mappings filepath:(NSString*)filepath;
-(instancetype)initWithRoutes:(TYRouteMap)routes mappings:(TYMappingMap)mappings fromMainBundle:(NSString*)filename;

-(RKResponseDescriptor*)descriptorForName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
