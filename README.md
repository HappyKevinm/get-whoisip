# get-whoisip

<#
.SYNOPSIS<br>
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.DESCRIPTION<br>
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.PARAMETER IP<br>
    Provide an IPv4 address to lookup
 
 .EXAMPLE<br>
    APNIC   = get-whoisIP 203.2.218.208
    AFRINIC = get-whoisIP 105.1.1.1
    LACNIC  = get-whoisIP 200.40.119.162

.NOTES<br>
    Author:  kemi (Exodops)
    Add note to line 79 of whatsthisip to advertise this command
#>
