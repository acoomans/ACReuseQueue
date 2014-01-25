# ACReuseQueue

A queue to keep and reusing objects.

A reuse queue is a way to quickly reuse objects when object allocation and initialization is time-consuming.
This reuse queue is inspired after UITableView's for reusing cells, headers and footers.

## Usage

In your iOS project:

1. Add the _ACReuseQueue_ directory or static library into your project.
2. Add `#import "ACReuseQueue.h"`

### Reuse queue

You can then use the default queue with:

	ACReuseQueue *myQueue = [ACReuseQueue defaultQueue];
	
or allocate and initialize your own queue.

To reuse an object, call _dequeueReusableObjectWithIdentifier:_

	[myQueue dequeueReusableObjectWithIdentifier:@"myIdentifier"];
	
When you are done using an object, return it to the queue with _enqueueReusableObject:_

	[myQueue enqueueReusableObject:myObject];

### Reusable object

To be reused, an object must conform to the _ACReusableObject_ and must implement the _reuseIdentifier_

	@property (nonatomic, copy) NSString *reuseIdentifier;

If an object may implement the _prepareForReuse_ method, it will be called before the object is returned by __dequeueReusableObjectWithIdentifier:_


### Registering a class or a nib

You can register a class or a nib for a given identifier with _registerClass:forObjectReuseIdentifier:_ or _registerNib:forObjectReuseIdentifier:_. It will automatically create an object for you if no object is available when dequeueing:

	[[ACReuseQueue defaultQueue] registerClass:ACButton.class forObjectReuseIdentifier:@"button"];

or

	[[ACReuseQueue defaultQueue] registerNibWithName:NSStringFromClass(ACButton.class)
                                              bundle:nil
                            forObjectReuseIdentifier:@"button"];

	
## Demo

The _ACReuseQueueDemo_ target contains an example application to compare the performance with and without the reuse queue. You should preferably run the app on an actual device.

The demo app has a page view controller, where each page contains about 200 buttons (I know the example is a little bit contrived but it serves to expose the performance difference). Swipe both fast and slowly to appreciate the difference.

Here are results of my tests on a ipad mini (note: your performance may vary):

a) without a reuse queue:

* a page is rendered  in approximately 0.2 seconds

b) with a reuse queue:

* the first and second page are rendered in approximately 0.2 seconds as well, BUT
* the next pages are rendered in 0.015 seconds (because it can reuse the buttons)

