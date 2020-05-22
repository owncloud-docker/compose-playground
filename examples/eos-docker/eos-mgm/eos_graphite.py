#!/usr/bin/env python2
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

import subprocess
import re
import socket
import time
import sys
import pickle
import struct

CARBON_HOST = '10.42.32.2'
CARBON_PORT = 2004
PREFIX = 'eos'
LOCKFILE = '/dev/shm/eos_graphite'

#io metrics
io_metrics = [
    'bwd_seeks',
    'bytes_bwd_wseek',
    'bytes_fwd_seek',
    'bytes_read',
    'bytes_written',
    'bytes_xl_bwd_wseek',
    'bytes_xl_fwd_seek',
    'disk_time_read',
    'disk_time_write',
    'fwd_seeks',
    'read_calls',
    'write_calls',
    'xl_bwd_seeks',
    'xl_fwd_seeks',
]

#io metrics
iofuse_metrics = [
    'app_io_out',
    'app_io_in',
]

#io fuse clients
iofuse_clients = [
        'fuse.clients',
]

# Space Metrics to report
space_metrics = [
    'nofs',
    'cfg.nominalsize',
    'avg.stat.disk.load',
    'sig.stat.disk.load',
    'sum.stat.disk.readratemb',
    'sum.stat.disk.writeratemb',
    'avg.stat.disk.load',
    'sum.stat.net.inratemib',
    'sum.stat.net.outratemib',
    'sum.stat.ropen',
    'sum.stat.wopen',
    'sum.stat.statfs.freebytes',
    'sum.stat.statfs.usedbytes',
    'sum.stat.statfs.capacity',
    'sum.stat.usedfiles',
    'sum.stat.statfs.ffree',
    'sum.stat.statfs.fused',
    'sum.stat.statfs.files',
    'sum.stat.statfs.ffiles',
]

# Group Metrics to report
group_metrics = [
        'nofs',
        'avg.stat.disk.load',
        'sig.stat.disk.load',
        'sum.stat.disk.readratemb',
        'sum.stat.disk.writeratemb',
        'sum.stat.net.ethratemib',
        'sum.stat.net.inratemib',
        'sum.stat.net.outratemib',
        'sum.stat.ropen',
        'sum.stat.wopen',
        'sum.stat.statfs.usedbytes',
        'sum.stat.statfs.freebytes',
        'sum.stat.statfs.capacity',
        'sum.stat.usedfiles',
        'sum.stat.statfs.ffree',
        'sum.stat.statfs.files',
        'dev.stat.statfs.filled',
        'avg.stat.statfs.filled',
        'sig.stat.statfs.filled',
]

# Node Metrics to report
node_metrics = [
    'avg.stat.disk.load',
    'sig.stat.disk.load',
    'sum.stat.disk.readratemb',
    'sum.stat.disk.writeratemb',
    'avg.stat.disk.load',
    'sum.stat.net.inratemib',
    'sum.stat.net.outratemib',
    'sum.stat.ropen',
    'sum.stat.wopen',
    'sum.stat.statfs.freebytes',
    'sum.stat.statfs.usedbytes',
    'sum.stat.usedfiles',
    'sum.stat.statfs.ffree',
    'sum.stat.statfs.fused',
    'sum.stat.statfs.files',
    'cfg.stat.sys.vsize',
    'cfg.stat.sys.rss',
    'cfg.stat.sys.threads',
    'cfg.stat.sys.sockets',
]

# Disk Metrics to report
disk_metrics = [
    'stat.disk.load',
    'stat.disk.readratemb',
    'stat.disk.writeratemb',
    'stat.ropen',
    'stat.wopen',
    'stat.statfs.freebytes',
    'stat.statfs.usedbytes',
    'stat.usedfiles',
    'stat.statfs.ffree',
    'stat.statfs.fused',
    'stat.statfs.files',
]

#Namespace metric
ns_metrics = [
    'ns.total.files',
    'ns.total.directories',
    'ns.boot.time',
    'ns.memory.virtual',
    'ns.memory.resident',
    'ns.memory.share',
    'ns.stat.threads',
    'ns.memory.growth',
    'ns.uptime',
    'total.exec.avg',
    'ns.fusex.caps',
    'ns.fusex.clients',
    'ns.fds.all',
]


# MGM Error stats
mgmerr_metrics = [
    'mgm.total.errors',
]

#uptime metric
uptime_metrics = [
    'system.uptime',
]

