Simulates gravitational interactions among circles in space. Includes versions written in C++, QuickBasic, and Python. Some of them have unique features that can create artistic-looking graphics, such as the ability to draw lines connecting every possible pair of objects, with or without erasing behind themselves as they change position. These things are controlled through hot-keys.

I think I never figured out how to get one of the features in the C++ version working or why it wouldn't work.

The QB and C++ versions are 2D. The Python version can handle any arbitrary number of dimensions (provided you code a way to display it, I've decoupled that from the gravitational calculations), but is currently set to calculate in 3 dimensions and display in 2. 

There are multiple versions of the program included for the QB version, because I don't know which one is supposed to be the latest or best or which ones are experimental or what (I coded the QB versions probably back in the 90's..).

I did some really interesting graphical things using the Python version, such as separating the screen into tiles that could be either colored or not colored depending on whether an object is--or maybe how many are--within a tile's area at the time. I think I also did some 5D stuff and experimented with different ways of displaying the 5 different position variables. I lost that version. =/

I also wrote one in Python, or a version of the Python one included, that shades the objects as spheres, and can actually display objects' depths in 3D interactions with the use of red and green 3D glasses. I seem to have lost that one too. =/ I think there may be the code to display for 3D glasses, but not as spheres, commented out in 3dgrav.py.

In addition to the problems with the Python version mentioned in the source, a couple of other problems are: 1) you can't close the pygame window, and 2) for some reason it actually <i>speeds up</i> when you move the mouse around over the pygame window, so I guess something's not being done as efficiently as it could be done there. 

Fixing the latter problem may involve allowing it to calculate position updates multiple times per screen update and maybe also modifying the gravitational constant and average initial inertias accordingly (this being how you do more or fewer position calculations per second while retaining visible simulation speed, or vice versa). 


