@ECHO off
ECHO RTP Scaler 3.0 times
ECHO by: RyanBram
ECHO.

SET MAGICK="%~dp0bin/ImageMagick/magick.exe"
SET xBR3="%~dp0bin/xBRScaler/3xBRLV4.exe"
SET SRMD="%~dp0bin/srmd-ncnn/srmd-ncnn-vulkan.exe"
SET modsrmd="%~dp0bin/srmd-ncnn/models-srmd"
SET PNGQUANT="%~dp0bin/pngquant/pngquant.exe"

IF EXIST "%~dp1temp" rmdir /s /q "%~dp1temp"
IF NOT EXIST "%~dp1temp" mkdir "%~dp1temp"

ECHO ===============================================================================
ECHO STEP 1 - Extracting alpha channel...
ECHO -------------------------------------------------------------------------------
%MAGICK% "%~dpnx1" -filter lanczos -background #404040 -alpha remove "%~dp1temp/%~n1.png"
%MAGICK% "%~dpnx1" -filter lanczos -alpha extract "%~dp1temp/mask.png"
ECHO Success!
ECHO.

ECHO ===============================================================================
ECHO STEP 2 - Improving source quality...
ECHO -------------------------------------------------------------------------------
%xBR3% "%~dp1temp/%~n1.png" "%~dp1temp/%~n1_xBR.png"
%xBR3% "%~dp1temp/mask.png" "%~dp1temp/mask_xBR.png"

%MAGICK% -precision 15 "%~dp1temp/%~n1_xBR.png" -define filter:lobes=2 -filter cubicspline -resize "%%[fx:100/3]%%" -unsharp 0x0.3 "%~dp1temp/%~n1_binning.png"
%MAGICK% -precision 15 "%~dp1temp/mask_xBR.png" -define filter:lobes=2 -filter cubicspline -resize "%%[fx:100/3]%%" -unsharp 0x0.3 "%~dp1temp/mask_binning.png"
ECHO.

ECHO ===============================================================================
ECHO STEP 3 - Scaling image...
ECHO -------------------------------------------------------------------------------
%SRMD% -i "%~dp1temp/%~n1_binning.png" -n -1 -s 3 -t 200 -m %modsrmd% -x -o "%~dp1temp/%~n1_srmdsharp.png"
%SRMD% -i "%~dp1temp/mask_binning.png" -n -1 -s 3 -t 200 -m %modsrmd% -x -o "%~dp1temp/mask_srmdsharp.png"

ECHO.

ECHO ===============================================================================
ECHO Finalizing...
ECHO -------------------------------------------------------------------------------
%MAGICK% "%~dp1temp/%~n1_srmdsharp.png" "%~dp1temp/mask_srmdsharp.png" -alpha Off -compose CopyOpacity -composite "%~dpn1_HR3x.png"
%PNGQUANT% --force --verbose --map "%~dpnx1" --nofs 256 --output "%~dpn1_HR3x_quantized.png" -- "%~dpn1_HR3x.png"

IF EXIST "%~dp1temp" rmdir /s /q "%~dp1temp"
ECHO.

ECHO DONE!
pause