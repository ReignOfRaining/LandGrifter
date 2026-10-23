@ECHO off
ECHO RTP Scaler 2.0 times
ECHO by: RyanBram
ECHO.

SET MAGICK="%~dp0bin/ImageMagick/magick.exe"
SET xBR4="%~dp0bin/xBRScaler/4xBRLV4.exe"
SET PNGQUANT="%~dp0bin/pngquant/pngquant.exe"

IF EXIST "%~dp1temp" rmdir /s /q "%~dp1temp"
IF NOT EXIST "%~dp1temp" mkdir "%~dp1temp"

ECHO ===============================================================================
ECHO STEP 1 - Extracting alpha channel...
ECHO -------------------------------------------------------------------------------
%MAGICK% "%~dpnx1" -filter lanczos -background #5a5a5a -alpha remove "%~dp1temp/%~n1.png"
%MAGICK% "%~dpnx1" -filter lanczos -alpha extract "%~dp1temp/mask.png"
ECHO Success!
ECHO.

ECHO ===============================================================================
ECHO STEP 2 - Improving source quality...
ECHO -------------------------------------------------------------------------------
ECHO.

ECHO ===============================================================================
ECHO STEP 3 - Scaling image...
ECHO -------------------------------------------------------------------------------
%xBR4% "%~dp1temp/%~n1.png" "%~dp1temp/%~n1_xBR.png"
%xBR4% "%~dp1temp/mask.png" "%~dp1temp/mask_xBR.png"

%MAGICK% -precision 15 "%~dp1temp/%~n1_xBR.png" -filter lanczos -resize "%%[fx:100/2]%%" "%~dp1temp/%~n1_HRx1p5.png"
%MAGICK% -precision 15 "%~dp1temp/mask_xBR.png" -filter lanczos -resize "%%[fx:100/2]%%" "%~dp1temp/mask_HRx1p5.png"
ECHO.

ECHO ===============================================================================
ECHO Finalizing...
ECHO -------------------------------------------------------------------------------
%MAGICK% "%~dp1temp/%~n1_HRx1p5.png" "%~dp1temp/mask_HRx1p5.png" -alpha Off -compose CopyOpacity -composite "%~dpn1_HR2x.png"
%PNGQUANT% --force --verbose --map "%~dpnx1" --nofs 256 --output "%~dpn1_HR2x_quantized.png" -- "%~dpn1_HR2x.png"

IF EXIST "%~dp1temp" rmdir /s /q "%~dp1temp"
ECHO.

ECHO DONE!
pause