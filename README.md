Anisotropy
--------------------------
this repository is maintained by Anders Sejr Hansen

### This code is associated with the paper from McSwiggen et al., "Evidence for DNA-mediated nuclear compartmentalization distinct from phase separation". eLife, 2019. http://dx.doi.org/10.7554/eLife.47098


# Overview of code for localization and tracking
This repository contains Matlab code for processing raw SPT movies in
either Nikon's nd2 format or in TIFF format. It contains multiple
scripts for multiple different purposes (e.g. fastSPT, slowSPT, PALM
etc.), but they all have the same general structure. The user opens
the script, adjusts the parameters, tells it where to find the movies
and where to save the trajectories and, finally, clicks "run". Below,
we will describe the code in a little bit of detail and then a brief
guide to how to use it.
The respository also contains a GUI (Graphical User Interface). Please
see below for how to use it. 

## Multiple-Target Tracing algorithm
The code uses the Multiple-Target Tracing (MTT) algorithm (see below
for reference to the key paper). Before using it, please read that
paper in detail to understand how it works and the function of each
parameter.

## Example guide - how to run the code on nd2 files
*Warning: this code uses BioFormats to read `nd2` files. Some versions
of BioFormats are incompatible with some Nikon `nd2` versions. When
this happens, BioFormats will mess-up, re-scale and otherwise corrupt
the `nd2` file, with catastrophic results. Please verify that your
`nd2` file version is compatible with this version of BioFormats after
loading in a file. There is also a version of the code in this
repository that reads TIFF files instead,
`SerialProcess_fastSPT_JF549_TIFF.m`.*

There are two types of scripts, `SerialProcess_` and
`ParallelProcess_`, which do either serial or parallel processing as
the name might suggest. Parallel processing requires multiple CPUs of
course but also a lot of memory - if you run out of memory you will
get Java errors in Matlab and have to restart. Here we will use
`SerialProcess_fastSPT_JF646.m` as an example on how to run the code:

1. Collect high-quality single-particle tracking data (SPT) in the
   fastSPT mode (e.g. spaSPT as described in [Hansen, Woringer et al.,
   Robust model-based analysis of single-particle tracking experiments
   with Spot-On, **eLife**, 2018](https://elifesciences.org/articles/33125)).
2. Download this repository to your computer. 
3. If in a BioFormats-compatible nd2 file format, place all `nd2`
files of the same frame rate in a single folder.
4. Open `SerialProcess_fastSPT_JF646.m` and modify `input_path` to
   where your `nd2` files are (don't forget to add `/` at the end if
   on a Mac or `\` add the end of on Windows). Change `output_path` to
   where you want to save the trajectories. If the folder does not
   exist, Matlab will create it automatically. These can be found in
   lines 19-20.
5. Adjust `ExposureTime` in line 40 to the time between frames in
   milliseconds. If you use 0.9 us vertical shift speed on an Andor
   iXon EM-CCD camera, add 447 us beyond the camera exposure time. All
   the other parameters are preset for standard fastSPT experiments. 
6. Click "Run".
7. The code will save one `MAT`-file per `nd2` file using the
`trackedPar` format. This format is directly readable by both the
web-version of [Spot-On](https://spoton.berkeley.edu) and the Matlab
version,  [Spot-On-Matlab](https://gitlab.com/tjian-darzacq-lab/spot-on-matlab). 

## Considerations for choosing parameters 
The code comes with a large number of user-specified parameters that
define how the tracking and localization is performed. Please read the
MTT-paper in details first (see reference below). Here we will
describe a few of the most important parameters:

* `LocalizationError`: a probabilitic detection threshold. Typically
  we use `LocalizationError = -6.25` corresponding to one false
  positive detection per $`10^{-6.25}`$. How to balance
  false-positives and false-negatives will depend on the
  Signal-to-Noise characteristics of your SPT data. Generally, 6-7 is
  a reasonable range for `LocalizationError`.
* `EmissionWavelength`: the average wavelength of your emission. Will depend
  on your fluorophore and also on your emission filter (e.g. if you
  emission filter cuts off parts of your emissions. Generally, we use
  580 for JF549 and 664 for JF646.
* `NumDeflationLoops`: how many deflation loops to do for the
  detections (i.e. attempting to find molecules partially obscured by
  other molecules). In my opinion, this feature is not robust and
  prone to give false positives and if you have a lot of molecules
  obscured by other molecules, you are imaging at too high densities
  in my opinion. So always set to 0 for no deflation loops.
* `MaxExpectedD`: the maximal expected diffusion coefficient for use
  in the tracking. Thus, this parameter adjusts how large displacements will
  be considered to be of the same molecule and when a displacement is
  soo long that it will be taken to be another molecule. For
  fastSPT/spaSPT I typically use 20, but this requires imaging at a
  very low density of 0.5-1 molecules per nucleus per frame on
  average. For slowSPT, where we only want to track bound molecules,
  but where there can be significant drift and cell movement, I
  typically use values in the range 0.05-0.1. Units are um^2 /s.
* `NumGapsAllowed`: The number of gaps allowed during the
  tracking. E.g. if a molecule is there in frame 1 and 3, but not in
  frame 2, the localizations will not be connected if
  `NumGapsAllowed=0`, but they will be connected if
  `NumGapsAllowed>1`. I typically use 1 for fastSPT and 2 for
  slowSPT. 

You will also need to specify a few parameters specific to your
microscope. For all our Nikon microscopes with 100x/1.49NA TIRF
objectives with iXon cameras (160 nm per pixel), use these:
* `impars.PixelSize=0.16`  um per pixel
* `impars.NA=1.49` NA of detection objective

More specialized localization and tracking parameters are controlled
in the `locpars` and `trackpars` structured arrays.

## Output MAT-files: SPT Trajectory data
After running the localization and dectection code, you will get a
MAT-file for each movie. Once loaded back into Matlab you will see
that these contain two structured arrays:
* `trackedPar`: structure array with length equal to the number of
trajectories. Each trajectory contains:
	* `trackedPar.xy`: Nx2 matrix of xy coordinates (double) in micrometers,
    where N is the trajectory length.
	* `trackedPar.Frame`: Nx1 column vector of the frame IDs (integers)
    of where the particle was located.
	* `trackedPar.TimeStamp`: Nx1 column vector of the time stamp (double)
    of when the particle was located in that frame.
* `settings`: contains a large amount of relevant metadata. 

Again, please carefully read the MTT algorithm paper for full
details.

## SLIMfast - Graphical User Interface for MTT
This respository also comes with SLIMfast, a GUI written by Christian
Richter. This version is somewhat out-of-date and many features are
broken in newer versions of Matlab. A minimal set of functions work in
Matlab 2014b and earlier, but if you user newer versions of Matlab,
expect even the most essential functions not to work. The GUI can be
found in the folder `SLIMfast_GUI`, where it comes with a manual
`Manuel SLIMfast.docx` written in French, but with lots of helpful
images. The GUI is especially helpful for getting to know the code and
for optimizing parameters. It only reads TIFF stacks. 

## Acknowledgements
The code implements the MTT algorithm. Please read and cite the
published paper:

	Sergé, A., Bertaux, N., Rigneault, H. and Marguet, D., 2008.
	Dynamic multiple-target tracing to probe spatiotemporal
	cartography of cell membranes.
	Nature methods, 5(8), p.687.

The code comes from the GUI SLIMfast, which was written by Christian
Richter. The code here comes from the GUI distributed by Davide
Normanno, Mohamed El-Beheiry and Zhe Liu. The GUI was "de-GUIfied" and
interfaced for batch processing by Mustafa Mir. The script-interface,
custom-BioFormat reader and parallel processing framework was written
by Anders Sejr Hansen. This code also made use of BioFormats for
Matlab. 

## License
The script-interface, custom-BioFormat reader and parallel processing
framework (i.e. the wrapper) are all are released under the GNU General Public License version 3 or upper (GPLv3+).

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
