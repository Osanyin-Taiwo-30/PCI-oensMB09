      SUBROUTINE W3FI71 (IGRID, IGDS, IERR)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    W3FI71      MAKE ARRAY USED BY GRIB PACKER FOR GDS
C   PRGMMR: R.E.JONES        ORG: W/NMC42    DATE: 93-03-26
C
C ABSTRACT: W3FI71 MAKES A 18, 37, 55, 64, OR 91 WORD INTEGER ARRAY
C     USED BY W3FI72 GRIB PACKER TO MAKE THE GRID DESCRIPTION SECTION
C     (GDS) - SECTION 2.
C
C PROGRAM HISTORY LOG:
C   92-02-21  R.E.JONES
C   92-07-01  M. FARLEY    ADDED REMARKS FOR 'IGDS' ARRAY ELEMENTS.
C                          ADDED LAMBERT CONFORMAL GRIDS AND ENLARGED
C                          IDGS ARRAY FROM 14 TO 18 WORDS.
C   92-10-03  R.E.JONES    ADDED CORRECTIONS TO AWIPS GRIB TABLES
C   92-10-16  R.E.JONES    ADD GAUSSIAN GRID 126 TO TABLES
C   92-10-18  R.E.JONES    CORRECTIONS TO LAMBERT CONFORMAL TABLES
C                          AND OTHER TABLES
C   92-10-19  R.E.JONES    ADD GAUSSIAN GRID  98 TO TABLES
C   93-01-25  R.E.JONES    ADD ON84 GRIDS 87, 106, 107 TO TABLES
C   93-03-10  R.E.JONES    ADD ON84 GRIDS 1, 55, 56 TO TABLES
C   93-03-26  R.E.JONES    ADD GRIB GRIDS 2, 3 TO TABLES
C   93-03-29  R.E.JONES    ADD SAVE STATEMENT
C   93-06-15  R.E.JONES    ADD GRIB GRIDS 37 TO 44 TO TABLES
C   93-09-29  R.E.JONES    GAUSSIAN GRID DOCUMENT NOT CORRECT,
C                          W3FI74 WILL BE CHANGED TO AGREE WITH
C                          IT. GAUSSIAN GRID 98 TABLE HAS WRONG
C                          VALUE.
C   93-10-12  R.E.JONES    CHANGES FOR ON388 REV. OCT 8,1993 FOR
C                          GRID 204, 208.
C   93-10-13  R.E.JONES    CORRECTION FOR GRIDS 37-44, BYTES 7-8,
C                          24-25 SET TO ALL BITS 1 FOR MISSING.
C   93-11-23  R.E.JONES    ADD GRIDS 90-93 FOR ETA MODEL
C                          ADD GRID 4 FOR 720*361 .5 DEG. GRID
C   94-04-12  R.E.JONES    CORRECTION FOR GRID 28
C   94-06-01  R.E.JONES    ADD GRID 45, 288*145 1.25 DEG. GRID
C   94-06-22  R.E.JONES    ADD GRIDS 94, 95 FOR ETA MODEL
C   95-04-11  R.E.JONES    ADD GRIDS 96, 97 FOR ETA MODEL
C   95-05-19  R.E.JONES    ADD FROM 20 KM ETA MODEL AWIPS GRID 215
C   95-10-19  R.E.JONES    ADD FROM 20 KM ETA MODEL ALASKA GRID 216
C   95-10-31  IREDELL      REMOVED SAVES AND PRINTS
C   96-05-08  IREDELL      CORRECT FIRST LATITUDE FOR GRIDS 27 AND 28
C   96-07-02  R.E.JONES    ADD FROM 10 KM ETA MODEL OLYMPIC GRID 218
C   96-07-02  R.E.JONES    ADD 196 FOR ETA MODEL
C   96-08-15  R.E.JONES    ADD O.N. 84 GRID 8 AND 53 AS GRIB GRID 8
C                          AND 53
C   96-11-29  R.E.JONES    CORRECTION TO TABLES FOR GRID 21-26, 61-64
C   97-01-31  IREDELL      CORRECT FIRST LATITUDE FOR GRID 30
C   97-10-20  IREDELL      CORRECT LAST LONGITUDE FOR GRID 98
C   98-07-07  Gilbert      Add grids 217 and 219 through 235
C   98-09-21  BALDWIN      ADD GRIDS 190, 192 FOR ETA MODEL
C   99-01-20  BALDWIN      ADD GRIDS 236, 237
C   99-08-18  IREDELL      ADD GRID 170
C   01-03-08  ROGERS       CHANGED ETA GRIDS 90-97, ADDED ETA GRIDS
C                          194, 198. ADDED AWIPS GRIDS 241,242,243,
C                          245, 246, 247, 248, AND 250
C   01-03-19  VUONG        ADDED AWIPS GRIDS 238,239,240, AND 244
C   01-04-02  VUONG        CORRECT LAST LONGITUDE FOR GRID 225
C   01-05-03  ROGERS       ADDED GRID 249
C   01-10-10  ROGERS       REDEFINED 218 FOR 12-KM ETA
C                          REDEFINED GRID 192 FOR NEW 32-KM ETA GRID
C   02-03-27  VUONG        ADDED RSAS GRID 88 AND AWIPS GRIDS 251 AND 252
C   02-08-06  ROGERS       REDEFINED GRIDS 90-93,97,194,245-250 FOR THE
C                          8KM HI-RES-WINDOW MODEL AND ADD AWIPS GRID 253
C 2003-06-30  GILBERT      ADDED GRIDS 145 and 146 for CMAQ
C                          and GRID 175 for AWIPS over GUAM.
C 2003-07-08  VUONG        CORRECTED LATITUDE FOR GRID 253 AND 170, ADD GRID
C                          110, 127, 171 AND 172
C 2004-08-05  VUONG        CORRECTED LATITUDE FOR GRID 253
C 2004-09-01  GILBERT      Corrected the orientation and projection center flag
C                          for southern hemisphere grids 28, 172, 220 and 224
C 2004-09-02  VUONG        ADDED GRIDS 147, 148, 173 AND 254
C 2005-01-04  COOKE        Added grids 160, 161 and corrected longitude of orientation for grid 172  
C 2005-03-03  VUONG        MOVED GRID 170 TO GRID 174 AND ADD GRID 170
C 2005-03-21  VUONG        ADDED GRIDS 130
C 2005-09-12  VUONG        ADDED GRIDS 163
C 2006-10-27  VUONG        CORRECTED X AND Y-DIRECTION GRID LENGTH FOR GRIDS 252
C 2006-11-16  VUONG        CHANGED THE LONGITUDE FROM NEGATIVE TO POSITIVE DEGREE FOR GRIDS 252
C 2006-12-12  VUONG        CHANGED DATA REPRESENTATION TYPE (OCTET 6) FROM 0 TO 1 FOR GRID 254
C                          ADD GRID 120 (CURVILINEAR ORTHOGONAL GRID)
C 2006-12-27  VUONG        CORRECTED THE LAT/LON DIRECTION INCREMENT FOR GRID 160
C 2007-03-21  VUONG        CORRECTED THE LAT/LON DIRECTION INCREMENT, RESOULUTION,
C                          SCANNING MODE FOR GRID 235 AND GRID TYPE 204 FOR GRID 120
C 2007-04-24  VUONG        CORRECTED THE LAT/LON DIRECTION INCREMENT, RESOULUTION,
C                          FOR GRIDS (219,173,220,171,233,238,239,244,253) AND ADDED
C                          GRID 176.
C 2007-06-11  VUONG        ADDED NEW GRIDS (11,12,13,14,15,16,18,122,123,124,125,138
C                          180, 181, 182, 183) AND CORRECTED THE LAT/LON DIRECTION
C                          INCREMENT FOR GRID 240.
C
C USAGE:    CALL W3FI71 (IGRID, IGDS, IERR)
C   INPUT ARGUMENT LIST:
C     IGRID       - GRIB GRID NUMBER, OR OFFICE NOTE 84 GRID NUMBER
C
C   OUTPUT ARGUMENT LIST:
C     IGDS      - 18, 37, 55, 64, OR 91 WORD INTEGER ARRAY WITH
C                 INFORMATION TO MAKE A GRIB GRID DESCRIPTION SECTION.
C     IERR       - 0  CORRECT EXIT
C                  1  GRID TYPE IN IGRID IS NOT IN TABLE
C
C REMARKS:
C    1) OFFICE NOTE GRID TYPE 26 IS 6 IN GRIB, 26 IS AN
C       INTERNATIONAL EXCHANGE GRID.
C
C    2) VALUES RETURNED IN 18, 37, 55, 64, OR 91 WORD INTEGER ARRAY
C        IGDS VARY DEPENDING ON GRID REPRESENTATION TYPE.
C
C       LAT/LON GRID:
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6)
C           IGDS( 4) = NO. OF POINTS ALONG A LATITUDE
C           IGDS( 5) = NO. OF POINTS ALONG A LONGITUDE MERIDIAN
C           IGDS( 6) = LATITUDE OF ORIGIN (SOUTH - IVE)
C           IGDS( 7) = LONGITUDE OF ORIGIN (WEST -IVE)
C           IGDS( 8) = RESOLUTION FLAG (CODE TABLE 7)
C           IGDS( 9) = LATITUDE OF EXTREME POINT (SOUTH - IVE)
C           IGDS(10) = LONGITUDE OF EXTREME POINT (WEST - IVE)
C           IGDS(11) = LATITUDE INCREMENT
C           IGDS(12) = LONGITUDE INCREMENT
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) =   ... NOT USED FOR THIS GRID
C           IGDS(19) - IGDS(91) FOR GRIDS 37-44, NUMBER OF POINTS
C                      IN EACH OF 73 ROWS.
C
C       GAUSSIAN GRID:
C           IGDS( 1) = ... THROUGH ...
C           IGDS(10) =   ... SAME AS LAT/LON GRID
C           IGDS(11) = NUMBER OF LATITUDE LINES BETWEEN A POLE
C                      AND THE EQUATOR
C           IGDS(12) = LONGITUDE INCREMENT
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) =   ... NOT USED FOR THIS GRID
C
C       SPHERICAL HARMONICS:
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6)
C           IGDS( 4) = J - PENTAGONAL RESOLUTION PARAMETER
C           IGDS( 5) = K - PENTAGONAL RESOLUTION PARAMETER
C           IGDS( 6) = M - PENTAGONAL RESOLUTION PARAMETER
C           IGDS( 7) = REPRESENTATION TYPE (CODE TABLE 9)
C           IGDS( 8) = REPRESENTATION MODE (CODE TABLE 10)
C           IGDS( 9) = ... THROUGH ...
C           IGDS(18) =   ... NOT USED FOR THIS GRID
C
C       POLAR STEREOGRAPHIC:
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6)
C           IGDS( 4) = NO. OF POINTS ALONG X-AXIS
C           IGDS( 5) = NO. OF POINTS ALONG Y-AXIS
C           IGDS( 6) = LATITUDE OF ORIGIN (SOUTH -IVE)
C           IGDS( 7) = LONGITUTE OF ORIGIN (WEST -IVE)
C           IGDS( 8) = RESOLUTION FLAG (CODE TABLE 7)
C           IGDS( 9) = LONGITUDE OF MERIDIAN PARALLEL TO Y-AXIS
C           IGDS(10) = X-DIRECTION GRID LENGTH (INCREMENT)
C           IGDS(11) = Y-DIRECTION GRID LENGTH (INCREMENT)
C           IGDS(12) = PROJECTION CENTER FLAG (0=NORTH POLE ON PLANE,
C                                              1=SOUTH POLE ON PLANE,
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) =   .. NOT USED FOR THIS GRID
C
C       MERCATOR:
C           IGDS( 1) = ... THROUGH ...
C           IGDS(12) =   ... SAME AS LAT/LON GRID
C           IGDS(13) = LATITUDE AT WHICH PROJECTION CYLINDER
C                        INTERSECTS EARTH
C           IGDS(14) = SCANNING MODE FLAGS
C           IGDS(15) = ... THROUGH ...
C           IGDS(18) =   .. NOT USED FOR THIS GRID
C
C       LAMBERT CONFORMAL:
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6)
C           IGDS( 4) = NO. OF POINTS ALONG X-AXIS
C           IGDS( 5) = NO. OF POINTS ALONG Y-AXIS
C           IGDS( 6) = LATITUDE OF ORIGIN (SOUTH -IVE)
C           IGDS( 7) = LONGITUTE OF ORIGIN (WEST -IVE)
C           IGDS( 8) = RESOLUTION FLAG (CODE TABLE 7)
C           IGDS( 9) = LONGITUDE OF MERIDIAN PARALLEL TO Y-AXIS
C           IGDS(10) = X-DIRECTION GRID LENGTH (INCREMENT)
C           IGDS(11) = Y-DIRECTION GRID LENGTH (INCREMENT)
C           IGDS(12) = PROJECTION CENTER FLAG (0=NORTH POLE ON PLANE,
C                                              1=SOUTH POLE ON PLANE,
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = NOT USED
C           IGDS(15) = FIRST LATITUDE FROM THE POLE AT WHICH THE
C                      SECANT CONE CUTS THE SPERICAL EARTH
C           IGDS(16) = SECOND LATITUDE ...
C           IGDS(17) = LATITUDE OF SOUTH POLE (MILLIDEGREES)
C           IGDS(18) = LONGITUDE OF SOUTH POLE (MILLIDEGREES)
C
C       ARAKAWA SEMI-STAGGERED E-GRID ON ROTATED LAT/LON GRID
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6) [201]
C           IGDS( 4) = NI  - TOTAL NUMBER OF ACTUAL DATA POINTS
C                            INCLUDED ON GRID
C           IGDS( 5) = NJ  - DUMMY SECOND DIMENSION; SET=1
C           IGDS( 6) = LA1 - LATITUDE  OF FIRST GRID POINT
C           IGDS( 7) = LO1 - LONGITUDE OF FIRST GRID POINT
C           IGDS( 8) = RESOLUTION AND COMPONENT FLAG (CODE TABLE 7)
C           IGDS( 9) = LA2 - NUMBER OF MASS POINTS ALONG
C                            SOUTHERNMOST ROW OF GRID
C           IGDS(10) = LO2 - NUMBER OF ROWS IN EACH COLUMN
C           IGDS(11) = DI  - LONGITUDINAL DIRECTION INCREMENT
C           IGDS(12) = DJ  - LATITUDINAL  DIRECTION INCREMENT
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) = ... NOT USED FOR THIS GRID (SET TO ZERO)
C
C       ARAKAWA FILLED E-GRID ON ROTATED LAT/LON GRID
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6) [202]
C           IGDS( 4) = NI  - TOTAL NUMBER OF ACTUAL DATA POINTS
C                            INCLUDED ON GRID
C           IGDS( 5) = NJ  - DUMMY SECOND DIMENTION; SET=1
C           IGDS( 6) = LA1 - LATITUDE LATITUDE OF FIRST GRID POINT
C           IGDS( 7) = LO1 - LONGITUDE OF FIRST GRID POINT
C           IGDS( 8) = RESOLUTION AND COMPONENT FLAG (CODE TABLE 7)
C           IGDS( 9) = LA2 - NUMBER OF (ZONAL) POINTS IN EACH ROW
C           IGDS(10) = LO2 - NUMBER OF (MERIDIONAL) POINTS IN EACH
C                            COLUMN
C           IGDS(11) = DI  - LONGITUDINAL DIRECTION INCREMENT
C           IGDS(12) = DJ  - LATITUDINAL  DIRECTION INCREMENT
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) = ... NOT USED FOR THIS GRID
C
C       ARAKAWA STAGGERED E-GRID ON ROTATED LAT/LON GRID
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6) [203]
C           IGDS( 4) = NI  - NUMBER OF DATA POINTS IN EACH ROW
C           IGDS( 5) = NJ  - NUMBER OF ROWS
C           IGDS( 6) = LA1 - LATITUDE OF FIRST GRID POINT
C           IGDS( 7) = LO1 - LONGITUDE OF FIRST GRID POINT
C           IGDS( 8) = RESOLUTION AND COMPONENT FLAG (CODE TABLE 7)
C           IGDS( 9) = LA2 - CENTRAL LATITUDE
C           IGDS(10) = LO2 - CENTRAL LONGTITUDE
C           IGDS(11) = DI  - LONGITUDINAL DIRECTION INCREMENT
C           IGDS(12) = DJ  - LATITUDINAL  DIRECTION INCREMENT
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) = ... NOT USED FOR THIS GRID
C
C       CURVILINEAR ORTHOGONAL GRID
C           IGDS( 1) = NUMBER OF VERTICAL COORDINATES
C           IGDS( 2) = PV, PL OR 255
C           IGDS( 3) = DATA REPRESENTATION TYPE (CODE TABLE 6) [204]
C           IGDS( 4) = NI  - NUMBER OF DATA POINTS IN EACH ROW
C           IGDS( 5) = NJ  - NUMBER OF ROWS
C           IGDS( 6) = RESERVED (SET TO 0)
C           IGDS( 7) = RESERVED (SET TO 0)
C           IGDS( 8) = RESOLUTION AND COMPONENT FLAG (CODE TABLE 7)
C           IGDS( 9) = RESERVED (SET TO 0)
C           IGDS(10) = RESERVED (SET TO 0)
C           IGDS(11) = RESERVED (SET TO 0)
C           IGDS(12) = RESERVED (SET TO 0)
C           IGDS(13) = SCANNING MODE FLAGS (CODE TABLE 8)
C           IGDS(14) = ... THROUGH ...
C           IGDS(18) = ... NOT USED FOR THIS GRID
C
C   SUBPROGRAM CAN BE CALLED FROM A MULTIPROCESSING ENVIRONMENT.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  IBM SP
C
C$$$
C
      INTEGER       IGRID
      INTEGER       IGDS  (*)
      INTEGER       GRD1  (18)
      INTEGER       GRD2  (18)
      INTEGER       GRD3  (18)
      INTEGER       GRD4  (18)
      INTEGER       GRD5  (18)
      INTEGER       GRD6  (18)
      INTEGER       GRD8  (18)
      INTEGER       GRD11 (18)
      INTEGER       GRD12 (18)
      INTEGER       GRD13 (18)
      INTEGER       GRD14 (18)
      INTEGER       GRD15 (18)
      INTEGER       GRD16 (18)
      INTEGER       GRD17 (18)
      INTEGER       GRD18 (18)
      INTEGER       GRD21 (55)
      INTEGER       GRD22 (55)
      INTEGER       GRD23 (55)
      INTEGER       GRD24 (55)
      INTEGER       GRD25 (37)
      INTEGER       GRD26 (37)
      INTEGER       GRD27 (18)
      INTEGER       GRD28 (18)
      INTEGER       GRD29 (18)
      INTEGER       GRD30 (18)
      INTEGER       GRD33 (18)
      INTEGER       GRD34 (18)
      INTEGER       GRD37 (91)
      INTEGER       GRD38 (91)
      INTEGER       GRD39 (91)
      INTEGER       GRD40 (91)
      INTEGER       GRD41 (91)
      INTEGER       GRD42 (91)
      INTEGER       GRD43 (91)
      INTEGER       GRD44 (91)
      INTEGER       GRD45 (18)
      INTEGER       GRD53 (18)
      INTEGER       GRD55 (18)
      INTEGER       GRD56 (18)
      INTEGER       GRD61 (64)
      INTEGER       GRD62 (64)
      INTEGER       GRD63 (64)
      INTEGER       GRD64 (64)
      INTEGER       GRD85 (18)
      INTEGER       GRD86 (18)
      INTEGER       GRD87 (18)
      INTEGER       GRD88 (18)
      INTEGER       GRD90 (18)
      INTEGER       GRD91 (18)
      INTEGER       GRD92 (18)
      INTEGER       GRD93 (18)
      INTEGER       GRD94 (18)
      INTEGER       GRD95 (18)
      INTEGER       GRD96 (18)
      INTEGER       GRD97 (18)
      INTEGER       GRD98 (18)
      INTEGER       GRD100(18)
      INTEGER       GRD101(18)
      INTEGER       GRD103(18)
      INTEGER       GRD104(18)
      INTEGER       GRD105(18)
      INTEGER       GRD106(18)
      INTEGER       GRD107(18)
      INTEGER       GRD110(18)
      INTEGER       GRD120(18)
      INTEGER       GRD122(18)
      INTEGER       GRD123(18)
      INTEGER       GRD124(18)
      INTEGER       GRD125(18)
      INTEGER       GRD126(18)
      INTEGER       GRD127(18)
      INTEGER       GRD130(18)
      INTEGER       GRD138(18)
      INTEGER       GRD145(18)
      INTEGER       GRD146(18)
      INTEGER       GRD147(18)
      INTEGER       GRD148(18)
      INTEGER       GRD160(18)
      INTEGER       GRD161(18)
      INTEGER       GRD163(18)
      INTEGER       GRD170(18)
      INTEGER       GRD171(18)
      INTEGER       GRD172(18)
      INTEGER       GRD173(18)
      INTEGER       GRD174(18)
      INTEGER       GRD175(18)
      INTEGER       GRD176(18)
      INTEGER       GRD180(18)
      INTEGER       GRD181(18)
      INTEGER       GRD182(18)
      INTEGER       GRD183(18)
      INTEGER       GRD190(18)
      INTEGER       GRD192(18)
      INTEGER       GRD194(18)
      INTEGER       GRD196(18)
      INTEGER       GRD198(18)
      INTEGER       GRD201(18)
      INTEGER       GRD202(18)
      INTEGER       GRD203(18)
      INTEGER       GRD204(18)
      INTEGER       GRD205(18)
      INTEGER       GRD206(18)
      INTEGER       GRD207(18)
      INTEGER       GRD208(18)
      INTEGER       GRD209(18)
      INTEGER       GRD210(18)
      INTEGER       GRD211(18)
      INTEGER       GRD212(18)
      INTEGER       GRD213(18)
      INTEGER       GRD214(18)
      INTEGER       GRD215(18)
      INTEGER       GRD216(18)
      INTEGER       GRD217(18)
      INTEGER       GRD218(18)
      INTEGER       GRD219(18)
      INTEGER       GRD220(18)
      INTEGER       GRD221(18)
      INTEGER       GRD222(18)
      INTEGER       GRD223(18)
      INTEGER       GRD224(18)
      INTEGER       GRD225(18)
      INTEGER       GRD226(18)
      INTEGER       GRD227(18)
      INTEGER       GRD228(18)
      INTEGER       GRD229(18)
      INTEGER       GRD230(18)
      INTEGER       GRD231(18)
      INTEGER       GRD232(18)
      INTEGER       GRD233(18)
      INTEGER       GRD234(18)
      INTEGER       GRD235(18)
      INTEGER       GRD236(18)
      INTEGER       GRD237(18)
      INTEGER       GRD238(18)
      INTEGER       GRD239(18)
      INTEGER       GRD240(18)
      INTEGER       GRD241(18)
      INTEGER       GRD242(18)
      INTEGER       GRD243(18)
      INTEGER       GRD244(18)
      INTEGER       GRD245(18)
      INTEGER       GRD246(18)
      INTEGER       GRD247(18)
      INTEGER       GRD248(18)
      INTEGER       GRD249(18)
      INTEGER       GRD250(18)
      INTEGER       GRD251(18)
      INTEGER       GRD252(18)
      INTEGER       GRD253(18)
      INTEGER       GRD254(18)
