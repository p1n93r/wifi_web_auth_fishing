<?php

/**
 * getClientMac
 * Gets the mac address of a client by the IP address
 * Returns the mac address as a string
 * @param $clientIP : The clients IP address
 * @return string
 */
function getClientMac($clientIP)
{
    return trim(exec("grep " . escapeshellarg($clientIP) . " /var/lib/misc/dnsmasq.leases | awk '{print $2}'"));
}

/**
 * getClientHostName
 * Gets the host name of the connected client by the IP address
 * Returns the host name as a string
 * @param $clientIP : The clients IP address
 * @return string
 */
function getClientHostName($clientIP)
{
    return trim(exec("grep " . escapeshellarg($clientIP) . " /var/lib/misc/dnsmasq.leases | awk '{print $4}'"));
}