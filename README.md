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
**Warning: this code uses BioFormats to read `nd2` files. Some versions
of BioFormats are incompatible with some Nikon `nd2` versions. When
this happens, BioFormats will mess-up, re-scale and otherwise corrupt
the `nd2` file, with catastrophic results. Please verify that your
`nd2` file version is compatible with this version of BioFormats after
loading in a file. There is also a version of the code in this
repository that reads TIFF files instead, `SerialProcess_fastSPT_JF549_TIFF.m`.**

## Acknowledgements
The code implements the MTT algorithm. Please read and cite the
published paper:

	Sergé, A., Bertaux, N., Rigneault, H. and Marguet, D., 2008.
	Dynamic multiple-target tracing to probe spatiotemporal
	cartography of cell membranes.
	Nature methods, 5(8), p.687.

The code comes from the GUI SLIMfast, which was written by Christian
Richter. The code here comes from the GUI distributed by Davide
Normanno, Mohamed El-Beheiry and Zhe Liu. The GUI was "de-GUIfied" for
batch processing by Mustafa Mir. The script-interface,
custom-BioFormat reader and parallel processing framework was written
by Anders Sejr Hansen.
