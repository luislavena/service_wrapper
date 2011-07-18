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

    sub test_ignore_garbage_section
        var conf = new ConfigurationFile("fixtures/garbage.conf")
        assert(conf->executable = "valid.exe")
        assert(conf->arguments = "arg1 arg2 arg3")
        delete conf
    end sub

    sub run()
        test_read_executable
        test_read_arguments
        test_ignore_garbage_section
    end sub
end namespace

TestConfigurationFile.run()
