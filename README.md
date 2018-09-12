# get-whoisip

<#
.SYNOPSIS<br>
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.DESCRIPTION<br>
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.PARAMETER IP<br>
    Provide an IPv4 address to lookup
 
 .EXAMPLE<br>
    APNIC   = get-whoisIP 203.2.218.208<br>
    AFRINIC = get-whoisIP 105.1.1.1<br>
    LACNIC  = get-whoisIP 200.40.119.162<br>

.NOTES<br>
    Author:  kevinm@wlkmmas.org

#>

Two different versions of the command
    <li>get-whoisip.ps1 uses a pile or write-hosts to output the data in a pretty format
    <li>get-whoisipObject.ps1 creates objects for each request and outputs the object vs the write-hosts
