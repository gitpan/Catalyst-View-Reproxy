#!perl -T

use strict;
use warnings;

use lib qw(t/lib);

use FindBin;
use Test::More;

eval { use LWP::Simple; };
plan(skip_all => 'LWP::Simple required') if ($@);

eval { use Catalyst::View::Reproxy::Test::HTTP::Server; };
plan $@ ? (skip_all => 'HTTP::Server::Simple, HTTP::Server::Simple::Static required') : (tests => 5);

ok (my $server = Catalyst::View::Reproxy::Test::HTTP::Server->new({port => 3500, docroot => $FindBin::Bin}), 'create http server instance');

my $pid;
if ($pid = fork) {
		ok($pid, 'create child process');
		sleep 1;

		ok(get("http://localhost:$ENV{TEST_HTTPD_PORT}/DUMMY"), 'Get DUMMY data');
		ok(get("http://localhost:$ENV{TEST_HTTPD_PORT}/DUMMY1"), 'Get DUMMY1 data');
		ok(get("http://localhost:$ENV{TEST_HTTPD_PORT}/DUMMY2"), 'Get DUMMY2 data');

		kill HUP => $pid;
}
else {
		defined $pid or die;
		$server->run;
}




