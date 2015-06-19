//
//  test.m
//  jacketReminder
//
//  Created by Christopher Peyton on 6/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import "test.h"

@interface test ()
{
    IBInspectable float ooo;
}
@property (nonatomic) IBInspectable UIColor *aaa;

@end

@implementation test

- (void)drawRect:(CGRect)rect {
    /* Set UIView Border */
    /*
     // Get the contextRef
     CGContextRef contextRef = UIGraphicsGetCurrentContext();
     
     // Set the border width
     CGContextSetLineWidth(contextRef, 5.0);
     
     // Set the border color to RED
     CGContextSetRGBStrokeColor(contextRef, 255.0, 0.0, 0.0, 1.0);
     
     // Draw the border along the view edge
     CGContextStrokeRect(contextRef, rect);
     */
    
    /* Draw a circle */
    // Get the contextRef
    
    IBInspectable CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Set the border width
    IBInspectable CGContextSetLineWidth(contextRef, ooo);
    CGContextAddEllipseInRect(contextRef, CGRectMake(50, 70, 200, 200));
    // Set the circle fill color to GREEN
    IBInspectable CGContextSetRGBFillColor(contextRef, 0.0, 255.0, 0.0, 1.0);
    
    // Set the cicle border color to BLUE
    IBInspectable CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 255.0, 1.0);
    
    // Fill the circle with the fill color
    IBInspectable CGContextFillEllipseInRect(contextRef, rect);
    
    // Draw the circle border
    IBInspectable CGContextStrokeEllipseInRect(contextRef, rect);
  
}

@end
