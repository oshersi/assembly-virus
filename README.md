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

### Prerequisites

The virus runs in the DOSBOX environment and therefore needs to be installed, and in order to analyze its effects, I recommend analyzing the files with the HEX editor.

The development environment of the virus is Turbo Assembler, which is able to compile and link all parts of the code.

### Installing

1) Download Turbo Assembler and install it, the links are here below .
2) clone this repository to  the local computer
3) Open all of the .asm files with the environment when the virus is compiled from the main file 


Installation of Turbo Assembler  is simple and is done with the help of Windows installation .


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


```
Give the example
```

And repeat

```
until finished
```


### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```



## Built With

* [Turbo Assembler](https://sourceforge.net/projects/guitasm8086/) - The framework used
* [HxD](https://mh-nexus.de/en/hxd/) - Binary file editor
* [DosBox](https://www.dosbox.com/download.php?main=1) - Test environment


## Contributing

Please read [contributors](https://github.com/oshersi/assembly-virus/commits?author=oshersi) for details on my code of conduct .

## License
This project is for research and study only. Permission to use this project is only to indicate above, do not use and exploit this project adversely.
This project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


