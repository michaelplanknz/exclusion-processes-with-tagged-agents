# Continuum models describing probabilistic motion of tagged particles in exclusion processes

This repository contains the code used for the article [Continuum models describing probabilistic motion of tagged particles in exclusion processes](https://dx.doi.org/10.1103/lzqy-n5mw).

## Version history

Results in [version 1](https://arxiv.org/abs/2509.25554v1) of the preprint were produced using the version of this repository tagged v1.0. 

Results in the [final published version](https://dx.doi.org/10.1103/lzqy-n5mw) were produced using the version tagged v1.1, which is also [archived](https://zenodo.org/records/18238920) as a Zenodo repository.

An open-access version of the accepted article is available on [arXiv](https://arxiv.org/abs/2509.25554).


## Structure of the repository

The repository is organised into the following folders:
* `code/` contains the all Matlab code used to run the model.
* `results/` contains the results of running the ABM simulation model and the PDE.
* `figures/` contains the figures that appear in the article.


## How to use the repository

To run the model and reproduce the figures that appear in the article:
1. Navigate to the `code/` directory.
2. Run the Matlab script `main.m`. This will save a .mat file containing the model output in the `results/` directory.
3. Run the Matlab script `plotGraphs.m`. This will plot the graphs and save the figures as .png files in the `figures/` directory.


