# assembly virus 

A sample overwritting virus in assembly x86 that will overwrite every COM file in it's
 directory.
The target operating system are DOS . 
There are two extremely broad viruses categories  , these being Resident and
  Nonresident viruses.
  In this case the virus works with TSR - Terminate and Stay Resident . 
  The virus has two modes when it runs from a host file and when it runs as a separate file.
  The virus encrypts itself when it pastes another file and decrypts it when it runs from a pasted file.
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 
</br> Please refer to the license for terms and use permissions .
</br> The above .asm files contain the code, where main.exe is the final product after the compile 
 .

### Prerequisites

The virus runs in the DOSBOX environment and therefore DOSBOX  needs to be installed, and in order to analyze its effects, I recommend analyzing the files with the HEX editor. </br> </br>
![dosbox](https://github.com/oshersi/assembly-virus/blob/master/dosbox.png)

The development environment of the virus is Turbo Assembler, which is able to compile and link all parts of the code.
</br></br>
![turbo](https://github.com/oshersi/assembly-virus/blob/master/dddd.png)

### Installing and compilation

1) Download Turbo Assembler and install it, the [links](#Built) are here below .
2) clone this repository to  the local computer
3) Open all of the .asm files with the environment when the virus is compiled from the main file 
4) Click on the button as in the image below to crumple, object file and run will appear after in the same folder .
![compile button](https://github.com/oshersi/assembly-virus/blob/master/asdasd.png)


Installation of Turbo Assembler  is simple and is done with the help of Windows installation .
</br>
You can also compile and link all the files together in the DOSBOX more details in the next link :
(https://www.instructables.com/id/How-to-run-TASM-and-Compile-x86-Assembly-Program-i/)
## Running the tests

The virus will be run in a DOSBOX environment  , is actually a virtual DOS operating system 
after its installation the link down below , Open a folder and make a muont that will be the main path of DOSBOX More details about this, can be seen in the next link :
(https://www.dosbox.com/wiki/MOUNT)
<br/>
for example -
```
Z:\>MOUNT C C:\DOSGAMES
```

After performing all the steps above, insert the virus file into the main folder of Dosbox, along with the COM files that the virus will infect when it runs.
A few com files can be found in the following link : <br/>
(https://www.hiren.info/downloads/dos-files)

![current](https://github.com/oshersi/assembly-virus/blob/master/%E2%80%8F%E2%80%8Fv.PNG)

next, open dosbox and run virus by typing its name in the dosbox window 

```
virus.exe
```
The output of the virus is displayed quickly, you can see the infection on sys file  <br/>
The output obtained below : <br/>

![output](https://github.com/oshersi/assembly-virus/blob/master/output.png)
<br>
To show the effect of the virus, compare the SYS file before and after the infection 
<br>
before :
<br>
![output1](https://github.com/oshersi/assembly-virus/blob/master/output2.png)
<br>
after :
<br>
![output2](https://github.com/oshersi/assembly-virus/blob/master/output3.png)
<br>
You can see that after the infection, when running the SYS file the virus routine opens and then the original routine of the file, in this case a simple output - incorrect DOS version
<br><br>
When opening files (SYS before and after) by HEX Editor, you can see the signature of the virus at the beginning of the file, when the virus has retained the original bits of the host and once the control is restored to the host file the virus will restore them .
![output2](https://github.com/oshersi/assembly-virus/blob/master/HEXCOMPARE.png) <br>
To the left is the original file  and to the right the file after infection .

### Built With

* [Turbo Assembler](https://sourceforge.net/projects/guitasm8086/) - The framework used
* [HxD](https://mh-nexus.de/en/hxd/) - Binary file editor
* [DosBox](https://www.dosbox.com/download.php?main=1) - Test environment


## Contributing

Please read [contributors](https://github.com/oshersi/assembly-virus/commits?author=oshersi) for details on my code of conduct .

## License
This project is for research and study only. Permission to use this project is only to indicate above, do not use and exploit this project adversely.
This project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


