## Facemover

### TODO

* Capture frames for training based of FlowTracker when face isn't detected.
* Model time since last real detection
* Do something about face passing out of edge of frame
* Get setup to do SVM detectMultiScale
* Make more test videos

### Progress Log

#### Implementing Optical Flow with OpenCV

OpenCV implements two flavors of optical flow: Farneback, which is a dense approach and PyrLK which is a sparse, feature-based approach. After some investigation of both of these techniques, I chose to go with Farneback because its is more biologically realistic (i.e. using motion throughout the visual field rather than some more specific concept of higher level features), closer to the approach taken in the Ullman paper, and easier to implement.

Having made that decision, I wrapped the OpenCV Farneback functions into [OpenCV for Processing](https://github.com/atduskgreg/opencv-processing), the OpenCV wrapper for Processing that I maintain (landed in version [0.5.2](https://github.com/atduskgreg/opencv-processing/releases/tag/v0.5.2)).

#### Tracking with Optical Flow in the absence of faces

With the optical flow implementation in hand, I used it to implement a FlowTracker class responsible for tracking the movement of a given point in the image based on the surrounding optical flow. Implementation [here](https://github.com/atduskgreg/facemover/blob/7734be38a4164e709d8319eb8a4c6e2631e07a9b/facemover_training/facemover_training.pde).

The FlowTracker picks up from the center of the last seen face on any frame where the face disappears and tracks based on the optical flow in the video within a square around that point.

You can see video of the FlowTracker augmenting the OpenCV face detection [here](https://vimeo.com/114073283). (The face rectangle is green when OpenCV's haar detection is responsible for it and blue when it's being updated through optical flow. The white line in the middle of the image represents the average flow within the face rectangle at any given point in the video.)

Once the FlowTracker was up and running I used it to capture images from my test video as an initial input to the machine learning module.

Currently, the FlowTracker produces some false positives that should be easily eliminated: it should have a decay rate so if it hasn't seen a face in a while it doesn't just wander into some part of the image. It should also deal better with boundaries of the image.

In the meantime, I separated the good samples from the bad ones by hand, setting aside the bad ones to use as negative examples

#### Feature Selection and OpenCV HOG Descriptor implementation

Based on previous experience doing object detection (and various literature we looked at this semester for computer vision object detection and how edge processing works in the ventral visual stream) I decided to use Histogram of Oriented Gradients as the source of my features for these images.

OpenCV includes a HOGDescriptor class that can compute HOG features for a given image. It also has a detectMultiScale function that can do multiscale detection within an image based on a trained classifier.

After some poking around with this obscure API, I was able to successfully compute the HOG descriptors and use them in an old example I had around that used HOG plus an SVM classifier to do hand gesture recognition. That example had used a separate HOG library so I was able to validate that substituting in this new OpenCV implementation worked successfully.

One troubling thing I learned in this process is that while OpenCV's detectMultiScale functionality can accept an SVM model to do the detection, absurdly, it cannot use the SVM models trained by its own machine learning module. Or by libsvm for that matter. There seem to be some people online who have figured out a transform to do on the support vectors yielded by libsvm in order to get detectMultiScale to accept them. I'll burn that bridge when I come to it, i.e. after training is working well I'll see if I can figure out this transform or I can just manually implement some less efficient version of windowed search as a stopgap.

#### Setting Up a Machine Learning Environment

Once I had HOG feature calculation up and running, I dove into setting up a training environment. I'd previously written a wrapper class for OpenCV's various machine learning classes (and libsvm since OpenCV's svm implementation is based on an old, crappy version of libsvm). It includes a unified interface to many different classification algorithms and some tools for doing things like crossfold validation, calculating evaluation metrics, etc.

I took the hand-labeled images from my initial optical flow-based tracker used them as a training set. Here's some numbers from the initial results (with 4-fold cross validation):
 
    ========CUMULATIVE RESULT (4 folds)================
    accuracy: 0.87261903
    precision: 0.9166667
    recall: 0.7916667
    f-measure: 0.81666666

Looking pretty good.

This is based on a really small data set as it's just from one video of me waving my face around in front of a camera. So, the next step is to expand the data set to more videos and see if these numbers hold. And, in parallel to work on improving the selection of positive and training examples in the FlowTracker to get the training process fully automated. Once that's working, all that will be left is implementing multiscale detection.
