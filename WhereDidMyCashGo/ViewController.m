//
//  ViewController.m
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/4/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Transaction.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Access the Delegate
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Setup the paths to save data entered by user
    delegate.paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    delegate.documentsDirectoryPath = [delegate.paths objectAtIndex:0];
    delegate.filePath = [delegate.documentsDirectoryPath stringByAppendingPathComponent:@"CashData"];
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tapToDismiss];
    
    [self checkIfAppHasRunOnce];
    
    [self loadDataFromStorage];
    
    [self getCurrentDate];
    
    [self checkIfNewMonth];
    
    [self displayTotals];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Check if this is the first time the app has ever run
-(void)checkIfAppHasRunOnce {
    static NSString * const hasAppRunOnceKey = @"hasAppRunOnceKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:hasAppRunOnceKey] == NO) {
        [defaults setBool:YES forKey:hasAppRunOnceKey];
    }
}

// Retrieve the transactions and monthly totals from persistent storage
// into memory
-(void)loadDataFromStorage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL appHasRun = [defaults boolForKey:@"hasAppRunOnceKey"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if (appHasRun) {
        // Load monthly totals from NSUserDefaults
        delegate.lastMonth = [defaults objectForKey:@"lastMonth"];
        delegate.lastMonthTotal = [defaults objectForKey:@"lastMonthTotal"];
        delegate.currentMonthTotal = [defaults objectForKey:@"currentMonthTotal"];
        
        // Load transaction data from NSKeyedArchiver
        if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.filePath])
        {
            delegate.arrayOfTransactions = [[NSKeyedUnarchiver unarchiveObjectWithFile:delegate.filePath] mutableCopy];
        }
    }
    else {
            delegate.lastMonth = @"";
            delegate.lastMonthTotal = 0;
            delegate.currentMonthTotal = 0;
    }
}

// Get current date to display Current Month in Navigation Bar.
-(void)getCurrentDate {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MMMM"];
    delegate.currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    self.navigationItem.title = delegate.currentMonth;
}

// If new month, reset Last Month's and This Month's spending totals and
// delete the list of transactions
-(void)checkIfNewMonth {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL appHasRun = [defaults boolForKey:@"hasAppRunOnceKey"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if ((![delegate.lastMonth isEqualToString:delegate.currentMonth]) &&
        (appHasRun)) {
            delegate.lastMonth = delegate.currentMonth;
            delegate.lastMonthTotal = delegate.currentMonthTotal;
            delegate.currentMonthTotal = 0;
        
            // delete transactions
    }
}

// Display Last Month's and This Month's spending totals
-(void)displayTotals {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###0.##"];
        
    NSString *formattedLastMonthString = [numberFormatter stringFromNumber:delegate.lastMonthTotal];
    float formattedLastMonth = [formattedLastMonthString floatValue];
    self.lblLastMonthTotal.text = [NSString stringWithFormat:@"%.2f", formattedLastMonth];
        
    NSString *formattedCurrentMonthString = [numberFormatter stringFromNumber:delegate.currentMonthTotal];
    float formattedCurrentMonth = [formattedCurrentMonthString floatValue];
    self.lblThisMonthTotal.text = [NSString stringWithFormat:@"%.2f", formattedCurrentMonth];
}

- (IBAction)btnEnterTransaction:(UIButton *)sender {
    self.txtDescription.hidden = NO;
    self.txtCost.hidden = NO;
    self.lblErrorMsg.text = @"";
    self.lblDollarSign.hidden = NO;
    self.lblCostFormat.hidden = NO;
    
    UIButton *cancel = (UIButton *)[self.view viewWithTag:10];
    [cancel setHidden:NO];
    
    UIButton *save = (UIButton *)[self.view viewWithTag:11];
    [save setHidden:NO];
}

- (IBAction)btnViewTransaction:(UIButton *)sender {
}

- (IBAction)btnCancel:(UIButton *)sender {
    self.txtDescription.text = @"";
    self.txtDescription.hidden = YES;
    self.txtCost.text = @"";
    self.txtCost.hidden = YES;
    self.lblErrorMsg.text = @"";
    self.lblDollarSign.hidden = YES;
    self.lblCostFormat.hidden = YES;
    
    UIButton *cancel = (UIButton *)[self.view viewWithTag:10];
    [cancel setHidden:YES];
    
    UIButton *save = (UIButton *)[self.view viewWithTag:11];
    [save setHidden:YES];
}

- (IBAction)btnSave:(UIButton *)sender {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

    // Need these to lose focus each time Save is tapped
    // because the Error Message doesn't always clear if one of them has focus
    [self.txtDescription resignFirstResponder];
    [self.txtCost resignFirstResponder];
    
    if ([self performErrorChecking] == YES) // Have good user input
    {
        Transaction *eachTransaction = [[Transaction alloc] init];

        [eachTransaction setPurchase:self.txtDescription.text];
    
        // Convert the Cost entered to an NSNumber so you can use NSNumberFormatter
        NSNumber *costEntered = @([self.txtCost.text floatValue]);
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"###0.##"];
        NSString *formattedNumberString = [numberFormatter stringFromNumber:costEntered];
        
        // Convert the formatted String to NSNumber type for storage
        NSNumber *formattedCost = @([formattedNumberString floatValue]);
        [eachTransaction setCost:formattedCost];
    
        // Save the custom object data into a mutable array
        [delegate.arrayOfTransactions addObject:eachTransaction];
    
        // Get Cost and add to CurrentMonthTotal
        float transactionCost = [self.txtCost.text floatValue];
        float currentTotal = [delegate.currentMonthTotal floatValue];
        
        currentTotal += transactionCost;
        self.lblThisMonthTotal.text = [NSString stringWithFormat:@"%.2f", currentTotal];

        delegate.currentMonthTotal = @(currentTotal);
        
        // Reset data entry fields after each successful Save
        self.txtDescription.text = @"";
        self.txtCost.text = @"";        
    }
}

// Check to make sure the user entered a value in the Purchase field
// and a valid value in the Cost field
-(BOOL)performErrorChecking {
    float costEntered = [self.txtCost.text floatValue];
    
    if ([self.txtDescription.text length] == 0 ||
        (costEntered <= 0.00))
    {
        self.lblErrorMsg.text = @"Please enter both a purchase and valid cost.";
        return NO;
    }
    return YES;
}

// Dismiss the keyboard when user taps the Return key
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

// Dismiss the keyboard when user taps in the background
-(void)dismissKeyboard:(id)sender {
    [self.txtDescription resignFirstResponder];
    
    [self.txtCost resignFirstResponder];
}

// Check user input:
// Description must be <=20 characters;
// Cost must be a numeric value
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 20) // Description field
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        return !([newString length] > 20);
    }
    
    if (textField.tag == 21) // Cost field
    {
        // User can use the backspace key
        if ([string isEqualToString:@""])
            return YES;
        
        // User can only enter numbers and one decimal
        NSCharacterSet *newCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if ([newCharSet characterIsMember:c])
            {
                NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
                NSArray *decimals = [newString componentsSeparatedByString:@"."];
                return !([decimals count] > 2);
            }
        }
        return NO;
    }
    else
        return NO;
}

// Clear the Error Message when user begins entering data in text fields
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 20 || textField.tag == 21)
    {
        self.lblErrorMsg.text = @"";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

    return delegate.arrayOfTransactions.count;
}

//-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//}

@end
