!****************************************************************************
! Purpose:      ZPL macro based on the Code V @JMRCC macro function, which is
!               useful for creating clearance/interference constraints
!               when optimizing off-axis reflective systems such as TMAs
!
! Syntax:       in DEFINE_JMRCC
!
! Execution: 	ZPLM 1 0
!
!				To call macro from the merit function, use operand ZPLM. Make sure
!				macro filename is "ZPL01.ZPL" or similar such that a two digit number
!				is used to represent the macro #. Then you can define the Mac# in the
!				merit function properly. The data value is 0 to output ypt_wrt_ray.
!
! Author:       Alex Hedglen     Date: 11-30-2020
!
! History:      11-30-2020 AH     Originally conceived
!               
!*****************************************************************************
! Similar to algorithm described in J. Michael Rodgers paper:
! "Control of Packaging Constraints in the Optimization of Unobscured Reflective Systems,"
! SPIE, Vol. 751, p. 143. (1987)
!
! Return value is signed distance from point B to line A,
! measured perpendicular to line.
! (Rodgers uses delta y only, isn't perpendicular to line).
! Concept: transform to (z',y') coordinates where "line" is the z' axis.
! No global coordinate surface need be specified.
!
! Inputs:
! 
!		FA - Field # for "Line A" (usually max field #3)
!		SA - Surface # for "Line A" (secondary mirror)
!		
!		FB - Field # for "Point B" (usually mid field #2)
!		SB - Surface # for "Point B" (primary mirror)
!
!		FC - (optional) field # for additional reference ray. 
!			 If non-zero, "the Point" is the intersection of two lines B & C 
!			 leaving the same surface SB, otherwise "the Point" is the
!			 intercept of marginal ray from field FB, on surface SB.
!
! Outputs:
!
!		ypt_wrt_ray - signed distance from point B to line A
!
! 
!
!
! The "Line A" is the ray LEAVING point A on the indicated surface.
! Only works when ray is in air, due to optical direction cosines.
! Distance is positive when point is above line and ray ("line")
! goes left to right. Sign does depend on ray direction.
!*****************************************************************************

! Define field and surface numbers for "line A" and "point B"
FA = 3
SA = 6
FB = 2
SB = 3

! (optional) define field # for additional reference ray
FC = 0

! Get # of field points and max field point
nfield = NFLD() 
maxfield = MAXF() 

! Trace marginal ray for field B to find Z and Y coordinates for "point B"
hx = FLDX(FB)/maxfield
hy = FLDY(FB)/maxfield
px = 0
py = -1
RAYTRACE hx,hy,px,py,PWAV()
zb = RAYZ(SB)
yb = RAYY(SB)

! Trace marginal ray for field A to find Z and Y coordinates for "line A" 
! 	and M and N direction cosines for "line A"
hx = FLDX(FA)/maxfield
hy = FLDY(FA)/maxfield
px = 0
py = -1
RAYTRACE hx,hy,px,py,PWAV()
za = RAYZ(SA)
ya = RAYY(SA)
cost = RAYN(SA)
sint = RAYM(SA)

IF FC != 0
	
	hx = FLDX(FB)/maxfield
	hy = FLDY(FB)/maxfield
	px = 0
	py = -1
	RAYTRACE hx,hy,px,py,PWAV()
	mb = RAYM(SB)
	nb = RAYN(SB)
	
	hx = FLDX(FC)/maxfield
	hy = FLDY(FC)/maxfield
	px = 0
	py = -1
	RAYTRACE hx,hy,px,py,PWAV()
	mc = RAYM(SB)
	nc = RAYN(SB)
	zc = RAYZ(SB)
	yc = RAYY(SB)
	
	zbc = (nb*nc*(yc-yb)+zb*mb*nc-zc*mc*nb)/(mb*nc-mc*nc)
	ybc = yb+(zbc-zb)*mb/nb
	ypt_wrt_ray = cost*(ybc-ya)-sint*(zbc-za)
	
ELSE

	ypt_wrt_ray = cost*(yb-ya)-sint*(zb-za)
	
ENDIF

OPTRETURN 0, ypt_wrt_ray
