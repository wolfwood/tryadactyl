
image:
	exiftool -overwrite_original -recurse -EXIF= images
	cd images; find . -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve
	cd images; find . -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --strip-all --preserve --totals --all-progressive
