
# generalisation2012

Raw data from Navarro, Dry and Lee (2012), experiments 1 and 2. The data predate my learning R, and the encoding is a little opaque. All the data are in Matlab .mat files, and I no longer have access to Matlab. Fortunately it appears that the files can all be opened in R using `R.matlab::readMat()`. The tricky thing is that the data are so old that I hadn't yet learned how to properly document the data (sigh). The notes below are my attempt to work out what I did back in my foolish youth...

## experiment 1

All the data are in the `experiment1/alldata.mat` file. My best guess as to how I encoded the data is as follows: 

- the `Q1`, `Q2` and `Q3` variables contain the instruction text for each of the three scenarios, and `q1`, `q2` and `q3` contain the short name associated with each question
- the `Z1`, `Z2` and `Z3` variables appear to be the test values that participants were asked to make generalisations about in scenarios 1, 2 and 3 respectively
- the `X` variables are the training data presented to people: so `X11` are the coordinates of the three positive observations shown to people in scenario 1, stage 1; `X12` are the five positive observations in stage 2 (i.e. when two more examples are shown); `X13` is the 10 observations in stage 3. The values in `X21`, `X22` and `X23` are the same thing for scenario 2, and similarly `X31`, `X32` and `X33` are the same for scenario 3
- the `D` variables are the response data: for example, `D11` are all responses to the stimuli in `X11` at the test values in `Z1`, etc. Each of the 24 columns refers to one of the 24 test values in `Z1`, and each of the 22 rows refers to one of the 22 subjects (in the same order every time). The other `D` variables are defined analogously.

## experiment 2

The data are represented differently. Each subject has their own data file (e.g., `experiment2/Subject1.mat`). The file contains a single variable `EMP`, a matrix of lists. If loaded like to a variable `s1` as follows:

```r
s1 <- R.matlab::readMat("experiment2/Subject1.mat")
```

then `s1$EMP[1,1]` is a 25x7 matrix. I admit I have not yet found the time to go back and reverse engineer what these values are exactly, but they are the raw data as written to file by the experiment script. Fortunately, that script also still exists and is included as `experiment2/BAYES_EXP.m`. Hopefully it is possible to reconstruct the data by looking at the script. :grimace:
