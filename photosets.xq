for $ps in .//photosets/photoset
return concat("{ title='",data($ps/title),"' ; id=",data($ps/@id)," ; }") 