#Namespace usage metrics
ns_ops_metrics = [
        'Access',
        'AdjustReplica',
        'AttrGet',
        'AttrLs',
        'AttrRm',
        'AttrSet',
        'Cd',
        'Checksum',
        'Chmod',
        'Chown',
        'Commit',
        'CommitFailedChunkOrder',
        'CommitFailedFid',
        'CommitFailedNamespace',
        'CommitFailedParameters',
        'CommitFailedUnlinked',
        'ConversionDone',
        'ConversionFailed',
        'CopyStripe',
        'DrainCentralFailed',
        'DrainCentralStarted',
        'DrainCentralSuccessful',
        'Drop',
        'DropStripe',
        'DumpMd',
        'Eosxd::ext::0-HANDLE',
        'Eosxd::ext::0-STREAM',
        'Eosxd::ext::BEGINFLUSH',
        'Eosxd::ext::CREATE',
        'Eosxd::ext::CREATELNK',
        'Eosxd::ext::DELETE',
        'Eosxd::ext::DELETELNK',
        'Eosxd::ext::ENDFLUSH',
        'Eosxd::ext::GET',
        'Eosxd::ext::GETCAP',
        'Eosxd::ext::GETLK',
        'Eosxd::ext::LS',
        'Eosxd::ext::MKDIR',
        'Eosxd::ext::MV',
        'Eosxd::ext::RENAME',
        'Eosxd::ext::RMDIR',
        'Eosxd::ext::SET',
        'Eosxd::ext::SETLK',
        'Eosxd::ext::SETLKW',
        'Eosxd::ext::UPDATE',
        'Eosxd::int::BcConfig',
        'Eosxd::int::BcDropAll',
        'Eosxd::int::BcMD',
        'Eosxd::int::BcRelease',
        'Eosxd::int::BcReleaseExt',
        'Eosxd::int::FillContainerCAP',
        'Eosxd::int::FillContainerMD',
        'Eosxd::int::FillFileMD',
        'Eosxd::int::Heartbeat',
        'Eosxd::int::MonitorCaps',
        'Eosxd::int::ReleaseCap',
        'Eosxd::int::SendCAP',
        'Eosxd::int::SendMD',
        'Eosxd::int::Store',
        'Eosxd::int::ValidatePERM',
        'Exists',
        'FileInfo',
        'Find',
        'FindEntries',
        'Fuse',
        'Fuse-Access',
        'Fuse-Checksum',
        'Fuse-Chmod',
        'Fuse-Chown',
        'Fuse-Dirlist',
        'Fuse-Mkdir',
        'Fuse-Stat',
        'Fuse-Statvfs',
        'Fuse-Utimes',
        'Fuse-XAttr',
        'GetMd',
        'GetMdLocation',
        'HashGet',
        'HashSet',
        'HashSetNoLock',
        'Http-COPY',
        'Http-DELETE',
        'Http-GET',
        'Http-HEAD',
        'Http-LOCK',
        'Http-MKCOL',
        'Http-MOVE',
        'Http-OPTIONS',
        'Http-POST',
        'Http-PROPFIND',
        'Http-PROPPATCH',
        'Http-PUT',
        'Http-TRACE',
        'Http-UNLOCK',
        'IdMap',
        'LRUFind',
        'Ls',
        'MarkClean',
        'MarkDirty',
        'Mkdir',
        'Motd',
        'MoveStripe',
        'NsLockR',
        'NsLockW',
        'Open',
        'OpenDir',
        'OpenDir-Entry',
        'OpenFailedCreate',
        'OpenFailedENOENT',
        'OpenFailedExists',
        'OpenFailedHeal',
        'OpenFailedNoUpdate',
        'OpenFailedPermission',
        'OpenFailedQuota',
        'OpenFailedReconstruct',
        'OpenFileOffline',
        'OpenLayout',
        'OpenProc',
        'OpenRead',
        'OpenShared',
        'OpenStalled',
        'OpenStalledHeal',
        'OpenWrite',
        'OpenWriteCreate',
        'OpenWriteTruncate',
        'Quota',
        'QuotaLockR',
        'QuotaLockW',
        'ReadLink',
        'Recycle',
        'Redirect',
        'RedirectENOENT',
        'RedirectENONET',
        'RedirectR',
        'RedirectR-Master',
        'RedirectW',
        'Rename',
        'ReplicaFailedChecksum',
        'ReplicaFailedSize',
        'Rewrite',
        'Rm',
        'RmDir',
        'Schedule2Balance',
        'Schedule2Delete',
        'Schedule2Drain',
        'Scheduled2Balance',
        'Scheduled2Delete',
        'Scheduled2Drain',
        'SchedulingFailedBalance',
        'SchedulingFailedDrain',
        'SendResync',
        'Stall',
        'Stat',
        'Symlink',
        'Touch',
        'Truncate',
        'TxState',
        'VerifyStripe',
        'Version',
        'Versioning',
        'ViewLockR',
        'ViewLockW',
        'WhoAmI',
]


def set_prefix():
    instance = sys.argv[1]
    return '.'.join([PREFIX, instance])

