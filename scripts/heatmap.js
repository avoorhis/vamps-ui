function open_pies(ds1,ds2)
{
    alert('in pie '+ds1+' -- '+ds2)
}

//pads left
String.prototype.lpad = function(padString, length) {
	var str = this;
	//alert(str.length+'-'+length)
    while (str.length < length){
        str = padString + str;
        //alert(str)
    }
    return str;
}

//pads right
String.prototype.rpad = function(padString, length) {
	var str = this;
	//alert(str.length+'-'+length)
    while (str.length < length){
        str = str + padString;
        //alert(str)
    }
    return str;
}