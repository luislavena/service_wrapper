#include once "helper.bi"
#include once "configuration_file.bi"

namespace TestConfigurationFile
    sub test_read_executable
        var conf = new ConfigurationFile("fixtures/simple.conf")
        assert(conf->executable = "foo.exe")
        delete conf
    end sub

    sub test_read_arguments
        var conf = new ConfigurationFile("fixtures/simple.conf")
        assert(conf->arguments = "arg1 arg2")
        delete conf
    end sub

    sub test_read_directory
        var conf = new ConfigurationFile("fixtures/simple.conf")
        assert(conf->directory = $"C:\MyApp")
        delete conf
    end sub

    sub test_read_logfile
        var conf = new ConfigurationFile("fixtures/simple.conf")
        assert(conf->logfile = "output.log")
        delete conf
    end sub

    sub test_ignore_garbage_section
        var conf = new ConfigurationFile("fixtures/garbage.conf")
        assert(conf->executable = "valid.exe")
        assert(conf->arguments = "arg1 arg2 arg3")
        delete conf
    end sub

    sub run()
        print "TestConfigurationFile: ";
        progress(test_read_executable)
        progress(test_read_arguments)
        progress(test_read_directory)
        progress(test_read_logfile)
        progress(test_ignore_garbage_section)
        print "DONE"
    end sub
end namespace

TestConfigurationFile.run()
