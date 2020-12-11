def var name
def var food   = 500
def var people = 100
def var year   = 550 
def var order

def proc main

	out "Hamurabi L (input 'q' to exit)" ln
	out " " ln
	out "Your name, master: "

	get name
	
	loop
		
		if $year == 560 then break
		
		out " " ln
		out "Hello, master " @ $name @ "!" ln
		out "Now is " @ $year @ " of our empire." ln
		out " " ln
		out "We have " @ $people @ " citizens!" ln
		out "We have " @ $food @ " seeds in granarys!" ln
		
		if $food > 0 then 
			
			out " " ln
			out "How many seeds we shall seed? (or 'w' for wait) - "
			get order
			
			if $order == "q" then return
			if $order == "w" then continue
			if $order > $food then continue
		
			food = $food - $order
			food = $food - $people * 4
			 
			if ($food < 0) | ($food == 0) then people = $people / 2
			
			food = $food + $order * 5 
			
			people = ($people * 8) / 5
			
		end if
		
		if $food <= 0 then
		
			food = 0
			people = $people / 2
			
			out " "	ln		
			out "We have no food. Our people is starvating!" ln
			out " " ln
			out "Press [enter]..."
			get order
				
		end if	
		
		out $people ln
		
		if $people <= 0 then
		
			out " " ln
			out "=================" ln
			out " " ln
			out "Game over, man, it's game over!" ln
			
			return
		
		end if
		
		year = $year + 1
		order = " "
				
	end loop
	
	out " " ln
	out "=====================================================" ln
	out " " ln
	out "You win, becouse your empire was alive over 10 years!" ln
	
end def