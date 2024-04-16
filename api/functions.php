<?php

//check availability of paramters
function checkAvailability($params)
{
    foreach ($params as $param) {
        if (!isset($_REQUEST[$param]) || empty($_REQUEST[$param])) {
            return false;
        }
    }

    return true;
}
