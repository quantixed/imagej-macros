# imagej-macros

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18172496.svg)](https://doi.org/10.5281/zenodo.18172496)

Tools for Fiji/ImageJ that we use in the lab for making figures etc.

## Instructions


For instuctions, please refer to the [wiki](https://github.com/quantixed/imagej-macros/wiki). 

Main topics:

* [Figure Maker](https://github.com/quantixed/imagej-macros/wiki/Figure-Maker)
* [How to use the other tools](https://github.com/quantixed/imagej-macros/wiki/Other-Utilities-and-Helpful-Routines)
* [Troubleshooting](https://github.com/quantixed/imagej-macros/wiki/Troubleshooting)


## Installation

These tools are available via the *quantixed* ImageJ [update site](http://sites.imagej.net/Quantixed/).
Instructions for how to follow a 3rd party update site are [here](http://imagej.net/How_to_follow_a_3rd_party_update_site).
This is the best way to install these macros and maintain the latest versions.

If you want to install manually, add the contents of `macros` and `scripts` to the corresponding directories in your Fiji/ImageJ installation.

After installation, all macros can be found under the menu item called **LabCode**.

<details>

<summary>Release notes</summary>

## v1.0.2

- CHange Montage Merge: LUT conversion now does not rely on other update sites.
- Inclusion of OFP luts with `q_` prefix.
- Fix for Change Montage Merge so that montage(s) stay open for inspection after the change.

## v1.0.1

- Major change to `Crop_Stack_XYCT.ijm`

## v1.0.0

- Initial version for release

</details>