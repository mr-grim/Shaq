package Shaq::Api::WebService::Youtube::User;
use strict;
use warnings;
use base qw/Shaq::Api::WebService::Base/;
use Data::Page;
use Data::Dumper;

our $DEBUG=0;

sub new {
    my ( $class, $config ) = @_;
    my $self = $class->SUPER::new( %$config,
        parser  => "XML::Simple",
        base_url => "http://gdata.youtube.com/feeds/api/" );
}

sub get {
    my ( $self, $username ) = @_;
    my $data = $self->parse( "users/$username" );
    return if $self->msg->has_errors;
    return $data;
}

1;

=head1 NAME

Shaq::Api::WebService::Youtube::User - Api

=head1 METHODS

=head2 new

=head2 get
