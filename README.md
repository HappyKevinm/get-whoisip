# get-whoisip

<#
.SYNOPSIS
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.DESCRIPTION
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.PARAMETER IP
    Provide an IPv4 address to lookup
 
 .EXAMPLE
    APNIC   = get-whoisIP 203.2.218.208
    AFRINIC = get-whoisIP 105.1.1.1
    LACNIC  = get-whoisIP 200.40.119.162

.NOTES
    Author:  kemi (Exodops)
    Add note to line 79 of whatsthisip to advertise this command
#>