# Send metric to Graphite
def send_metric(data):
    payload = pickle.dumps(data, protocol=2)
    header = struct.pack("!L", len(payload))
    message = header + payload
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect((CARBON_HOST, CARBON_PORT))
    except socket.error, msg:
        print "Couldn't send data to graphite host: %s" % msg
        return
    sock.sendall(message)
    sock.close()

# Returns true is machine is master
def is_master():
    p = subprocess.Popen(['eos', '-b', 'ns'],stdout=subprocess.PIPE)
    for line in p.stdout:
        if (re.search('Replication\s+(mode=master-rw|is_master=true)', line) is not None):
            return True
    return False

# Space metrics
def get_space_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'space', 'ls', '-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('([a-z][\w|.]*=[\w\-|:|.]+)\s+', line, re.MULTILINE)
        space = None
        for match in matches:
            metric, value = match.split('=')
            if metric == 'name':
                space = re.match('[\w-]+', value).group(0)
            if metric in space_metrics:
                data = ('.'.join([prefix, 'space', space, metric]), (int(time.time()), float(value)))
                output.append(data)
    return output

# Space metrics
def get_groups_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'group', 'ls', '-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('([a-z][\w|.]*=[\w\-|:|.]+)\s+', line, re.MULTILINE)
        group = None
        for match in matches:
            metric, value = match.split('=')
            if metric == 'name':
                value = value.replace('.', '_')
                group = re.match('\w+', value).group(0)
            if metric in group_metrics:
                data = ('.'.join([prefix, 'group', group, metric]), (int(time.time()), float(value)))
                output.append(data)
    return output

# Namespace metrics
def get_ns_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'ns', 'stat' ,'-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('([a-z][\w|.]*=[\w\-|:|.]+)\s+', line, re.MULTILINE)
        ns = None
        for match in matches:
            metric, value = match.split('=')
            ns = re.match('\w+', value).group(0)
            if metric in ns_metrics:
                data = ('.'.join([prefix, 'ns', metric]), (int(time.time()), float(value)))
                output.append(data)
    return output

# io metrics
def get_io_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'io', 'stat' , '-l', '-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('measurement=(?P<name>\w+).*300s=(?P<value>\d+)', line, re.MULTILINE)[0]
        if matches[0] in io_metrics:
            metric = matches[0]
            value = matches[1]
            data = ('.'.join([prefix, 'io', metric]), (int(time.time()), float(value)))
            output.append(data)

    return output

# io fuse metrics
def get_iofuse_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'io', 'stat' , '-x', '-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('measurement=(?P<meas>.*)\s(?:app|application)=(?P<app>\S+).*300s=(?P<value>\d+)', line, re.MULTILINE)[0]
        if matches[0] in iofuse_metrics:
            metric = matches[0]
            metric2 = matches[1]
            value = matches[2]
            data = ('.'.join([prefix, 'iofuse', re.sub(r"\W", "", metric), metric2.replace('"','')]), (int(time.time()), float(value)))
            output.append(data)
    return output


# io fuse clients
def get_iofuse_clients(prefix):
    output = []
    command='eos who -a|grep fuse|wc -l'
    p = subprocess.Popen(command,universal_newlines=True, shell=True,stdout=subprocess.PIPE)
    for line in p.stdout.readlines():
        p = re.findall('([0-9]+)', line, re.MULTILINE)
        data = ('.'.join([prefix, 'iofuse_clients']), (int(time.time()), float(p[0])))
        output.append(data)
    return output



# MGM error metrics
def get_mgmerr_metrics(prefix):
    output = []
    p = subprocess.Popen(['wc', '-l', '/var/log/eos/mgm/error.log'],stdout=subprocess.PIPE)
    for line in p.stdout.readlines():
        p = re.findall('([0-9]+)', line, re.MULTILINE)
        data = ('.'.join([prefix, 'mgmerr_metrics']), (int(time.time()), float(p[0])))
        output.append(data)
    return output

#uptime
def get_uptime_metrics(prefix):
    output = []
    p = subprocess.Popen(['cat', '/proc/uptime'],stdout=subprocess.PIPE)
    for line in p.stdout.readlines():
        p = re.findall('([0-9]+)', line, re.MULTILINE)
        data = ('.'.join([prefix, 'uptime_metrics']), (int(time.time()), float(p[0])))
        output.append(data)
    return output

#NS metrics

def get_ns_ops_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'ns', 'stat' ,'-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('cmd=([a-zA-Z\-0-9:]+)\s+total=([0-9]+)', line, re.MULTILINE)
        ns = None
        for match in matches:
            if match[0] in ns_ops_metrics:
                data = ('.'.join([prefix, 'ns_ops', match[0]]), (int(time.time()), float(match[1])))
                output.append(data)
    return output

