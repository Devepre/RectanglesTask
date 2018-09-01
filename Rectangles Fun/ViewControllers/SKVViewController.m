//
//  SKVViewController.m
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import "SKVViewController.h"
#import "UIColor+SKVRandomColor.h"
#import "UIPinchGestureRecognizer+SKVDirection.h"

#import "RectangleView.h"

@interface SKVViewController ()

@property(strong, nonatomic) UIView *startPointView;
@property (assign, nonatomic, getter=isCreatingRectangle) BOOL creatingRectangle;
@property (assign, nonatomic) CGPoint firstTapPoint;
@property (assign, nonatomic) CGPoint secondTapPoint;

@property(weak, nonatomic) UIView *currentlyCreatingView;

@end

@implementation SKVViewController

static const CGFloat TOUCH_VIEW_FRAME_SIZE = 15;
static const CGFloat DEFAULT_RECTANGLE_SIZE = 100;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeGestures];
}


- (void)initializeGestures {
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGlobalPan:)];
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
}


- (void)attachGesturesToView:(UIView *)view {
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [view addGestureRecognizer:rotationGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForRectangleView:)];
    panGesture.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [view addGestureRecognizer:pinchGesture];
}


#pragma mark - Drawing

- (RectangleView *)createRectangleViewForStartPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
                                animated:(BOOL)animated
                                         normalized:(BOOL)normalized {
    CGRect frame = CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    
    if (normalized) {
        frame = [self normalizeFrame:frame];
    }
    
    RectangleView *rectangleView = [[RectangleView alloc] initWithFrame:frame];
    
    rectangleView.backgroundColor = UIColor.randomColor;
    [self.view addSubview:rectangleView];
    
    if (animated) {
        rectangleView.alpha = 0.f;
        // Perform animations to show rectangle smoothly
        [UIView animateWithDuration:0.3
                         animations:^{
                             rectangleView.alpha = 1.f;
                         } completion:^(BOOL finished) {
                             [self attachGesturesToView:rectangleView];
                         }];
    } else {
        [self attachGesturesToView:rectangleView];
    }
    return rectangleView;
}


- (CGRect)normalizeFrame:(CGRect)frame {
    CGRect result = frame;
    if (ABS(frame.size.width) < DEFAULT_RECTANGLE_SIZE) {
        int multiplier = frame.size.width > 0 ? 1 : -1;
        result.size.width = DEFAULT_RECTANGLE_SIZE * multiplier;
    }
    if (ABS(frame.size.height) < DEFAULT_RECTANGLE_SIZE) {
        int multiplier = frame.size.height > 0 ? 1 : -1;
        result.size.height = DEFAULT_RECTANGLE_SIZE * multiplier;
    }
    return result;
}


- (void)addStartPointViewAtPoint:(CGPoint)point {
    CGRect touchFrame = CGRectMake(point.x - TOUCH_VIEW_FRAME_SIZE / 2.f, point.y - TOUCH_VIEW_FRAME_SIZE / 2.f,
                                   TOUCH_VIEW_FRAME_SIZE, TOUCH_VIEW_FRAME_SIZE);
    self.startPointView = [[UIView alloc] initWithFrame:touchFrame];
    self.startPointView.backgroundColor = UIColor.purpleColor;
    self.startPointView.alpha = .5f;
    self.startPointView.layer.cornerRadius = TOUCH_VIEW_FRAME_SIZE / 2.f;
    [self.view addSubview:self.startPointView];
    
    // Perform animations - should be moved to separate view class
    CGAffineTransform currentTransform = CGAffineTransformMakeScale(.7f, .7f);
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 1.3f, 1.3f);
    self.startPointView.transform = currentTransform;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.startPointView.transform = newTransform;
                     }];
}


- (void)removeStartPointViewWithAnimation:(BOOL)animated {
    // Perform animations - should be moved to separate view class
    CGAffineTransform currentTransform = self.startPointView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 0.2f, 0.2f);
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.startPointView.transform = newTransform;
                         } completion:^(BOOL finished) {
                             [self.startPointView removeFromSuperview];
                             self.startPointView = nil;
                         }];
    } else {
        [self.startPointView removeFromSuperview];
        self.startPointView = nil;
    }
}


#pragma mark - Helper methods

- (void)bringToFrontRectangleView:(RectangleView *)rectangleView {
    [self.view bringSubviewToFront:(UIView *)rectangleView];
}


- (RectangleView *)getRectangleForPoint:(CGPoint)point {
    RectangleView *result = nil;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:RectangleView.class]) {
            CGPoint insidePoint = [self.view convertPoint:point toView:view];
            if ([view pointInside:insidePoint withEvent:nil]) {
                result = (RectangleView *)view;
            }
        }
    }
    return result;
}


- (void)changeViewColorForPoint:(CGPoint)point toColor:(UIColor *)color {
    RectangleView *rectangleView = [self getRectangleForPoint:point];
    if (!rectangleView) {
        return;
    }
    rectangleView.backgroundColor = color;
}


