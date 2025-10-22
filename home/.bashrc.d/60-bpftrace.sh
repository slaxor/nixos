bpftrace="$(which bpftrace 2>/dev/null)"
if [ ! -z ${bpftrace} ] ; then
  # New processes with arguments
  tracenewprocs() {
    sudo ${bpftrace} -e 'tracepoint:syscalls:sys_enter_execve { join(args->argv); }'
  }

  # Files opened by process
  tracefileopen() {
    sudo ${bpftrace} -e 'tracepoint:syscalls:sys_enter_open { printf("%s %s\n", comm, str(args->filename)); }'
  }

  # Syscall count by program
  traceprgsyscallstats() {
    sudo ${bpftrace} -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'
  }

  # Syscall count by syscall
  tracesyscallsyscallstats() {
    sudo ${bpftrace} -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }'
  }

  # Syscall count by process
  traceprocsyscallstats() {
    sudo ${bpftrace} -e 'tracepoint:raw_syscalls:sys_enter { @[pid, comm] = count(); }'
  }

  # Read bytes by process:
  traceprocbyteread() {
    sudo ${bpftrace} -e 'tracepoint:syscalls:sys_exit_read /args->ret/ { @[comm] = sum(args->ret); }'
  }

  # Read size distribution by process:
  traceprocreadsize() {
    sudo ${bpftrace} -e 'tracepoint:syscalls:sys_exit_read { @[comm] = hist(args->ret); }'
  }

  # Disk size by process
  traceprocdisksize() {
    sudo ${bpftrace} -e 'tracepoint:block:block_rq_issue { printf("%d %s %d\n", pid, comm, args->bytes); }'
  }

  # Pages paged in by process
  traceprocpages() {
    sudo ${bpftrace} -e 'software:major-faults:1 { @[comm] = count(); }'

  }

  # Page faults by process
  traceprocpagefault() {
    sudo ${bpftrace} -e 'software:faults:1 { @[comm] = count(); }'
  }

  # Profile user-level stacks at 99 Hertz, for PID 189:
  traceprocuserstack() {
    sudo ${bpftrace} -e "profile:hz:99 /pid == ${1}/ { @[ustack] = count(); }"
  }
fi
