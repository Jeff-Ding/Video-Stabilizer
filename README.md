# Video Stabilizer
This MATLAB program takes in a handheld (or otherwise shaky or unstable) video and attempts to output a motion stabilized version of it.

## Usage
Video must be in the form of an image sequence with file names *1, 2, 3,...,n* and the file extension, where *n* is the number of frames in the video. All images in the sequence must be in one directory.

* **Gauss_levels:** Levels of detail to extract from input video and use for warping (default is 1, more details below)
* **input_folder:** The directory containing the image sequence.
* **output_folder:** The directory for the stabilized output (image sequence with same file type as input). Will be created if non-existing.
* **file_type:** File extension of input image sequence.
* **video_length:** Number of frames of input video.
