for $ph in .//photoset/photo
return concat("{ name='",data($ph/@title),"' ; _url='http://farm",$ph/@farm,".static.flickr.com/",$ph/@server,"/",$ph/@id,"_",$ph/@secret,".jpg' ; id='",$ph/@id,"' ; date='",$ph/@datetaken,"' ;}") 
