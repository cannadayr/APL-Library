#! /usr/local/bin/apl --script
 ⍝ ********************************************************************
 ⍝   $Id: $
 ⍝ $desc: Routine to import arrays from text files $
 ⍝ ********************************************************************
⍝ Copyright (C) 2018 Bill Daly

⍝ This program is free software: you can redistribute it and/or modify
⍝ it under the terms of the GNU General Public License as published by
⍝ the Free Software Foundation, either version 3 of the License, or
⍝ (at your option) any later version.

⍝ This program is distributed in the hope that it will be useful,
⍝ but WITHOUT ANY WARRANTY; without even the implied warranty of
⍝ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
⍝ GNU General Public License for more details.

⍝ You should have received a copy of the GNU General Public License
⍝ along with this program.  If not, see <http://www.gnu.org/licenses/>.


)copy 5 FILE_IO
)copy 1 utl
)copy 1 lex

∇array←config import∆file fname;txt;lines
  ⍝ Base function to read a text file and return an array based on
  ⍝ that file. Config is a optional lexicon describing how the file is
  ⍝ organized.
  →(2 = ⎕nc 'config')/go1
  config←lex∆init
go1:
  ⎕es (utl∆numberp txt←FIO∆read_file fname)/'ERROR READING ',fname
  →(config lex∆haskey 'file_type')/dispatch
guess:
  lines←+/txt=⎕tc[3]
  →(import∆delimThreshold>(+/txt=⎕av[10])÷lines)/guess2
  config←config lex∆assign 'file_type' 'tab'
  →dispatch
guess2:
  →(import∆delimThreshold>(+/txt=',')÷lines)/ohNo
  config←config lex∆assign 'file_type' 'comma'
  →dispatch
dispatch:
  ⍎(∧/'tab'=3↑config lex∆lookup 'file_type')/'array←import∆file∆tab txt◊→go2'
  ⍎(∧/'comma'=5↑config lex∆lookup 'file_type')/'array←import∆file∆comma txt◊→go2'
go2:
  array←utl∆convertStringToNumber ¨ ⊃array
  →0
ohNo:
  ⎕es fname,' IS NOT A DELIMITED FILE'
∇
 

∇array←import∆file∆tab txt;dcount
  ⍝ Function converts the text in filea fname to an vector of vectors
  ⍝ using delimiters line feed and tab (⎕av[11 10])
  dcount←+/⎕av[11]=txt
  →((.05×dcount)<dcount-+/⎕av[14]=txt)/nolf
  txt←(txt≠⎕av[14])/txt
nolf:
  txt←(-⎕av[11]=¯1↑txt)↓txt
  array←⎕av[10] utl∆split_with_quotes ¨ ⎕av[11] utl∆split txt
∇

∇array←import∆file∆comma txt;dcount
    ⍝ Function converts the text in filea fname to an vector of vectors
  ⍝ using delimiters line feed and comma
  dcount←+/⎕av[11]=txt
  →((.05×dcount)<dcount-+/⎕av[14]=txt)/nolf
  txt←(txt≠⎕av[14])/txt
nolf:
  txt←(-⎕AV[11]=¯1↑txt)↓txt
  array←',' utl∆split_with_quotes ¨ ⎕av[11] utl∆split txt
∇

∇new←import∆table array;nos;cols
  ⍝ function finds the table in an array generated by import∆file.  It
  ⍝ removes blank columns and rows at the begining and end of the file
  ⍝ which lack data.
  nos←utl∆numberp ¨ array
  cols←(0<+⌿nos)/⍳1↓⍴nos
  nos←∨/nos
  nos←~(∧\~nos)∨⌽∧\⌽~nos
  new←nos⌿array
  new←cols import∆table∆cols new
∇

∇new←cols import∆table∆cols array;c;b
  ⍝ Function inserts zeros into numeric columns of array
  ⍎(0=⍴cols)/'new←array ◊ →0'
  new←(1↓cols) import∆table∆cols array
  c←''⍴cols
  b←utl∆numberp ¨ new[;c]
  new[;c]←b\b/new[;c]
∇

∇fname import∆table∆save array;shape;ix;fh
  ⍝ Function writes array to file fname as a tab delimited array.
  →(scalar,vector,matrix)[1+⍴shape←⍴array]
scalar:
  array←(⍕array),⎕av[11]
  →write
vector:
  array[ix]←⍕¨array[ix←(utl∆numberp array)/⍳⍴array]
  array←(⎕av[10] utl∆join array),⎕av[11]
  →write
matrix:
  array←,array
  array[ix]←⍕¨array[ix←(utl∆numberp array)/⍳⍴array]
  array←⎕av[10] utl∆join ¨ ⊂[2]shape⍴array
  array←⎕av[11] utl∆join array
write:
  fh←'w' FIO∆fopen fname
  (⎕ucs array) FIO∆fwrite fh
  FIO∆fclose fh
∇
  
∇Z←import⍙metadata
  Z←0 2⍴⍬
  Z←Z⍪'Author'          'Bill Daly'
  Z←Z⍪'BugEmail'        'bugs@dalywebandedit.com'
  Z←Z⍪'Documentation'   'import.txt'
  Z←Z⍪'Download'        'https://sourceforge.net/p/apl-library/code/ci/master/tree/import.apl'
  Z←Z⍪'License'         'GPL v3.0'
  Z←Z⍪'Portability'     'L2'
  Z←Z⍪'Provides'        ''
  Z←Z⍪'Requires'        'lex, util, FILE_IO'
  Z←Z⍪'Version'                  '0 1 2'
  Z←Z⍪'Last update'         '2019-02-11'
∇


⍝ Threshold for ratio of a delimiter to text
import∆delimThreshold←1		⍝ per line of text