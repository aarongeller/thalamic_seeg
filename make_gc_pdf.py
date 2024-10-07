#!/usr/bin/python

import os, sys
from glob import glob

subjname = sys.argv[1]
topdir = sys.argv[2]

figspath = os.path.join("analyses", subjname, "figs", topdir)
figspath_forward = os.path.join(figspath, "forward")
figspath_backward = os.path.join(figspath, "backward")

texfname = os.path.join(subjname, subjname + "_" + topdir + ".tex")
texf = open(texfname, 'w')

subjname_parts = subjname.split("_")
if len(subjname_parts) > 1:
    subjname = "\_".join(subjname_parts)

title = subjname + " Granger Figures"
preamble = "\\documentclass[12pt]{article}\n\\usepackage{graphicx, hyperref, longtable, pdflscape}\n" \
    + "\\hypersetup{colorlinks=true,linkcolor=blue,pdftitle={" + title + "}}\n" \
    + "\\renewcommand{\\familydefault}{\\sfdefault}\n\\title{" + title + "}\n" \
    + "\\begin{document}\n\\maketitle\clearpage\pagenumbering{gobble}\n\n" \
    + "\\setlength\\LTleft{-40mm}\\begin{landscape}\n\\hspace{-4cm}\n\\begin{longtable}{|c|c|c|c|c|}\n" \
    + "\caption{Granger causality plots.} \label{tab:long} \\\\\n\n" \
    + "\hline \multicolumn{1}{|c|}{\\textbf{Channel pair}} & \multicolumn{1}{c|}{\\textbf{Forward GC}} & \multicolumn{1}{c|}{\\textbf{Backward GC}} & \multicolumn{1}{c|}{\\textbf{z(Forward GC)}} & \multicolumn{1}{c|}{\\textbf{z(Backward GC)}} \\\\ \hline\n" \
    + "\endfirsthead\n\n" \
    + "\multicolumn{5}{c}%\n" \
    + "{{\\bfseries \\tablename\ \\thetable{} -- continued from previous page}} \\\\\n" \
    + "\hline \multicolumn{1}{|c|}{\\textbf{Channel pair}} & \multicolumn{1}{c|}{\\textbf{Forward GC}} & \multicolumn{1}{c|}{\\textbf{Backward GC}} & \multicolumn{1}{c|}{\\textbf{z(Forward GC)}} & \multicolumn{1}{c|}{\\textbf{z(Backward GC)}} \\\\ \hline\n" \
    + "\endhead\n\n" \
    + "\hline \multicolumn{5}{|r|}{{Continued on next page}} \\\\ \hline\n" \
    + "\endfoot\n\n" \
    + "\hline \hline\n" \
    + "\endlastfoot\n"

texf.write(preamble)

imgfiles_forward = glob(os.path.join(figspath_forward, '*.png'))
imgfiles_forward.sort()

imgfiles_backward = glob(os.path.join(figspath_backward, '*.png'))
imgfiles_backward.sort()

imgsize = 0.37
total_pairs = int(len(imgfiles_forward)/2)

for i,f in enumerate(imgfiles_forward):
    fparts = os.path.basename(f).split('_')
    if fparts[0]=="z":
        break
    else:
        seedstr = fparts[1]
        target = fparts[2][:-4]
        label = seedstr + " $\\leftrightarrow$ " + target
        thisline = "\\begin{tabular}{c}\n" + label + " \n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + f + "}\n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + imgfiles_backward[i] + "}\n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + imgfiles_forward[i+total_pairs] + "}\n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + imgfiles_backward[i+total_pairs] + "}\n\end{tabular}\n\\\\\n"
    texf.write(thisline)

postamble = "\\end{longtable}\n\\end{landscape}\n\n\\end{document}\n"
texf.write(postamble)

texf.close()

os.system("pdflatex -output-directory " + os.path.join("analyses", subjname) + " " + texfname)
os.system("pdflatex -output-directory " + os.path.join("analyses", subjname) + " " + texfname)
