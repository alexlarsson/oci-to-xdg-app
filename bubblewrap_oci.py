#!/bin/python3

import sys, json, os;

configfile = open("config.json")
config = json.load(configfile)

root = config["root"]
rootfs = root["path"]
readonly = False
if "readonly" in root:
    readonly=root["readonly"]

args = ["bwrap"]
if readonly:
    args = args + ["--ro-bind"]
else:
    args = args + ["--bind"]

args = args + [os.path.join(os.getcwd(), rootfs), "/"]

if "mounts" in config:
    mounts = config["mounts"]
    for m in mounts:
        t = m["type"]
        source = m["source"]
        destination = m["destination"]
        if t == "proc":
            args = args + [ "--proc", destination]
        elif t == "sysfs":
            args = args + [ "--bind", "/sys", destination]


process = config["process"]

if "cwd" in process:
    args = args + ["--chdir", process["cwd"]]

if "env" in process:
    for e in process["env"]:
        ee = e.split("=")
        args = args + ["--setenv", ee[0], ee[1]]

if "linux" in config:
    linux = config["linux"]
    if "namespaces" in linux:
        for ns in linux["namespaces"]:
            if ns["type"] == "pid":
                args = args + ["--unshare-pid"]
            if ns["type"] == "network":
                args = args + ["--unshare-net"]
            if ns["type"] == "ipc":
                args = args + ["--unshare-ipc"]
            if ns["type"] == "uts":
                args = args + ["--unshare-uts"]

args = args + process["args"]

#print(args)

os.execvp(args[0], args)
