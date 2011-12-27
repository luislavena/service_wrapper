# Hello: Simple Sinatra service using ServiceWrapper

The example contained in this directory shows how to use ServiceWrapper
executable and make a Windows service.

## Requirements

### Administrator required

You require administrative privileges to be able to install, start, stop and
remove Windows services.

### Ruby installation

The file `hello.conf` contains comments that will help you setup your Ruby
installation.

Don't forget to adjust the path that points to `ruby.exe` prior starting the
service.

Also install `sinatra` gem:

```
gem install sinatra
```

## Making the service work

### Ensuring things work before running the service

Once again, don't forget to verify the information of the configuration file
(`hello.conf`) to match your local installation (directory to Ruby, logfile,
etc).

A good practice is run the same command (executable + arguments) from the
command line and see if there is an error.

### Installing the service

After you placed the example into `C:\hello` directory, it is time now to
install it using `sc.exe` utility:

```
C:\> sc create hello binPath= "C:\hello\service_wrapper.exe C:\hello\hello.conf"
```

See `sc create /?` for additional options you can use, like automatic start or
dependencies in other services.

Please note that on this example I've copied `service_wrapper.exe` inside our
example directory. If you plan on running multiple services, I recommend you
place it in a central location so updates to it are more easy to perform.

### Starting/Stopping the service

Now that the service is installed, starting and stopping it can be perform
using both Services UI (`services.msc`) or `sc.exe` command line utility.

Use `net start hello` to start it and `net stop hello` to stop it.

### Removing the service

In case you find yourself in the need to remove the service, use `sc delete`,
but always verify the service is stopped first.

```
C:\> net stop hello
C:\> sc delete hello
```

## Limitations

When using `logfile` setting, both STDOUT and STDERR of the executable are
redirected to a file. Due buffering nature, if the child process output is too
small, the file might look empty at the beginning.

You can change the way STDOUT/STDERR works by using `$stdout.sync = true` in
your code.

I recommend not do that and instead use a more robust logging mechanism.
