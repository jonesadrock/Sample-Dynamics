//
//  SecondViewController.m
//  SampleDynamics
//
//  Created by Adam Jones on 9/20/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "SecondViewController.h"

/**
 
 The second tab in this sample application provides a quick demo of how you can configure dynamic
 item behaviors.
 
 There are various properties that you can set and it's easy to see how each property can influence
 the overall behavior of your items.  For example, when collisions are enabled, the elasticity property
 can really add to or limit the effect of things bouncing around.  Also, the interaction between angular 
 and linear velocities with their respective resistance properties is interesting, enabling you to mimic
 real-world interactions.
 
 One thing to note that I've observed about the UIKit Dynamics framework, at least in the cases when 
 UIViews are used, the frames sometimes get out-of-whack (as of the initial release of iOS7).  If you 
 start and stop the dynamics in this example, the dynamic items will look like they change shape.  
 Instead of a perfect square, you could end up with any manner of different sized rectangles.
 
 I've also noticed this effect when collisions occur.  In fact, you might see this behavior in the first 
 tab's sample code.
 
 */

@interface SecondViewController ()

// properties
// animator and behaviors
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;           // dynamic animator
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior1;  // dynamic item behavior
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior2;  // dynamic item behavior
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior3;  // dynamic item behavior
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;       // collision behavior

// for resetting view positions
@property CGRect view1Frame;     // view1 frame
@property CGRect view2Frame;     // view2 frame
@property CGRect view3Frame;     // view3 frame

// outlets
// general
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;              // start/stop dynamics
@property (strong, nonatomic) IBOutlet UIView *view1;                       // view1 - dynamic item
@property (strong, nonatomic) IBOutlet UIView *view2;                       // view2 - dynamic item
@property (strong, nonatomic) IBOutlet UIView *view3;                       // view3 - dynamic item
@property (strong, nonatomic) IBOutlet UIButton *addVelocity;               // add linear velocity

// actions
- (IBAction)toggleDynamics:(UIButton *)sender;                              // turn dynamics on/off
- (IBAction)addLinearVelocty:(UIButton *)sender;                            // add linear velocity

@end

NSString *const kStart = @"Start Dynamics";     // for start dynamics button title
NSString *const kStop = @"Stop Dynamics";       // for stop dynamics button title

@implementation SecondViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // save the dynamic item positions so we can reset their positions
    _view1Frame = _view1.frame;
    _view2Frame = _view2.frame;
    _view3Frame = _view3.frame;
    
    // init and set the reference view for the dynamic animator
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // set the default title for the start/stop dynamics button
    [_toggleButton setTitle:kStart forState:UIControlStateNormal];
    // default the add linear velocity button to hidden
    _addVelocity.hidden = YES;
}

#pragma mark - Actions
// toggle start/stop dynamics button text
- (IBAction)toggleDynamics:(UIButton *)sender {
    if (sender.currentTitle == kStart) {
        [self startDynamics];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [sender setTitle:kStop forState:UIControlStateNormal];
        _addVelocity.hidden = NO;
    }
    else {
        [self stopDynamics];
        [sender setTitle:kStart forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _addVelocity.hidden = YES;
    }
}

- (void)startDynamics {
    
    //
    // dynamic item behavior settings
    //
    
    // add a collision behavior so there is some interactivity between the items and the reference bounds
    _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_view1, _view2, _view3]];
    [_collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
    [_collisionBehavior setCollisionMode:UICollisionBehaviorModeEverything];
    
    // Initialize dynamic item behaviors
    _dynamicItemBehavior1 = [[UIDynamicItemBehavior alloc] initWithItems:@[_view1]];
    _dynamicItemBehavior2 = [[UIDynamicItemBehavior alloc] initWithItems:@[_view2]];
    _dynamicItemBehavior3 = [[UIDynamicItemBehavior alloc] initWithItems:@[_view3]];

    // Configure dynamic item behaviors
    [_dynamicItemBehavior1 setAllowsRotation:YES];
    [_dynamicItemBehavior1 setDensity:1.0];                 // kind of a standard defined density
    [_dynamicItemBehavior1 setElasticity:1.0];              // 0 - 1 (most elasticity)
    [_dynamicItemBehavior1 setFriction:0.2];                // 1 implies strong friction but you can go higher
    [_dynamicItemBehavior1 setResistance:0.0];              // 0 means no linear velocity damping; velocity won't slow down over time
    [_dynamicItemBehavior1 setAngularResistance:0.0];       // 0 means object will not slow down rotation over time
    
    [_dynamicItemBehavior2 setAllowsRotation:YES];
    [_dynamicItemBehavior2 setDensity:2.0];                 // two times the density of item 1
    [_dynamicItemBehavior2 setElasticity:0.5];              // half the elasticity of item 1
    [_dynamicItemBehavior2 setFriction:0.1];                // a little less friction than item 1
    [_dynamicItemBehavior2 setResistance:0.0];              // no linear velocity damping
    [_dynamicItemBehavior2 setAngularResistance:0.2];       // a little bit of angular rotation damping
    
    [_dynamicItemBehavior3 setAllowsRotation:NO];
    [_dynamicItemBehavior3 setDensity:5.0];                 // five times the density of item 1
    [_dynamicItemBehavior3 setElasticity:0.5];              // half the elasticity of item 1
    [_dynamicItemBehavior3 setFriction:0.0];                // no friction at all
    [_dynamicItemBehavior3 setResistance:0.0];              // no linear velocity damping
    [_dynamicItemBehavior3 setAngularResistance:0.4];       // a little higher angular rotation damping
    
    // Add some angular velocity
    // Without any velocity, angular or linear, the items will just sit there.
    // Start with angular velocity when the behavior is added and the items will just spin in place.
    // Notice how items 2 & 3 are affected by the angular resistance properties, as the spin slows down.
    [_dynamicItemBehavior1 addAngularVelocity:5.0 forItem:_view1];
    [_dynamicItemBehavior2 addAngularVelocity:-20.0 forItem:_view2];
    [_dynamicItemBehavior3 addAngularVelocity:50.0 forItem:_view3];
    
    // add behaviors to the animator
    [_dynamicAnimator addBehavior:_collisionBehavior];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior1];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior2];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior3];
    
}

// stop the dynamics from executing and reset all the items
- (void)stopDynamics {
    
    // remove all dynamic animator behaviors
    [_dynamicAnimator removeAllBehaviors];
    
    // reset the dynamic items views to their original positions
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _view1.frame = _view1Frame;
                         _view2.frame = _view2Frame;
                         _view3.frame = _view3Frame;
                     }
                     completion:^(BOOL finished){
                     }
     ];
    
}

// adding linear velocity to the dynamic items...
- (void)addLinearVelocty:(UIButton *)sender {
    [_dynamicItemBehavior1 addLinearVelocity:CGPointMake(10.0, 100.0) forItem:_view1];
    [_dynamicItemBehavior2 addLinearVelocity:CGPointMake(-30.0, 150.0) forItem:_view2];
    [_dynamicItemBehavior3 addLinearVelocity:CGPointMake(40.0, 200.0) forItem:_view3];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior1];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior2];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior3];
}


@end
