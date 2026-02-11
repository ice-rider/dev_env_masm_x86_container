# escape=`

FROM --platform=windows/amd64 mcr.microsoft.com/windows/servercore:ltsc2022 AS installer

ADD https://aka.ms/vs/17/release/vs_BuildTools.exe C:\vs_BuildTools.exe

RUN C:\vs_BuildTools.exe --quiet --wait --norestart --nocache `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
    --add Microsoft.VisualStudio.Component.VC.MASM `
    --includeRecommended --installPath C:\BuildTools `
 && del C:\vs_BuildTools.exe

FROM --platform=windows/amd64 mcr.microsoft.com/windows/servercore:ltsc2022

COPY --from=installer ["C:\\BuildTools", "C:\\BuildTools"]

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN $msvcPath = (Get-ChildItem C:\BuildTools\VC\Tools\MSVC -Directory | Select-Object -First 1).FullName; `
    $newPath = $env:PATH + \";$msvcPath\bin\Hostx64\x86;$msvcPath\bin\Hostx86\x86;C:\BuildTools\Common7\IDE\"; `
    setx /M PATH $newPath

WORKDIR C:\workspace
CMD ["cmd.exe"]