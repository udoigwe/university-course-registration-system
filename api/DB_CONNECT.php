<?php
date_default_timezone_set("Africa/Lagos");

const DB_HOST = "localhost";
const DB_USER = "root";
const DB_PASS = "";
const DB_NAME = "ucrs";

//connect to database
$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

//check connection
if ($mysqli->connect_errno) {
    exit();
}