#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    CGPoint locationInView = [tapGesture locationInView:self.view];
    
    // tap is on top of rectangle?
    RectangleView *tappedRectangle = [self getRectangleForPoint:locationInView];
    if (tappedRectangle) {
        [self bringToFrontRectangleView:tappedRectangle];
    } else { // handling creating rectangle
        if (self.isCreatingRectangle) {
            [self removeStartPointViewWithAnimation:YES];
            self.secondTapPoint = locationInView;
            [self createRectangleViewForStartPoint:self.firstTapPoint
                                          endPoint:self.secondTapPoint
                                          animated:YES
                                        normalized:YES];
        } else {
            self.firstTapPoint = locationInView;
            [self addStartPointViewAtPoint:locationInView];
        }
        self.creatingRectangle = !self.isCreatingRectangle;
    }
}


// User can create rectangle
- (void)handleGlobalPan:(UIPanGestureRecognizer *)sender {
    CGPoint locationInView = [sender locationInView:self.view];
    static CGSize initialSize;
    static CGPoint initialOrigin;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            // FIXME: looks like DRY principle is broken here
            // tap is on top of rectangle?
            RectangleView *tappedRectangle = [self getRectangleForPoint:locationInView];
            if (tappedRectangle) {
                [self bringToFrontRectangleView:tappedRectangle];
            } else { // handling creating rectangle
                if (self.creatingRectangle) {
                    [self removeStartPointViewWithAnimation:NO];
                }
                self.creatingRectangle = YES;
                self.firstTapPoint = locationInView;
                [self addStartPointViewAtPoint:locationInView];
                
                self.currentlyCreatingView = [self createRectangleViewForStartPoint:locationInView
                                                                           endPoint:locationInView
                                                                           animated:NO
                                                                         normalized:NO];
            }
            initialSize = self.currentlyCreatingView.frame.size;
            initialOrigin = self.currentlyCreatingView.frame.origin;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [sender translationInView:sender.view.superview];
            
            CGRect newFrame = CGRectMake(initialOrigin.x,
                                         initialOrigin.y,
                                         initialSize.width + translation.x,
                                         initialSize.height + translation.y);
            self.currentlyCreatingView.frame = newFrame;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        default:
            self.currentlyCreatingView.frame = [self normalizeFrame:self.currentlyCreatingView.frame];
            [self removeStartPointViewWithAnimation:NO];
            self.creatingRectangle = NO;
            self.currentlyCreatingView = nil;
            break;
    }
}


// user can change object color with long tap gesture (just apply new random color)
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint locationInView = [longPressGesture locationInView:self.view];
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self changeViewColorForPoint:locationInView
                                  toColor:UIColor.randomColor];
            break;
        default:
            break;
    }
    
}

// user can remove object via 2 taps on object
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTapGesture {
    CGPoint locationInView = [doubleTapGesture locationInView:self.view];
    
    RectangleView *rectangleView = [self getRectangleForPoint:locationInView];
    if (rectangleView) {
        [self bringToFrontRectangleView:rectangleView];
        [rectangleView removeFromSuperview];
    }
}


// User can rotate object
- (void)handleRotation:(UIRotationGestureRecognizer *)sender {
    static CGFloat initialRotation;
    if (sender.state == UIGestureRecognizerStateBegan) {
        initialRotation = atan2f(sender.view.transform.b, sender.view.transform.a);
    }
    CGFloat newRotation = initialRotation + sender.rotation;
    sender.view.transform = CGAffineTransformMakeRotation(newRotation);
}


// User can drag/move object
- (void)handlePanForRectangleView:(UIPanGestureRecognizer *)sender {
    static CGPoint initialCenter;
    if (sender.state == UIGestureRecognizerStateBegan) {
        initialCenter = sender.view.center;
    }
    [self bringToFrontRectangleView:(RectangleView *)sender.view];
    CGPoint translation = [sender translationInView:sender.view.superview];
    sender.view.center = CGPointMake(initialCenter.x + translation.x, initialCenter.y + translation.y);
}


// User can resize objects
- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
    CGFloat scale = sender.scale;
    static CGRect initialBounds;
    RectangleView *currentView = (RectangleView *)sender.view;
    
    // Helper block created in order to make
    // later switch-case more clear to read
    void(^changeSizeOfView)(RectangleView *) = ^(RectangleView *view) {
        UIPinchGestureRecognizerOrientation currentOrientation = [sender getDirection];
        switch (currentOrientation) {
            case OrientaionVertical: {
                CGFloat newHeight = CGRectGetHeight(initialBounds) * scale;
                [view setWidth:CGRectGetWidth(initialBounds)
                               height:newHeight];
                break;
            }
            case OrientaionHorizontal: {
                CGFloat newWidth = CGRectGetWidth(initialBounds) * scale;
                [view setWidth:newWidth
                               height:CGRectGetHeight(initialBounds)];
                break;
            }
            case OrientaionDoiagonal: {
                CGFloat newWidth = CGRectGetWidth(initialBounds) * scale ;
                CGFloat newHeight = CGRectGetHeight(initialBounds) * scale ;
                [currentView setWidth:newWidth
                               height:newHeight];
                break;
            }
            default:
                break;
        }
    };
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            initialBounds = currentView.bounds;
            break;
        case UIGestureRecognizerStateChanged: {
            changeSizeOfView(currentView);
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            currentView.bounds = [self normalizeFrame:currentView.bounds];
        default:
            break;
    }
    
}

@end
