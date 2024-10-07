#!/usr/bin/python

import os, sys
from glob import glob

subjname = sys.argv[1]
topdir = sys.argv[2]

figspath = os.path.join("analyses", subjname, "figs", topdir)

texfname = os.path.join("analyses", subjname, subjname + "_" + topdir + ".tex")
texf = open(texfname, 'w')

subjname_parts = subjname.split("_")
if len(subjname_parts) > 1:
    subjname = "\_".join(subjname_parts)

title = subjname + " Imaginary Coherence Figures"
preamble = "\\documentclass[12pt]{article}\n\\usepackage{graphicx}\n" \
    + "\\renewcommand{\\familydefault}{\\sfdefault}\n\\title{" + title + "}\n" \
    + "\\begin{document}\n\\maketitle\clearpage\pagenumbering{gobble}\n\n" \
    # + "\\setlength\\LTleft{-40mm}\\begin{landscape}\n\\hspace{-4cm}\n\\begin{longtable}{|c|c|c|c|c|}\n" \
    # + "\caption{Granger causality plots.} \label{tab:long} \\\\\n\n" \
    # + "\hline \multicolumn{1}{|c|}{\\textbf{Channel pair}} & \multicolumn{1}{c|}{\\textbf{Forward GC}} & \multicolumn{1}{c|}{\\textbf{Backward GC}} & \multicolumn{1}{c|}{\\textbf{z(Forward GC)}} & \multicolumn{1}{c|}{\\textbf{z(Backward GC)}} \\\\ \hline\n" \
    # + "\endfirsthead\n\n" \
    # + "\multicolumn{5}{c}%\n" \
    # + "{{\\bfseries \\tablename\ \\thetable{} -- continued from previous page}} \\\\\n" \
    # + "\hline \multicolumn{1}{|c|}{\\textbf{Channel pair}} & \multicolumn{1}{c|}{\\textbf{Forward GC}} & \multicolumn{1}{c|}{\\textbf{Backward GC}} & \multicolumn{1}{c|}{\\textbf{z(Forward GC)}} & \multicolumn{1}{c|}{\\textbf{z(Backward GC)}} \\\\ \hline\n" \
    # + "\endhead\n\n" \
    # + "\hline \multicolumn{5}{|r|}{{Continued on next page}} \\\\ \hline\n" \
    # + "\endfoot\n\n" \
    # + "\hline \hline\n" \
    # + "\endlastfoot\n"

texf.write(preamble)

imgfiles = glob(os.path.join(figspath, '*.png'))
imgfiles.sort()

imgsize = 0.5
total_pairs = int(len(imgfiles)/2)

for i,f in enumerate(imgfiles):
    fparts = os.path.basename(f).split('_')
    if len(fparts)>2:
        continue
    else:        
        seedstr = fparts[0]
        target = fparts[1].split('.')[0]
        label = seedstr + " $\\leftrightarrow$ " + target
        fparts2 = f.split('.')
        thisline = "\\section{" + label + "}\n\\begin{tabular}{cc}\n" \
        + "\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + fparts2[0] + "} &\n" \
        + "\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + fparts2[0] + "_zscore}\\\\\n\end{tabular}\n\n"
    texf.write(thisline)

postamble = "\\end{document}\n"
texf.write(postamble)
texf.close()

os.system("pdflatex -output-directory " + os.path.join("analyses", subjname) + " " + texfname)
os.system("pdflatex -output-directory " + os.path.join("analyses", subjname) + " " + texfname)
