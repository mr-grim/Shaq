package Shaq::CMS::ArchiveParser::Trac;
use Any::Moose;
with 'Shaq::CMS::ArchiveParser::Parser';
use Carp;
use Shaq::CMS::Archive;
use Text::Trac;
use Web::Scraper;

__PACKAGE__->meta->make_immutable;

no Any::Moose;

sub parse {
    my ( $self , %arg ) = @_;

    my $basename = $arg{basename} or croak("Please specify arg: basename");
    my $text     = $arg{text}     or croak("Please specify arg: text");

    my $parser = Text::Trac->new;
    $parser->parse($text);

    my $html = $parser->html;

    ### イタリック表示する構文を乗っ取る    
    $html =~ s!<p>\s*<strong><i>(.*)</i></strong>\s*</p>!<p id="description">$1<\/p>!gm;
    $html =~ s!<i>([^<]*)</i>!<em>$1<\/em>!g;

    my $scraper = scraper { 
        process 'h1', 'title' => 'TEXT';
        process '#description', description => 'TEXT';
        process 'em', 'emphases[]' => 'TEXT';
    };
    my $res = $scraper->scrape( $html );

    ### 強調語句が初めて出現した場合は@keywordsに格納され、2度目は格納されない
    ### 強調語句が1つも存在しない場合はwarn
    my %is_existing;
    my @keywords    = grep { !$is_existing{$_}++ } @{ $res->{emphases} }; 
    warn "$basename has no keyword!!"     unless @keywords;
   
    ### descriptionがない場合もwarn 
    my $description = $res->{description} || undef;
    warn "$basename has no description!!" unless $description;
    
    my %param = (
        basename    => $basename,    
        title       => $res->{title},
        keywords    => [@keywords],
        description => $description,
        content     => $html,
    );

    my $archive = Shaq::CMS::Archive->new( %param );
}

=head1 NAME

CMS::Lite::ArchiveParser::Trac - Trac形式に変換

=head1 DESCRIPTION

Trac 形式のテキストデータをArchiveクラスに格納できる形式に変換

=head1 METHODS

=head2 parse

=cut


1;
