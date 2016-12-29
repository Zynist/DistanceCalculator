//
//  ViewController.m
//  PeerReview04
//
//  Created by Aaron Deadman on 27/12/2016.
//  Copyright © 2016 Aaron Deadman. All rights reserved.
//

#import "ViewController.h"
#import "DistanceGetter/DGDistanceRequest.h"

@interface ViewController ()

@property (nonatomic) DGDistanceRequest *request;

@property (weak, nonatomic) IBOutlet UITextField *startingLocation;

@property (weak, nonatomic) IBOutlet UITextField *endLocationA;
@property (weak, nonatomic) IBOutlet UILabel *distanceA;

@property (weak, nonatomic) IBOutlet UITextField *endLocationB;
@property (weak, nonatomic) IBOutlet UILabel *distanceB;

@property (weak, nonatomic) IBOutlet UITextField *endLocationC;
@property (weak, nonatomic) IBOutlet UILabel *distanceC;

@property (weak, nonatomic) IBOutlet UITextField *endLocationD;
@property (weak, nonatomic) IBOutlet UILabel *distanceD;

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSelector;

@property NSArray *distances;

@end

@implementation ViewController
- (IBAction)calculateButtonTapped:(id)sender {
    self.calculateButton.enabled = NO;
    
    self.request = [DGDistanceRequest alloc];
    NSString *start = self.startingLocation.text;
    NSString *destA = self.endLocationA.text;
    NSString *destB = self.endLocationB.text;
    NSString *destC = self.endLocationC.text;
    NSString *destD = self.endLocationD.text;
    NSArray *dests = @[destA, destB, destC, destD];
    self.request = [self.request initWithLocationDescriptions:dests sourceDescription:start];
    
    __weak ViewController *weakSelf = self;
    self.request.callback = ^(NSArray *responses){
        ViewController *parent = weakSelf;
        if(parent){
            parent.distances = responses;
            NSArray *labels = @[parent.distanceA, parent.distanceB, parent.distanceC, parent.distanceD];
            for (int i = 0; i < 4; i++) {
                [parent processResponse:responses[i] withLabel:labels[i]];
            }
            parent.calculateButton.enabled = YES;
            parent.request = nil;
        }
    };
    [self.request start];
}
- (void)processResponse:(id)response withLabel:(UILabel*) label {
    NSNull *badResponse = [NSNull null];
    float distanceInM = 0.0;
    if (response != badResponse) // only use valid responses
        distanceInM = [response floatValue];
    
    float distanceInKm = distanceInM/1000;
    float distanceInMiles = distanceInM/1609.34;
    
    NSString *output = [NSString alloc];
    if (self.unitSelector.selectedSegmentIndex == 0) {
        output = [NSString stringWithFormat:@"%.2f m", distanceInM];
    } else if (self.unitSelector.selectedSegmentIndex == 1) {
        output = [NSString stringWithFormat:@"%.2f km", distanceInKm];
    } else {
        output = [NSString stringWithFormat:@"%.2f mi", distanceInMiles];
    }
    label.text = output;
}
- (IBAction)unitSelectorChanged:(id)sender {
    NSArray *labels = @[self.distanceA, self.distanceB, self.distanceC, self.distanceD];
    for (int i = 0; i < 4; i++){
        // if our self.distances array exists, use it, otherwise
        // use a float value of 0.0.
        id resp;
        if (self.distances != nil)
            resp = self.distances[i];
        else
            resp = [[NSNumber alloc] initWithFloat: 0.0];
        [self processResponse:resp withLabel:labels[i]];
    }
}
@end
