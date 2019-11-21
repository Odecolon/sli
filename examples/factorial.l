def proc main

	def var n 
	def var i
        def var f = 0
        
	out "n = "
	getln n          
	        
	i = "%$n - 1" 
	 
	f = $n
	
	loop
	
		f = "%$f * $i"
		i = "%$i - 1"
		
		if $i = 0 then
		
			break
			
		end if
	        		
	end loop
	
	out "f = "
	outln $f   

end def