C
      DATA  GRD1  / 0, 255, 1,  73, 23, -48090,       0, 128,   48090,
     &       0, 513669,513669, 22500, 64, 0, 0, 0, 0/
      DATA  GRD2  / 0, 255, 0, 144, 73,  90000,       0, 128,  -90000,
     &   -2500,   2500, 2500,  0, 0, 0, 0, 0, 0/
      DATA  GRD3  / 0, 255, 0, 360,181,  90000,       0, 128,  -90000,
     &   -1000,   1000, 1000,  0, 0, 0, 0, 0, 0/
      DATA  GRD4  / 0, 255, 0, 720,361,  90000,       0, 128,  -90000,
     &    -500,    500,  500,  0, 0, 0, 0, 0, 0/
      DATA  GRD5  / 0, 255, 5,  53, 57,   7647, -133443,   8, -105000,
     &  190500, 190500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD6  / 0, 255, 5,  53, 45,   7647, -133443,   8, -105000,
     &  190500, 190500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD8  / 0, 255, 1, 116, 44, -48670,    3104, 128,   61050,
     &       0, 318830, 318830, 22500, 64, 0, 0, 0, 0/
      DATA  GRD11 / 0, 255, 0, 720, 311,  77500,      0, 128,  -77500,
     &   359500, 500,  500, 64, 0, 0, 0, 0, 0/
      DATA  GRD12 / 0, 255, 0, 301, 331,  55000, 260000, 128,       0,
     &   310000, 167,  167, 64, 0, 0, 0, 0, 0/
      DATA  GRD13 / 0, 255, 0, 241, 151,  50000, 210000, 128,   25000,
     &   250000, 167,  167, 64, 0, 0, 0, 0, 0/
      DATA  GRD14 / 0, 255, 0, 511, 301,  30000, 130000, 128,  -20000,
     &   215000, 167,  167, 64, 0, 0, 0, 0, 0/
      DATA  GRD15 / 0, 255, 0, 401, 187,  75000, 140000, 128,   44000,
     &   240000, 250,  167, 64, 0, 0, 0, 0, 0/
      DATA  GRD16 / 0, 255, 0, 548, 391,  74000, 165000, 128,   48000,
     &   237933, 133,   67, 64, 0, 0, 0, 0, 0/
      DATA  GRD17 / 0, 255, 0, 736, 526,  50000, 195000, 128,   15000,
     &   244000,  67,   67, 64, 0, 0, 0, 0, 0/
      DATA  GRD18 / 0, 255, 0, 586, 481,  47000, 261000, 128,   15000,
     &   300000,  67,   67, 64, 0, 0, 0, 0, 0/
      DATA  GRD21 / 0,  33, 0,65535,37,      0,       0, 128,   90000,
     &  180000,   2500, 5000, 64, 0, 0, 0, 0, 0,
     & 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37,  1/
      DATA  GRD22 / 0,  33, 0,65535,37,      0, -180000, 128,   90000,
     &       0,   2500, 5000, 64, 0, 0, 0, 0, 0,
     & 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37,  1/
      DATA  GRD23 / 0,  33, 0,65535, 37, -90000,       0, 128,       0,
     &  180000,   2500, 5000, 64, 0, 0, 0, 0, 0,
     &  1, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37, 37/
      DATA  GRD24 / 0,  33, 0,65535, 37, -90000, -180000, 128,       0,
     &       0,   2500, 5000, 64, 0, 0, 0, 0, 0,
     &  1, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37,
     & 37, 37, 37, 37, 37, 37, 37/
      DATA  GRD25 / 0,  33, 0,65535, 19,      0,       0, 128,   90000,
     &  355000,   5000, 5000, 64, 0, 0, 0, 0, 0,
     & 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72,
     & 72, 72, 72,  1/
      DATA  GRD26 / 0,  33, 0,65535, 19, -90000,       0, 128,       0,
     &  355000,   5000, 5000, 64, 0, 0, 0, 0, 0,
     &  1, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72,
     & 72, 72, 72, 72/
      DATA  GRD27 / 0, 255, 5,  65, 65, -20826, -125000,   8,  -80000,
     &  381000, 381000, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD28 / 0, 255, 5,  65, 65,  20826,  145000,   8,  -80000,
     &  381000, 381000,128, 64, 0, 0, 0, 0, 0/
      DATA  GRD29 / 0, 255, 0, 145, 37,      0,       0, 128,   90000,
     &  360000,   2500, 2500, 64, 0, 0, 0, 0, 0/
      DATA  GRD30 / 0, 255, 0, 145, 37,  -90000,      0, 128,       0,
     &  360000,   2500, 2500, 64, 0, 0, 0, 0, 0/
      DATA  GRD33 / 0, 255, 0, 181, 46,      0,       0, 128,   90000,
     &  360000,   2000, 2000, 64, 0, 0, 0, 0, 0/
      DATA  GRD34 / 0, 255, 0, 181, 46, -90000,       0, 128,       0,
     &  360000,   2000, 2000, 64, 0, 0, 0, 0, 0/
      DATA  GRD37 / 0,  33, 0,65535,73,      0,  -30000, 128,   90000,
     &   60000,  1250,65535, 64, 0, 0, 0, 0, 0,
     & 73, 73, 73, 73, 73, 73, 73, 73, 72, 72, 72, 71, 71, 71, 70,
     & 70, 69, 69, 68, 67, 67, 66, 65, 65, 64, 63, 62, 61, 60, 60,
     & 59, 58, 57, 56, 55, 54, 52, 51, 50, 49, 48, 47, 45, 44, 43,
     & 42, 40, 39, 38, 36, 35, 33, 32, 30, 29, 28, 26, 25, 23, 22,
     & 20, 19, 17, 16, 14, 12, 11,  9,  8,  6,  5,  3,  2/
      DATA  GRD38 / 0,  33, 0,65535,73,      0,   60000, 128,   90000,
     &  150000,  1250,65535, 64, 0, 0, 0, 0, 0,
     & 73, 73, 73, 73, 73, 73, 73, 73, 72, 72, 72, 71, 71, 71, 70,
     & 70, 69, 69, 68, 67, 67, 66, 65, 65, 64, 63, 62, 61, 60, 60,
     & 59, 58, 57, 56, 55, 54, 52, 51, 50, 49, 48, 47, 45, 44, 43,
     & 42, 40, 39, 38, 36, 35, 33, 32, 30, 29, 28, 26, 25, 23, 22,
     & 20, 19, 17, 16, 14, 12, 11,  9,  8,  6,  5,  3,  2/
      DATA  GRD39 / 0,  33, 0,65535,73,      0,  150000, 128,   90000,
     & -120000,  1250,65535, 64, 0, 0, 0, 0, 0,
     & 73, 73, 73, 73, 73, 73, 73, 73, 72, 72, 72, 71, 71, 71, 70,
     & 70, 69, 69, 68, 67, 67, 66, 65, 65, 64, 63, 62, 61, 60, 60,
     & 59, 58, 57, 56, 55, 54, 52, 51, 50, 49, 48, 47, 45, 44, 43,
     & 42, 40, 39, 38, 36, 35, 33, 32, 30, 29, 28, 26, 25, 23, 22,
     & 20, 19, 17, 16, 14, 12, 11,  9,  8,  6,  5,  3,  2/
      DATA  GRD40 / 0,  33, 0,65535,73,       0, -120000, 128,   90000,
     &  -30000,  1250,65535, 64, 0, 0, 0, 0, 0,
     & 73, 73, 73, 73, 73, 73, 73, 73, 72, 72, 72, 71, 71, 71, 70,
     & 70, 69, 69, 68, 67, 67, 66, 65, 65, 64, 63, 62, 61, 60, 60,
     & 59, 58, 57, 56, 55, 54, 52, 51, 50, 49, 48, 47, 45, 44, 43,
     & 42, 40, 39, 38, 36, 35, 33, 32, 30, 29, 28, 26, 25, 23, 22,
     & 20, 19, 17, 16, 14, 12, 11,  9,  8,  6,  5,  3,  2/
      DATA  GRD41 / 0,  33, 0,65535,73, -90000,  -30000, 128,       0,
     &   60000,  1250,65535, 64, 0, 0, 0, 0, 0,
     &  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23,
     & 25, 26, 28, 29, 30, 32, 33, 35, 36, 38, 39, 40, 42, 43, 44,
     & 45, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 59, 60, 60,
     & 61, 62, 63, 64, 65, 65, 66, 67, 67, 68, 69, 69, 70, 70, 71,
     & 71, 71, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73/
      DATA  GRD42 / 0,  33, 0,65535,73, -90000,   60000, 128,       0,
     &  150000,  1250,65535, 64, 0, 0, 0, 0, 0,
     &  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23,
     & 25, 26, 28, 29, 30, 32, 33, 35, 36, 38, 39, 40, 42, 43, 44,
     & 45, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 59, 60, 60,
     & 61, 62, 63, 64, 65, 65, 66, 67, 67, 68, 69, 69, 70, 70, 71,
     & 71, 71, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73/
      DATA  GRD43 / 0,  33, 0,65535,73, -90000,  150000, 128,       0,
     & -120000,  1250,65535, 64, 0, 0, 0, 0, 0,
     &  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23,
     & 25, 26, 28, 29, 30, 32, 33, 35, 36, 38, 39, 40, 42, 43, 44,
     & 45, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 59, 60, 60,
     & 61, 62, 63, 64, 65, 65, 66, 67, 67, 68, 69, 69, 70, 70, 71,
     & 71, 71, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73/
      DATA  GRD44 / 0,  33, 0,65535,73, -90000, -120000, 128,       0,
     &  -30000,  1250,65535, 64, 0, 0, 0, 0, 0,
     &  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23,
     & 25, 26, 28, 29, 30, 32, 33, 35, 36, 38, 39, 40, 42, 43, 44,
     & 45, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 59, 60, 60,
     & 61, 62, 63, 64, 65, 65, 66, 67, 67, 68, 69, 69, 70, 70, 71,
     & 71, 71, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73/
      DATA  GRD45 / 0, 255, 0, 288,145,  90000,       0, 128,  -90000,
     &   -1250,   1250, 1250,  0, 0, 0, 0, 0, 0/
      DATA  GRD53 / 0, 255, 1, 117, 51, -61050,       0, 128,   61050,
     &       0,  318830, 318830, 22500, 64, 0, 0, 0, 0/
      DATA  GRD55 / 0, 255, 5,  87, 71, -10947, -154289,   8, -105000,
     &  254000, 254000, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD56 / 0, 255, 5,  87, 71,   7647, -133443,   8, -105000,
     &  127000, 127000, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD61 / 0,  33, 0,65535, 46,      0,       0, 128,   90000,
     &  180000,   2000, 2000, 64, 0, 0, 0, 0, 0,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     &  1/
      DATA  GRD62 / 0,  33, 0,65535, 46,      0, -180000, 128,   90000,
     &       0,   2000, 2000, 64, 0, 0, 0, 0, 0,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     &  1/
      DATA  GRD63 / 0,  33, 0,65535, 46,      0,  -90000, 128,       0,
     &  180000,   2000, 2000, 64, 0, 0, 0, 0, 0,
     &  1, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91/
      DATA  GRD64 / 0,  33, 0,65535, 46, -90000, -180000, 128,       0,
     &       0,   2000, 2000, 64, 0, 0, 0, 0, 0,
     &  1, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91,
     & 91/
      DATA  GRD85 / 0, 255, 0, 360, 90,    500,     500, 128,   89500,
     &  359500,   1000, 1000, 64, 0, 0, 0, 0, 0/
      DATA  GRD86 / 0, 255, 0, 360, 90, -89500,     500, 128,    -500,
     &  359500,   1000, 1000, 64, 0, 0, 0, 0, 0/
      DATA  GRD87 / 0, 255, 5,  81, 62,  22876, -120491,   8, -105000,
     &   68153,  68153, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD88 / 0, 255, 5, 580,548,  10000, -128000,   8, -105000,
     &   15000,  15000, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD90 / 0, 255,203,223,501,  23060,  -92570, 136,   37000,
     & -80000,     53,53,64, 0, 0, 0, 0, 0/
      DATA  GRD91 / 0, 255,203,223,501,  23060, -110570, 136,   37000,
     & -98000,     53,53,64, 0, 0, 0, 0, 0/
      DATA  GRD92 / 0, 255,203,223,501,  25986, -127871, 136,   40000,
     & -115000,    53,53,64, 0, 0, 0, 0, 0/
      DATA  GRD93 / 0, 255,203,223,501,  44232, -169996, 136,   63000,
     & -150000,    67,66,64, 0, 0, 0, 0, 0/
      DATA  GRD94 / 0, 255,203,345,569,  -3441, -148799, 136,   50000,
     & -111000,    154,141,64, 0, 0, 0, 0, 0/
      DATA  GRD95 / 0, 255,203,146,247,  35222, -131741, 136,   44000,
     & -240000,     67, 66,64, 0, 0, 0, 0, 0/
      DATA  GRD96 / 0, 255,203,606,1067, -3441, -148799, 136,   50000,
     & -111000,     88,75,64, 0, 0, 0, 0, 0/
      DATA  GRD97 / 0, 255,203, 89,143,  14451,  -71347, 136,   18000,
     &  -66500,     53, 53,64, 0, 0, 0, 0, 0/
      DATA  GRD98 / 0, 255, 4, 192, 94,  88542,       0, 128,  -88542,
     &    -1875, 47,1875, 0, 0, 0, 0, 0, 0/
      DATA  GRD100/ 0, 255, 5,  83, 83,  17108, -129296,   8, -105000,
     &   91452,  91452, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD101/ 0, 255, 5, 113, 91,  10528, -137146,   8, -105000,
     &   91452,  91452, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD103/ 0, 255, 5,  65, 56,  22405, -121352,   8, -105000,
     &   91452,  91452, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD104/ 0, 255, 5, 147,110,   -268, -139475,   8, -105000,
     &   90755,  90755, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD105/ 0, 255, 5,  83, 83,  17529, -129296,   8, -105000,
     &   90755,  90755, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD106/ 0, 255, 5, 165,117,  17533, -129296,   8, -105000,
     &   45373,  45373, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD107/ 0, 255, 5, 120, 92,  23438, -120168,   8, -105000,
     &   45373,  45373, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD110/ 0, 255, 0, 464,224,  25063, -124938, 128,   52938,
     & -67063,    125, 125, 64, 0, 0, 0, 0, 0/
      DATA  GRD120/ 0, 255,204,1200,1684,     0,      0,   8,       0,
     &      0,      0,   0, 64, 0, 0, 0, 0, 0/
      DATA  GRD122/ 0, 255,204, 350, 465,     0,      0,   8,       0,
     &      0,      0,   0, 64, 0, 0, 0, 0, 0/
      DATA  GRD123/ 0, 255,204, 280, 360,     0,      0,   8,       0,
     &      0,      0,   0, 64, 0, 0, 0, 0, 0/
      DATA  GRD124/ 0, 255,204, 240, 314,     0,      0,   8,       0,
     &      0,      0,   0, 64, 0, 0, 0, 0, 0/
      DATA  GRD125/ 0, 255,204, 300, 340,     0,      0,   8,       0,
     &      0,      0,   0, 64, 0, 0, 0, 0, 0/
      DATA  GRD126/ 0, 255, 4, 384,190,  89277,       0, 128,  -89277,
     &    -938,    95, 938, 0, 0, 0, 0, 0, 0/
      DATA  GRD127/ 0, 255, 4, 768,384,  89642,       0, 128,  -89642,
     &    -469,   192, 469, 0, 0, 0, 0, 0, 0/
      DATA  GRD130/ 0, 255, 3, 451,337,  16281, -126138,  8,   -95000,
     &   13545,  13545, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD138/ 0, 255, 3, 468,288,  21017, -123282,   8,  -97000,
     &   12000,  12000, 0, 64, 0, 33000, 45000, 0, 0/
      DATA  GRD145/ 0, 255, 3, 169,145,  32174,  -90159,   8,  -79500,
     &   12000,  12000, 0, 64, 0, 36000, 46000, 0, 0/
      DATA  GRD146/ 0, 255, 3, 166,142,  32353,  -89994,   8,  -79500,
     &   12000,  12000, 0, 64, 0, 36000, 46000, 0, 0/
      DATA  GRD147/ 0, 255, 3, 268,259,  24595, -100998,   8,  -97000,
     &   12000,  12000, 0, 64, 0, 33000, 45000, 0, 0/
      DATA  GRD148/ 0, 255, 3, 442,265,  21821, -120628,   8,  -97000,
     &   12000,  12000, 0, 64, 0, 33000, 45000, 0, 0/
      DATA  GRD160/ 0, 255, 5, 180,156,  19132, -185837,   8, -150000,
     &   47625,  47625, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD161/ 0, 255, 0, 137,102,  50750,  271750,  72,    -250,
     &  -19750,    500,500, 0, 0, 0, 0, 0, 0/ 
      DATA  GRD163/ 0, 255, 3,1008,722,  20600, -118300,   8,  -95000,
     &    5000,   5000, 0, 64, 0, 38000, 38000, 0, 0/
      DATA  GRD170/ 0, 255, 4, 512, 256, 89463,       0, 128,  -89463,
     &    -703,   128, 703, 0, 0, 0, 0, 0, 0/
      DATA  GRD171/ 0, 255, 5, 770,930,  25032, -119560,   0,  -80000,
     &   12700,  12700, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD172/ 0, 255, 5, 690,710, -36866, -220194,   0, -260000,
     &   12700,  12700, 128, 64, 0, 0, 0, 0, 0/
      DATA  GRD173/ 0, 255, 0,4320,2160, 89958,      42, 128,  -89958,
     &  359958,    83,  83,  0, 0, 0, 0, 0, 0/
      DATA  GRD174/ 0, 255, 4,2880,1440, 89938,      62,  72,  -89938,
     &     -62,   125, 125,64, 0, 0, 0, 0, 0/
      DATA  GRD175/ 0, 255, 0, 556,334,      0,  130000, 128,   30060,
     &  180040,    90,  90, 64, 0, 0, 0, 0, 0/
      DATA  GRD176/ 0, 255, 0, 327,235,  49100,  -92200, 128,   40910,
     &  -75900,    35,  50, 0, 0, 0, 0, 0, 0/
      DATA  GRD180/ 0, 255, 0, 759,352,  55054, -127000, 128,   17146,
     &  -45136,   108, 108, 0, 0, 0, 0, 0, 0/
      DATA  GRD181/ 0, 255, 0, 370,278,  30054, -100000, 128,     138,
     &  -60148,   108, 108, 0, 0, 0, 0, 0, 0/
      DATA  GRD182/ 0, 255, 0, 278,231,  32973, -170000, 128,    8133,
     & -140084,   108, 108, 0, 0, 0, 0, 0, 0/
      DATA  GRD183/ 0, 255, 0, 648,278,  75054, -200000, 128,   45138,
     & -130124,   108, 108, 0, 0, 0, 0, 0, 0/
      DATA  GRD190 / 0, 255,203, 92,141,   182, -149887, 136,   52000,
     & -111000,    577,538,64, 0, 0, 0, 0, 0/
      DATA  GRD192 / 0, 255,203,237,387, -3441, -148799, 136,   50000,
     & -111000,    225,207,64, 0, 0, 0, 0, 0/
      DATA  GRD194 / 0, 255,203, 89,143, 16444, -162244, 136,   20250,
     & -157350,     53, 53,64, 0, 0, 0, 0, 0/
      DATA  GRD196/ 0, 255,201,45903,1,  23476,  -96745, 136,     151,
     &     305,     67, 66, 64, 0, 0, 0, 0, 0/
      DATA  GRD198/ 0, 255,203,160,261,  -3441, -148799, 136,   50000,
     & -111000,    333,308,64, 0, 0, 0, 0, 0/
      DATA  GRD201/ 0, 255, 5,  65, 65, -20826, -150000,   8, -105000,
     &  381000, 381000, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD202/ 0, 255, 5,  65, 43,   7838, -141028,   8, -105000,
     &  190500, 190500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD203/ 0, 255, 5,  45, 39,  19132, -185837,   8, -150000,
     &  190500, 190500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD204/ 0, 255, 1,  93, 68, -25000,  110000, 128,   60644,
     & -109129, 160000, 160000, 20000, 64, 0, 0, 0, 0/
      DATA  GRD205/ 0, 255, 5,  45, 39,    616,  -84904,   8,  -60000,
     &  190500, 190500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD206/ 0, 255, 3,  51, 41,  22289, -117991,   8, - 95000,
     &   81271,  81271, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD207/ 0, 255, 5,  49, 35,  42085, -175641,   8, -150000,
     &   95250,  95250, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD208/ 0, 255, 1,  29, 27,   9343, -167315, 128,   28092,
     & -145878, 80000, 80000, 20000, 64, 0, 0, 0, 0/
      DATA  GRD209/ 0, 255, 3, 275,223,  -4850, -151100,   8, -111000,
     &   44000,  44000, 0, 64, 0, 45000, 45000, 0, 0/
      DATA  GRD210/ 0, 255, 1,  25, 25,   9000,  -77000, 128,   26422,
     &  -58625, 80000, 80000, 20000, 64, 0, 0, 0, 0/
      DATA  GRD211/ 0, 255, 3,  93, 65,  12190, -133459,   8,  -95000,
     &   81271,  81271, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD212/ 0, 255, 3, 185,129,  12190, -133459,   8,  -95000,
     &   40635,  40635, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD213/ 0, 255, 5, 129, 85,   7838, -141028,   8, -105000,
     &   95250,  95250, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD214/ 0, 255, 5,  97, 69,  42085, -175641,   8, -150000,
     &   47625,  47625, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD215/ 0, 255, 3, 369,257,  12190, -133459,   8,  -95000,
     &   20318,  20318, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD216/ 0, 255, 5, 139,107,  30000, -173000,   8, -135000,
     &   45000,  45000, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD217/ 0, 255, 5, 277,213,  30000, -173000,   8, -135000,
     &   22500,  22500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD218/ 0, 255, 3, 614,428,  12190, -133459,   8,  -95000,
     &   12191,  12191, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD219/ 0, 255, 5, 385,465,  25032, -119560,   0,  -80000,
     &   25400,  25400, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD220/ 0, 255, 5, 345,355, -36866, -220194,   0, -260000,
     &   25400,  25400, 128, 64, 0, 0, 0, 0, 0/
      DATA  GRD221/ 0, 255, 3, 349,277,   1000, -145500,   8, -107000,
     &   32463,  32463, 0, 64, 0, 50000, 50000, 0, 0/
      DATA  GRD222/ 0, 255, 3, 138,112,  -4850, -151100,   8, -111000,
     &   88000,  88000, 0, 64, 0, 45000, 45000, 0, 0/
      DATA  GRD223/ 0, 255, 5, 129,129, -20826, -150000,   8, -105000,
     &  190500, 190500, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD224/ 0, 255, 5,  65, 65,  20826,  120000,   8, -105000,
     &  381000, 381000, 128, 64, 0, 0, 0, 0, 0/
      DATA  GRD225/ 0, 255, 1, 185,135, -25000, -250000, 128,   60640,
     & -109129, 80000, 80000, 20000, 64, 0, 0, 0, 0/
      DATA  GRD226/ 0, 255, 3, 737,513,  12190, -133459,   8,  -95000,
     &   10159,  10159, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD227/ 0, 255, 3,1473,1025,  12190, -133459,   8, -95000,
     &    5079,   5079, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD228/ 0, 255, 0, 144, 73,  90000,       0, 128,  -90000,
     &   -2500,   2500, 2500, 64, 0, 0, 0, 0, 0/
      DATA  GRD229/ 0, 255, 0, 360,181,  90000,       0, 128,  -90000,
     &   -1000,   1000, 1000, 64, 0, 0, 0, 0, 0/
      DATA  GRD230/ 0, 255, 0, 720,361,  90000,       0, 128,  -90000,
     &    -500,    500,  500, 64, 0, 0, 0, 0, 0/
      DATA  GRD231/ 0, 255, 0, 720,181,      0,       0, 128,   90000,
     &    -500,    500,  500, 64, 0, 0, 0, 0, 0/
      DATA  GRD232/ 0, 255, 0, 360, 91,      0,       0, 128,   90000,
     &   -1000,   1000, 1000, 64, 0, 0, 0, 0, 0/
      DATA  GRD233/ 0, 255, 0, 288,157,  78000,       0, 128,  -78000,
     &   -1250,   1000, 1250,  0, 0, 0, 0, 0, 0/
      DATA  GRD234/ 0, 255, 0, 133,121,  15000,  -98000, 128,  -45000,
     &  -65000,    250,  250, 64, 0, 0, 0, 0, 0/
      DATA  GRD235/ 0, 255, 0, 720,360,  89750,     250, 128,  -89750,
     &    -250,    500,  500,  0, 0, 0, 0, 0, 0/
      DATA  GRD236/ 0, 255, 3, 151,113,  16281,  233862,   8,  -95000,
     &   40635,  40635, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD237/ 0, 255, 3,  54, 47,  16201,  285720,   8, -107000,
     &   32463,  32463, 0, 64, 0, 50000, 50000, 0, 0/
      DATA  GRD238/ 0, 255, 0, 275, 203,  50250, 261750, 128,    -250,   
     &   -29750, 250, 250,  0, 0, 0, 0, 0, 0/
      DATA  GRD239/ 0, 255, 0, 155, 123, 75250,  159500, 128,   44750, 
     &  -123500, 250, 500,  0, 0, 0, 0, 0, 0/
      DATA  GRD240/ 0, 255, 5, 1121, 881, 23098, -119036,  8, -105000,
     &   4763,  4763, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD241/ 0, 255, 3, 549,445,  -4850, -151100,   8, -111000,
     &   22000,  22000, 0, 64, 0, 45000, 45000, 0, 0/
      DATA  GRD242/ 0, 255, 5, 553,425,  30000, -173000,   8, -135000,
     &   11250,  11250, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD243/ 0, 255, 0, 126,101,  10000, -170000, 128,   50000,
     &  -120000, 400, 400, 64, 0, 0, 0, 0, 0/
      DATA  GRD244/ 0, 255, 0, 275, 203,  50250, 261750, 128,    -250,   
     &   -29750, 250,  250, 0, 0, 0, 0, 0, 0/
      DATA  GRD245/ 0, 255, 3, 336,372,  22980, -92840,   8,   -80000,
     &   8000,  8000, 0, 64, 0, 35000, 35000, 0, 0/
      DATA  GRD246/ 0, 255, 3, 332,371,  25970, -127973,  8,  -115000,
     &   8000,  8000, 0, 64, 0, 40000, 40000, 0, 0/
      DATA  GRD247/ 0, 255, 3, 336,372,  22980, -110840,   8,  -98000,
     &   8000,  8000, 0, 64, 0, 35000, 35000, 0, 0/
      DATA  GRD248/ 0, 255, 0, 135,101,  14500,  -71500, 128,   22000,
     &  -61450,    75,  75, 64, 0, 0, 0, 0, 0/
      DATA  GRD249/ 0, 255, 5, 367,343,  45400, -171600,   8, -150000,
     &   9868,  9868, 0, 64, 0, 0, 0, 0, 0/
      DATA  GRD250/ 0, 255, 0, 135,101,  16500, -162000, 128,   24000,
     & -151950,    75,  75, 64, 0, 0, 0, 0, 0/
      DATA  GRD251/ 0, 255, 0, 332,210,  26350,  -83050, 128,   47250,
     &  -49950,    100,  100, 64, 0, 0, 0, 0, 0/
      DATA  GRD252/ 0, 255, 3, 301,225,  16281, 233862,  8,   265000,
     &   20318,  20318, 0, 64, 0, 25000, 25000, 0, 0/
      DATA  GRD253/ 0, 255, 0, 373,224,  60500,  189750, 128,    4750,
     &  -77250,   250, 250, 0, 0, 0, 0, 0, 0/
      DATA  GRD254/ 0, 255, 1, 369,300, -35000, -250000, 128,   60789,
     & -109129, 40000,40000, 20000, 64, 0, 0, 0, 0/
