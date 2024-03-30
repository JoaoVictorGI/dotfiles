#include <stdio.h>                                                            
#include "../lib/util.h"                                                      
#define FUNC_ARGS (char __unused _o, const char __unused* _a,               \
		   uint32_t __unused _i, void __unused* _p)                   
#if defined(USE_ALSA)                                                         
#	define VOLUME "alsa"                                                  
#elif defined(USE_PULSE)                                                      
#	define VOLUME "pulse"                                                 
#else                                                                         
#	define VOLUME "default"                                               
#endif
void battery_perc FUNC_ARGS {puts(__func__);}
void battery_state FUNC_ARGS {puts(__func__);}
void battery_remaining FUNC_ARGS {puts(__func__);}
void brightness FUNC_ARGS {puts(__func__);}
void bspwm_ws FUNC_ARGS {puts(__func__);}
void cpu_freq FUNC_ARGS {puts(__func__);}
void cpu_perc FUNC_ARGS {puts(__func__);}
void datetime FUNC_ARGS {puts(__func__);}
void disk_free FUNC_ARGS {puts(__func__);}
void disk_perc FUNC_ARGS {puts(__func__);}
void disk_total FUNC_ARGS {puts(__func__);}
void disk_used FUNC_ARGS {puts(__func__);}
void entropy FUNC_ARGS {puts(__func__);}
void hostname FUNC_ARGS {puts(__func__);}
void ipv4 FUNC_ARGS {puts(__func__);}
void ipv6 FUNC_ARGS {puts(__func__);}
void kernel_release FUNC_ARGS {puts(__func__);}
void keymap FUNC_ARGS {puts(__func__);}
void load_avg FUNC_ARGS {puts(__func__);}
void netspeed_rx FUNC_ARGS {puts(__func__);}
void netspeed_tx FUNC_ARGS {puts(__func__);}
void num_files FUNC_ARGS {puts(__func__);}
void ram_free FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void ram_perc FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void ram_total FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void ram_used FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void run_command FUNC_ARGS {puts(__func__);}
void swap_free FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void swap_perc FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void swap_total FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void swap_used FUNC_ARGS {puts(__func__);puts("file:../lib/meminfo.c");}
void temp FUNC_ARGS {puts(__func__);}
void uptime FUNC_ARGS {puts(__func__);}
void gid FUNC_ARGS {puts(__func__);}
void uid FUNC_ARGS {puts(__func__);}
void username FUNC_ARGS {puts(__func__);}
void vol_perc FUNC_ARGS {puts("file:volume/"VOLUME".c");}
void wifi_perc FUNC_ARGS {puts(__func__);}
void wifi_essid FUNC_ARGS {puts(__func__);}
