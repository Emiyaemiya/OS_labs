#include <stdio.h>
#include <ulib.h>
#include <string.h>

int global_var = 100;

int main(void) {
    cprintf("COW test: parent process start. global_var = %d\n", global_var);

    int pid = fork();

    if (pid == 0) {
        // Child process
        cprintf("COW test: child process start. global_var = %d\n", global_var);
        
        // Read global variable (should be shared initially)
        if (global_var != 100) {
            cprintf("COW test: child read error! global_var = %d\n", global_var);
            exit(-1);
        }

        // Write global variable (should trigger COW)
        cprintf("COW test: child modifying global_var to 200...\n");
        global_var = 200;
        cprintf("COW test: child modified global_var. global_var = %d\n", global_var);

        if (global_var != 200) {
             cprintf("COW test: child write error! global_var = %d\n", global_var);
             exit(-1);
        }
        
        cprintf("COW test: child process exit.\n");
        exit(0);
    } else {
        // Parent process
        if (pid < 0) {
            cprintf("COW test: fork failed.\n");
            exit(-1);
        }

        cprintf("COW test: parent waiting for child...\n");
        if (wait() != 0) {
            cprintf("COW test: wait failed.\n");
            exit(-1);
        }

        // Check global variable (should remain unchanged in parent)
        cprintf("COW test: parent process resumed. global_var = %d\n", global_var);
        if (global_var == 100) {
            cprintf("COW test: success! Parent's global_var is unchanged.\n");
        } else {
            cprintf("COW test: failure! Parent's global_var was modified to %d.\n", global_var);
        }
    }

    return 0;
}
