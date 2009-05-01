for $size in .//sizes/size
return if ($size/@label="Medium")
	   then concat("{ width='",data($size/@width),"' ; height='",data($size/@height),"' ; url='",data($size/@source),"' ;}")
	   else () 