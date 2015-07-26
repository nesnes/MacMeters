//
//  cppFunctions.h
//  
// Author: Alexandre Brehmer
// @alexnesnes

#ifndef ____cppFunctions__
#define ____cppFunctions__

#include <stdio.h>
#include <unistd.h>
#include <iostream>

//Cpu
#include <mach/mach_host.h>
#include <mach/processor_info.h>

//Ram
#include <mach/vm_statistics.h>
#include <mach/mach_types.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>
#include <sys/types.h>
#include <sys/sysctl.h>

//Network
#include <sys/sysctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <net/route.h>
#include <sys/time.h>


/// This C++ class is a function dictionary that gets some system informations that are not accessible with Swift
class cppFunctions {
public:
    
    /**
     Get the processor usage information
     :param: returnTab  the float array where the result will be returned.
     :returns: the total percent of Cpu used, and the percent used by the user. [0]=used, [1]=user
     :note: to get the better estimation of the Cpu used, this function takes 0.5 second
     */
    static void getCpu(float* returnTab);
    
    /**
     Get the Ram usage information
     :param: returnTab  the float array where the result will be returned.
     :returns: the total amount of Ram, and the used amount of Ram in MBytes. [0]=total, [1]=used
     */
    static void getRam(float* returnTab);
    
    /**
     Get the network usage information
     :param: returnTab  the float array where the result will be returned.
     :returns: the download speed used, and the upload speed used in bit/s. [0]=download, [1]=upload
     :note: to get the better estimation of the network speed, this function takes 0.5 second
     */
    static void getNetwork(float* returnTab);
    
private:
    //Cpu
    static struct Ticks {
        unsigned long long int usertime;
        unsigned long long int nicetime;
        unsigned long long int systemtime;
        unsigned long long int idletime;
        unsigned long long int used() { return usertime + nicetime + systemtime; }
        unsigned long long int total() { return usertime + nicetime + systemtime + idletime; }
    } prev;
    static Ticks updated_ticks_();
    
    //Network
    static void getIOByteCount(long long int* bytesCount[2]);
    
};

#endif /* defined(____cppFunctions__) */
