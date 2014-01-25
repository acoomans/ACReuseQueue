//
//  ACReuseQueueTests.m
//  ACReuseQueueTests
//
//  Created by Arnaud Coomans on 22/01/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACReuseQueue.h"
#import "ACReusableTestObject.h"


static NSString * const kReuseIdentifierA = @"kReuseIdentifierA";
static NSString * const kReuseIdentifierB = @"kReuseIdentifierB";


@interface ACReuseQueueTests : XCTestCase

@end

@implementation ACReuseQueueTests

- (void)setUp {
    [super setUp];
    //
}

- (void)tearDown {
    //
    [super tearDown];
}

#pragma mark - default queue

- (void)testDefaultQueue {
    
    ACReuseQueue *q = [ACReuseQueue defaultQueue];
    
    XCTAssertNotNil(q, @"No default queue");
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 0);
}


#pragma mark - enqueue

- (void)testEnqueue {
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    XCTAssertTrue(q.unusedCount == 1);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 1);

    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    XCTAssertTrue(q.unusedCount == 2);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 2);
}

- (void)testEnqueueWithMultipleIdentifiers {
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    XCTAssertTrue(q.unusedCount == 1);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 1);
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierB]];
    
    XCTAssertTrue(q.unusedCount == 2);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 2);
}

- (void)testEnqueueWithoutIdentifier {
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:nil]];
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 0);
}



#pragma mark - dequeue

- (void)testDequeue {
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    XCTAssertTrue(q.unusedCount == 1);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 1);
    
    [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 1);
    XCTAssertTrue(q.count == 1);
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    XCTAssertTrue(q.unusedCount == 1);
    XCTAssertTrue(q.usedCount == 1);
    XCTAssertTrue(q.count == 2);
    
    [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 2);
    XCTAssertTrue(q.count == 2);
}

- (void)testDequeueWithMultipleIdentifiers {
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    XCTAssertTrue(q.unusedCount == 1);
    XCTAssertTrue(q.usedCount == 0);
    XCTAssertTrue(q.count == 1);
    
    id<ACReusableObject> r = [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    
    XCTAssertEqualObjects(r.reuseIdentifier, kReuseIdentifierA);
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 1);
    XCTAssertTrue(q.count == 1);
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierB]];
    
    XCTAssertTrue(q.unusedCount == 1);
    XCTAssertTrue(q.usedCount == 1);
    XCTAssertTrue(q.count == 2);
    
    r = [q dequeueReusableObjectWithIdentifier:kReuseIdentifierB];
    
    XCTAssertEqualObjects(r.reuseIdentifier, kReuseIdentifierB);
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 2);
    XCTAssertTrue(q.count == 2);
}

- (void)testPrepareForReuse {
    
    __block BOOL blockDidRun = NO;
    
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    ACReusableTestObject *r = [[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA];
    r.prepareForReuseBlock = ^{
        blockDidRun = YES;
    };
    
    [q enqueueReusableObject:r];
    XCTAssertFalse(blockDidRun);
    
    [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    XCTAssertTrue(blockDidRun);
}

- (void)testDequeueEmpty {
    
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    @try {
        [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
        XCTAssertTrue(NO);
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.name, ACReuseQueueEmptyException);
    }
}

- (void)testDequeueEmptyForIdentifier {
    
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    @try {
        [q dequeueReusableObjectWithIdentifier:kReuseIdentifierB];
        XCTAssertTrue(NO);
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.name, ACReuseQueueEmptyException);
    }
}

- (void)testDequeueEmptied {
    
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    
    @try {
        [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
        XCTAssertTrue(NO);
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.name, ACReuseQueueEmptyException);
    }
}


#pragma - register 

- (void)testRegisterClass {
    
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    [q registerClass:ACReusableTestObject.class forObjectReuseIdentifier:kReuseIdentifierA];
    
    ACReusableTestObject *r = [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    XCTAssertNotNil(r);
    XCTAssertEqualObjects(r.reuseIdentifier, kReuseIdentifierA);
    XCTAssertTrue([r isKindOfClass:ACReusableTestObject.class]);

    @try {
        [q dequeueReusableObjectWithIdentifier:kReuseIdentifierB];
        XCTAssertTrue(NO);
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.name, ACReuseQueueEmptyException);
    }
}

- (void)testRegisterNib {
    
    // hack for tests
    __block NSBundle *bundleContainingNib = nil;
    [[NSBundle allBundles] enumerateObjectsUsingBlock:^(NSBundle *bundle, NSUInteger idx, BOOL *stop) {
        NSString *locatedPath = [bundle pathForResource:@"ACReusableTest" ofType:@"nib"];
        if (locatedPath) {
            bundleContainingNib = bundle;
            *stop = YES;
        }
    }];
    // end hack for tests

    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    [q registerNib:[UINib nibWithNibName:@"ACReusableTest" bundle:bundleContainingNib] forObjectReuseIdentifier:kReuseIdentifierA];
    
    ACReusableTestObject *r = [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    XCTAssertNotNil(r);
    XCTAssertEqualObjects(r.reuseIdentifier, kReuseIdentifierA);
    XCTAssertTrue([r isKindOfClass:ACReusableTestObject.class]);
    
    @try {
        [q dequeueReusableObjectWithIdentifier:kReuseIdentifierB];
        XCTAssertTrue(NO);
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.name, ACReuseQueueEmptyException);
    }
}

- (void)testMemoryWarning {
    
    ACReuseQueue *q = [[ACReuseQueue alloc] init];
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    [q enqueueReusableObject:[[ACReusableTestObject alloc] initWithReuseIdentifier:kReuseIdentifierA]];
    
    [q dequeueReusableObjectWithIdentifier:kReuseIdentifierA];
    
    XCTAssertTrue(q.unusedCount == 2);
    XCTAssertTrue(q.usedCount == 1);
    XCTAssertTrue(q.count == 3);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    XCTAssertTrue(q.unusedCount == 0);
    XCTAssertTrue(q.usedCount == 1);
    XCTAssertTrue(q.count == 1);
    
    
}



@end
