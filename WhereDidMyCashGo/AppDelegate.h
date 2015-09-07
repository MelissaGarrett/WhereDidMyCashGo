//
//  AppDelegate.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/4/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) NSArray *paths;

@property (strong, nonatomic) NSString *documentsDirectoryPath;

@property (strong, nonatomic) NSString *filePath;


@property (strong, nonatomic) NSMutableArray *arrayOfTransactions;

@property (strong, nonatomic) NSString *currentMonth;

@property (strong, nonatomic) NSString *lastMonth;

@property (strong, nonatomic) NSNumber *lastMonthTotal;

@property (strong, nonatomic) NSNumber *currentMonthTotal;





@end

