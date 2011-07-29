#include once "configuration_file.bi"

constructor ConfigurationFile(byref filename as string)
    '# store file reference for future enquires
    _filename = filename
end constructor

destructor ConfigurationFile()
end destructor

property ConfigurationFile.executable() as string
    return retrieve("executable")
end property

property ConfigurationFile.arguments() as string
    return retrieve("arguments")
end property

property ConfigurationFile.directory() as string
    return retrieve("directory")
end property

property ConfigurationFile.logfile() as string
    return retrieve("logfile")
end property

function ConfigurationFile.retrieve(byref key as string) as string
    dim buffer as zstring * 2048
    dim request as DWORD

    request = GetPrivateProfileString("service", key, NULL, _
        @buffer, 2048, _filename)

    if (request > 0) then
        return buffer
    end if
end function
