#!/usr/bin/perl -w
use IPC::SysV;
use CGI;

my $cgi = new CGI;
print $cgi->start_html();

$handle = $cgi->param("handle");
shmread($handle, $data, 0, 10);

if($data =~ /[0-9]/) {
    print $data;
} else {

    shmread($handle, $data, 0, 1000000);
    shmctl($handle, IPC_REMOVE, 0);

    if($data =~ /###([^#]+)###/) {
	print $1;
    }
}

print $cgi->end_html();
