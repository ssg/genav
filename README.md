GenAv
=====

What's it?
----------
This project had started from a personal need: clean some viruses 
which virus scanners at the time didn't recognize on my computer. 
It's not data-driven which means it contains ad-hoc code for 
each and every virus it detects which I think are 8 viruses in total :) 
It wasn't the most sustainable AV project.

FatalVision UI:
![FatalVision screenshot](https://github.com/user-attachments/assets/70c13415-7e5a-4c3e-afb3-982c426022ee)

FatalVision menu screenshot:
![FatalVision menu](https://github.com/user-attachments/assets/e48fce31-1704-41e8-afad-d466c8292d83)



TurboVision UI:
![TurboVision screenshot](https://user-images.githubusercontent.com/241217/159136492-7eed3ad6-041c-4d41-97b5-dcd2f780631f.png)


The source code contains three variants: 

 - operator.pas: Old TurboVision based UI
 - genav.pas: FatalVision based UI.
 - avenger.pas: Command-line (which I think was the way to go, but I was too 
 young to run away from the urge to code cool looking UIs)

Detected viruses
----------------
Literal translation from the documentation:

Name       | Type         |  Description
-----------|--------------|----------------------------------------------------
ATB        |COM+EXE files |A harmful virus that doesn't check for overlays
Mirage     |COM+EXE files |A virus that is well-coded and well-harmful
X1         |COM+EXE files |Makes the date/times of the files invalid
X2         |COM+EXE files |Mirage variant but coded better
X3         |COM+EXE files |Written for deleting EXE files of some games
Cascade1661|COM files     |An interesting virus
Mumcu      |COM files     |Makes EXEs read-only


 
Why release the code?
---------------------
Mostly for educational purposes. That is definitely not the right 
way to write a generic AV software. However, considering the requirements
vs effort, I think I kept a good balance, and the software itself
served me really well in its time.

There was much more advanced AV projects originated from Turkey such as 
ARA by Bulent Eren which was data-driven and contained heuristic 
scanners as well.

Contact
-------
http://github.com/ssg