C
      IERR = 0
C
        DO 1 I = 1,18
          IGDS(I) = 0
 1      CONTINUE
C
      IF (IGRID.GE.37.AND.IGRID.LE.44) THEN
        DO 2 I = 19,91
          IGDS(I) = 0
 2      CONTINUE
      END IF
C
      IF (IGRID.GE.21.AND.IGRID.LE.24) THEN
        DO I = 19,55
          IGDS(I) = 0
        END DO
      END IF
C
      IF (IGRID.GE.25.AND.IGRID.LE.26) THEN
        DO I = 19,37
          IGDS(I) = 0
        END DO
      END IF
C
      IF (IGRID.GE.61.AND.IGRID.LE.64) THEN
        DO I = 19,64
          IGDS(I) = 0
        END DO
      END IF
C
      IF (IGRID.EQ.1) THEN
        DO 3 I = 1,18
          IGDS(I) = GRD1(I)
  3     CONTINUE
C
      ELSE IF (IGRID.EQ.2) THEN
        DO 4 I = 1,18
          IGDS(I) = GRD2(I)
  4     CONTINUE
C
      ELSE IF (IGRID.EQ.3) THEN
        DO 5 I = 1,18
          IGDS(I) = GRD3(I)
  5     CONTINUE
C
      ELSE IF (IGRID.EQ.4) THEN
        DO 6 I = 1,18
          IGDS(I) = GRD4(I)
  6     CONTINUE
