//
//  cppFunctions.cpp
//  
// Author: Alexandre Brehmer
// @alexnesnes

/**
 With the help of code samples seen on:
  - http://stackoverflow.com/questions/1126790/how-to-get-network-adapter-stats-in-linux-mac-osx
  - http://stackoverflow.com/questions/63166/how-to-determine-cpu-and-memory-consumption-from-inside-a-process
  - http://mogproject.blogspot.co.uk/2014/09/c-how-to-get-per-core-cpu-usage-in-mac.html
 
*/


#include "cppFunctions.h"

void cppFunctions::getCpu(float* returnTab){
    Ticks prev = updated_ticks_();
    usleep(0.5*1000000);
    Ticks t = updated_ticks_();
    unsigned long long int used = (t.used() - prev.used())*2;           //the calcul work for a 1s sleep,
    unsigned long long int user = (t.usertime - prev.usertime)*2;       //so we are waiting 0.5s and adding a x2 on the result
    returnTab[0] = (float)used;
    returnTab[1] = (float)user;
}

cppFunctions::Ticks cppFunctions::updated_ticks_() {
    unsigned int cpu_count;
    processor_cpu_load_info_t cpu_load;
    mach_msg_type_number_t cpu_msg_count;
    int rc =  host_processor_info(mach_host_self( ),PROCESSOR_CPU_LOAD_INFO,&cpu_count,
                                  (processor_info_array_t *) &cpu_load,&cpu_msg_count);
    if (rc != 0) {
        //printf("Error: failed to scan processor info (rc=%d)\n", rc);
        Ticks t = {1,1,1,1};
        return t;
    }
    unsigned long long int usertime = 0;
    unsigned long long int nicetime = 0;
    unsigned long long int systemtime = 0;
    unsigned long long int idletime = 0;
    for(int i=0;i< cpu_count;i++) {
        usertime += cpu_load[i].cpu_ticks[CPU_STATE_USER];
        nicetime += cpu_load[i].cpu_ticks[CPU_STATE_NICE];
        systemtime += cpu_load[i].cpu_ticks[CPU_STATE_SYSTEM];
        idletime += cpu_load[i].cpu_ticks[CPU_STATE_IDLE];
    }
    Ticks t = {usertime/cpu_count, nicetime/cpu_count, systemtime/cpu_count, idletime/cpu_count};
    return t;
}

void cppFunctions::getRam(float* returnTab){
    vm_size_t page_size;
    mach_port_t mach_port;
    mach_msg_type_number_t count;
    vm_statistics64_data_t vm_stats;
    long long used_memory = 0;
    mach_port = mach_host_self();
    count = sizeof(vm_stats) / sizeof(natural_t);
    if (KERN_SUCCESS == host_page_size(mach_port, &page_size) &&
        KERN_SUCCESS == host_statistics64(mach_port, HOST_VM_INFO,
        (host_info64_t)&vm_stats, &count))
    {
        //long long free_memory = (int64_t)vm_stats.free_count * (int64_t)page_size;
        used_memory = ((int64_t)vm_stats.active_count +
                       (int64_t)vm_stats.inactive_count +
                       (int64_t)vm_stats.wire_count) *  (int64_t)page_size;
    }
    int mib[2];
    int64_t physical_memory;
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    unsigned long length = sizeof(int64_t);
    sysctl(mib, 2, &physical_memory, &length, NULL, 0);
    returnTab[0] = physical_memory/1024/1024;
    returnTab[1] = used_memory/1024/1024;
}

void cppFunctions::getNetwork(float* returnTab){
    long long int bytesCountT1[2];
    cppFunctions::getIOByteCount((long long**)&bytesCountT1);
    usleep(0.5*1000000);
    long long int bytesCountT2[2];
    cppFunctions::getIOByteCount((long long**)&bytesCountT2);
    returnTab[0] = (bytesCountT2[0] - bytesCountT1[0])*2; //speed in (bit/s)
    returnTab[1] = (bytesCountT2[1] - bytesCountT1[1])*2; //speed out (bit/s)
}

void cppFunctions::getIOByteCount(long long int* bytesCount[2]) {
    bytesCount[0] = 0 ;
    bytesCount[1] = 0 ;
    int mib[] = {CTL_NET,PF_ROUTE,0,0,NET_RT_IFLIST2, 0};
    size_t len;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return ;
    }
    char *buf = (char *)malloc(len);
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        return ;
    }
    char *lim = buf + len;
    char *next = NULL;
    for (next = buf; next < lim; ) {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
            struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
            bytesCount[0] += if2m->ifm_data.ifi_ibytes;
            bytesCount[1] += if2m->ifm_data.ifi_obytes;
        }
    }
    free(buf);
}

























