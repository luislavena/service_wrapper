#include once "helper.bi"
#include once "console_process.bi"

namespace TestConsoleProcess
    sub cleanup()
        shell("taskkill.exe /F /IM mock_process.exe 1>NUL 2>&1")
    end sub

    sub test_require_executable()
        var child = new ConsoleProcess("prog.exe")
        assert(child->executable = "prog.exe")
        delete child
    end sub

    sub test_quoted_executable()
        var child = new ConsoleProcess("executable with spaces.exe")
        assert(instr(child->executable, !"\""))
        delete child
    end sub

    sub test_optional_arguments()
        var child = new ConsoleProcess("prog.exe", "arg1 arg2")
        assert(child->arguments = "arg1 arg2")
        delete child
    end sub

    sub test_start_failed()
        var child = new ConsoleProcess("invalid.exe")
        assert(child->start() = 0)
        delete child
    end sub

    sub test_start_succeed()
        var child = new ConsoleProcess("mock_process.exe")
        assert(child->start())
        delete child
    end sub

    sub test_pid_invalid()
        var child = new ConsoleProcess("invalid.exe")
        child->start()
        assert(child->pid = 0)
        delete child
    end sub

    sub test_pid_worked()
        var child = new ConsoleProcess("mock_process.exe")
        child->start()
        assert(child->pid)
        delete child
    end sub

    sub test_pid_worked_with_error()
        var child = new ConsoleProcess("mock_process.exe", "error")
        child->start()
        assert(child->pid)
        delete child
    end sub

    sub test_exit_code_invalid()
        var child = new ConsoleProcess("invalid.exe")
        child->start()
        assert(child->exit_code() = 0)
        delete child
    end sub

    sub test_exit_code_worked()
        var child = new ConsoleProcess("mock_process.exe")
        child->start()
        sleep 250
        assert(child->exit_code() = 0)
        delete child
    end sub

    sub test_exit_code_still_active()
        var child = new ConsoleProcess("mock_process.exe", "delay")
        child->start()
        assert(child->exit_code() = STILL_ACTIVE)
        delete child
    end sub

    sub test_exit_code_worked_with_error()
        var child = new ConsoleProcess("mock_process.exe", "error")
        child->start()
        sleep 250
        assert(child->exit_code() = 1)
        delete child
    end sub

    sub test_exist_code_twice()
        var child = new ConsoleProcess("mock_process.exe", "error")
        child->start()
        assert(child->exit_code() = STILL_ACTIVE)
        sleep 250
        assert(child->exit_code() = 1)
        delete child
    end sub

    sub test_running_not_started()
        var child = new ConsoleProcess("mock_process.exe")
        assert(child->running() = 0)
        delete child
    end sub

    sub test_running_quick()
        var child = new ConsoleProcess("mock_process.exe")
        child->start()
        assert(child->running())
        delete child
    end sub

    sub test_running_ended()
        var child = new ConsoleProcess("mock_process.exe")
        child->start()
        sleep 250
        assert(child->running() = 0)
        delete child
    end sub

    sub test_running_ended_with_error()
        var child = new ConsoleProcess("mock_process.exe", "error")
        child->start()
        sleep 250
        assert(child->running() = 0)
        delete child
    end sub

    sub test_terminate_not_started()
        var child = new ConsoleProcess("invalid.exe")
        assert(child->terminate() = 0)
        delete child
    end sub

    sub test_terminate_invalid()
        var child = new ConsoleProcess("invalid.exe")
        child->start()
        assert(child->terminate() = 0)
        delete child
    end sub

    sub test_terminate_ended()
        var child = new ConsoleProcess("mock_process.exe")
        child->start()
        sleep 250
        assert(child->terminate() = 0)
        delete child
    end sub

    sub test_terminate_waiting()
        var child = new ConsoleProcess("mock_process.exe", "wait")
        child->start()
        sleep 250
        assert(child->terminate())
        assert(child->exit_code())
        delete child
        cleanup
    end sub

    sub run()
        test_require_executable
        test_quoted_executable
        test_optional_arguments
        test_start_failed
        test_start_succeed
        test_pid_invalid
        test_pid_worked
        test_pid_worked_with_error
        test_exit_code_invalid
        test_exit_code_worked
        test_exit_code_still_active
        test_exit_code_worked_with_error
        test_exist_code_twice
        test_running_not_started
        test_running_quick
        test_running_ended
        test_running_ended_with_error
        test_terminate_not_started
        test_terminate_invalid
        test_terminate_ended
        test_terminate_waiting
    end sub
end namespace

TestConsoleProcess.run()
