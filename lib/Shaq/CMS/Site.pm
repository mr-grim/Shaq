package Shaq::CMS::Site;
use Any::Moose;
#use MouseX::AttributeHelpers;
#use MouseX::Types::Path::Class;
use FindBin qw($Bin);
use Path::Class qw/dir file/;
#use Template;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has archives  => ( 
    metaclass => 'Collection::Array',
    is => 'rw', 
    isa => 'ArrayRef[Shaq::CMS::Archives]', 
    default => sub {[]},
    provides => {
        push => 'add_archives',
    },
);

has menus   => ( 
    metaclass => 'Collection::Array',
    is => 'rw', 
    isa => 'ArrayRef[Shaq::CMS::Menu]', 
    default => sub {[]},
    provides => {
        push => 'add_menus',
    },
);

__PACKAGE__->meta->make_immutable;

no Any::Moose;

sub pages {
    my ($self) = @_;

    map { { name => $self->name, menus => $self->menus, archive => $_, } }
      @{ $self->archives };
}

sub backup {
    my ( $self ) = @_;

    my $zip = Archive::Zip->new;
    my $dt  = DateTime->now( time_zone => 'local' );

    my $backup_file = "backup" . "_" . $dt->ymd('') . ".zip";

    $zip->addTree( $self->root_dir->stringify, 'backup' );
    $zip->writeToFileNamed( file( $self->backup_dir, $backup_file )->stringify );
}

sub upload {
    my ( $self, $config ) = @_;
    
    my $hostname = $self->{ftp}->{hostname};
    my $username = $self->{ftp}->{username};
    my $password = $self->{ftp}->{password};

    my $local_dir  = $self->root_dir;
    my $upload_dir = $self->upload_dir;

    my $ftp = Net::FTP->new( $hostname, Debug => 0)
      or die "Cannot connect to some.host.name: $@";

    $ftp->login($username, $password)
      or die "Cannot login ", $ftp->message;

    $ftp->cwd( "/" )
      or die "Cannot change working directory ", $ftp->message;

    $ftp->mkdir($upload_dir->dir_list( -1 ), 1)
      or die "mkdir failed ", $ftp->message;

    $ftp->cwd($upload_dir->dir_list( -1 ))
      or die "Cannot change working directory ", $ftp->message;


    for my $child ( $local_dir->children ) {
        warn $child->basename;
        $ftp->put( $child->stringify, $child->basename );
    }

    $ftp->quit;
  
}

=cut

1;

=head1 NAME

CMS::Lite::Site - framework class

=head1 DESCRIPTION

この雛型に情報を流しこむとサイトが完成します

=head1 METHODS

=head2 write

=head2 backup

=head2 upload

=cut



