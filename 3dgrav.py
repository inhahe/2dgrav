#!/usr/bin/env python
#need correction if objects get too close

#sometimes larger objects are attracted to smaller objects more than vice versa
#uniting should position to center of mass
#should multithread
#change bounce to be accurate
#change bounce to use radius
#how does an object rotate once around another and then leave?
#speed coefficient doesn't work right

from __future__ import division

import pygame
from random import *
from math import *

w, h = 1000, 1000
cfps = None #compute at most this many frames per second, None=unlimited
dfps = 60   #show at most this many frames per second, None=show every time a frame is computed
cs = 50     

os = int(w*h/cs/cs)
os = 17      #number of objects

bsize = 1000 #size of bounding box (None=disable)
ds = 3       #number of dimensions
exp = 2      #exponent of gravity attenuation (logically ds-1, but lower values might be more entertaining)
g = 1000     #force per mass (at a distance of 1 pixel)
mmu = 10    #avg mass
msigma = 40   #breadth of the mass curve
vsigma = 500  #breadth of the velocity curve, note that out of laziness higher ds will make total velocity faster for the same vsigma
speed = .001  #speed of the simulation (more speed = fewer in-between frames computed)
density = .1 #mass per volume of objects (unit = 1 pixel^3), note that diameter increases only with the ds'th root of volume

#g, mmu, speed, and vsigma aren't completely orthogonal.

class Object:
  def __init__(self, **kwargs):
    self.__dict__.update(kwargs)

def init():
#  seed(1000)
  global objects
  objects = []
  for i in xrange(os):
    object = Object()
    while 1:
      m = gauss(mmu, msigma)
      if m > 0: break
    object.m = m
    object.ps = [random()*bsize for _ in xrange(ds)]
    object.vs=[gauss(0, vsigma)*speed for _ in xrange(ds)]
    #object.vs[-1] = 0 #debug
    #object.ps[-1] = 500 #debug
    object.i = i
    object.r = ((object.m/density)*3/4)**(1/3)
    object._mg = object.m*g*speed
    objects += [object]
  
def oneframe():
  for object in objects:
    ps = object.ps
    vs = object.vs
    for d in xrange(ds):
      np = ps[d]+vs[d]
      if bsize and not 0 <= np <= bsize:
        vs[d] *= -1                         # this isn't exactly a perfect bounce.
                                            # also, should bounce when side of object meets edge
      else:
        ps[d] = np
    for object2 in objects:
      if object2 != object:
        ps2 = object2.ps
        d = sqrt(sum(((p2-p1)**2 for p1, p2 in zip(ps, ps2))))
        if d < object2.r+object.r:  # change position to center of mass
          #vs = [(v*object.m+v2*object2.m)/(object.m+object2.m) for v, v2 in zip(object.vs, object2.vs)] 
          #object.m += object2.m
          #object.r = ((object.m/density)*3/4)**(1/3)
          #object._mg = object.m*g*speed
          #objects.remove(object2)
          
          #take the average momentum and each object reflects off of it in the vector that's colinear with their centers of mass.  orthogonal vectors remain unchanged.
          
                    
          
          
          break
        f = object2._mg/d**exp 
        vs = [v+(p2-p1)/d*f for v, p1, p2 in zip(vs, ps, ps2)]
    object.vs = vs    

def updatescr():
  scr.fill((0,0,0))
  for object in objects:
    #pygame.draw.circle(scr, (0, 255,0), object.ps[:2], object.r)
    #rh = object.ps[2]*rhsf
    #pygame.draw.circle(scr, (255,0,0), object.ps[:2], rh, 1 if rh >= 1 else 0)
    ps2s = object.ps[2]/bsize*255
    pygame.draw.circle(scr, (ps2s, 0,255-ps2s), object.ps[:2], object.r)
  pygame.display.flip()

pygame.init()
scr = pygame.display.set_mode((bsize, bsize), pygame.DOUBLEBUF)

init()

if cfps:
  pygame.time.set_timer(pygame.USEREVENT+1, int(1000/cfps))
if dfps:
  pygame.time.set_timer(pygame.USEREVENT+2, int(1000/dfps))

while 1:
  for event in pygame.event.get():
    if (not cfps) or event.type == pygame.USEREVENT+1:
      oneframe()
      if not dfps:
        updatescr()
    if event.type == pygame.USEREVENT+2:
      updatescr()
    if event.type == pygame.QUIT:
      break


