//
//  ThirdViewController.m
//  SampleDynamics
//
//  Created by Adam Jones on 9/25/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "ThirdViewController.h"

/**
 
 This is a simple example that mimics some of the behavior you see in the new iOS7 lock screen and
 provides a good overview of the techniques required to implement such a behavior.  Apple informs us
 that their lock screen is composed of four behaviors:
    Gravity + Collision + Attachment + Push
 
 In this example, I don't use a snap behavior.  Instead, I substituted a UIDynamicItemBehavior in place
 of the Attachment behavior.  There are multiple ways to accomplish similar behaviors and this is just
 one of them.
 
 In a nutshell, there are two boundaries defined, one offscreen to the top of the view and another onscreen
 at the bottom.  When you drag the view from the top, it will move with your gesture.  When the gesture ends,
 the view will impart some calculated linear velocity, eventually colliding with the bottom boundary, bouncing,
 and then coming to rest.  The opposite will occur when the view is dragged from the bottom position.
 
 This example includes a pan gesture and the implementation of the collision behavior delegate.  Also introduced
 is the [_dynamicAnimator updateItemUsingCurrentState:<#(id<UIDynamicItem>)#>] method, which is important when
 using gestures that move a dynamic item before adding behaviors.  This method tells the dynamic animator to
 update its state for a specific dynamic item.  Also important is the determination of which direction the
 user is panning, which is calculated by the velocity of the view within the gesture.  You can see that there
 is a relatively low number of lines required to create this behavior.
 
 */

@interface ThirdViewController ()

@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;       // collision behavior
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior;   // dynamic item behavior
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;           // gravity behavior
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;           // dynamic animator
@property (strong, nonatomic) UIPushBehavior *pushBehavior;                 // push animator
@property (strong, nonatomic) IBOutlet UIView *blueView;                    // view being dragged/pulled
@property CGRect blueFrame;                                                 // to hold the starting position of the blue frame
@property CGFloat minAllowedCenterYCoord;
@property CGFloat maxAllowedCenterYCoord;

@end

@implementation ThirdViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _blueFrame = _blueView.frame;   // save the starting frame for our blue view
    
    // Determine the minimum and maximum y coordinates so that our blue view never goes past a certain point.
    // When panning the blue view up and down 'normally' these coordinates aren't needed. However, if you load
    // this controller for first time, the min coordinate will help prevent a pan gesture updwards.  When the
    // blue view is against the bottom boundary, the max coordinate will help prevent a pan gesture downwards.
    // In my testing, I found that if the blue view was panned (via gesture) past one of the boundaries, the
    // entire dynamics 'system' ceased working.
    _minAllowedCenterYCoord = _blueFrame.origin.y + _blueFrame.size.height/2;
    _maxAllowedCenterYCoord = [[UIScreen mainScreen] applicationFrame].size.height - 40 - _blueFrame.size.height/2;
    
    // Pan gesture configuration
     UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_blueView setUserInteractionEnabled:YES];
    [_blueView addGestureRecognizer:panGestureRecognizer];
    
    // Init behaviors
    _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_blueView]];
    _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_blueView]];
    _dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[_blueView]];
    _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_blueView] mode:UIPushBehaviorModeContinuous];
    
   
    // Configure behaviors
    
    // Collisions
    // You will see that the collision boundaries are extended 10 points longer than the width of the blue view,
    // to each side.  When the boundaries were created with the same width, the collision would sometimes 'rock'
    // the blue view and turn it on its side.  An interesting side effect but not the one we're looking for!
    // Just one of the unexpected quirks noticed in the first iteration of UIKit Dynamics, similar to how collisions
    // can cause a view to change shape.
    
    // The top collision boundary, set to the starting position of the blue view
    [_collisionBehavior addBoundaryWithIdentifier:@"top"
                                        fromPoint:CGPointMake(-10, _blueFrame.origin.y)
                                          toPoint:CGPointMake(_blueFrame.size.width +20, _blueFrame.origin.y)];
    // The bottom collision, set to 40 points above the main screen application frame
    [_collisionBehavior addBoundaryWithIdentifier:@"bottom"
                                        fromPoint:CGPointMake(-10, [[UIScreen mainScreen] applicationFrame].size.height - 40)
                                          toPoint:CGPointMake([[UIScreen mainScreen] applicationFrame].size.width + 20, [[UIScreen mainScreen] applicationFrame].size.height - 40)];
    
    _collisionBehavior.collisionDelegate = self;
    
    // gravity
    [_gravityBehavior setGravityDirection:CGVectorMake(0, 0)];  // no gravity when the view loads
    
    // push
    // don't set anything for the push behavior because the default vector magnitude is nil, equal to no force
    
    // dynamic item
    [_dynamicItemBehavior setElasticity:0.25];   // for bouncing off the boundaries
    
    // Add the behaviors
    [_dynamicAnimator addBehavior:_collisionBehavior];
    [_dynamicAnimator addBehavior:_gravityBehavior];
    [_dynamicAnimator addBehavior:_pushBehavior];
    [_dynamicAnimator addBehavior:_dynamicItemBehavior];
    
}


- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view];  // get the translation
    CGFloat yVelocity = [gesture velocityInView:gesture.view].y;  // get the y velocity
    
    // Briefly referenced in the comments for _maxAllowedCenterYCoord and _minAllowedCenterYCoord, this statement
    // checks to see if the user is panning the blue view past one of the boundaries.  If they are, we just return.
    if ((yVelocity <= 0.0f && gesture.view.center.y + translation.y <= _minAllowedCenterYCoord) || (yVelocity > 0.0f && gesture.view.center.y + translation.y >= _maxAllowedCenterYCoord)) {
        return;
    }
    
    // Set the blue view's center, don't apply the translation to the x value since we want the blue
    // view to move up and down only
    gesture.view.center = CGPointMake(gesture.view.center.x, gesture.view.center.y + translation.y);
    // Move the view the intended amount of translation
    [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
    
    // All of the behavior work is done in this if statement and only when the gesture state ends.  This allows
    // the user to move the blue view around to wherever they want before releasing it.
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        // turn off interaction with the blue view until it collides with a boundary
        [_blueView setUserInteractionEnabled:NO];
        // Important step: Because the behaviors were created in viewDidLoad, when the blue view is at it's
        // starting position, we must tell the animator to update the blue view's state (at this point, the
        // blue view is in another location).  Otherwise, the view would appear to move back to where the
        // gesture started before continuing down it's intended direction.  Comment out this line and take a look.
        [_dynamicAnimator updateItemUsingCurrentState:_blueView];
        
        // With a view this large, it's generally ok to use a high value for the push behavior vector.  However,
        // if you get the velocity of the gesture high enough, the blue view will exhibit what looks to be a
        // 'stuck-in-place' vibration of sorts, up against the boundary.  This block just limits the imparted
        // velocity to 500 in the y direction.
        // For each if -
        // 1. Set the gravity direction accordingly, based on which way the gesture occurs
        // 2. Set the elasticity to be higher for a harder push.  This is a bit odd but that is the behavior
        // I observed.  Simply letting the blue view go at a certain point resulted in a higher bounce coefficient.
        // Maybe a higher velocity counteracts the elasticity?
        // 3. Set the push direction vector; if it's lower than 500, just set it to 500.  Otherwise, you could
        // have the blue view floating down the screen like a feature and that's not the effect we want.  The
        // larger the view, the harder the push needs to be.
        if (yVelocity < -500.0) {
            [_gravityBehavior setGravityDirection:CGVectorMake(0, -1)];
            [_dynamicItemBehavior setElasticity:0.5];
            [_pushBehavior setPushDirection:CGVectorMake(0, [gesture velocityInView:gesture.view].y)];
        }
        else if (yVelocity >= -500.0 && yVelocity < 0) {
            [_gravityBehavior setGravityDirection:CGVectorMake(0, -1)];
            [_dynamicItemBehavior setElasticity:0.25];
            [_pushBehavior setPushDirection:CGVectorMake(0, -500.0)];
        }
        else if (yVelocity >= 0 && yVelocity < 500.0) {
            [_gravityBehavior setGravityDirection:CGVectorMake(0, 1)];
            [_dynamicItemBehavior setElasticity:0.25];
            [_pushBehavior setPushDirection:CGVectorMake(0, 500.0)];
        } else {
            [_gravityBehavior setGravityDirection:CGVectorMake(0, 1)];
            [_dynamicItemBehavior setElasticity:0.5];
            [_pushBehavior setPushDirection:CGVectorMake(0, [gesture velocityInView:gesture.view].y)];
        }
        
    }

}

// Collision behavior delegate
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {

    // Turn user interaction back on and turn off the gravity
    [_blueView setUserInteractionEnabled:YES];
    [_gravityBehavior setGravityDirection:CGVectorMake(0, 0)];
  
}



@end
