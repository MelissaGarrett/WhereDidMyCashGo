//
//  Transaction.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/11/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject <NSCoding>

@property (strong, nonatomic) NSString *purchase;
@property (strong, nonatomic) NSNumber *cost;

@end
