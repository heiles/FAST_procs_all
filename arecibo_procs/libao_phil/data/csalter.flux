From csalter@naic.edu Tue Nov  6 18:45:51 2001
Return-Path: <csalter@naic.edu>
Received: from mani.naic.edu by nevis.naic.edu (4.1/SMI-4.1)
	id AA05954; Tue, 6 Nov 01 18:45:50 AST
Received: (from csalter@localhost)
	by mani.naic.edu (8.9.3+Sun/8.9.3) id SAA13833;
	Tue, 6 Nov 2001 18:45:50 -0400 (AST)
Date: Tue, 6 Nov 2001 18:45:50 -0400 (AST)
Message-Id: <200111062245.SAA13833@mani.naic.edu>
From: csalter@naic.edu
To: phil@naic.edu
Subject: Contains your 6 sources.
Cc: csalter@naic.edu, koneil@naic.edu
Content-Length: 6036
X-Lines: 118
Status: RO

    Spectral Fits for Various Continuum Sources
    -------------------------------------------

	I have made least-squares fits to the flux-density spectra of a
number of sources used for calibration runs at Arecibo. For this, I
fitted the three following spectral functions, and chose the best by a
combination of, a) "eye examination", and b) the rms of the deviations
between the published values and the fitted spectrum.

If  y = log10(S[Jy]),
and x = log10(Freq[MHz]), then the functions fitted were;

	1) y = a0 + a1 * x                -- Linear Fit
	2) y = a0 + a1 * x + a2 * x^2     -- Parabolic Fit
	3) y = a0 + a1 * x + a2 * exp(-x) -- as per Kuehr et al. (1981)

	As the Parabolic and "Kuehr" fits invariably produced similar
rms's, and as there is no theoretical reason to prefer one of these
functional forms over the other (at least that I know of!), I have 
made a final choice between just the Linear and Kuehr fits for each
source in the tables below. I have divided the sources into two tables;
a) those sources which I judge to be non-variable and relatively well
measured, and hence potentially good flux-density calibrators, and b)
those which appear to be variable or badly measured, and are thus poor
flux-density calibrators. (Of course, sources in the second class are
still likely to be good pointing calibrators.)

a) Sources believed to be Good Intensity Calibrators
----------------------------------------------------

