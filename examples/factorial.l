def var n 
def var f

def proc main

	out "n = "
	get n
	
	do factorial

	out "f = "
	out $f ln
	
end def

def proc factorial

	f = 1

	loop
		
		if $n == 0 then break
		
		f = $f * $n
		n = $n - 1
		
	end loop

end def

