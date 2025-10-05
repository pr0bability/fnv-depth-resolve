set FXC="C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\fxc.exe"

if not exist package\Shaders\Loose mkdir package\Shaders\Loose

set SHADER_FILE=shaders\DOF.hlsl

%FXC% /T vs_3_0 /E Main /DVS /Fo "package\shaders\loose\ISDOF.vso" "%SHADER_FILE%"
%FXC% /T ps_3_0 /E Main /DPS /Fo "package\shaders\loose\ISDOF.pso" "%SHADER_FILE%"
