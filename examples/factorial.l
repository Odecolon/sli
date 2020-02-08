def proc main

	def var n 
        def var f = 0
        
	out "n = "
	getln n          
	        
	n = "% $n + 1" 
	 
	f = 1          
	
	loop
	        
		if $n = 1 then
		      
			break
		
		end if       
		
		n = "% $n - 1"
		f = "% $f * $n"		
	
	end loop
	
	out "f = "
	outln $f   

end def
