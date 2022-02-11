@set TOOLSDIR=..\..\verification\auto_gen_scripts
@set REPODIR=..

@REM generate the testbench registers
@py -3 %TOOLSDIR%\gen_vlog.py  -r %REPODIR%  -j test.json -b csr -o .\ -s _auto
@py -3 %TOOLSDIR%\gen_htm.py   -r %REPODIR%  -j test.json -b csr -B
@py -3 %TOOLSDIR%\gen_elhal.py -r %REPODIR%  -j test.json -b csr -o .\src\hal

@REM Add project specific build here. Normally just point to top of the repository for hierarchical scan

@py -3 %TOOLSDIR%\gen_vlog.py  -r %REPODIR% -j core.json -b csr -s _auto
@py -3 %TOOLSDIR%\gen_htm.py   -r %REPODIR% -j core.json -b csr -B -w "950px" -W "700px"
@py -3 %TOOLSDIR%\gen_elhal.py -r %REPODIR% -j core.json -b csr -o .\src\hal