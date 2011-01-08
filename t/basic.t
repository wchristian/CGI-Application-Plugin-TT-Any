use strict;
use warnings;

package basic_test;

use Test::More tests => 6;

BEGIN {
    chdir '..' if -d '../t';
    use lib './lib';
}

BEGIN { require_ok('CGI::Application::Plugin::TT::Any') };

$ENV{CGI_APP_RETURN_ONLY} = 1;

use CGI;
use lib 't/lib';
use TestAppBasic;
my $t1_obj = TestAppBasic->new();
my $t1_output = $t1_obj->run();

like($t1_output, qr/template param\./, 'template parameter');
like($t1_output, qr/template param hash\./, 'template parameter hash');
like($t1_output, qr/template param hashref\./, 'template parameter hashref');
like($t1_output, qr/pre_process param\./, 'pre process parameter');
like($t1_output, qr/post_process param\./, 'post process parameter');

