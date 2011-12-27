#include once "helper.bi"
#include once "console_process.bi"

namespace TestConsoleProcess
    sub cleanup()
        shell("taskkill.exe /F /IM mock_process.exe 1>NUL 2>&1")
        kill("output.log")
    end sub

    function read_file(byref filename as string) as string
        dim result as string
        dim handle as integer

        handle = freefile
        open "output.log" for binary as #handle
        result = space(lof(handle))
        get #handle, , result
        close #handle

        return result
    end function

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

    sub test_terminate_induced_ctrl_c()
        var child = new ConsoleProcess("mock_process.exe", "slow1")
        child->start()
        sleep 250
        assert(child->terminate())
        assert(child->exit_code() = 10)
        delete child
        cleanup
    end sub

    sub test_terminate_forced_ctrl_break()
        var child = new ConsoleProcess("mock_process.exe", "slow2")
        child->start()
        sleep 250
        assert(child->terminate())
        assert(child->exit_code() = 20)
        delete child
        cleanup
    end sub

    sub test_terminate_with_default_timeout()
        dim as double a, b
        dim diff as integer
        var child = new ConsoleProcess("mock_process.exe", "slow2")
        child->start()
        sleep 250
        a = timer()
        child->terminate()
        b = timer()
        diff = int(b - a)
        assert(diff = 5)
        delete child
        cleanup
    end sub

    sub test_terminate_with_customized_timeout()
        dim as double a, b
        dim diff as integer
        var child = new ConsoleProcess("mock_process.exe", "slow2")
        child->start()
        sleep 250
        a = timer()
        child->terminate(8)
        b = timer()
        diff = int(b - a)
        assert(diff = 8)
        delete child
        cleanup
    end sub

    sub test_terminate_zombie_fail()
        var child = new ConsoleProcess("mock_process.exe", "zombie")
        child->start()
        sleep 250
        assert(child->terminate(1) = 0)
        assert(child->running())
        delete child
        cleanup
    end sub

    sub test_kill_not_started()
        var child = new ConsoleProcess("invalid.exe")
        assert(child->kill() = 0)
        delete child
    end sub

    sub test_kill_zombie()
        var child = new ConsoleProcess("mock_process.exe", "zombie")
        child->start()
        sleep 250
        assert(child->kill())
        sleep 250
        assert(child->running() = 0)
        delete child
        cleanup
    end sub

    sub test_not_redirected()
        var child = new ConsoleProcess("mock_process.exe")
        assert(child->redirected() = 0)
        delete child
    end sub

    sub test_redirect_invalid()
        var child = new ConsoleProcess("mock_process.exe")
        assert(child->redirect("") = 0)
        delete child
    end sub

    sub test_redirect()
        var child = new ConsoleProcess("mock_process.exe")
        assert(child->redirect("output.log"))
        assert(child->redirected())
        delete child
    end sub

    sub test_redirected_file()
        dim filename as string
        var child = new ConsoleProcess("mock_process.exe")
        child->redirect("output.log")
        child->start()
        sleep 250
        filename = Dir("output.log")
        assert(len(filename) > 0)
        delete child
    end sub

    sub test_redirected_file_contents()
        dim contents as string

        var child = new ConsoleProcess("mock_process.exe")
        child->redirect("output.log")
        child->start()
        sleep 250
        contents = read_file("output.log")

        assert(instr(contents, "out: message"))
        assert(instr(contents, "err: error"))

        delete child
        cleanup
    end sub

    sub test_redirected_file_append()
        dim as string contents1, contents2
        var child = new ConsoleProcess("mock_process.exe")
        child->redirect("output.log")
        child->start()
        sleep 250
        '# read contents first time
        contents1 = read_file("output.log")
        '# start and read contents again
        child->start()
        sleep 250
        contents2 = read_file("output.log")
        assert(len(contents2) > len(contents1))
        delete child
        cleanup
    end sub

    sub test_current_directory_not_set()
        var child = new ConsoleProcess("mock_process.exe", "pwd")
        assert(child->directory = "")
        delete child
    end sub

    sub test_current_directory_not_set_executed()
        dim contents as string
        var child = new ConsoleProcess("mock_process.exe", "pwd")
        child->redirect("output.log")
        child->start()
        sleep 250
        contents = read_file("output.log")
        assert(instr(contents, EXEPATH))
        delete child
        cleanup
    end sub

    sub test_current_directory_changed()
        var child = new ConsoleProcess(EXEPATH + "\mock_process.exe", "pwd")
        child->directory = EXEPATH + $"\fixtures"
        assert(child->directory = EXEPATH + $"\fixtures")
        delete child
    end sub

    sub test_current_directory_changed_executed()
        dim contents as string
        var child = new ConsoleProcess(EXEPATH + "\mock_process.exe", "pwd")
        child->directory = EXEPATH + $"\fixtures"
        child->redirect("output.log")
        child->start()
        sleep 250
        contents = read_file("output.log")
        assert(instr(contents, EXEPATH + $"\fixtures"))
        delete child
        cleanup
    end sub

    sub run()
        print "TestConsoleProcess: ";
        progress(test_require_executable)
        progress(test_quoted_executable)
        progress(test_optional_arguments)
        progress(test_start_failed)
        progress(test_start_succeed)
        progress(test_pid_invalid)
        progress(test_pid_worked)
        progress(test_pid_worked_with_error)
        progress(test_exit_code_invalid)
        progress(test_exit_code_worked)
        progress(test_exit_code_still_active)
        progress(test_exit_code_worked_with_error)
        progress(test_exist_code_twice)
        progress(test_running_not_started)
        progress(test_running_quick)
        progress(test_running_ended)
        progress(test_running_ended_with_error)
        progress(test_terminate_not_started)
        progress(test_terminate_invalid)
        progress(test_terminate_ended)
        progress(test_terminate_waiting)
        progress(test_terminate_induced_ctrl_c)
        progress(test_terminate_forced_ctrl_break)
        progress(test_terminate_with_default_timeout)
        progress(test_terminate_with_customized_timeout)
        progress(test_terminate_zombie_fail)
        progress(test_kill_not_started)
        progress(test_kill_zombie)
        progress(test_not_redirected)
        progress(test_redirect_invalid)
        progress(test_redirect)
        progress(test_redirected_file)
        progress(test_redirected_file_contents)
        progress(test_redirected_file_append)
        progress(test_current_directory_not_set)
        progress(test_current_directory_not_set_executed)
        progress(test_current_directory_changed)
        progress(test_current_directory_changed_executed)
        print "DONE"
    end sub
end namespace

TestConsoleProcess.run()
