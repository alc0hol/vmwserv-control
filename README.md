## wmserv-control
I use VMware's virtualization technology a lot. But this doesn't mean that i want to run it's components while doing something else, right?!
After installing VMware i observed that some of it's needed services keep running even after you close the program. I hate this behavior from
the deepest of my heart because i've grown up with the idea that 'the less, the better'. Keeping useless software running on your computer damages
the overall system's security and performance. If someone managed to find a vulnerability in one of these services, and used this vulnerability
against me, this would mean I lost, but I **never** lose.
### What to do.
Taking a look at the currently running services, you will quickly notice these:

![VMware Services](/images/vmware-services.png)

These services are the layer between the host and the guest machines, thus they're only needed when you're running a virtual machine.
The first step is to set the *Startup Type* of each of these services to *Manual*. To do so, open *Services* and scroll down until you find
the mentioned services. Right click on each service and go to **Properties->Startup type** and set it to **Manual**.
Done! Now the services won't start automatically anymore. The next step is to be able to control the state of those services so you can
**run, stop and restart** them whenever you need it. You could open *Services* and run each service manually, or you could use the four scripts
contained in this repository which will do it automatically.
### Using the scripts.
This repository contains 4 simple scripts that ease operations on vmware's services. After downloading the repo on your computer (If you're running virtual
machines i am assuming you know how to do that lmao) just run the script with the correct suffix based on the operation you need to accomplish. 
Each operation requires Administrator privileges to execute. The scripts can be executed both by double clicking on a gui or by specifying their path
on the command line.
### Additional Information.
The 4 scripts distributed with this repository are independent of each other, I chose to design them this way in order to relieve users from having to download all the scripts as not all of these might be essential to their workflow. At the same time, this choice involves duplicate code in each
file, but I don't see how this could affect the overall experience since each script is so *direct* on what it wants to do.