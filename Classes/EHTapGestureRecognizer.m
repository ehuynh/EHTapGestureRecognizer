//
//  EHTapGestureRecognizer.m
//  EHTapGestureRecognizer
//
//  Copyright (c) 2013 Edward Huynh
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EHTapGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface EHTapGestureRecognizer ()

/// timer that fails the gesture after it's time has elapsed
@property (nonatomic, strong) NSTimer *failGestureTimer;

/// count of how many taps that have been recognized so far
@property (nonatomic) NSUInteger numberOfTapsRecognized;

@end

static CGFloat defaultWaitTime = 0.0f;

@implementation EHTapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    
    if (self)
    {
        self.failGestureTimer = nil;
        self.waitTime = defaultWaitTime;
        self.numberOfTapsRequired = 1;
        self.numberOfTapsRecognized = 0;
    }
    
    return self;
}

#pragma mark - UIGestureRecognizer

- (void)reset
{
    [super reset];
    
    self.numberOfTapsRecognized = 0;
    [self.failGestureTimer invalidate];
    self.failGestureTimer = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    // if the touch has moved, then it is not a tap. Fail gesture immediately
    [self failGesture];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self fireTimerIfItIsNotAlreadyRunning];
    [self incrementNumberOfTapsRecognized];
    [self updateGestureState];
}

#pragma mark - tap processing

- (void)incrementNumberOfTapsRecognized
{
    self.numberOfTapsRecognized++;
}

- (void)updateGestureState
{
    if (self.numberOfTapsRecognized == self.numberOfTapsRequired)
    {
        [self.failGestureTimer invalidate];
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)setNumberOfTapsRequired:(NSUInteger)numberOfTapsRequired
{
    _numberOfTapsRequired = numberOfTapsRequired;
    
    // no wait time is required if the number of taps required is 1
    if (numberOfTapsRequired > 1 && ![self hasWaitTimeBeenSet])
    {
        [self calculateReasonableWaitTimeForNumberOfTaps:numberOfTapsRequired];
    }
}

#pragma mark - Timer handling

- (void)fireTimerIfItIsNotAlreadyRunning
{
    if (![self isTimerRunning])
    {
        [self fireTimer];
    }
}

- (void)fireTimer
{
    self.failGestureTimer = [NSTimer scheduledTimerWithTimeInterval:self.waitTime
                                                             target:self
                                                           selector:@selector(failGesture)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (BOOL)isTimerRunning
{
    return self.failGestureTimer && self.failGestureTimer.isValid;
}

- (void)failGesture
{
    self.state = UIGestureRecognizerStateFailed;
}

#pragma mark - wait time

- (BOOL)hasWaitTimeBeenSet
{
    return self.waitTime != defaultWaitTime;
}

- (void)calculateReasonableWaitTimeForNumberOfTaps:(NSInteger)numberOfTaps
{
    static CGFloat reasonableWaitTimePerTap = 0.1f;
    
    self.waitTime = reasonableWaitTimePerTap * numberOfTaps;
}

@end
