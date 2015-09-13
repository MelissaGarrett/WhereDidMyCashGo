//
//  MonthlyDataManager.m
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 9/12/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import "MonthlyDataManager.h"
#import "AppDelegate.h"

@implementation MonthlyDataManager

+ (MonthlyDataManager *) sharedManager {
    static MonthlyDataManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _arrayOfTransactions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// Retrieve the transactions and monthly totals from persistent storage
// into memory
-(void)loadDataFromStorage {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL appHasRun = [defaults boolForKey:@"hasAppRunOnceKey"];
    
    if (appHasRun) {
        // Load monthly totals from NSUserDefaults
        _lastMonth = [defaults objectForKey:@"lastMonth"];
        _lastMonthTotal = [defaults objectForKey:@"lastMonthTotal"];
        _currentMonthTotal = [defaults objectForKey:@"currentMonthTotal"];
        
        // Load transaction data from NSKeyedArchiver
        if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.filePath])
        {
            _arrayOfTransactions = [[NSKeyedUnarchiver unarchiveObjectWithFile:delegate.filePath] mutableCopy];
        }
    }
    else {
        _lastMonth = @"";
        _lastMonthTotal = 0;
        _currentMonthTotal = 0;
    }
}

// If new month, reset Last Month's and This Month's spending totals and
// delete the list of transactions
-(void)checkIfNewMonth {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL appHasRun = [defaults boolForKey:@"hasAppRunOnceKey"];
    
    if ((![_lastMonth isEqualToString:_currentMonth]) &&
        (appHasRun)) {
        _lastMonth = _currentMonth;
        _lastMonthTotal = _currentMonthTotal;
        _currentMonthTotal = 0;
        
        // delete transactions
    }
}


@end