-------------------------------------------------
Source 		a0	a1       a2      rms(%)
-------------------------------------------------
B0017+154      4.393  -1.251   -2.866      4.9 3C9
B0019-000      6.988  -1.680  -28.966      7.6
B0026+346      3.398  -0.791  -15.293      6.5
B0038+328      4.236  -1.097   -6.051      6.9 3C19 Valid > 150 MHz
B0049+175      3.096  -0.947      -        9.4 3C23 Conf at 4.1'
B0106+130      4.562  -1.055   -3.759      6.8 3C33 Size~4'
B0109+144      3.324  -1.011      -        9.5
B0116+319      3.771  -0.885  -12.332      7.5
B0123+329      2.573  -0.645      -        8.2 3C41
B0124+189      0.877  -0.313    5.137     12.5 Size~40"+/-8"
B0134+329      4.829  -1.072   -6.011      1.8 3C48 Fit to VLA fit
B0231+313      5.169  -1.592   -4.369     11.8 3C68.2
B0240-002      3.919  -0.958   -4.638      5.4 3C71 Size~16"
B0300+162      2.508  -0.657      -       10.2 3C76.1 Size~1.2'
B0316+162      7.689  -1.754  -29.660      4.8 CTA21 Valid > 300 MHz
B0320+053      5.703  -1.466  -14.119      7.2
B0428+205      5.761  -1.276  -26.891      5.7 Valid > 1 GHz
B0518+165      3.523  -0.779   -3.732      5.8 3C138 Fit to VLA fit
B0521+281      3.362  -0.988      -        8.1 3C139.2; Size~2.1'
B0640+233      3.769  -1.029   -2.417      6.9 3C165 Size~1.2'
B0732+332      3.243  -0.876   -2.719      9.5
B0824+294      2.941  -0.828      -        8.8 3C200
B0858+292      2.305  -0.641      -        8.6 3C213.1
B0932+089      2.873  -0.858   -3.531      9.0
B0940+029      3.072  -0.880   -4.721      9.2
B0949+287      3.569  -0.992   -7.159      4.2 Small conf at 4.3'
B1004+130      2.576  -0.795      -       12.0 Size~1.45'
B1039+029      3.346  -0.885   -3.284     11.8
B1140+223      4.475  -1.202   -4.420      5.2 3C263.1
B1153+317      4.941  -1.257  -11.274      8.5
B1312+210      3.300  -0.966   -5.495      7.9
B1317+179      2.342  -0.689      -       14.5
B1328+254      3.286  -0.729   -3.532      6.4 3C287
B1328+307      3.650  -0.721   -5.088      2.1 3C286 Fit to VLA fit
B1413+349      4.814  -1.176  -20.090      6.4 Valid <~8GHz
B1545+210      3.468  -0.938   -2.861      4.3 3C323.1; Size~1'
B1607+268      9.909  -2.291  -47.645      9.6 CTD93; cut-off below 1 GHz
B1615+212      3.647  -1.029   -3.482     10.8
B1622+238      3.565  -0.969   -2.100      5.9 3C336
B1634+269      2.932  -0.897      -       11.9 Size~34"+/-6"
B1829+290      3.700  -0.930   -7.453     10.0
B1843+098      3.170  -0.792      -        5.5 3C390
B1857+129      3.300  -0.907      -        9.5 3C394
B1913+302      2.874  -0.774      -        8.2 3C399.1 Size~70"
B1939+103      4.279  -1.262   -3.500     11.8
B2018+295      3.074  -0.662      -        9.8 3C410
B2041+170      2.540  -0.863      -       12.0
B2121+248      4.218  -0.967   -2.288      7.0 3C433; Size ~ 2'
B2128+048      6.243  -1.431  -25.809      5.5 Above 365 MHz
B2209+080      2.454  -0.706      -        7.5
B2247+140      2.056  -0.531   -1.720      8.9 Conf at 7.1'
B2249+185      2.888  -0.805      -        7.8 3C454
B2329+296      3.880  -1.180   -2.516     12.7
B2337+220      4.116  -1.090   -7.963      6.1
B2338+132      6.936  -1.898  -16.451      9.8
B2353+154      3.914  -1.076  -11.124      5.7
-------------------------------------------------


b) Sources thought to be Poor Intensity Calibrators
---------------------------------------------------

-------------------------------------------------
Source 		a0	a1       a2	rms(%)
-------------------------------------------------
B0149+218     -1.948   0.413   17.362    14.7 Doubtful < 1 GHz;  
						Conf source at 4.2'
B0202+149      1.679  -0.325   -1.542    11.9 Probable variable
B0333+321      4.368  -0.994  -16.591    12.8
B1004+141      0.551  -0.177     -        8.3
B1023+131      0.249  -0.137     -       18.1
B1222+036      4.311  -0.990  -26.400    19.8 Str conf source at 11.5'
B1441+252     -0.252  -0.050     -       15.2 Just 1.4 & 5 GHz data
                                               Str conf source at 6.0'
B1538+149     -0.438   0.119    6.866    22.9 Strongly variable
                                               Recently in weak state
B1749+096     -1.110   0.358     -       39.0
B1801+010     -0.024   0.010     -       20.9 Strongly variable
B2001+139      0.356  -0.247    8.734    15.0
B2145+067            Complex                  Strongly variable
B2223+210      1.535  -0.395     -       24.3 Variable
B2251+158      0.116   0.260    4.303    10.8 3C454.3
B2328+107      0.194  -0.054     -       13.6
------------------------------------------------
 

