# How To Run Jupyter from a Remote Server (such as on an Azure DSVM)
_Referenced from: https://ljvmiranda921.github.io/notebook/2018/01/31/running-a-jupyter-notebook/_

### Step 1: Run Jupyter Notebook from remote machine

Log-in to your remote machine the usual way you do. In most cases, this is simply
done via an `ssh` command. Once the console shows, type the following:

```s
remoteuser@remotehost: jupyter notebook --no-browser --port=XXXX

# Note: Change XXXX to the port of your choice. Usually, the default is 8888. 
# You can try 8889 or 8890 as well.
```

- `jupyter notebook`: simply fires up your notebook
- `--no-browser`: this starts the notebook without opening a browser
- `--port=XXXX`: this sets the port for starting your notebook where the default is `8888`. When it's occupied, it finds the next available port.

### Step 2: Forward port XXXX to YYYY and listen to it

In your remote, the notebook is now running at the port `XXXX` that you
specified. What you'll do next is forward this to port `YYYY` *of your
machine* so that you can listen and run it from your browser. To achieve
this, we write the following command:

```s
localuser@localhost: ssh -N -f -L localhost:YYYY:localhost:XXXX remoteuser@remotehost
```

- `ssh`: your handy ssh command. See [man page](https://man.openbsd.org/ssh) for more info
- `-N`: suppresses the execution of a remote command. Pretty much used in port forwarding.
- `-f`: this requests the `ssh` command to go to background before execution.
- `-L`: this argument requires an input in the form of `local_socket:remote_socket`. Here, we're specifying our port as `YYYY` which will be binded to the port `XXXX` from your remote connection.

### Step 3: Fire-up Jupyter Notebook

To open up the Jupyter notebook from your remote machine, simply start your
browser and type the following in your address bar:

```s
localhost:YYYY
```

Again, the reason why we're opening it at `YYYY` and not at `XXXX` is because
the latter is already being forwarded to the former. `XXXX` and `YYYY` can be
the "same" number (not the same port, technically) because they are from
different machines.

If you're successful, you should see the typical Jupyter Notebook home screen
in the directory where you ran the command in Step 1. At the same time, if
you look in your remote terminal, you should see some log actions happening
as you perform some tasks.

In your first connection, you may be prompted to enter an Access Token as typical
to most Jupyter notebooks. Normally, I'd just copy-paste it from my terminal, but
to make things easier for you, you can [set-up your own notebook password](http://jupyter-notebook.readthedocs.io/en/stable/public_server.html#automatic-password-setup).

### Closing all connections

To close connections, I usually stop my notebook from remote via `CTRL + C` then
`Y`, and kill the process on `YYYY` via:

```s
localuser@localhost: sudo netstat -lpn |grep :YYYY

# This will show the process ID (PID), e.g. ABCDEF of the one running in YYYY,
# you can kill it by simply typing

localuser@localhost: kill ABCDEF
```
