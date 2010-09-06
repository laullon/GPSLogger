for $result in .//GeocodeResponse/result
return if ($result/type="political")
	   then data($result/formatted_address)
	   else () 