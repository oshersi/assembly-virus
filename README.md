# assembly virus 

A sample overwritting virus in assembly x86 that will overwrite every COM file in it's
 directory.
The target operating system are DOS . 
There are two extremely broad viruses categories  , these being Resident and
  Nonresident viruses.
  In this case the virus works with TSR - Terminate and Stay Resident . 
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

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
for example -
```
Z:\>MOUNT C C:\DOSGAMES
```

After performing all the steps above, insert the virus file into the main folder of Dosbox, along with the COM files that the virus will infect when it runs.



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

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Turbo Assembler](https://sourceforge.net/projects/guitasm8086/) - The framework used
* [HxD](https://mh-nexus.de/en/hxd/) - Binary file editor

## Contributing

Please read [CONTRIBUTING.md](https://github.com/oshersi/assembly-virus/commits?author=oshersi) for details on my code of conduct .

## Versioning

We use [SemVer]http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