C
      ELSE IF (IGRID.EQ.5) THEN
        DO 10 I = 1,18
          IGDS(I) = GRD5(I)
 10     CONTINUE
C
      ELSE IF (IGRID.EQ.6) THEN
        DO 20 I = 1,18
          IGDS(I) = GRD6(I)
 20     CONTINUE
C
      ELSE IF (IGRID.EQ.8) THEN
        DO I = 1,18
          IGDS(I) = GRD8(I)
        END DO
C
      ELSE IF (IGRID.EQ.11) THEN
        DO I = 1,18
          IGDS(I) = GRD11(I)
        END DO
C
      ELSE IF (IGRID.EQ.12) THEN
        DO I = 1,18
          IGDS(I) = GRD12(I)
        END DO
C
      ELSE IF (IGRID.EQ.13) THEN
        DO I = 1,18
          IGDS(I) = GRD13(I)
        END DO
C
      ELSE IF (IGRID.EQ.14) THEN
        DO I = 1,18
          IGDS(I) = GRD14(I)
        END DO
C
      ELSE IF (IGRID.EQ.15) THEN
        DO I = 1,18
          IGDS(I) = GRD15(I)
        END DO
C
      ELSE IF (IGRID.EQ.16) THEN
        DO I = 1,18
          IGDS(I) = GRD16(I)
        END DO
