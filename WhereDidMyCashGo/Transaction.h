//
//  Transaction.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/11/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject <NSCoding>

@property NSString *purchase;
@property NSNumber *cost;

@end
