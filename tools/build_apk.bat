echo off
copy /Y "%~dp0build_native_release.bat" "%~dp0../frameworks/runtime-src/proj.android/build_native_release.bat"
%~dp0../frameworks/runtime-src/proj.android/build_apk.bat