use strict;
use warnings;

package CGI::Application::Plugin::TT::Any;

# ABSTRACT: load CGI::Application::Plugin::TT with any TT-compatible class

=head1 SYNOPSIS

    use strict;
    use warnings;

    package MyCGIApp;

    use base qw(CGI::Application);
    use CGI::Application::Plugin::TT;
    use CGI::Application::Plugin::TT::Any;

    sub setup {
        my ( $self ) = @_;
        $self->tt_config(
            TEMPLATE_OPTIONS => {
                CLASS => 'Template::AutoFilter',
                INCLUDE_PATH => 't',
            },
        );
    }

    sub myrunmode {
        my ( $self ) = @_;
        my %params = ( email => 'email@company.com' );
        return $self->tt_process( 'template.tmpl', \%params );
    }

Alternatively:

    use strict;
    use warnings;

    package MyCGIApp;

    use base qw(CGI::Application);
    use CGI::Application::Plugin::TT;

    use CGI::Application::Plugin::TT::Any (
        TEMPLATE_OPTIONS => {
            CLASS => 'Template::AutoFilter',
            INCLUDE_PATH => 't',
        },
    );

    sub myrunmode {
        my ( $self ) = @_;
        my %params = ( email => 'email@company.com' );
        return $self->tt_process( 'template.tmpl', \%params );
    }

=head1 METHODS

=head2 tt_obj

Overrides L<CGI::Application::Plugin::TT>'s tt_obj() with a version that
inspects the CLASS field of the TEMPLATE_OPTIONS hashref in the options
and, if set, loads the Template object using that class. Otherwise it
defaults to Template.

=cut

use Class::Load 'load_class';
use Carp;

require CGI::Application::Plugin::TT;

sub import {
    my $pkg = shift;
    my $callpkg = caller;
    {
        no warnings 'redefine';
        no strict 'refs';
        for (qw( tt_obj )) {
            my %target = %{"$callpkg\::"};
            die "CGI::Application::Plugin::TT needs to be loaded first" if !$target{$_};
            *{"$callpkg\::$_"} = \&{$_};
        }
    }
    return if !@_;
    return $callpkg->tt_config( @_ );
}

sub tt_obj {
    my $self = shift;

    my ($tt, $options, $frompkg) = CGI::Application::Plugin::TT::_get_object_or_options($self);

    return $tt if $tt;

    my $tt_options = $options->{TEMPLATE_OPTIONS} || {};
    my $class = delete $tt_options->{CLASS} || 'Template';
    load_class $class;

    $tt = $class->new( $tt_options ) || carp "Can't load Template";

    CGI::Application::Plugin::TT::_set_object( $frompkg||$self, $tt );

    return $tt;
}

1;
