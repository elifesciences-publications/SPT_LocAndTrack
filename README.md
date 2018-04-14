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