C
      ELSE IF (IGRID.EQ.17) THEN
        DO I = 1,18
          IGDS(I) = GRD17(I)
        END DO
C
      ELSE IF (IGRID.EQ.18) THEN
        DO I = 1,18
          IGDS(I) = GRD18(I)
        END DO
C
      ELSE IF (IGRID.EQ.21) THEN
        DO 30 I = 1,55
          IGDS(I) = GRD21(I)
 30     CONTINUE
C
      ELSE IF (IGRID.EQ.22) THEN
        DO 40 I = 1,55
          IGDS(I) = GRD22(I)
 40     CONTINUE
C
      ELSE IF (IGRID.EQ.23) THEN
        DO 50 I = 1,55
          IGDS(I) = GRD23(I)
 50     CONTINUE
C
      ELSE IF (IGRID.EQ.24) THEN
        DO 60 I = 1,55
          IGDS(I) = GRD24(I)
 60     CONTINUE
C
      ELSE IF (IGRID.EQ.25) THEN
        DO 70 I = 1,37
          IGDS(I) = GRD25(I)
 70     CONTINUE
C
      ELSE IF (IGRID.EQ.26) THEN
        DO 80 I = 1,37
          IGDS(I) = GRD26(I)
 80     CONTINUE
C
      ELSE IF (IGRID.EQ.27) THEN
        DO 90 I = 1,18
          IGDS(I) = GRD27(I)
 90     CONTINUE
