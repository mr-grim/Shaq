package Shaq::CMS::Manager;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Class qw/dir file/;
use Archive::Zip;
use DateTime;
use Shaq::CMS::Site;
use Shaq::CMS::Category;
use Shaq::CMS::Menu;

sub new {
    my ( $class, %arg ) = @_;
   
    my $name     = $arg{name};
    my $doc_dir  = $arg{doc_dir};
    my $root_dir = $arg{root_dir};
    my $backup_dir = $arg{backup_dir};
    my $parser   = $arg{parser};

    Carp::croak("Please set param 'name' ...") unless $name;

    for my $dir ( $doc_dir, $root_dir, $backup_dir ) {
        Carp::croak("$dir is not 'Path::Class::Dir' ...")
            unless $dir->isa('Path::Class::Dir');
    }

    Carp::croak("$parser couldn't does 'parse' ...")
      unless $parser->can('parse');

    bless {
        _name     => $name,
        _doc_dir  => $doc_dir,
        _root_dir => $root_dir,
        _backup_dir => $backup_dir,
        _parser   => $parser,
    }, $class;
}

sub name        { $_[0]->{_name}       }
sub doc_dir     { $_[0]->{_doc_dir}    }
sub root_dir    { $_[0]->{_root_dir}   }
sub backup_dir  { $_[0]->{_backup_dir} }
sub parser      { $_[0]->{_parser}     }

sub get_categories { map { $_[0]->dir2category($_) } $_[0]->doc_dir->children; }
sub get_archives   { map { $_[0]->dir2archives($_) } $_[0]->doc_dir->children; } 
sub get_menus      { map { $_[0]->dir2menu($_) }     $_[0]->doc_dir->children; }

sub doc2site {
    my ($self) = @_;

    my @categories =
      map  { $self->dir2category($_) }
      sort { $a cmp $b } $self->doc_dir->children;

    my $site = Shaq::CMS::Site->new( name => $self->name, categories => [@categories] );
}

sub backup {
    my ($self) = @_;

    my $zip = Archive::Zip->new;
    my $dt = DateTime->now( time_zone => 'local' );

    my $filename =
      file( $self->backup_dir, "backup_" . $dt->ymd('') . ".zip" )->stringify;

    $zip->addTree( $self->doc_dir );
    $zip->writeToFileNamed($filename);
}

sub dir2category {
    my ( $self, $cat_dir ) = @_;

    my @dir_list = $cat_dir->dir_list;
    my $dirname  = $dir_list[-1];

    my ( @all_archives, @menus );
    for my $dir ( sort { $a cmp $b } $cat_dir->children ) {
        my $menu = $self->dir2menu($dir) or next;
        my @archives = $self->dir2archives($dir);

        for my $archive (@archives) {

            $menu->add_list(
                { basename => $archive->basename, title => $archive->title } );
        }

        push @all_archives, @archives;
        push @menus,        $menu;
    }

    my $category = Shaq::CMS::Category->new(
        dirname  => $dirname,
        menus    => [@menus],
        archives => [@all_archives]
    );
}

sub dir2menu {
    my ( $self, $dir ) = @_;

    die("the param must be Path::Class::Dir.")
      unless $dir->isa('Path::Class::Dir');

    my @list = $dir->dir_list;
    my $dirname = $list[-1];
    
    $dirname =~ m/
                    ^
                    (\d+)
                    -
                    ([^-]*)   # 日本語OK
                    $
                /x
    ? Shaq::CMS::Menu->new( order=> $1, name => $2 )
    : undef;
}

sub dir2archives {
    my ( $self, $dir ) = @_;

    die("the param must be Path::Class::Dir.")
      unless $dir->isa('Path::Class::Dir');

    my @list = $dir->dir_list;
    my $dirname = $list[-1];
 
    $dirname =~ m/
                    ^
                    (\d+)
                    -
                    ([^-]*)   # 日本語OK
                    $
                /x;
   
    grep { defined $_ } map { $self->file2archive($1, $_) } sort {"$a" cmp "$b"} $dir->children;
}

sub file2archive {
    my ( $self, $dir_num, $file ) = @_;

    Carp::croak("the param must be Path::Class::File.")
      unless $file->isa('Path::Class::File');

    $file->basename =~ m/^
                          \d+               # 並び順
                          -                 # ハイフン
                          (\w*)             # ファイル名、-は指定できない仕様
                          \.txt             # 拡張子
                          $
                       /x;

    my $basename = ( $1 eq 'index' ) ? 'index' : $dir_num . "-" . $1;
    $self->parser->parse( basename => $basename, text => scalar $file->slurp ) or undef;
}

1;

