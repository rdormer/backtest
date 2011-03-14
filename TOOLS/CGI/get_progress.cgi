#!/usr/bin/perl -w
use IPC::SysV;
use CGI;

my $cgi = new CGI;
print $cgi->header();

$handle = $cgi->param("handle");
shmread($handle, $data, 0, 3);

if($data eq "###") {

    shmread($handle, $data, 0, 1000000);
    shmctl($handle, IPC_REMOVE, 0);

    if($data =~ /###([^#]+)###/) {
	print $1;
    }

} else {
    
    shmread($handle, $data, 0, 500);

    if($data =~ /(.+)===/) {
	print $1;
    } else {
	print "<img src='/images/ajax-loader.gif' />";
    }
}
