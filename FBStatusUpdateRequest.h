//
//  FBStatusUpdateRequest.h
//  Thumbprint
//
//  Created by Blake Watters on 5/13/09.
//  Copyright 2009 Objective 3. All rights reserved.
//

#import "FBConnect/FBConnect.h"
#import "FBPermissionRequest.h"

@protocol FBStatusUpdateRequestDelegate;

@interface FBStatusUpdateRequest : NSObject <FBRequestDelegate, FBPermissionRequestDelegate> {
	FBSession* _session;
	FBPermissionRequest* _permissionRequest;
	NSString* _statusText;
	
	id<FBStatusUpdateRequestDelegate> _delegate;
}

@property (nonatomic, retain) FBSession* session;
@property (nonatomic, readonly) NSString* statusText;
@property (nonatomic, assign) id<FBStatusUpdateRequestDelegate> delegate;

+ (FBStatusUpdateRequest*)requestStatusUpdate:(NSString*)statusString withSession:(FBSession*)session delegate:(id<FBStatusUpdateRequestDelegate>)delegate;
+ (FBStatusUpdateRequest*)requestStatusUpdate:(NSString*)statusString delegate:(id<FBStatusUpdateRequestDelegate>)delegate;

- (id)initWithSession:(FBSession*)session;
- (void)updateStatus:(NSString*)status;

@end

@protocol FBStatusUpdateRequestDelegate <NSObject>

@optional

/**
 * Called when the status update request succeeded.
 */
- (void)statusUpdateRequestWasSuccessful:(FBStatusUpdateRequest*)statusUpdateRequest;

/**
 * Called when the status update request was not successful.
 */
- (void)statusUpdateRequestFailed:(FBStatusUpdateRequest*)statusUpdateRequest;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)statusUpdateRequest:(FBStatusUpdateRequest*)statusUpdateRequest didFailWithError:(NSError*)error;

@end
