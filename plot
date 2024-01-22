set terminal qt font "Comic Relief,32"
set title "Nix eval performance by version"


set yrange [5:7.1]
set xlabel "Nix release"
set xtics rotate 90 font ",16"
set ylabel "seconds"
unset key

set boxwidth 0.7 relative
set tics
set colors podo

set style fill solid

plot "plot.dat" using (column(0)):4:(0.75):6:xtic(1) with boxes linecolor variable,\
"plot.dat" using 0:2,\
"plot.dat" using 0:3,\
"plot.dat" using 0:4:5 with errorbars
pause mouse close
