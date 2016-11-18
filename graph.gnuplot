set term svg
set output "compression.svg"
set title "Compression"
set xlabel "Time"
set ylabel "Compression Ratio"
plot "res/zip.cmp" title "Zip", \
     "" with labels offset 1,0.5 notitle, \
     "res/gz.cmp" title "GZip", \
     "" with labels offset 1,0.5 notitle, \
     "res/bz2.cmp" title "BZip2", \
     "" with labels offset 1,0.5 notitle, \
     "res/lzip.cmp" title "LZip", \
     "" with labels offset 1,0.5 notitle, \
     "res/xz.cmp" title "XZ", \
     "" with labels offset 1,0.5 notitle

set term svg
set output "decompression.svg"
set title "Decompression"
set xlabel "Time"
set ylabel "Compression ratio"
plot "res/zip.uncmp" title "Zip", \
     "" with labels offset 1,0.5 notitle, \
     "res/gz.uncmp" title "GZip", \
     "" with labels offset 1,0.5 notitle, \
     "res/bz2.uncmp" title "BZip2", \
     "" with labels offset 1,0.5 notitle, \
     "res/lzip.uncmp" title "LZip", \
     "" with labels offset 1,0.5 notitle, \
     "res/xz.uncmp" title "XZ", \
     "" with labels offset 1,0.5 notitle