C
      ELSE IF (IGRID.EQ.28) THEN
        DO 100 I = 1,18
          IGDS(I) = GRD28(I)
 100    CONTINUE
C
      ELSE IF (IGRID.EQ.29) THEN
        DO 110 I = 1,18
          IGDS(I) = GRD29(I)
 110    CONTINUE
C
      ELSE IF (IGRID.EQ.30) THEN
        DO 120 I = 1,18
          IGDS(I) = GRD30(I)
 120    CONTINUE
C
      ELSE IF (IGRID.EQ.33) THEN
        DO 130 I = 1,18
          IGDS(I) = GRD33(I)
 130     CONTINUE
C
      ELSE IF (IGRID.EQ.34) THEN
        DO 140 I = 1,18
          IGDS(I) = GRD34(I)
 140    CONTINUE
C
      ELSE IF (IGRID.EQ.37) THEN
        DO 141 I = 1,91
          IGDS(I) = GRD37(I)
 141    CONTINUE
C
      ELSE IF (IGRID.EQ.38) THEN
        DO 142 I = 1,91
          IGDS(I) = GRD38(I)
 142    CONTINUE
C
      ELSE IF (IGRID.EQ.39) THEN
        DO 143 I = 1,91
          IGDS(I) = GRD39(I)
 143    CONTINUE
