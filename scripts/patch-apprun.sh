# Adopted from https://gist.github.com/neilcsmith-net/69bcb23bcc6698815438dc4e3df6caa3

# INPUT_APPIMAGE must be absolute path
INPUT_APPIMAGE=$1

# System architecture to create AppImage for - see options at https://github.com/AppImage/AppImageKit/releases/continuous/
SYSTEM_ARCH="x86_64"
APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$SYSTEM_ARCH.AppImage"

TMP_DIR=$(mktemp -d)

cd $TMP_DIR
cp $INPUT_APPIMAGE .

# get the filename of the AppImage
APP_IMAGE_TMP=$(basename -- "$INPUT_APPIMAGE")

echo $APP_IMAGE_TMP

# Extract AppImage for the INPUT_APPIMAGE, which will be put into squashfs-root
chmod +x "$APP_IMAGE_TMP"
"./$APP_IMAGE_TMP" --appimage-extract

# Download appimagetool
wget -c "$APPIMAGETOOL_URL" -O appimagetool
chmod +x appimagetool

# Patch the AppRun script to add a new environment variable 
# ELECTRON_OZONE_PLATFORM_HINT=auto

file="squashfs-root/AppRun"  # The file to modify

# Use awk to process the file
awk '
BEGIN { OFS=FS="\n" }  # Set input and output field separator to newline
/export/ { lastExport=NR }  # Record the line number of the last "export"
{ lines[NR]=$0 }  # Store each line in the lines array
END {
    for (i=1; i<=NR; i++) {
        print lines[i]  # Print each line
        if (i == lastExport) {
            print "export ELECTRON_OZONE_PLATFORM_HINT=auto"  # Print new line after last EXPORT
        }
    }
}' "$file" > tmpfile && mv tmpfile "$file"  # Process the file and replace it

# Add execute permission to the AppRun script
chmod +x "$file"

# AppRun patched. Repack the AppImage
./appimagetool ./squashfs-root/ "$INPUT_APPIMAGE"

rm -rf $TMP_DIR

# Done
echo "patch-app-image.sh: Done."