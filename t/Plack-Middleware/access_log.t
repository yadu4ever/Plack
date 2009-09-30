use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use Plack::Test;
use Plack::Middleware qw(AccessLog);
use Plack::Builder;

my $log;
my $handler = builder {
    enable Plack::Middleware::AccessLog
        logger => sub { $log .= "@_" }, format => "%{Host}i %{Content-Type}o";
    sub { [ 200, [ 'Content-Type' => 'text/plain' ], [ 'OK' ] ] };
};

my $test_req = sub {
    my $req = shift;
    test_psgi app => $handler,
        client => sub {
        my $cb = shift;
        $cb->($req);
    };
};

{
    $test_req->(GET "http://localhost/");
    chomp $log;
    is $log, 'localhost:80 text/plain';
}

done_testing;