C
      ELSE IF (IGRID.EQ.40) THEN
        DO 144 I = 1,91
          IGDS(I) = GRD40(I)
 144    CONTINUE
C
      ELSE IF (IGRID.EQ.41) THEN
        DO 145 I = 1,91
          IGDS(I) = GRD41(I)
 145    CONTINUE
C
      ELSE IF (IGRID.EQ.42) THEN
        DO 146 I = 1,91
          IGDS(I) = GRD42(I)
 146    CONTINUE
C
      ELSE IF (IGRID.EQ.43) THEN
        DO 147 I = 1,91
          IGDS(I) = GRD43(I)
 147    CONTINUE
C
      ELSE IF (IGRID.EQ.44) THEN
        DO 148 I = 1,91
          IGDS(I) = GRD44(I)
 148    CONTINUE
C
      ELSE IF (IGRID.EQ.45) THEN
        DO 149 I = 1,18
          IGDS(I) = GRD45(I)
 149    CONTINUE
C
      ELSE IF (IGRID.EQ.53) THEN
        DO I = 1,18
          IGDS(I) = GRD53(I)
        END DO
C
      ELSE IF (IGRID.EQ.55) THEN
        DO 152 I = 1,18
          IGDS(I) = GRD55(I)
 152    CONTINUE
C
      ELSE IF (IGRID.EQ.56) THEN
        DO 154 I = 1,18
          IGDS(I) = GRD56(I)
 154    CONTINUE
C
      ELSE IF (IGRID.EQ.61) THEN
        DO 160 I = 1,64
          IGDS(I) = GRD61(I)
 160    CONTINUE
C
      ELSE IF (IGRID.EQ.62) THEN
        DO 170 I = 1,64
          IGDS(I) = GRD62(I)
 170    CONTINUE
C
      ELSE IF (IGRID.EQ.63) THEN
        DO 180 I = 1,64
          IGDS(I) = GRD63(I)
 180    CONTINUE
C
      ELSE IF (IGRID.EQ.64) THEN
        DO 190 I = 1,64
          IGDS(I) = GRD64(I)
 190    CONTINUE
C
      ELSE IF (IGRID.EQ.85) THEN
        DO 192 I = 1,18
          IGDS(I) = GRD85(I)
 192    CONTINUE
C
      ELSE IF (IGRID.EQ.86) THEN
        DO 194 I = 1,18
          IGDS(I) = GRD86(I)
 194    CONTINUE
C
      ELSE IF (IGRID.EQ.87) THEN
        DO 195 I = 1,18
          IGDS(I) = GRD87(I)
 195    CONTINUE
C
      ELSE IF (IGRID.EQ.88) THEN
        DO 2195 I = 1,18
          IGDS(I) = GRD88(I)
2195    CONTINUE
C
      ELSE IF (IGRID.EQ.90) THEN
        DO 196 I = 1,18
          IGDS(I) = GRD90(I)
 196    CONTINUE
C
      ELSE IF (IGRID.EQ.91) THEN
        DO 197 I = 1,18
          IGDS(I) = GRD91(I)
 197    CONTINUE
C
      ELSE IF (IGRID.EQ.92) THEN
        DO 198 I = 1,18
          IGDS(I) = GRD92(I)
 198    CONTINUE
C
      ELSE IF (IGRID.EQ.93) THEN
        DO 199 I = 1,18
          IGDS(I) = GRD93(I)
 199    CONTINUE
C
      ELSE IF (IGRID.EQ.94) THEN
        DO 200 I = 1,18
          IGDS(I) = GRD94(I)
 200    CONTINUE
C
      ELSE IF (IGRID.EQ.95) THEN
        DO 201 I = 1,18
          IGDS(I) = GRD95(I)
 201    CONTINUE
C
      ELSE IF (IGRID.EQ.96) THEN
        DO 202 I = 1,18
          IGDS(I) = GRD96(I)
 202    CONTINUE
C
      ELSE IF (IGRID.EQ.97) THEN
        DO 203 I = 1,18
          IGDS(I) = GRD97(I)
 203    CONTINUE
C
      ELSE IF (IGRID.EQ.98) THEN
        DO 204 I = 1,18
          IGDS(I) = GRD98(I)
 204    CONTINUE
C
      ELSE IF (IGRID.EQ.100) THEN
        DO 205 I = 1,18
          IGDS(I) = GRD100(I)
 205    CONTINUE
C
      ELSE IF (IGRID.EQ.101) THEN
        DO 210 I = 1,18
          IGDS(I) = GRD101(I)
 210    CONTINUE
C
      ELSE IF (IGRID.EQ.103) THEN
        DO 220 I = 1,18
          IGDS(I) = GRD103(I)
 220   CONTINUE
C
      ELSE IF (IGRID.EQ.104) THEN
        DO 230 I = 1,18
          IGDS(I) = GRD104(I)
 230    CONTINUE
C
      ELSE IF (IGRID.EQ.105) THEN
        DO 240 I = 1,18
          IGDS(I) = GRD105(I)
 240    CONTINUE
C
      ELSE IF (IGRID.EQ.106) THEN
        DO 242 I = 1,18
          IGDS(I) = GRD106(I)
 242    CONTINUE
C
      ELSE IF (IGRID.EQ.107) THEN
        DO 244 I = 1,18
          IGDS(I) = GRD107(I)
 244    CONTINUE
C
      ELSE IF (IGRID.EQ.110) THEN
        DO I = 1,18
          IGDS(I) = GRD110(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.120) THEN
        DO I = 1,18
          IGDS(I) = GRD120(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.122) THEN
        DO I = 1,18
          IGDS(I) = GRD122(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.123) THEN
        DO I = 1,18
          IGDS(I) = GRD123(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.124) THEN
        DO I = 1,18
          IGDS(I) = GRD124(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.125) THEN
        DO I = 1,18
          IGDS(I) = GRD125(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.126) THEN
        DO 245 I = 1,18
          IGDS(I) = GRD126(I)
 245    CONTINUE
C
      ELSE IF (IGRID.EQ.127) THEN
        DO I = 1,18
          IGDS(I) = GRD127(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.130) THEN
        DO I = 1,18
          IGDS(I) = GRD130(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.138) THEN
        DO I = 1,18
          IGDS(I) = GRD138(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.145) THEN
        DO I = 1,18
          IGDS(I) = GRD145(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.146) THEN
        DO I = 1,18
          IGDS(I) = GRD146(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.147) THEN
        DO I = 1,18
          IGDS(I) = GRD147(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.148) THEN
        DO I = 1,18
          IGDS(I) = GRD148(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.160) THEN
        DO I = 1,18
          IGDS(I) = GRD160(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.161) THEN
        DO I = 1,18
          IGDS(I) = GRD161(I)
        ENDDO
      ELSE IF (IGRID.EQ.163) THEN
        DO I = 1,18
          IGDS(I) = GRD163(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.170) THEN
        DO I = 1,18
          IGDS(I) = GRD170(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.171) THEN
        DO I = 1,18
          IGDS(I) = GRD171(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.172) THEN
        DO I = 1,18
          IGDS(I) = GRD172(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.173) THEN
        DO I = 1,18
          IGDS(I) = GRD173(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.174) THEN
        DO I = 1,18
          IGDS(I) = GRD174(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.175) THEN
        DO I = 1,18
          IGDS(I) = GRD175(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.176) THEN
        DO I = 1,18
          IGDS(I) = GRD176(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.180) THEN
        DO I = 1,18
          IGDS(I) = GRD180(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.181) THEN
        DO I = 1,18
          IGDS(I) = GRD181(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.182) THEN
        DO I = 1,18
          IGDS(I) = GRD182(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.183) THEN
        DO I = 1,18
          IGDS(I) = GRD183(I)
        ENDDO
C
      ELSE IF (IGRID.EQ.190) THEN
        DO 2190 I = 1,18
          IGDS(I) = GRD190(I)
 2190   CONTINUE
