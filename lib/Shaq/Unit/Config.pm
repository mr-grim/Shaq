package Shaq::Unit::Config;
use strict;
use warnings;
use base 'Class::Singleton';
use Cwd;
use Path::Class::Dir;
use Path::Class::File;
use Config::Multi;

our $FILES;

sub _new_instance {
    my ( $class, %arg ) = @_;

    my $conf_dir  = $arg{conf_dir}  || path_to('conf')->stringify;
    my $app_name  = $arg{app_name}  || 'myapp';
    my $extension = $arg{extension} || 'yml';

    my $cm = Config::Multi->new({
        dir         => $conf_dir,
        app_name    => $app_name,
        extension   => $extension,
    });

    my $config = $cm->load();
    $FILES = $cm->files;
    return $config;
}

sub files { return $FILES; }

#sub home { Path::Class::Dir->new( $Bin, '..' ); }
sub home { Path::Class::Dir->new(  getcwd()  ); }

sub path_to {
    my ( @path ) = @_;
    my $path = Path::Class::Dir->new( &home , @path );

    if ( -d $path ) { return $path }
    else { return Path::Class::File->new( &home, @path ) }
}

1;

=head1 NAME

Shaq::Unit::Config - Config Unit

=head1 METHODS

=head2 _new_instance

=head2 files

=head2 home

=head2 path_to

=head2 SEE ALSO

http://perl-mongers.org/2008/08/catalystconfig.html

=cut


