#!/usr/bin/python2.2
"""HTML Diff: http://www.aaronsw.com/2002/diff
Rough code, badly documented. Send me comments and patches."""

__author__ = 'Aaron Swartz <me@aaronsw.com>'
__copyright__ = '(C) 2003 Aaron Swartz. GNU GPL 2.'
__version__ = '0.22'

import difflib, string

def isTag(x): return x[0] == "<" and x[-1] == ">"

def textDiff(a, b):
	"""Takes in strings a and b and returns a human-readable HTML diff."""

	out = []
	a, b = html2list(a), html2list(b)
	s = difflib.SequenceMatcher(None, a, b)
	for e in s.get_opcodes():
		if e[0] == "replace":
			# @@ need to do something more complicated here
			# call textDiff but not for html, but for some html... ugh
			# gonna cop-out for now
			out.append(list2html(a[e[1]:e[2]],'<del class="diffmod">','</del>') + list2html(b[e[3]:e[4]],'<ins class="diffmod">','</ins>'))
		elif e[0] == "delete":
			out.append(list2html(a[e[1]:e[2]],'<del class="diffmod">','</del>'))
		elif e[0] == "insert":
			out.append(list2html(b[e[3]:e[4]],'<ins class="diffins">','</ins>'))
		elif e[0] == "equal":
			out.append(list2html(b[e[3]:e[4]],'',''))
		else: 
			raise "Um, something's broken. I didn't expect a '" + `e[0]` + "'."
	return ''.join(out)

def list2html(l, start_tag, end_tag):
  """takes list l (of text and html tags) and turns it into a string,
  wrapping all of the text blocks in the tags given by start_tag and end_tag"""
  mode = 'tag'
  out = ''
  for x in l:
    if x[0] == '<':
      if mode == 'char':
        out += end_tag
        mode = 'tag'
      out += x
    else:
      if mode == 'tag':
        out += start_tag
        mode = 'char'
      out += x
  if mode == 'char':
    out += end_tag
  return out

def html2list(x, b=0):
	mode = 'char'
	cur = ''
	out = []
	for c in x:
		if mode == 'tag':
			if c == '>': 
				if b: cur += ']'
				else: cur += c
				out.append(cur); cur = ''; mode = 'char'
			else: cur += c
		elif mode == 'char':
			if c == '<': 
				out.append(cur)
				if b: cur = '['
				else: cur = c
				mode = 'tag'
			elif c in string.whitespace: out.append(cur+c); cur = ''
			else: cur += c
	out.append(cur)
	return filter(lambda x: x is not '', out)

if __name__ == '__main__':
	import sys
	try:
		a, b = sys.argv[1:3]
	except ValueError:
		print "htmldiff: highlight the differences between two html files"
		print "usage: " + sys.argv[0] + " a b"
		sys.exit(1)
	print textDiff(open(a).read(), open(b).read())
	