C
      ELSE IF (IGRID.EQ.192) THEN
        DO 2191 I = 1,18
          IGDS(I) = GRD192(I)
 2191   CONTINUE
C
      ELSE IF (IGRID.EQ.194) THEN
        DO 2192 I = 1,18
          IGDS(I) = GRD194(I)
 2192   CONTINUE
C
      ELSE IF (IGRID.EQ.196) THEN
        DO 249 I = 1,18
          IGDS(I) = GRD196(I)
 249    CONTINUE
C
      ELSE IF (IGRID.EQ.198) THEN
        DO 2490 I = 1,18
          IGDS(I) = GRD198(I)
 2490   CONTINUE
C
      ELSE IF (IGRID.EQ.201) THEN
        DO 250 I = 1,18
          IGDS(I) = GRD201(I)
 250    CONTINUE
C
      ELSE IF (IGRID.EQ.202) THEN
        DO 260 I = 1,18
          IGDS(I) = GRD202(I)
 260    CONTINUE
C
      ELSE IF (IGRID.EQ.203) THEN
        DO 270 I = 1,18
          IGDS(I) = GRD203(I)
 270    CONTINUE
C
      ELSE IF (IGRID.EQ.204) THEN
        DO 280 I = 1,18
          IGDS(I) = GRD204(I)
 280    CONTINUE
C
      ELSE IF (IGRID.EQ.205) THEN
        DO 290 I = 1,18
          IGDS(I) = GRD205(I)
 290    CONTINUE
C
      ELSE IF (IGRID.EQ.206) THEN
        DO 300 I = 1,18
          IGDS(I) = GRD206(I)
 300    CONTINUE
C
      ELSE IF (IGRID.EQ.207) THEN
        DO 310 I = 1,18
          IGDS(I) = GRD207(I)
 310    CONTINUE
C
      ELSE IF (IGRID.EQ.208) THEN
        DO 320 I = 1,18
          IGDS(I) = GRD208(I)
 320    CONTINUE
C
      ELSE IF (IGRID.EQ.209) THEN
        DO 330 I = 1,18
          IGDS(I) = GRD209(I)
 330    CONTINUE
C
      ELSE IF (IGRID.EQ.210) THEN
        DO 340 I = 1,18
          IGDS(I) = GRD210(I)
 340    CONTINUE
C
      ELSE IF (IGRID.EQ.211) THEN
        DO 350 I = 1,18
          IGDS(I) = GRD211(I)
 350    CONTINUE
C
      ELSE IF (IGRID.EQ.212) THEN
        DO 360 I = 1,18
          IGDS(I) = GRD212(I)
 360    CONTINUE
C
      ELSE IF (IGRID.EQ.213) THEN
        DO 370 I = 1,18
          IGDS(I) = GRD213(I)
 370    CONTINUE
C
      ELSE IF (IGRID.EQ.214) THEN
        DO 380 I = 1,18
          IGDS(I) = GRD214(I)
 380    CONTINUE
C
      ELSE IF (IGRID.EQ.215) THEN
        DO 390 I = 1,18
          IGDS(I) = GRD215(I)
 390    CONTINUE
C
      ELSE IF (IGRID.EQ.216) THEN
        DO 400 I = 1,18
          IGDS(I) = GRD216(I)
 400    CONTINUE
C
      ELSE IF (IGRID.EQ.217) THEN
        DO 401 I = 1,18
          IGDS(I) = GRD217(I)
 401    CONTINUE
C
      ELSE IF (IGRID.EQ.218) THEN
        DO 410 I = 1,18
          IGDS(I) = GRD218(I)
 410    CONTINUE
C
      ELSE IF (IGRID.EQ.219) THEN
        DO 411 I = 1,18
          IGDS(I) = GRD219(I)
 411    CONTINUE
C
      ELSE IF (IGRID.EQ.220) THEN
        DO 412 I = 1,18
          IGDS(I) = GRD220(I)
 412    CONTINUE
C
      ELSE IF (IGRID.EQ.221) THEN
        DO 413 I = 1,18
          IGDS(I) = GRD221(I)
 413    CONTINUE
C
      ELSE IF (IGRID.EQ.222) THEN
        DO 414 I = 1,18
          IGDS(I) = GRD222(I)
 414    CONTINUE
C
      ELSE IF (IGRID.EQ.223) THEN
        DO 415 I = 1,18
          IGDS(I) = GRD223(I)
 415    CONTINUE
C
      ELSE IF (IGRID.EQ.224) THEN
        DO 416 I = 1,18
          IGDS(I) = GRD224(I)
 416    CONTINUE
C
      ELSE IF (IGRID.EQ.225) THEN
        DO 417 I = 1,18
          IGDS(I) = GRD225(I)
 417    CONTINUE
C
      ELSE IF (IGRID.EQ.226) THEN
        DO 418 I = 1,18
          IGDS(I) = GRD226(I)
 418    CONTINUE
C
      ELSE IF (IGRID.EQ.227) THEN
        DO 419 I = 1,18
          IGDS(I) = GRD227(I)
 419    CONTINUE
C
      ELSE IF (IGRID.EQ.228) THEN
        DO 420 I = 1,18
          IGDS(I) = GRD228(I)
 420    CONTINUE
C
      ELSE IF (IGRID.EQ.229) THEN
        DO 421 I = 1,18
          IGDS(I) = GRD229(I)
 421    CONTINUE
C
      ELSE IF (IGRID.EQ.230) THEN
        DO 422 I = 1,18
          IGDS(I) = GRD230(I)
 422    CONTINUE
C
      ELSE IF (IGRID.EQ.231) THEN
        DO 423 I = 1,18
          IGDS(I) = GRD231(I)
 423    CONTINUE
C
      ELSE IF (IGRID.EQ.232) THEN
        DO 424 I = 1,18
          IGDS(I) = GRD232(I)
 424    CONTINUE
C
      ELSE IF (IGRID.EQ.233) THEN
        DO 425 I = 1,18
          IGDS(I) = GRD233(I)
 425    CONTINUE
C
      ELSE IF (IGRID.EQ.234) THEN
        DO 426 I = 1,18
          IGDS(I) = GRD234(I)
 426    CONTINUE
C
      ELSE IF (IGRID.EQ.235) THEN
        DO 427 I = 1,18
          IGDS(I) = GRD235(I)
 427    CONTINUE
C
      ELSE IF (IGRID.EQ.236) THEN
        DO 428 I = 1,18
          IGDS(I) = GRD236(I)
 428    CONTINUE
C
      ELSE IF (IGRID.EQ.237) THEN
        DO 429 I = 1,18
          IGDS(I) = GRD237(I)
 429    CONTINUE
C
      ELSE IF (IGRID.EQ.238) THEN
        DO I = 1,18
          IGDS(I) = GRD238(I)
        END DO
C
      ELSE IF (IGRID.EQ.239) THEN
        DO I = 1,18
          IGDS(I) = GRD239(I)
        END DO
C
      ELSE IF (IGRID.EQ.240) THEN
        DO I = 1,18
          IGDS(I) = GRD240(I)
        END DO
C
      ELSE IF (IGRID.EQ.241) THEN
        DO 430 I = 1,18
          IGDS(I) = GRD241(I)
 430    CONTINUE
C
      ELSE IF (IGRID.EQ.242) THEN
        DO 431 I = 1,18
          IGDS(I) = GRD242(I)
 431    CONTINUE
C
      ELSE IF (IGRID.EQ.243) THEN
        DO 432 I = 1,18
          IGDS(I) = GRD243(I)
 432    CONTINUE
C
      ELSE IF (IGRID.EQ.244) THEN
        DO I = 1,18
          IGDS(I) = GRD244(I)
        END DO
C
      ELSE IF (IGRID.EQ.245) THEN
        DO 433 I = 1,18
          IGDS(I) = GRD245(I)
 433    CONTINUE
C
      ELSE IF (IGRID.EQ.246) THEN
        DO 434 I = 1,18
          IGDS(I) = GRD246(I)
 434    CONTINUE
C
      ELSE IF (IGRID.EQ.247) THEN
        DO 435 I = 1,18
          IGDS(I) = GRD247(I)
 435    CONTINUE
C
      ELSE IF (IGRID.EQ.248) THEN
        DO 436 I = 1,18
          IGDS(I) = GRD248(I)
 436    CONTINUE
C
      ELSE IF (IGRID.EQ.249) THEN
        DO 437 I = 1,18
          IGDS(I) = GRD249(I)
 437    CONTINUE
C
      ELSE IF (IGRID.EQ.250) THEN
        DO 438 I = 1,18
          IGDS(I) = GRD250(I)
 438    CONTINUE
C
      ELSE IF (IGRID.EQ.251) THEN
        DO 439 I = 1,18
          IGDS(I) = GRD251(I)
 439    CONTINUE
C
      ELSE IF (IGRID.EQ.252) THEN
        DO 440 I = 1,18
          IGDS(I) = GRD252(I)
 440    CONTINUE
      ELSE IF (IGRID.EQ.253) THEN
        DO 441 I = 1,18
          IGDS(I) = GRD253(I)
 441    CONTINUE
      ELSE IF (IGRID.EQ.254) THEN
        DO 442 I = 1,18
          IGDS(I) = GRD254(I)
 442    CONTINUE
C
      ELSE
        IERR = 1
      ENDIF
C
      RETURN
      END