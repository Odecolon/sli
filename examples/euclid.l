def var n
def var m
def var gcd

def proc main
	
	out "n = "
	get n
	
	out "m = "
	get m
	
	do gcd_euclid

	out " " ln
	out "gcd = " @ $gcd ln
	
end def

def proc gcd_euclid

	gcd = 1

	loop
	
		if $n == $m	then break
		if $n > $m	then n = $n - $m	
		if $m > $n	then m = $m - $n
		
	end loop
	
	gcd = $n

end def