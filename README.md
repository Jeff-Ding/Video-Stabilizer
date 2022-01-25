# Purpose of this Clone
I (@frank-engel-usgs) created this clone of the original [Video Stabilizer](https://github.com/Jeff-Ding/Video-Stabilizer) project in order to modify it for use in stabilizing video shot mainly from Drones that are being used to derive surface velocities with image velocimetry techniques like PIV. I wanted to be able to create new functionality without issuing Pull Requests (at least for now). My additions are superficial mostly, and credit should be given to Jeff Ding and his team for the original methods. 

Summary of changes:
* Created a very simple UI which will prompt users to select the folder where image frames to be processed are located, then specific the folder where stabilized images should be located.
* Added the ability to specify a mask (using `roipoly`) to exclude unintended motion from analysis. This was necessary for my use case because, generally I am correcting motion from a drone looking at a flowing river. By masking out the moving water, the end result is a stabilized view of the river.
* I modified how `stabilize.m` works to read in frame pairs rather than a large stack array of all imagery. This reduced memory useage dramitically, allowing for faster processing, and also ensuring that `stabilize.m` would not crash for larger datasets (either image size/resolution or number of input frames). 

We have been using this modified version of the original code in the US Geologicla Survey for a couple of years now with some suucess. There are still some known issues. For example, the first frame (last output by `stabilize.m`) tends to be incorrect. Future improvements can fix this. 

# Video Stabilizer
This MATLAB program takes in a handheld (or otherwise shaky or unstable) video and outputs a motion stabilized version of it.

- [Usage](#usage)
- [Example](#example)
- [Details](#details)
- [References](#references)
 
## Usage
Video must be in the form of an image sequence with file names *1, 2, 3,...,n* and the file extension, where *n* is the number of frames in the video. All images in the sequence must be in one directory. Stabilization is performed by invoking the **stabilize()** function with parameters:

* **Gauss_levels:** Levels of detail to extract from input video and use for warping (default is 1, more details below)
* **input_folder:** The directory containing the image sequence.
* **output_folder:** The directory for the stabilized output (image sequence with same file type as input). Will be created if non-existing.
* **file_type:** File extension of input image sequence.
* **video_length:** Number of frames of input video.

## Example
[Original Video](https://vimeo.com/200021989/b444cff847)

[Stabilized Video](https://vimeo.com/200022148/6799054385)

## Details
The stabilization technique assumes the operator is attempting to keep the camera stationary but cannot do so because of prevailing conditions, including environment, equipment, and operator skill. The technique attempts to negate motion from the current frame to the next frame by detecting such motion and warping the current frame to the position and rotation of the next frame. This is done in succession backwards from the end of the video so that all frames are warped to the last frame in the video.

To begin, the motion between two 2D frames **f(x,y,t)** and **f(x,y,t−1)** can be described with
an affine model, in which the succeeding frame can be expressed in terms of scaling, rotating, and translating (in 2 dimensions) the current frame. This can be represented as the parameters
**m<sub>1</sub>**, **m<sub>2</sub>**, **m<sub>3</sub>**, **m<sub>4</sub>** in the scaling and rotation matrix **A = [m<sub>1</sub> m<sub>2</sub>; m<sub>3</sub> m<sub>4</sub>]** and parameters **m<sub>5</sub>** and **m<sub>6</sub>** in the translation vector **T = [m<sub>5</sub>; m<sub>6</sub>]** so that **[x'; y'] = A[x; y] + T**, where **(x', y')** is the position of the subsequent frame. In other words:
 
<p align="center"><b>f(x,y,t) = f(m<sub>1</sub>x + m<sub>2</sub>y + m<sub>5</sub>, m<sub>3</sub>x + m<sub>4</sub>y + m<sub>6</sub>, t−1)</b>.</p>

The objective is to find the next frame that minimizes the difference from the current frame. This means minimizing the quadratic error function:

<p align="center"><b>E(M) = ∑<sub>x,y∈Ω</sub>[f(x,y,t) - f(m<sub>1</sub>x + m<sub>2</sub>y + m<sub>5</sub>, m<sub>3</sub>x + m<sub>4</sub>y + m<sub>6</sub>, t−1)]<sup>2</sup></b>,</p>

where **M = (m<sub>1</sub> ... m<sub>6</sub>)<sup>T</sup>** and **Ω** a region-of-interest to perform the calculation over (the dimensions of the video frame). The error function simplifies using a first
order truncated Taylor series expansion:

<p align="center">
 <b>
  E(m) ≈ ∑<sub>x,y∈Ω</sub>[f<sub>t</sub> - (m<sub>1</sub>x + m<sub>2</sub>y + m<sub>5</sub> - x)f<sub>x</sub> -   (m<sub>3</sub>x + m<sub>4</sub>y + m<sub>6</sub> - y)f<sub>y</sub>]<sup>2</sup>
  <br>
  = ∑<sub>x,y∈Ω</sub>[k - C<sup>T</sup>M]<sup>2</sup>
 </b>,
</p>

where
<p align="center">
 <b>k = f<sub>t</sub> + xf<sub>x</sub> + yf<sub>y</sub></b>
 and
 <b>C<sup>T</sup> = (xf<sub>x</sub> yf<sub>x</sub> xf<sub>y</sub> yf<sub>y</sub> f<sub>x</sub> f<sub>y</sub>)</b>
</p>

and temporal and spatial derivatives given by the convolutions:

<p align="center">
 <b>
 f<sub>x</sub>(x,y,t) = (0.5f(x,y,t) + 0.5f(x,y,t−1)) ★ d(x) ★ p(y)<br>
 f<sub>y</sub>(x,y,t) = (0.5f(x,y,t) + 0.5f(x,y,t−1)) ★ p(x) ★ d(y)<br>
 f<sub>t</sub>(x,y,t) = (0.5f(x,y,t) - 0.5f(x,y,t−1)) ★ p(x) ★ p(y)
 </b>.
</p>

With the 1D filters **d(x) = (0.5 -0.5), p(x) = (0.5 0.5)** and **d(y) = d(x)<sup>T</sup>, p(y) = p(x)<sup>T</sup>**.

With the error function now linear with respect to **M**, we can minimize by differentiating and setting equal to zero:

<p align="center"><b>dE(M)/dM = ∑<sub>Ω</sub>2c[k - C<sup>T</sup>M] = 0</b>.</p>

Solving yields the parameter **m**'s:

<p align="center"><b>M = [∑<sub>Ω</sub>CC<sup>T</sup>]<sup>-1</sup>[∑<sub>Ω</sub>Ck]</b>.</p>

The use of these derivatives limits the range of motion able to be estimated, so each frame is separated as a stack of its coarse-to-fine details by applying a Gaussian pyramid of low-pass filters to extract the information at each level of detail. Starting at the bottom, the motion from the coarsest level is used to warp the next, more finely detailed level, and so on until the final, full resolution level is reached. Thus, the coarser motions are first estimated and then refined by the finer motions. Let **L** be the number of levels in such a Gaussian pyramid *(this is the Gauss_level parameter)*.

To avoid excessive blurring, instead of warping at each level with the motion of the previous level all the way up to **l = 1** (the full resolution video), we instead apply all warps to the top-level frame. This means at each pyramid level **l** we warp the original frame with the affine matrix **A = [m<sub>1</sub> m<sub>2</sub>; m<sub>3</sub> m<sub>4</sub>]** and translation vector **T = [2<sup>l-1</sup>m<sub>5</sub>; 2<sup>l-1</sup>m<sub>6</sub>]**. Note that applying the warp **A<sub>1</sub>**, **T<sub>1</sub>** followed by the warp **A<sub>2</sub>**, **T<sub>2</sub>** is the equivalent of applying

<p align="center">
 <b>A = A<sub>2</sub>A<sub>1</sub></b>
 and
 <b>T = A<sub>2</sub>T<sub>1</sub> + T<sub>2</sub></b>.
</p>

In this way, instead of applying warps at every level, we can stack and accumulate the warps by repeating this for all levels **l** and end up with one matrix and one vector describing the motion between two frames. The motion parameters are calculated for every pair of successive frames in the video, and then, moving backwards from the last frame, each frame is warped to the previous frame so that all frames end up being warped to the last frame. This process produces a single, stabilized video.

## References
Stabilization technique based on algorithm described in http://www.cs.dartmouth.edu/farid/downloads/publications/tr07.pdf.
