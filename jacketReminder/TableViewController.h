//
//  TableViewController.h
//  jacketReminder
//
//  Created by Christopher Peyton on 6/1/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSMutableArray *homeInformationFromRoot;//will contain 2 items: cllocation and address string
@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@end
