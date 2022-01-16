# A container for the fiftyone dataset management package

This is a standalone container that installs fiftyone on top  of pytorch. It was written for GPU environments although it should run or can be easily modified for CPU-only environments as well (at least the visualization part).

## Build and Run it

In VS Code with the Remote containers extension press CTRL+P and select the option (or type it in) "Remote-Containers: Rebuild container". After the container builds, in a new terminal 

```
python ./src/startserver.py 
```
you will then see the web interface of the quickstart dataset. 

![](fiftyone.png)

