//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectManager;


@protocol ESObjectManagerFactory <NSObject>

-(RKObjectManager * )createObjectManager;

@end
