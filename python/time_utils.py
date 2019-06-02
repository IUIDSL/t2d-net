#!/usr/bin/env python
'''
	Time related utils 
'''

#############################################################################
def NiceTime(secs):
  """ Express time in human readable format. """
  s=int(secs)
  if s<60: return '%ds'%s
  m,s = divmod(s,60)
  if m<60: return '%dm:%02ds'%(m,s)
  h,m = divmod(m,60)
  if h<24: return '%dh:%02dm:%02ds'%(h,m,s)
  d,h = divmod(h,24)
  return '%dd:%02dh:%02dm:%02ds'%(d,h,m,s)
