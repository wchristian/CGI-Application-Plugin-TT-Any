package TestAppBasic;

use strict;

use base qw(TestAppBase);

sub test_mode {
    my $self = shift;

    $self->tt_params(template_param_hash => 'template param hash.');
    $self->tt_params({template_param_hashref => 'template param hashref.'});


    my $tt_vars = {
                    template_var => 'template param.'
    };

    return $self->tt_process(\*DATA, $tt_vars);
}

sub tt_pre_process {
    my $self = shift;
    my $file = shift;
    my $vars = shift;

    $vars->{pre_process_var} = 'pre_process param.';
}

sub tt_post_process {
    my $self    = shift;
    my $htmlref = shift;

    $$htmlref =~ s/post_process_var/post_process param./;
}

1;

# The test template file is below in the DATA segment

__DATA__

[% template_var %]
[% template_param_hash %]
[% template_param_hashref %]

[% pre_process_var %]

post_process_var

