# Video Stabilizer
This MATLAB program takes in a handheld (or otherwise shaky or unstable) video and attempts to output a motion stabilized version of it.

## Usage
Video must be in the form of an image sequence with file names *1, 2, 3,...,n* and the file extension, where *n* is the number of frames in the video. All images in the sequence must be in one directory. Stabilization is performed by invoking the **stabilize()** function with parameters:

* **Gauss_levels:** Levels of detail to extract from input video and use for warping (default is 1, more details below)
* **input_folder:** The directory containing the image sequence.
* **output_folder:** The directory for the stabilized output (image sequence with same file type as input). Will be created if non-existing.
* **file_type:** File extension of input image sequence.
* **video_length:** Number of frames of input video.

## Details
The stabilization technique assumes the operator is attempting to keep the camera stationary but cannot do so because of prevailing conditions, including environment, equipment, and operator skill. The technique attempts to negate motion from the current frame to the next frame by detecting such motion and warping the current frame to the position and rotation of the next frame. This is done in succession backwards from the end of the video so that all frames are warped to the last frame in the video.

To begin, the motion between two 2D frames ***f(x,y,t)*** and ***f(x,y,t−1)*** can be described with
an affine model, in which the succeeding frame can be expressed in terms of scaling, rotating, and translating (in 2 dimensions) the current frame. This can be represented as the parameters
***m<sub>1</sub>***, ***m<sub>2</sub>***, ***m<sub>3</sub>***, ***m<sub>4</sub>*** in the scaling and rotation matrix ***A = [m<sub>1</sub> m<sub>2</sub>; m<sub>3</sub> m<sub>4</sub>]*** and parameters ***m<sub>5</sub>*** and ***m<sub>6</sub>*** in the translation ***T = [m<sub>5</sub>; m<sub>6</sub>]*** so that ***[x'; y'] = A[x; y] + T***, where ***(x', y')*** is the position of the subsequent frame. In other words:
