Anisotropy
--------------------------
this repository is maintained by Anders Sejr Hansen

# Overview of code for localization and tracking
This repository contains Matlab code for processing raw SPT movies in
either Nikon's nd2 format or in TIFF format. It contains multiple
scripts for multiple different purposes (e.g. fastSPT, slowSPT, PALM
etc.), but they all have the same general structure. The user opens
the script, adjusts the parameters, tells it where to find the movies
and where to save the trajectories and, finally, clicks "run". Below,
we will describe the code in a little bit of detail and then a brief
guide to how to use it.

# Multiple-Target Tracing algorithm
The code uses the Multiple-Target Tracing (MTT) algorithm (see below
for reference to the key paper). Before using it, please read that
paper in detail to understand how it works and the function of each
parameter.

# Example guide - how to run the code on nd2 files
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
   fastSPT mode (e.g. spaSPT as described in Hansen, Woringer et al.,
   Robust model-based analysis of single-particle tracking experiments
   with Spot-On, **eLife**, 2018).
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
   iXon EM-CCD camera, add 447 us beyond the camera exposure time.
6. Click "Run".
7. The code will save one `MAT`-file per `nd2` file using the
`trackedPar` format. This format is directly readable by both the
web-version of [Spot-On](https://spoton.berkeley.edu) and the Matlab
version,  [Spot-On-Matlab](https://gitlab.com/tjian-darzacq-lab/spot-on-matlab). 

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
by Anders Sejr Hansen.
