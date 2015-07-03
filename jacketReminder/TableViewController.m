//
//  TableViewController.m
//  jacketReminder
//
//  Created by Christopher Peyton on 6/1/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

{
    NSMutableArray *_pickerData;
}

@property (strong, nonatomic) IBOutlet UITextView *addressLabel;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *addressString;

@property (nonatomic) IBInspectable UIColor *settingsTableBackgroundColor;

@end

@implementation TableViewController

//detects tap to close number pad keyboard
-(void)tap: (UIGestureRecognizer *) tappedGesture
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Settings";
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    
    [self.view addGestureRecognizer:tapGesture];

    _pickerData = [NSMutableArray array];
    for (int x = 99; x > 0; x--)
    {
        NSString *temp = [NSString stringWithFormat:@"%d", x];
        [_pickerData addObject:temp];
    }

    self.picker.delegate =self;
    self.picker.dataSource =self;
    
    [self.picker selectRow:[[[NSUserDefaults standardUserDefaults] objectForKey:@"picker"] intValue] inComponent:0 animated:YES];

    //self.view.backgroundColor = self.settingsTableBackgroundColor;
    UIImage *image = [UIImage imageNamed:@"raindrops.jpg"];
    
    UIImageView *backimage = [[UIImageView alloc]initWithImage:image];
    //backimage.alpha = .23;
    [backimage setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = backimage;
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [backimage addSubview:effectView];

//    // create blur effect
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    
//    // create vibrancy effect
//    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
//    
//    // add blur to an effect view
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
//    effectView.frame = self.view.frame;
//    
//    // add vibrancy to yet another effect view
//    UIVisualEffectView *vibrantView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
//    effectView.frame = self.view.frame;
//    
//    // add both effect views to the image view
//    [backimage addSubview:effectView];
//    [backimage addSubview:vibrantView];
}


- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *temp = [NSString stringWithFormat:@"%ld", (long)row];
    
    //save array index
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"picker"];
    //save temperature from array index
    [[NSUserDefaults standardUserDefaults] setInteger:[_pickerData[row] integerValue] forKey:@"monitoredTemp"];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //retrieve home location string
    self.addressString = self.homeInformationFromRoot[1];

    self.addressLabel.text = self.addressString;

  
}

//PREVENT PASTING NON NUMERICAL VALUES AS TEMPERATURE VALUE
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    /* for backspace */
    if([string length]==0){
        return YES;
    }
    
    /*  limit to only numeric characters  */
    
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            
            return YES;
        }
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 4;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 3;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