# Node metrics
def get_node_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'node', 'ls', '-l', '-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('([a-z][\w|.]*=[\w|:|.|-]+)\s+', line, re.MULTILINE)
        machine = None
        for match in matches:
            metric, value = match.split('=')
            if metric == 'hostport':
                machine = re.match('[\w-]+', value).group(0)
            if metric in node_metrics:
                data = ('.'.join([prefix, 'node', machine, metric]), (int(time.time()), float(value)))
                output.append(data)
    return output

# Disks metrics
def get_disk_metrics(prefix):
    output = []
    p = subprocess.Popen(['eos', '-b', 'fs', 'ls', '-m'],stdout=subprocess.PIPE)
    for line in p.stdout:
        matches = re.findall('([a-z][\w|.]*=[\w|:|.|/|-]+)\s+', line, re.MULTILINE)
        machine = None
        disk = None
        for match in matches:
            metric, value = match.split('=')
            if metric == 'host':
                machine = re.match('([\w|-]+)', value).group(0)
            if metric == 'path':
                disk = value.replace('/', '')
            if metric in disk_metrics:
                data = ('.'.join([prefix, 'node', machine, 'disks', disk, metric]), (int(time.time()), float(value)))
                output.append(data)
    return output


# Headnode fsck stats
def get_fsck_metrics(prefix):
   output = []
   p = subprocess.Popen(['eos', '-b', 'fsck', 'report'],stdout=subprocess.PIPE)
   for line in p.stdout:
      matches = re.match('timestamp=(?P<ts>[0-9]+)\stag="(?P<name>.*)"\sn=(?P<value>[0-9]+)', line)
      data = ('.'.join([prefix, 'fsck', matches.group('name')]), (int(time.time()), float(matches.group('value'))))
      output.append(data)
   return output

# Count of File Descriptors open on the MGM
def get_mgmfd_metrics(prefix):
   output = []
   p = subprocess.Popen('ls /proc/$(pgrep -f xrootd.*mgm -P 1)/fd/ | wc -l', stdout=subprocess.PIPE, shell=True)
   for line in p.stdout:
      data = ('.'.join([prefix, 'ns', 'fd', 'number']), (int(time.time()), float(line)))
      output.append(data)
   return output

# Report FSTs versions
def get_fst_versions(prefix):
   from collections import defaultdict
   #from pprint import pprint
   output = []
   p = subprocess.Popen(['eos', '-b',  'node', 'ls', '-m'], stdout=subprocess.PIPE)
   versions_count = defaultdict(int)
   for line in p.stdout.readlines():
      matches = re.search('sys\.eos\.version=(?P<version>\S+)', line)
      if matches is None:
          versions_count['unknown'] += 1
          continue
      versions_count[matches.group('version')] += 1
   for k, v in versions_count.iteritems():
      data = ('.'.join([prefix, 'versions', k.replace('.', '_')]), (int(time.time()), float(v)))
      output.append(data)
   #pprint(output)
   return output

def get_ns_latency(instance, prefix):
    output = []
    TESTDIR = '/eos/'+instance+'/opstest/graphite/'
    commands = {'dir':  ['mkdir','rmdir'],
                'file': ['touch','rm']}
    for type in commands.keys():
        for cmd in commands[type]:
            before = time.time()
            p = subprocess.call(['eos', '-b', cmd, TESTDIR+'/test_'+type],  stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            # not actually readingfrom the output..
            duration = time.time() - before
            if p != 0:
                duration = -duration
            data = ('.'.join([prefix, 'ns_latency', type, cmd]), (int(before), duration))
            output.append(data)

    return output



if __name__ == '__main__':
    if len(sys.argv) != 2:
        print >> sys.stderr, "Please specify the instance name as only argument:"
        print >> sys.stderr, "    eos_graphite.py <eos instance name>"
        sys.exit(1)

    if not is_master():
        print >> sys.stderr, "I'm sorry Dave, I'm afraid I can't do that"
        sys.exit(1)

    while True: 
        print(time.asctime(time.localtime(time.time())))
        send_metric(get_space_metrics(set_prefix()))
        send_metric(get_groups_metrics(set_prefix()))
        send_metric(get_disk_metrics(set_prefix()))
        send_metric(get_node_metrics(set_prefix()))
        send_metric(get_ns_metrics(set_prefix()))
        send_metric(get_fsck_metrics(set_prefix()))
        send_metric(get_ns_ops_metrics(set_prefix()))
        send_metric(get_mgmerr_metrics(set_prefix()))
        send_metric(get_io_metrics(set_prefix()))
        send_metric(get_iofuse_metrics(set_prefix()))
        send_metric(get_uptime_metrics(set_prefix()))
        send_metric(get_iofuse_clients(set_prefix()))
        send_metric(get_mgmfd_metrics(set_prefix()))
        send_metric(get_fst_versions(set_prefix()))
        #send_metric(get_ns_latency(sys.argv[1], set_prefix()))
        time.sleep(5)
	
