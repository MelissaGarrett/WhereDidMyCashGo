//
//  MonthlyDataManager.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 9/12/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthlyDataManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrayOfTransactions;

@property (strong, nonatomic) NSString *currentMonth;

@property (strong, nonatomic) NSString *lastMonth;

@property (strong, nonatomic) NSNumber *lastMonthTotal;

@property (strong, nonatomic) NSNumber *currentMonthTotal;


+ (MonthlyDataManager*) sharedManager; // method to return the singleton object

-(void)loadDataFromStorage;
-(void)checkIfNewMonth;

@end
